# Syaahi Notifications — N0 Sprint Completion Report

**To:** Senior Developer / Project Owner
**From:** N0 Investigation & Design Team
**Date:** 2026-10
**Sprint:** N0 — Architecture & Security Gate
**Initiative:** `phase_noti`
**Repository:** `https://github.com/raghavendrashivam474/syaahi`
**Branch:** `main` (clean, tracking `origin/main`)
**Baseline commit:** `e57719e` — *docs(syaahi): add notification system discovery note*
**Proposed checkpoint tag:** `v-noti_N0` *(not yet created — awaiting approval)*
**Status:** **Ready for Review**

---

## 1. Executive Summary

N0 was executed as a pure investigation and design sprint. No application code, database schema, migrations, dependencies, or runtime configuration were modified. The sprint produced an evidence-backed, implementation-ready architecture specification for the Syaahi Notifications v0.1 feature, along with a security review, decision records, API contract, and a six-sprint implementation plan.

All six open questions documented in the prior `Notification_System_Discovery_Note.md` have been resolved. The threat model identifies zero unresolved critical or high-severity blockers. One product decision (ADR-025, author self-notification) remains flagged for explicit owner sign-off before N3 implementation begins.

The recommendation is to **approve N0 and authorize N1**.

---

## 2. What Was Implemented

To be precise about scope: **N0 implemented documentation only.** No runtime behavior changed. The deliverables are five documents, totaling the complete architectural, security, and planning specification for the notification system.

### 2.1 Documents produced

| # | Document | Path | Purpose |
|---|---|---|---|
| 1 | Architecture Specification | `docs/NOTIFICATIONS_ARCHITECTURE.md` | Complete design: scope, auth map, data model, API contract, publication event semantics, push provider evaluation, idempotency strategy, observability, sprint dependencies |
| 2 | Security & Threat Review | `docs/NOTIFICATIONS_SECURITY_REVIEW.md` | 12-threat model with likelihood, impact, mitigation, verification, and evidence; verification checklist |
| 3 | Sprint Plan (N1–N6) | `docs/NOTIFICATIONS_SPRINT_PLAN.md` | Task-level breakdown, files to touch, tests, acceptance criteria, rollback procedures |
| 4 | N0 Completion Report | `docs/NOTIFICATIONS_N0_REPORT.md` | This document (summary form) |
| 5 | Architecture Decisions | `docs/DECISIONS.md` *(appended)* | ADR-021 through ADR-027 added following the existing convention |

### 2.2 Code and infrastructure changes

**None.** The repository safety contract was honored throughout:

- No files under `syaahi-backend/src/` were modified.
- No files under `syaahi-app/lib/` were modified.
- `prisma/schema.prisma` was not touched.
- No migrations were generated or applied.
- No entries were added to `package.json` or `pubspec.yaml`.
- No environment variables were added, modified, or renamed.
- No Git tags were created.
- No RLS policies, grants, or Supabase configuration were changed.

---

## 3. How It Was Implemented

### 3.1 Methodology

The sprint followed the minimal repository inspection plan prescribed in the N0 brief. Investigation proceeded in evidence-first order: baseline verification → backend path tracing → Flutter path tracing → documentation review → database security review → synthesis into design.

The guiding principle throughout: *preserve the system that already works.* Every proposed addition was weighed against the existing architectural conventions (ADR-001 through ADR-020) and rejected if it created inconsistency without concrete justification.

### 3.2 Investigation phases

**Phase 1 — Baseline (Block 1)**

Confirmed the working tree was clean, the branch (`main`) was tracking the correct remote, and recorded the HEAD commit (`e57719e`) so any future reader can reproduce the exact state the design was built against.

**Phase 2 — Backend path tracing (Blocks 2–3)**

Inspected the Express assembly (`app.ts`), route mounting pattern (`api.ts`, `vercel.json`), the authentication middleware (`auth.ts`), the complete poem publication path (`poems.routes.ts` → `poems.controller.ts` → `poems.schemas.ts`), the Prisma schema, environment validation (`env.ts`), the Prisma client singleton, the error handler, the custom `ApiError` class, and the async handler utility.

This yielded a complete map of the publication request path from HTTP entry to database persistence, and confirmed that the backend uses a custom JWT (HS256) with `jsonwebtoken`, not Supabase Auth. The identity carried through every request is `req.user.userId`, extracted by the `authenticate` middleware and verified against `env.JWT_SECRET`.

**Phase 3 — Flutter path tracing (Block 4)**

Mapped the Flutter `lib/` tree, read `pubspec.yaml`, then inspected the Dio API client with its auth interceptor, the secure token storage, the GoRouter route table, the auth repository and providers, the poems repository and providers, the writer screen, and the Poem and User models.

This yielded a complete map of the publication UI path and confirmed critical facts: no Supabase SDK is installed on the client, no push notification packages are present, and all backend communication flows through a single Dio instance that automatically attaches the JWT. The app is Android-only.

**Phase 4 — Documentation review (Block 5a)**

Read the existing `ARCHITECTURE.md`, `API_CONTRACT.md`, `DECISIONS.md` (ADR-001 through ADR-020), and the prior `Notification_System_Discovery_Note.md`. This established the response envelope conventions, the ADR authoring format, the ten architectural principles, and confirmed the six open questions from the discovery phase.

**Phase 5 — Database security review (Block 5b)**

Searched the entire repository for SQL files, migration files, Supabase configuration directories, and RLS policy definitions. Read `.env.example` and `package.json` to understand environment surface and dependency set.

**Finding of significance:** no SQL files exist, no `supabase/` directory exists, and no RLS policies are defined anywhere in the repository. All access control is enforced at the application layer in Express controllers. This single finding shaped the most important security decision in the architecture (ADR-021).

**Phase 6 — Synthesis and documentation (Parts 1–5)**

The five deliverables were produced in sequence, each building on the evidence gathered. The architecture document was written first and sectioned 1 through 11. The security review was derived from the architecture. The ADRs were extracted from the architecture decisions. The sprint plan was derived from the N1–N6 dependency map in Section 11. The completion report (this document) was written last.

### 3.3 Key design decisions and their justification

**Data model (Section 5 of architecture, ADR-024)**

The `Notification` model uses UUID v4 IDs, `onDelete: Cascade` on both the recipient and poem foreign keys, a unique constraint on `[recipientId, poemId, type]` for idempotency, and two indexes: `[recipientId, createdAt]` for inbox pagination and `[recipientId, readAt]` for the unread count query. The `NotificationPreference` model uses `userId` as the primary key for a natural one-to-one relationship. The `DeviceToken` model is proposed for N5 only.

Every convention here matches an existing precedent in `schema.prisma`. No new ID strategy, timestamp convention, or deletion policy was introduced.

**Opt-in model (ADR-023)**

Strict opt-in with `newPoemAlerts` defaulting to `false` for all users, including existing ones. This was chosen over opt-out or followers-only for three reasons: it respects user consent without assumption, it avoids the scope expansion of building a follow UI (which does not currently exist in the client), and it aligns with Syaahi's emotional-first product philosophy.

**Event processing strategy (ADR-022, ADR-027)**

Notification creation is synchronous within the publication request, performed after the poem is persisted and deliberately *not* wrapped in a transaction with the poem creation. The reasoning is twofold. First, Vercel serverless does not support background workers; an outbox pattern would require adding external infrastructure (Vercel Cron, Railway worker, BullMQ) disproportionate to v0.1 scale. Second, the poem represents the user's creative output and must survive any notification system failure. A notification error must never roll back a poem.

**Push provider (ADR-026)**

Firebase Cloud Messaging via the HTTP v1 API. Android is the only target platform, FCM is the native Android push service, it has unlimited free messages, the HTTP API is compatible with Vercel serverless (no persistent connections needed), and we retain full control over payload content for privacy enforcement.

**Isolation model (ADR-021)**

Application-level enforcement in Express controllers, consistent with how all existing features (poems, hearts, reactions, follows) handle authorization. No RLS policies are introduced for notifications alone, because doing so would create an inconsistent security model relative to the rest of the schema. RLS is noted as a future consideration for the entire system as a defense-in-depth measure before production launch.

---

## 4. Problems Encountered and How They Were Mitigated

### 4.1 Problem: Ambiguity in the publication event definition

**Encountered during:** Backend path tracing (Phase 2).

**Nature of the problem:** The `Poem` model defaults `isPublished` to `true`, but the `updatePoemSchema` permits toggling `isPublished`. This creates two distinct event sources: (a) new poem creation (which is immediately published), and (b) an existing poem transitioning from unpublished to published. Additionally, an ordinary edit of a published poem should *not* be treated as a new publication. The question of what precisely constitutes a "publication event" was ambiguous.

**Mitigation:** Section 4.2 of the architecture document enumerates all seven possible transition scenarios (new creation, false→true transition, ordinary edit, retry, idempotent re-publish, failure, deletion before view) and specifies the correct behavior for each. The design treats poem creation and the false→true transition as events, and all other states as no-ops. The unique constraint on `[recipientId, poemId, type]` guarantees that even if the detection logic is imperfect, no user receives duplicate notifications for the same poem.

### 4.2 Problem: Absence of RLS policies and Supabase configuration

**Encountered during:** Database security review (Phase 5).

**Nature of the problem:** The N0 brief instructed the investigator to inspect Supabase migrations, RLS policies, grants, and database configuration. None of these exist in the repository. There are no SQL files, no `supabase/` directory, and no evidence of RLS policies being defined. This created initial uncertainty about whether the application was relying on database-level isolation that we were simply failing to find.

**Mitigation:** The investigation widened to confirm the finding by three independent methods: searching for any `.sql` files repository-wide, checking for a `supabase/` directory at the repo root, and inspecting whether the Flutter client installs `supabase_flutter` (it does not). All three checks confirmed the same conclusion: *all access control in Syaahi is enforced at the application layer*. This finding was then documented explicitly in Section 2.6 of the architecture, formalized as ADR-021 (application-level isolation), and listed in the risk register as an existing architectural limitation to be addressed system-wide at a later date — not something notifications should fix in isolation.

### 4.3 Problem: Vercel serverless constraints vs. reliable event processing

**Encountered during:** Design synthesis for publication event handling.

**Nature of the problem:** The ideal pattern for reliable event-driven notification creation is an outbox: the publication request writes an event row atomically with the poem, and a background worker drains the outbox, retrying on failure. However, Vercel serverless functions have no persistent process, no background workers, no built-in queue, and a 10-second execution timeout. Introducing a worker would require either Vercel Cron Jobs (polling, not event-driven), an external service (Railway, Render), or a managed queue (BullMQ + Redis). All of these would materially expand scope beyond v0.1.

**Mitigation:** The design chose synchronous in-request processing as the smallest viable implementation (ADR-022), with explicit documentation of its consistency guarantees and failure modes in Section 9 of the architecture. The reasoning: for the expected v0.1 scale (fewer than 1,000 opted-in users per publication), a bulk insert completes in well under one second, comfortably within the serverless timeout. The unique constraint provides strong idempotency, so retries are safe. Push delivery is explicitly fire-and-forget and does not affect the persisted inbox. The architecture then documents the outbox pattern as a future proposal for when scale justifies it, so this is a deferred decision, not a hidden deficit.

### 4.4 Problem: Risk of poem loss due to notification failure

**Encountered during:** Design synthesis for event processing.

**Nature of the problem:** If poem creation and notification creation were wrapped in a single database transaction, any failure during notification bulk insert would roll back the poem itself. The user's creative work would be destroyed by a notification error. This is unacceptable.

**Mitigation:** ADR-027 explicitly separates the two operations. The poem is persisted first and committed. Notification creation then runs as a best-effort step. If it fails, the poem survives, the failure is logged with sufficient detail to backfill later, and the user sees a successful publication response. This is documented in Section 9.4 of the architecture with the complete reasoning so no future developer re-introduces a transaction thinking it is an improvement.

### 4.5 Problem: Push payload privacy risk

**Encountered during:** Push provider evaluation.

**Nature of the problem:** Default push notification behavior displays the full payload content on the device lock screen, visible to anyone with physical access to the phone. Poetry is often deeply personal. A push payload containing poem content, excerpts, or private text would be a serious privacy violation inconsistent with the product's values.

**Mitigation:** Section 8.5 of the architecture establishes an explicit allow-list and forbid-list for push payload fields. The `title` field may contain the author's display name only. The `body` field may contain the poem title or a generic "A new poem was published" string, never poem content. The `data` field carries only UUIDs and the notification type. This rule is formalized in the threat model (Threat 1.7) with a mandatory manual verification step on a locked Android device during N5 testing.

### 4.6 Problem: Author self-notification is a product decision, not a technical one

**Encountered during:** Publication event semantics specification.

**Nature of the problem:** When a user publishes their own poem, should they receive a notification about it? There is no technically correct answer. The current product behavior (success snackbar + feed refresh) already acknowledges the publication, so a self-notification is arguably redundant. However, in a multi-device world, a self-notification could help an author confirm successful publication from a second device.

**Mitigation:** This was explicitly flagged as ADR-025 with status "Pending Owner Approval." The recommended default is Option A (no self-notification), the opposite is clearly described, and the sprint plan marks N3 Task 3.2 as blocked on this decision. The team declined to make this decision unilaterally, consistent with the N0 brief's instruction to never invent product answers.

### 4.7 Problem: Large-content terminal output and file encoding anomalies

**Encountered during:** Throughout investigation, particularly when reading long files via `Get-Content` and piping to the terminal.

**Nature of the problem:** PowerShell's default UTF-8 handling, combined with Unicode emoji in some documentation and source files (feather glyphs, flame symbols, honorific markers), produced visibly corrupted characters when output was captured. The prior discovery note (Section 6) had already identified this concern. Additionally, some file reads were truncated by terminal buffer limits, requiring targeted re-reads of specific sections.

**Mitigation:** All deliverable documents were written in plain ASCII where possible, using only standard Markdown characters. Unicode characters appearing in evidence quotes were preserved verbatim without attempting re-encoding, so no silent character corruption is introduced into the design documents. When terminal output was truncated during inspection, the file was re-read in a smaller, targeted block (as happened with `api_client.dart`, `token_storage.dart`, `app_router.dart`, `auth_providers.dart`, and `auth_repository.dart`), rather than guessing at the missing content. All findings in the architecture document are backed by content that was successfully read in full.

### 4.8 Problem: `.env.example` contains incorrect content

**Encountered during:** Environment configuration review.

**Nature of the problem:** The file `syaahi-backend/.env.example` was expected to contain example environment variable names. Inspection revealed that it instead contains `.gitignore`-style content (`node_modules/`, `dist/`, `.env`, `*.log`, etc.). This appears to be a historical file placement error.

**Mitigation:** This finding was documented in Section 6 of the N0 report as a low-severity, non-blocking issue. It does not affect notification implementation because the actual environment schema is validated at startup by `env.ts` using Zod (ADR-002). The N0 team deliberately did not fix this file, because the sprint scope was documentation-only and this is pre-existing unrelated to notifications. A note was added recommending cleanup in a separate, scoped change.

---

## 5. Verification of N0 Exit Criteria

### Architecture

| Criterion | Status | Reference |
|---|---|---|
| Current authentication and database access paths are mapped | ✓ | Architecture §3 |
| Trusted recipient identity is established | ✓ | `req.user.userId` from JWT; Architecture §3.2 |
| Existing authorization and RLS/grant behavior investigated | ✓ | Architecture §2.6; confirmed absent |
| Publication event semantics defined for all transitions | ✓ | Architecture §4.2 (seven scenarios) |
| Opt-in defaults and recipient eligibility explicitly defined | ✓ | Architecture §6; ADR-023 |
| Data model, constraints, indexes, deletion behavior specified | ✓ | Architecture §5; ADR-024 |
| Idempotency and failure recovery specified | ✓ | Architecture §9; ADR-022, ADR-027 |
| API contracts and pagination behavior defined | ✓ | Architecture §7 (6 endpoints, full shapes) |
| Push provider and device lifecycle design justified | ✓ | Architecture §8; ADR-026 |
| Operational visibility and privacy requirements documented | ✓ | Architecture §10 |

### Security

| Criterion | Status | Reference |
|---|---|---|
| Threat model complete enough to guide implementation | ✓ | Security Review §1 (12 threats) |
| Cross-user access prevention explicitly designed and testable | ✓ | Threat 1.1; verified via query filter rule |
| No unresolved critical security blocker hidden or ignored | ✓ | Security Review §2 (zero unresolved) |
| Secret management and payload privacy requirements documented | ✓ | Threats 1.7, 1.10, 1.12 |

### Engineering

| Criterion | Status | Reference |
|---|---|---|
| All major decisions have rationale and supporting evidence | ✓ | 7 new ADRs with Context/Decision/Reasoning/Consequences |
| Architectural changes have documented impact, migration, rollback | ✓ | Sprint Plan rollback sections |
| N1–N6 dependencies and acceptance criteria ready | ✓ | Sprint Plan all phases |
| Documentation follows existing repository conventions | ✓ | ADR format matches ADR-001 through ADR-020 |
| No feature implementation or unauthorized runtime change | ✓ | Confirmed; `git status` shows only `docs/` additions |

### Approval

| Criterion | Status |
|---|---|
| Project owner has reviewed the specification | **Pending** |
| Blocking product decisions resolved or explicitly accepted | **Pending (ADR-025)** |
| Project owner explicitly approves N0 | **Pending** |
| Implementation authorization separately recorded | **Pending** |

---

## 6. Decisions Awaiting Owner Action

| # | Item | Decision needed | Recommendation | Consequence of delay |
|---|---|---|---|---|
| 1 | **ADR-025 — Author self-notification** | Option A (no self-notification) or Option B (self-notification) | Option A | N3 Task 3.2 (recipient query) cannot be finalized |
| 2 | **N0 architecture approval** | Approve / Request revisions / Reject | Approve | All N1–N6 work is blocked |
| 3 | **ADR-025 Firebase project** | Create Firebase project; provision service account; add `google-services.json` | Needed before N5 | N5 work cannot begin |

---

## 7. Risks and Accepted Trade-offs

| Risk | Severity | Mitigation | Status |
|---|---|---|---|
| No RLS policies (system-wide, pre-existing) | Medium | Application-level isolation + code review + integration tests | Accepted; documented as a future system-wide improvement |
| Vercel 10-second timeout for very large recipient lists | Low | Synchronous bulk insert is fast for v0.1 scale; monitor; migrate to outbox if needed | Accepted for v0.1 |
| No JWT revocation (pre-existing, ADR-003) | Medium | 7-day expiry; accepted trade-off from prior sprint | Accepted; unchanged |
| Notification gap possible if backend crashes between poem insert and notification insert | Low | Logged with sufficient detail for backfill; cannot cause data corruption | Accepted; backfill script is a future utility |
| `.env.example` contains `.gitignore` content | Low | Non-blocking; recommend cleanup in a separate scoped change | Noted |

**No critical blockers.**

---

## 8. Repository Safety Confirmation

- Working branch: `main`, clean, tracking `origin/main` at the start of the sprint.
- Baseline HEAD: `e57719e` — unchanged.
- No commits created yet (deliverables are staged for review as uncommitted documentation).
- `git status` output after N0 completion shows only new or modified files under `docs/`.
- No file under `syaahi-backend/`, `syaahi-app/`, or any other application directory was modified.
- No tags were created. The `v-noti_N0` tag will be created only after explicit approval, on the specific reviewed commit.
- No force-push, reset, rebase, stash, or clean operations were performed.
- No credentials, `.env` files, or secret values were inspected, printed, or committed.

---

## 9. Next Actions

**For the project owner:**

1. Review `docs/NOTIFICATIONS_ARCHITECTURE.md` in full.
2. Review `docs/NOTIFICATIONS_SECURITY_REVIEW.md` in full.
3. Review the new ADR entries (ADR-021 through ADR-027) in `docs/DECISIONS.md`.
4. Make a decision on ADR-025 (author self-notification).
5. Approve, request revisions, or reject N0.

**For the development team upon approval:**

1. Update ADR-025 status from "Pending Owner Approval" to "Active" with the owner's decision.
2. Commit the approved documentation with message: `docs(noti): define notification architecture and security gate`.
3. Push to `origin/main`.
4. Create the annotated tag: `git tag -a v-noti_N0 -m "Syaahi Notifications: N0 architecture and security gate approved"`.
5. Push the tag: `git push origin v-noti_N0`.
6. Begin N1 work per the sprint plan.

---

## 10. Recommendation

**Approve N0 and authorize N1.**

The specification is complete, evidence-backed, and consistent with the existing Syaahi codebase. Every design choice has a documented rationale tied to concrete evidence in the repository. The threat model is practical and testable. The sprint plan is detailed enough that N1 can begin without architectural guesswork.

Approval of N0 is approval of the design. Implementation authorization for N1 remains a separate, explicit step as prescribed by the brief.

---

**End of Report.**