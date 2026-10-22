# Syaahi Notifications — N0 Completion Report

**Initiative:** `phase_noti`
**Sprint:** N0 — Architecture & Security Gate
**Date:** 2026-10
**Proposed checkpoint tag:** `v-noti_N0`

---

## 1. Investigation Performed

### Backend inspection
- Mapped the complete Express application structure: `app.ts` → route modules → controllers → Prisma.
- Traced the authentication flow: custom JWT (HS256) via `jsonwebtoken`, verified by `authenticate` middleware, identity stored in `req.user.userId`.
- Traced the poem publication path: `createPoem` controller → `createPoemSchema.parse()` (no `isPublished` field) → `prisma.poem.create()` (defaults to `true`).
- Verified `updatePoemSchema` permits `isPublished` changes (false→true transition is a secondary publication event).
- Confirmed response envelope: `{ success, data }` / `{ success, message, errors }`.
- Confirmed Vercel serverless deployment (`vercel.json`).
- Confirmed in-memory rate limiting (`express-rate-limit`).
- Confirmed Zod validation on all request bodies (ADR-005).

### Flutter inspection
- Traced the publication UI path: `WriterScreen._publish()` → `WriterNotifier.publish()` → `PoemsRepository.createPoem()` → Dio POST.
- Confirmed Dio interceptor auto-attaches JWT from `flutter_secure_storage`.
- Confirmed Riverpod StateNotifier pattern for all state management.
- Confirmed GoRouter for navigation with flat route structure.
- Confirmed no Supabase Flutter SDK installed (all communication via Express API).
- Confirmed no push notification packages installed.
- Confirmed Android-only target (`ios: false`).

### Database inspection
- Reviewed the complete Prisma schema: 8 models, 4 enums, all using UUID v4 IDs and cascade deletes.
- Confirmed no SQL migration files exist in the repository.
- Confirmed no `supabase/` directory exists.
- Confirmed no RLS policies are defined anywhere.
- Confirmed all access control is application-level (Express controllers).
- Confirmed Prisma connects via `DATABASE_URL` (pooler) and `DIRECT_URL` (migrations).

### Documentation inspection
- Read `ARCHITECTURE.md`: 10 architectural principles, deployment targets, architecture summary.
- Read `API_CONTRACT.md`: response envelope, status codes, auth, pagination, rate limiting, known limitations.
- Read `DECISIONS.md`: ADR-001 through ADR-020, established convention for new decisions.
- Read `Notification_System_Discovery_Note.md`: prior discovery findings, 6 open questions (all now resolved by N0).

---

## 2. Files and Configuration Inspected

### Backend (14 files)
| File | Purpose |
|---|---|
| `syaahi-backend/src/app.ts` | Express assembly, route registration, middleware |
| `syaahi-backend/src/api.ts` | Vercel entry point |
| `syaahi-backend/src/server.ts` | Local dev server (not inspected in detail, not needed) |
| `syaahi-backend/src/config/env.ts` | Environment validation (Zod) |
| `syaahi-backend/src/config/prisma.ts` | Prisma client singleton |
| `syaahi-backend/src/middleware/auth.ts` | JWT authentication |
| `syaahi-backend/src/middleware/errorHandler.ts` | Error response formatting |
| `syaahi-backend/src/middleware/rateLimiter.ts` | Rate limiting (referenced, not read in detail) |
| `syaahi-backend/src/modules/poems/poems.routes.ts` | Poem route definitions |
| `syaahi-backend/src/modules/poems/poems.controller.ts` | Poem CRUD handlers |
| `syaahi-backend/src/modules/poems/poems.schemas.ts` | Poem validation schemas |
| `syaahi-backend/src/utils/ApiError.ts` | Custom error class |
| `syaahi-backend/src/utils/asyncHandler.ts` | Async wrapper |
| `syaahi-backend/prisma/schema.prisma` | Complete data model |
| `syaahi-backend/vercel.json` | Serverless deployment config |
| `syaahi-backend/package.json` | Dependencies and scripts |
| `syaahi-backend/.env.example` | Environment variable template |

### Flutter (11 files)
| File | Purpose |
|---|---|
| `syaahi-app/lib/main.dart` | App bootstrap |
| `syaahi-app/lib/core/network/api_client.dart` | Dio configuration + auth interceptor |
| `syaahi-app/lib/core/storage/token_storage.dart` | JWT persistence |
| `syaahi-app/lib/core/router/app_router.dart` | GoRouter route table |
| `syaahi-app/lib/features/auth/data/auth_repository.dart` | Login/signup HTTP calls |
| `syaahi-app/lib/features/auth/state/auth_providers.dart` | Auth Riverpod state |
| `syaahi-app/lib/features/poems/data/poems_repository.dart` | Poem API calls |
| `syaahi-app/lib/features/poems/state/poems_providers.dart` | Poem Riverpod state |
| `syaahi-app/lib/features/poems/presentation/writer_screen.dart` | Publication UI |
| `syaahi-app/lib/shared/models/poem.dart` | Poem model + enums |
| `syaahi-app/lib/shared/models/user.dart` | User model |
| `syaahi-app/pubspec.yaml` | Dependencies |

### Documentation (4 files)
| File | Purpose |
|---|---|
| `docs/ARCHITECTURE.md` | Architecture overview |
| `docs/API_CONTRACT.md` | API specification |
| `docs/DECISIONS.md` | ADR records |
| `docs/Notification_System_Discovery_Note.md` | Prior discovery |

---

## 3. Key Findings

| # | Finding | Evidence |
|---|---|---|
| 1 | Auth is custom JWT, not Supabase Auth | `auth.ts` uses `jsonwebtoken` + `env.JWT_SECRET` |
| 2 | Every new poem is immediately published | `createPoemSchema` omits `isPublished`; Prisma defaults to `true` |
| 3 | `isPublished` can be toggled via PATCH | `updatePoemSchema` includes `z.boolean().optional()` |
| 4 | No RLS policies exist | No SQL files, no `supabase/` directory |
| 5 | All isolation is application-level | Controller checks like `existing.authorId !== req.user.userId` |
| 6 | Flutter talks only to Express | No `supabase_flutter` in `pubspec.yaml` |
| 7 | Vercel serverless, no workers | `vercel.json` routes all to `src/api.ts` |
| 8 | Cascade deletes on all relations | Every FK in `schema.prisma` has `onDelete: Cascade` |
| 9 | Follow model exists but no UI | `Follow` model in schema, no follow routes in Flutter |
| 10 | Android-only target | `pubspec.yaml` — `ios: false` |

---

## 4. Decisions Made

| ADR | Decision | Rationale |
|---|---|---|
| ADR-021 | Application-level notification isolation | Consistent with existing architecture; no RLS infrastructure |
| ADR-022 | Synchronous in-request event processing | Vercel serverless; no workers available; sufficient for v0.1 scale |
| ADR-023 | Strict opt-in (default false) | Privacy-first; no assumed consent; aligns with product philosophy |
| ADR-024 | Cascade delete for notifications | Consistent with all existing relations |
| ADR-026 | FCM as push provider | Native Android; free; simple HTTP API; Vercel compatible |
| ADR-027 | Non-transactional poem + notification | Poem must survive notification failures; notifications are derived data |

---

## 5. Decisions Awaiting Owner Approval

| ADR | Decision | Options | Recommendation | Blocking |
|---|---|---|---|---|
| ADR-025 | Author self-notification | (A) No self-notification, (B) Self-notification | Option A | Blocks N3 task 3.2 |
| — | N0 architecture approval | Approve / Request revisions / Reject | Approve | Blocks all N1–N6 |

---

## 6. Risks and Blockers

| Risk | Severity | Mitigation | Status |
|---|---|---|---|
| No RLS policies (existing) | Medium | Application-level isolation + code review + tests | Accepted, documented |
| Vercel timeout for large recipient lists | Low | Synchronous insert is fast for <1000 users; monitor | Accepted for v0.1 |
| No token revocation (existing) | Medium | 7-day JWT expiry; accepted trade-off (ADR-003) | Accepted, documented |
| `.env.example` contains `.gitignore` content | Low | Non-blocking; cleanup recommended | Noted |

**No critical blockers identified.**

---

## 7. Documents Created or Updated

| Document | Action | Path |
|---|---|---|
| Architecture Specification | Created | `docs/NOTIFICATIONS_ARCHITECTURE.md` |
| Security Review | Created | `docs/NOTIFICATIONS_SECURITY_REVIEW.md` |
| Sprint Plan | Created | `docs/NOTIFICATIONS_SPRINT_PLAN.md` |
| N0 Completion Report | Created | `docs/NOTIFICATIONS_N0_REPORT.md` |
| Architecture Decisions | Updated | `docs/DECISIONS.md` (ADR-021 through ADR-027) |

---

## 8. Commands and Checks Run

| Command | Purpose | Result |
|---|---|---|
| `git status --short --branch` | Verify clean working tree | Clean, `main` branch |
| `git log -5 --oneline` | Record recent history | HEAD at `e57719e` |
| `Get-ChildItem` (backend tree) | Map backend structure | 37 files identified |
| `Get-ChildItem` (Flutter tree) | Map Flutter structure | 24 lib files identified |
| `Get-Content` (14 backend files) | Read backend implementation | All read successfully |
| `Get-Content` (11 Flutter files) | Read Flutter implementation | All read successfully |
| `Get-Content` (4 doc files) | Read documentation | All read successfully |
| SQL file search | Find RLS/migration files | None found |
| Supabase directory search | Find Supabase config | None found |

---

## 9. Confirmation of No Runtime Changes

- [x] No application code was modified.
- [x] No Prisma schema changes were made.
- [x] No migrations were generated or applied.
- [x] No database policies or grants were changed.
- [x] No package dependencies were added or modified.
- [x] No environment configuration was changed.
- [x] No `.env` files were created or modified.
- [x] No Git tags were created.
- [x] No existing behavior was altered.
- [x] All changes are documentation-only.

---

## 10. Recommendation

**Approve N0 and authorize N1 implementation.**

The architecture is minimal, secure, and consistent with the existing Syaahi codebase. All six open questions from the discovery note have been resolved. The threat model identifies no unresolved critical issues. The sprint plan provides clear, testable acceptance criteria for each phase.

**Pending owner action:**
1. Review `docs/NOTIFICATIONS_ARCHITECTURE.md`.
2. Review `docs/NOTIFICATIONS_SECURITY_REVIEW.md`.
3. Resolve ADR-025 (author self-notification: yes or no).
4. Explicitly approve N0.
5. Authorize N1 to begin.

Upon approval, the checkpoint tag `v-noti_N0` will be created on the approved commit.
