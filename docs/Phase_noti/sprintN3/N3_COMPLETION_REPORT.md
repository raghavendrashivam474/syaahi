# N3 Completion Report — Publication Events & Reliable Record Creation

**Date:** 2026-10-23
**Sprint:** N3
**Phase:** phase_noti
**Status:** Complete

---

## 1. Sprint Objective

Create notification records when eligible poem-publication events occur, connecting the existing poem-publication workflow to the N1 notification foundation and N2 secure API layer.

**Result:** Achieved. All 19 N3 tests pass. Full N1/N2 regression green (66 total assertions).

---

## 2. Git State

| Field | Value |
|---|---|
| Starting commit | `88e480e` (tag `v-noti_N2`) |
| Starting branch | `main` |
| Final commit | PLACEHOLDER_COMMIT |
| Working tree | Clean |
| Tag | None (requires owner authorization) |

---

## 3. Files Changed

### Created
| File | Purpose |
|---|---|
| `syaahi-backend/src/modules/notifications/notification.service.ts` | `createPublicationNotifications()` — recipient query + bulk insert |
| `syaahi-backend/src/__tests__/notifications.publication.test.ts` | 19-assertion integration test suite |
| `docs/Phase_noti/sprintN3/N3_COMPLETION_REPORT.md` | This report |

### Modified
| File | Change |
|---|---|
| `syaahi-backend/src/modules/poems/poems.controller.ts` | Added import + notification calls in `createPoem` and `updatePoem` |
| `syaahi-backend/package.json` | Added `test:n3` script |
| `docs/DECISIONS.md` | ADR-025 status changed from Pending to Approved |

### Intentionally Untouched
- All N1 migration files
- All N2 routes, controllers, schemas
- `prisma/schema.prisma` (no schema changes)
- All other application modules (auth, users, heart, reactions, feed)

---

## 4. Publication Entry Point & Event Semantics

| Path | Event | Notification Trigger |
|---|---|---|
| `POST /api/v1/poems` | Poem creation (always published; `isPublished` defaults to `true`, not exposed in `createPoemSchema`) | Always fires after successful `prisma.poem.create` |
| `PATCH /api/v1/poems/:id` | Poem update | Fires **only** on `isPublished` false → true transition |
| `PATCH /api/v1/poems/:id` | Edit of already-published poem | Does **not** fire |

No other code paths create or publish poems.

---

## 5. ADR-025 Decision

**Status:** Approved
**Decision:** No self-notification. The author is excluded from the recipient list.
**Rationale:** Author already sees a success snackbar and feed refresh. Self-notification adds no informational value.
**Implementation:** `userId: { not: authorId }` in the `NotificationPreference` query.

---

## 6. Recipient Selection & Preference Behavior

1. Query `NotificationPreference` for `newPoemAlerts = true` AND `userId != authorId`.
2. Users without a `NotificationPreference` row are **not** notified (default is opt-out, `false`).
3. Users with `newPoemAlerts = false` are **not** notified.
4. The author is **never** notified (ADR-025).

---

## 7. Duplicate-Handling Strategy

- `prisma.notification.createMany({ skipDuplicates: true })` — generates `INSERT ... ON CONFLICT DO NOTHING`.
- Relies on the existing `@@unique([recipientId, poemId, type])` constraint.
- The `updatePoem` path also prevents re-notification by checking `existing.isPublished === false && poem.isPublished === true` before calling the service.
- Concurrent duplicate inserts are handled at the database level by the unique constraint.

---

## 8. Transaction & Failure-Handling Behavior

**Design:** Synchronous best-effort after publication (consistent with N0 proposal).

- The poem is fully persisted **before** notification creation begins.
- `createPublicationNotifications` is `await`-ed in the request handler.
- If notification creation fails, the error is caught and logged via `console.error` (visible in Vercel function logs).
- The poem publication response is **not** affected by notification failures.
- No background promises, in-memory queues, or unawaited work.

---

## 9. Reliability Guarantees & Limitations

### Guarantees
- A successfully published poem will attempt notification creation synchronously.
- Duplicate records are impossible due to the database unique constraint.
- Only opted-in, non-author users receive notifications.
- Notification failures do not corrupt or roll back poem publication.

### Documented Limitations
- **No automatic retry.** If the notification `createMany` fails (e.g., transient database error), the notifications for that event are lost. There is no outbox, queue, or background retry mechanism.
- **No delivery guarantee.** This sprint creates in-app records only. Push delivery is N5.
- **Best-effort only.** The system does not claim eventual consistency for notification records after a write failure.

---

## 10. Test Commands & Results

| Command | Result |
|---|---|
| `npx tsc --noEmit` | PASS (clean) |
| `npm run test:n1` | 8 Passed, 0 Failed |
| `npm run test:n2` | 39 Passed, 0 Failed |
| `npm run test:n3` | 19 Passed, 0 Failed |
| **Total** | **66 Passed, 0 Failed** |

---

## 11. N1/N2 Regression

All N1 and N2 tests pass without modification. No N2 API contracts were changed. Records created by N3 are correctly exposed through the existing N2 inbox and unread-count endpoints (proven by N3 tests 8 and 9).

---

## 12. Schema & Migration Impact

**None.** No changes to `prisma/schema.prisma`. No new migrations. The existing `@@unique([recipientId, poemId, type])` constraint and `NotificationType.POEM_PUBLISHED` enum were used as-is.

---

## 13. Architectural Decisions

| ADR | Status | Summary |
|---|---|---|
| ADR-025 | Approved | No author self-notification |

No new ADRs were required. The N0 best-effort architecture was followed as proposed.

---

## 14. Known Risks & Follow-Up Recommendations

1. **No retry mechanism.** If notification writes fail, those notifications are permanently lost. Consider an outbox pattern in a future sprint if reliability requirements increase.
2. **Scale consideration.** The current implementation queries all opted-in users in a single `findMany`. If the user base grows to tens of thousands, this query and the subsequent `createMany` may need batching.
3. **Seed scripts.** The `scripts/` directory contains seed scripts that create poems. These bypass the controller and will not trigger notifications. This is acceptable for seed data but should be documented.

---

## 15. Handoff to N4

N4 (Flutter In-App Inbox) can now consume:
- `GET /api/v1/notifications` — returns N3-created records with `type`, `poemId`, `readAt`, `createdAt`, and nested `poem.title`.
- `GET /api/v1/notifications/unread-count` — reflects N3-created unread records.
- `PATCH /api/v1/notifications/:id/read` — marks N3 records as read.
- `PATCH /api/v1/notifications/read-all` — bulk marks N3 records.

No N2 API changes are needed for N4.