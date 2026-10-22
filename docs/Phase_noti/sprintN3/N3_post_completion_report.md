---

# Post-Sprint Report: N3 — Publication Events & Reliable Record Creation

**Project:** Syaahi
**Phase:** `phase_noti`
**Sprint:** N3
**Author:** Implementation Developer
**Date:** 2025-07-11
**Baseline:** `88e480e` (tag `v-noti_N2`, confirmed)
**Final commit:** `PLACEHOLDER` (branch `main`)
**Status:** Complete — all acceptance criteria met, all tests green

---

## Executive Summary

N3 connects Syaahi's poem-publication workflow to the notification foundation (N1) and secure API layer (N2). When a poem is published, the system now identifies opted-in recipients and creates persistent `POEM_PUBLISHED` notification records. These records are immediately visible through the existing N2 inbox and unread-count endpoints without any changes to the N2 API layer.

The implementation is deliberately small: one new service function, two integration points in the existing poem controller, and a 19-assertion test suite. No schema changes, no migrations, no new dependencies, no architectural departures from the N0 design.

**Test results:** 66/66 passing (N1: 8, N2: 39, N3: 19). TypeScript clean.

---

## 1. What Was Implemented

### 1.1 New File: `notification.service.ts`

**Path:** `syaahi-backend/src/modules/notifications/notification.service.ts`

A single exported async function: `createPublicationNotifications(poemId: string, authorId: string): Promise<void>`.

**Responsibilities:**
- Queries `NotificationPreference` for all users where `newPoemAlerts = true` and `userId != authorId`.
- Maps the result into an array of notification records with `type: 'POEM_PUBLISHED'`.
- Inserts all records in a single `prisma.notification.createMany()` call with `skipDuplicates: true`.
- Catches and logs any unexpected errors without throwing.

**What it does NOT do:**
- It does not create preferences for users who lack them.
- It does not retry on failure.
- It does not dispatch push notifications, emails, or any side effects beyond the database write.
- It does not validate that the poem exists (the caller is responsible for that).

### 1.2 Modified File: `poems.controller.ts`

**Path:** `syaahi-backend/src/modules/poems/poems.controller.ts`

Three surgical changes:

**Change 1 — Import (line 6):**
```typescript
import { createPublicationNotifications } from '../notifications/notification.service';
```

**Change 2 — `createPoem` handler (after `prisma.poem.create`):**
```typescript
await createPublicationNotifications(poem.id, req.user!.userId);
```
This fires unconditionally because `createPoemSchema` does not expose `isPublished` to the client, and the Prisma model defaults `isPublished` to `true`. Every POST is a publication event.

**Change 3 — `updatePoem` handler:**
- Added `isPublished: true` to the `select` clause of the pre-update `findUnique` call.
- Added a post-update conditional:
```typescript
if (existing.isPublished === false && poem.isPublished === true) {
  await createPublicationNotifications(poem.id, req.user!.userId);
}
```
This ensures notifications fire only on the specific `false → true` transition, not on edits to already-published poems.

**Untouched handlers:** `listPoems`, `getPoem`, `deletePoem` — zero changes.

### 1.3 ADR-025 Resolution

**File:** `docs/DECISIONS.md`

ADR-025 (Author Self-Notification Policy) was in "Pending Owner Approval" status at the start of N3. The brief explicitly gated implementation on this decision.

**Decision approved by project owner:** No self-notification. The author is excluded from the recipient list.

**Implementation:** The `userId: { not: authorId }` filter in the `NotificationPreference` query. This is a single-clause exclusion that is trivially reversible if the product decision changes.

### 1.4 Test Suite

**File:** `syaahi-backend/src/__tests__/notifications.publication.test.ts`

19 assertions across 9 test groups, following the exact conventions established in N1 and N2 (raw `tsx` execution, `app.listen(0)`, JWT-signed `fetch` calls, custom `assert` function, cleanup in `finally`).

| # | Scenario | Assertions |
|---|---|---|
| 1 | POST creates notification for opted-in recipient | 3 (status, record exists, readAt null) |
| 2 | Author excluded from self-notification (ADR-025) | 1 |
| 3 | Opted-out user receives nothing | 1 |
| 4 | No-preference user receives nothing (default false) | 1 |
| 5 | PATCH `isPublished` false→true triggers notification | 3 (draft has 0, PATCH succeeds, opted-in notified) |
| 6 | Editing already-published poem does not re-notify | 2 (PATCH succeeds, count unchanged) |
| 7 | Duplicate protection on re-publish attempt | 2 (PATCH succeeds, count still 1) |
| 8 | N2 inbox integration | 4 (status, poem1 present, draftPoem present, shape correct) |
| 9 | N2 unread count integration | 2 (recipientIn ≥ 2, author = 0) |

### 1.5 Build Configuration

**File:** `syaahi-backend/package.json`

Added `test:n3` script: `npx tsx src/__tests__/notifications.publication.test.ts`.

---

## 2. How It Was Implemented — Design Rationale

### 2.1 Publication Lifecycle Discovery

The first technical task was understanding what "published" means in Syaahi. This required reading the Prisma schema, the Zod validation schemas, and the controller code. The findings were not obvious from the schema alone:

| Aspect | Finding | Implication |
|---|---|---|
| `Poem.isPublished` | Boolean, default `true` | Poems are published by default |
| `createPoemSchema` (Zod) | Does **not** include `isPublished` | Clients cannot create unpublished poems via POST |
| `updatePoemSchema` (Zod) | **Does** include `isPublished: z.boolean().optional()` | Clients can unpublish and republish via PATCH |
| `createPoem` controller | Single `prisma.poem.create`, no transaction | Publication is the create itself |
| `updatePoem` controller | `findUnique` then `update`, no transaction | State transition detection is possible |

This asymmetry between POST (always published) and PATCH (conditionally published) is the central design constraint. The implementation handles both paths with different trigger logic.

### 2.2 Recipient Selection Strategy

The recipient query is:
```typescript
prisma.notificationPreference.findMany({
  where: {
    newPoemAlerts: true,
    userId: { not: authorId },
  },
  select: { userId: true },
});
```

**Why this approach:**
- It queries only users who have explicitly opted in. Users without a `NotificationPreference` row are excluded because the row doesn't exist — there's no need to check a default value.
- The `not: authorId` clause implements ADR-025 at the query level, which means the database does the filtering rather than the application.
- It returns only `userId`, minimizing data transfer.

**What was considered and rejected:**
- Querying all users and filtering in application code — wasteful, doesn't scale.
- Joining `User` to check for inactive/deleted status — the existing schema has no `isActive` or `deletedAt` field, so this would be speculative.
- Creating default `NotificationPreference` rows for all users — the brief explicitly forbids this, and the N2 preference API already handles missing rows by returning `false`.

### 2.3 Duplicate Protection

Two layers:

**Application layer:** The `updatePoem` handler checks `existing.isPublished === false && poem.isPublished === true` before calling the notification service. This prevents the service from being called at all when a poem is merely edited.

**Database layer:** `createMany({ skipDuplicates: true })` generates `INSERT ... ON CONFLICT DO NOTHING`, which leverages the existing `@@unique([recipientId, poemId, type])` constraint. This is the final safeguard against:
- Concurrent requests that both pass the application-layer check.
- Retry scenarios where the same publication event is processed twice.
- Any future code path that might call the service redundantly.

**Why not `findFirst` + conditional insert:** A read-then-write pattern is vulnerable to race conditions. Two concurrent requests could both observe "no record exists" and both attempt insertion. The unique constraint catches this, but relying on it via `skipDuplicates` is cleaner than catching P2002 errors manually.

### 2.4 Failure Handling — Best-Effort Design

The N0 architecture report proposed synchronous best-effort notification creation. N3 follows that proposal.

**The guarantee:** The poem is fully persisted before notification creation begins. If notification creation fails, the poem remains published and the HTTP response is unaffected.

**The limitation:** There is no retry mechanism. If the `createMany` call fails due to a transient database error, those notification records are lost permanently. This is documented honestly in the completion report and in the service function's JSDoc.

**Why not a transaction wrapping both operations:**
- The poem creation and notification creation serve different durability requirements. A poem is user-generated content; a notification is a derived side effect. Rolling back a poem because a notification write failed would be a worse user experience than losing the notification.
- The existing `createPoem` handler has no transaction. Introducing one would change the behavior of the primary write path, which is out of scope.

**Why not an outbox or queue:**
- The brief explicitly forbids building an outbox, queue, or worker without architectural approval.
- The deployment is Vercel serverless. Background workers and in-memory queues are not viable in that environment.
- The current user base doesn't justify the complexity. This is documented as a follow-up recommendation.

### 2.5 Serverless Compatibility

The implementation is fully compatible with Vercel serverless functions:
- All work is `await`-ed within the request handler.
- No `setTimeout`, `setInterval`, or unawaited promises.
- No in-memory state or caching.
- No background processing after the HTTP response is sent.

---

## 3. Problems Faced and Mitigations

### 3.1 ADR-025 Gate Blocked Initial Implementation

**Problem:** ADR-025 (author self-notification policy) was in "Pending Owner Approval" status. The brief explicitly forbids implementing publication-triggered notification creation until this decision is resolved. Implementing either behavior silently would have been a violation of the sprint's decision gate.

**Mitigation:** Split the work into gated phases. Blocks 1–2 (preflight, lifecycle analysis, test conventions) proceeded in parallel while the decision was pending. The decision request was drafted with clear alternatives and consequences. Implementation (Block 3) began only after explicit owner approval was received and recorded in `docs/DECISIONS.md`.

**Impact:** No delay to the overall sprint. The preflight work was productive and necessary regardless of the ADR outcome.

### 3.2 Asymmetric Publication Semantics Between POST and PATCH

**Problem:** The `createPoemSchema` does not expose `isPublished`, meaning every POST is a publication. But `updatePoemSchema` does expose `isPublished`, meaning a PATCH can be a publication, an unpublication, an edit, or a no-op. The notification trigger logic had to handle both paths correctly without creating false positives.

**Mitigation:** Two distinct trigger strategies:
- `createPoem`: unconditional notification call (every POST is a publication).
- `updatePoem`: conditional notification call, gated on `existing.isPublished === false && poem.isPublished === true`.

This required adding `isPublished` to the `select` clause of the pre-update `findUnique` in `updatePoem`, which is a zero-cost change (one additional column read).

**Risk if missed:** Without the transition check, every PATCH to a published poem (title edit, content edit, etc.) would have triggered a notification attempt. The `skipDuplicates` flag would have prevented actual duplicate records, but the unnecessary database queries would have been wasteful and the behavior semantically incorrect.

### 3.3 No Existing Event Abstraction

**Problem:** The Syaahi backend has no event bus, service layer, or pub/sub mechanism. The poem controller calls Prisma directly. This meant there was no natural "hook" for notification creation — it had to be wired directly into the controller.

**Mitigation:** Created a standalone service function in the notifications module and imported it into the poems controller. This keeps the notification logic testable and isolated without introducing speculative infrastructure. If a future sprint introduces an event system, the service function can be called from an event handler instead of the controller with no changes to its internals.

**What was explicitly avoided:** Building an event bus, emitter pattern, or hook system for a single event type. The brief requires architectural approval for such additions, and the cost-benefit doesn't justify it at this stage.

### 3.4 Seed Scripts Bypass the Controller

**Problem:** The `syaahi-backend/scripts/` directory contains `seed.ts`, `seed-content.ts`, and `cleanup-and-reseed.ts`. These scripts create poems directly via Prisma, bypassing the controller entirely. Poems created by seed scripts will not trigger notifications.

**Mitigation:** Documented as a known limitation in the completion report. This is acceptable behavior — seed data is development/fixture data, not real user publications. If seed scripts need to trigger notifications in the future, they can import and call `createPublicationNotifications` directly.

### 3.5 PowerShell 5.1 Compatibility

**Problem:** The development environment runs Windows PowerShell 5.1, which does not support the null-coalescing operator (`??`) introduced in PowerShell 7. Initial preflight scripts used `??` for fallback values and failed with `UnexpectedToken` parse errors.

**Mitigation:** Replaced all `??` expressions with explicit `if/elseif/else` chains. All subsequent scripts were written with PS 5.1 compatibility as a constraint.

### 3.6 Unicode Encoding Issues in Test Output

**Problem:** The N2 test file contains Unicode box-drawing characters (e.g., `═══`, `───`) and emoji checkmarks (`✅`) that displayed as garbled text (`âœ…`, `â"€â"€`) in the PS 5.1 terminal due to encoding mismatches between UTF-8 file content and the console's code page.

**Mitigation:** The N3 test file uses plain ASCII for all output: `PASS`/`FAIL` labels, `--` section dividers, and no emoji. File writes use `[System.Text.UTF8Encoding]::new($false)` (UTF-8 without BOM) to prevent BOM-related issues with `tsx`.

### 3.7 Scale Consideration for Recipient Query

**Problem:** The `findMany` query for opted-in users returns all matching rows in a single call. If the user base grows to tens of thousands of opted-in users, this query and the subsequent `createMany` could become slow or exceed database limits.

**Mitigation:** Documented as a follow-up recommendation. At the current user base, this is not a practical concern. If it becomes one, the solution would be batching (e.g., `take`/`skip` loops or cursor-based iteration), which can be added to the service function without changing its interface.

---

## 4. What Was NOT Done (and Why)

| Item | Reason |
|---|---|
| Push notifications | Out of scope — N5 |
| Flutter inbox UI | Out of scope — N4 |
| Outbox/queue/worker | Requires architectural approval; not justified at current scale |
| Schema changes | Not needed; existing models and constraints are sufficient |
| Event bus framework | Requires architectural approval; overkill for one event type |
| Seed script integration | Seed data doesn't need notifications |
| Notification for poem edits | Product semantics say edits are not publication events |
| Automatic retry on failure | Best-effort is the approved design; retry requires durable infrastructure |
| Generalized notification types | Only `POEM_PUBLISHED` exists; no speculative enum values |

---

## 5. Reliability Guarantees — Honest Assessment

| Guarantee | Status |
|---|---|
| Published poem triggers notification attempt | ✅ Yes |
| Only opted-in users receive notifications | ✅ Yes |
| Author never receives self-notification | ✅ Yes (ADR-025) |
| Duplicate records are impossible | ✅ Yes (DB unique constraint) |
| Notification failure preserves poem | ✅ Yes (best-effort, no rollback) |
| Notification failure is observable | ✅ Yes (`console.error` → Vercel logs) |
| Notification records are visible via N2 API | ✅ Yes (proven by tests 8–9) |
| Failed notifications are retried | ❌ No (documented limitation) |
| Delivery is guaranteed | ❌ No (best-effort only) |
| Push delivery works | ❌ No (N5) |

---

## 6. Recommendations for Follow-Up

1. **N4 (Flutter Inbox):** Can proceed immediately. The N2 API contract is stable and N3 records are being persisted correctly. No backend changes needed.

2. **Scale monitoring:** If the opted-in user count exceeds ~5,000, consider batching the `createMany` call in `notification.service.ts`.

3. **Retry mechanism:** If product requirements evolve to demand guaranteed notification delivery, an outbox pattern with a durable retry mechanism should be designed and approved as a separate sprint. This would require schema changes and a worker process, which are incompatible with the current Vercel serverless deployment without additional infrastructure.

4. **Seed script parity:** If seed scripts need to trigger notifications for testing purposes, they can import `createPublicationNotifications` directly. This is a low-priority enhancement.

5. **Observability:** Consider adding structured logging (e.g., JSON-formatted `console.error` with `poemId`, `recipientCount`, and `error` fields) to make Vercel log queries easier as the system grows.

---

## 7. Files Changed — Summary

| File | Action | Lines Changed |
|---|---|---|
| `syaahi-backend/src/modules/notifications/notification.service.ts` | Created | ~55 |
| `syaahi-backend/src/modules/poems/poems.controller.ts` | Modified | +7 (net) |
| `syaahi-backend/src/__tests__/notifications.publication.test.ts` | Created | ~323 |
| `syaahi-backend/package.json` | Modified | +1 |
| `docs/DECISIONS.md` | Modified | +5 (ADR-025 status) |
| `docs/Phase_noti/sprintN3/N3_COMPLETION_REPORT.md` | Created | ~170 |

**Total new application code:** ~62 lines (service + controller changes).
**Total test code:** ~323 lines.
**Schema changes:** 0.
**Migration changes:** 0.

---

*End of report. N3 is ready for code review and merge. N4 handoff can proceed.*