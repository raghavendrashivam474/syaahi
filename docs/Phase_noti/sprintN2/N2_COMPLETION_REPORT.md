# N2 Completion Report — Secure Notification & Preference APIs

**Sprint:** N2 | **Phase:** phase_noti | **Status:** ✅ Complete

---

## 1. Objective & Status

Deliver six authenticated backend APIs for notification inbox, unread counts, read-state management, and preferences on top of the N1 data foundation. All six endpoints implemented, 39/39 tests pass, N1 regression green (8/8), zero TypeScript errors.

## 2. Commits

- **Baseline:** `4edc438` (tag: `v-noti_N1`)
- **Final:** `COMMIT_HASH` (patch after commit)

## 3. Files

**Created:** `notifications.schemas.ts`, `notifications.controller.ts`, `notifications.routes.ts`, `notifications.api.test.ts`, this report.
**Modified:** `app.ts` (2 route mounts + import), `package.json` (test:n2 script).
**Unchanged:** Prisma schema, migrations, N1 tests, all existing modules.

## 4. Endpoint Contracts

| # | Method | Path | Key Behavior |
|---|--------|------|-------------|
| 1 | GET | `/api/v1/notifications` | Cursor-paginated inbox, limit 1–50 (default 20), ordered `createdAt DESC, id DESC` |
| 2 | GET | `/api/v1/notifications/unread-count` | DB-level COUNT of `readAt: null` |
| 3 | PATCH | `/api/v1/notifications/:id/read` | Atomic `updateMany` with ownership in WHERE, idempotent |
| 4 | PATCH | `/api/v1/notifications/read-all` | Single bounded update, returns `markedCount` |
| 5 | GET | `/api/v1/notification-preferences` | Returns default `false` if no row exists (no write) |
| 6 | PATCH | `/api/v1/notification-preferences` | Strict boolean validation, atomic upsert |

All responses use the existing `{ success, data }` envelope.

## 5. Authentication & Authorization

Reuses existing `authenticate` middleware. Identity from `req.user.userId` (JWT). No user-supplied recipient IDs trusted anywhere. All endpoints return 401 without a valid token.

## 6. Pagination & Defaults

Cursor pagination using Prisma composite cursor on `[createdAt, id]` for deterministic ordering even with duplicate timestamps. Fetches `limit + 1` to detect next page. Preference default is `false` per N1 schema; GET returns the default without creating a row.

## 7. Tests

**39 assertions across 7 categories:**
- Inbox: 9 (pagination, ordering, limits, cursor, isolation)
- Unread count: 2 (per-user accuracy)
- Mark one read: 7 (ownership, idempotency, 404/400, cross-user)
- Mark all read: 4 (bulk, idempotency, isolation)
- Preferences read: 2 (default behavior, no side-effect write)
- Preferences update: 9 (strict boolean, reject invalid types/extras, cross-user)
- Auth rejection: 6 (all endpoints return 401)

Two distinct test users created; cross-user isolation explicitly verified on every ownership-sensitive endpoint.

## 8. Regression

- N1 foundation tests: 8/8 pass (`npm run test:n1`)
- TypeScript build: 0 errors (`npx tsc --noEmit`)
- Prisma client: generated successfully

## 9. Schema & Migration Impact

**None.** No schema changes, no new migrations. N2 is purely an API layer on the existing N1 data model.

## 10. Architectural Changes

**None.** Followed existing module pattern (`controller.ts`, `routes.ts`, `schemas.ts`), reused `authenticate`, `asyncHandler`, `ApiError`, and Prisma singleton. No new dependencies added.

## 11. Git Status

- Branch: `main`, clean working tree after commit
- No force-push, no amended commits, no tag changes
- `.env` changes (Supabase vars) not committed (gitignored)

## 12. Known Limitations

- Test runner is raw `tsx` (no Jest/Vitest). N1 recommended evaluating a proper runner; deferred to avoid scope creep.
- First API call in tests is slow (~2s) due to cold Prisma connection; subsequent calls are fast.

## 13. Unresolved Risks

None blocking. The ADR-025 author self-notification decision remains pending for N3.

## 14. Next Steps (N3)

N3 — Publication Events & Reliable Record Creation. Will create notification records in response to poem publication events, consuming the stable N2 API and data contracts. ADR-025 must be resolved before N3 begins.