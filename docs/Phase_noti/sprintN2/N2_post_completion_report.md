---

# N2 Post-Sprint Report — Secure Notification & Preference APIs

**Project:** Syaahi  
**Phase:** `phase_noti`  
**Sprint:** N2  
**Author:** Implementation Developer  
**Date:** 2025-07-11  
**Baseline:** `4edc438` (tag `v-noti_N1`, branch `main`)  
**Status:** ✅ Complete — Ready for Owner Review  

---

## Executive Summary

Sprint N2 delivered the API layer for Syaahi's notification system, building directly on the N1 database foundation. Six authenticated endpoints were implemented covering the notification inbox, unread counts, read-state transitions, and user preference management. The implementation strictly reuses the existing backend architecture — no new dependencies, no schema changes, no migration history modifications, and no alterations to unrelated modules.

All 39 integration tests pass. The N1 regression suite (8 tests) remains green. TypeScript compiles with zero errors. Cross-user data isolation is explicitly verified on every ownership-sensitive operation using two distinct test identities.

---

## 1. What Was Implemented

### 1.1 Six API Endpoints

| # | Method | Path | Purpose |
|---|--------|------|---------|
| 1 | `GET` | `/api/v1/notifications` | Cursor-paginated notification inbox |
| 2 | `GET` | `/api/v1/notifications/unread-count` | Unread badge count |
| 3 | `PATCH` | `/api/v1/notifications/:id/read` | Mark single notification as read |
| 4 | `PATCH` | `/api/v1/notifications/read-all` | Mark all unread as read |
| 5 | `GET` | `/api/v1/notification-preferences` | Retrieve user preferences |
| 6 | `PATCH` | `/api/v1/notification-preferences` | Update user preferences |

### 1.2 Module Structure

Following the established `src/modules/{feature}/` convention, three files were created:

- **`notifications.schemas.ts`** — Zod validation schemas. `listNotificationsSchema` coerces and bounds the `limit` query parameter (1–50, default 20) and validates the `cursor` as a UUID. `updatePreferencesSchema` enforces strict boolean typing on `newPoemAlerts` and rejects unknown fields via `.strict()`.

- **`notifications.controller.ts`** — Six async handler functions. Each extracts the user identity from `req.user!.userId`, validates inputs at the boundary, executes a recipient-scoped database operation, and returns the standard `{ success, data }` envelope.

- **`notifications.routes.ts`** — Two Express `Router` instances. The `notificationRouter` is mounted at `/api/v1/notifications` and the `preferenceRouter` at `/api/v1/notification-preferences`. Static paths (`/unread-count`, `/read-all`) are registered before the parameterized `/:id/read` route to prevent Express from matching literal path segments as UUID parameters.

### 1.3 Integration Test Suite

A 304-line test file (`notifications.api.test.ts`) that starts the Express application on an ephemeral port, creates three test users with JWT tokens, seeds notifications and poems, and exercises all six endpoints through real HTTP requests using Node's built-in `fetch`. The suite follows the same raw `tsx` execution pattern established by N1 — no test framework was introduced.

---

## 2. How It Was Implemented

### 2.1 Architecture Adherence

The implementation was deliberately constrained to match the existing codebase patterns observed during preflight inspection:

- **Authentication:** The existing `authenticate` middleware from `src/middleware/auth.ts` is applied to every route. No new middleware was created. The user identity is sourced exclusively from `req.user.userId`, which is populated by JWT verification against `env.JWT_SECRET`.

- **Async handling:** All controllers are wrapped in the existing `asyncHandler` utility, which catches rejected promises and forwards them to the Express error pipeline.

- **Error responses:** All error conditions throw the existing `ApiError` class with appropriate HTTP status codes. The global `errorHandler` middleware serializes these into `{ success: false, message }` responses. Zod validation failures are caught by the existing Zod branch in the error handler.

- **Database access:** The shared Prisma singleton from `src/config/prisma.ts` is used directly. No repository or service abstraction was introduced, consistent with the existing modules (e.g., `heart.controller.ts` accesses Prisma directly).

- **Response format:** All successful responses use `{ success: true, data: {} }`, matching the existing contract.

### 2.2 Security Decisions

**Ownership enforcement at the database level.** Every notification query includes `recipientId: userId` in the Prisma `where` clause. This is not a post-fetch filter — the database itself restricts the result set.

**Atomic read-state updates.** The mark-as-read endpoint uses `prisma.notification.updateMany()` with `{ id, recipientId: userId, readAt: null }` in the WHERE clause. This eliminates the fetch-then-update race condition where a concurrent request could modify the record between the ownership check and the write. If the `updateMany` count is zero, a secondary `findFirst` with the same ownership filter distinguishes between "already read" (idempotent 200) and "not found or not owned" (404).

**No information leakage on cross-user access.** When user B attempts to mark user A's notification as read, the response is 404 — identical to a nonexistent notification ID. The API does not reveal whether the notification exists under a different owner.

**Strict preference validation.** The `updatePreferencesSchema` uses Zod's `.strict()` mode, which rejects any request body containing fields beyond `newPoemAlerts`. The `newPoemAlerts` field is typed as `z.boolean()` without coercion, meaning string values like `"true"`, numeric values like `1`, and `null` are all rejected with a 400 error. This prevents silent type coercion bugs that could arise from JSON serialization quirks in various clients.

**Read-only GET semantics for preferences.** When a user has no `NotificationPreference` row in the database, the GET endpoint returns the schema default (`newPoemAlerts: false`) without creating a database record. This avoids unexpected side effects during read operations and defers row creation to the explicit PATCH endpoint, which uses an atomic `upsert`.

### 2.3 Pagination Strategy

Cursor-based pagination was implemented using Prisma's composite cursor support on the `[createdAt, id]` compound ordering. This addresses the brief's explicit requirement that "a timestamp alone may not uniquely identify a position when multiple notifications share the same timestamp." The `id` field serves as a deterministic tie-breaker.

The implementation fetches `limit + 1` records. If the result set exceeds the requested limit, the extra record is discarded and its ID is returned as `nextCursor`. This is the same pattern used by the existing `getMyHeart` controller in `heart.controller.ts`.

Input validation enforces a minimum limit of 1 and a maximum of 50, with a default of 20. The cursor is validated as a UUID v4 string before being passed to Prisma.

---

## 3. Problems Encountered and Mitigations

### 3.1 Express 5 Parameter Typing (`req.params.id` as `string | string[]`)

**Problem:** The TypeScript compiler rejected three usages of `req.params.id` in the mark-as-read controller. Express 5's type definitions type `req.params` values as `string | string[]` rather than `string`, causing incompatibility with both the UUID regex test and Prisma's `where` clause typing.

**Mitigation:** Applied the same `as string` cast used by the existing `heart.controller.ts` (`const poemId = req.params.id as string`). This is safe in our routing context because the `/:id/read` route pattern guarantees a single path segment. The cast was applied at the point of extraction, keeping the rest of the handler type-safe.

### 3.2 PowerShell UTF-8 BOM Corruption of `package.json`

**Problem:** When adding the `test:n2` script to `package.json` via PowerShell's `ConvertTo-Json | Set-Content -Encoding UTF8`, the file was written with a UTF-8 Byte Order Mark (BOM: `EF BB BF`). Node.js's `JSON.parse` cannot handle a BOM prefix, causing both `npm run test:n1` and `npm run test:n2` to crash with `Error parsing: package.json` before any test code executed. This was particularly insidious because PowerShell's `ConvertFrom-Json` and `Get-Content` both handle BOMs transparently, so the file appeared valid in all PowerShell-based checks.

**Mitigation:** Replaced all file writes with .NET's `System.IO.File.WriteAllText()` using `new UTF8Encoding($false)`, which produces clean UTF-8 without a BOM. Verified the fix by running `node -e "JSON.parse(require('fs').readFileSync('package.json','utf8'))"` directly. This approach was used for all subsequent file operations (test file type fixes, completion report).

### 3.3 Route Mount Regex False Positive

**Problem:** The PowerShell script that patches `app.ts` used a two-step process: first add the import line, then add the `app.use()` mount lines. The mount-step guard checked `$appTs -notmatch "notificationRouter"` to avoid duplicate mounts. However, the import line (added in step 1) already contained the string `notificationRouter`, causing the guard to evaluate as false and skip the mount lines entirely. The result was a file with the import but no route registrations.

**Mitigation:** Changed the guard regex from the generic `"notificationRouter"` to the specific mount string `"app\.use\('/api/v1/notifications'"`, which only matches an actual route registration line. Re-ran the mount step, which correctly added both `app.use()` lines.

### 3.4 Missing Supabase Environment Variables

**Problem:** The N2 test suite imports the full Express application (`import app from '../app'`) to start an HTTP server for integration testing. This triggers `src/config/env.ts`, which uses Zod to validate all required environment variables at import time. Three Supabase variables (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`) were absent from the local `.env` file. The N1 tests did not encounter this issue because they import Prisma directly without loading the Express application or its configuration.

**Mitigation:** Added the three Supabase credentials to `.env` from the project's Supabase dashboard (Settings → API). These values were already in use by the deployed application; they were simply missing from the local development environment. The `.env` file is gitignored, so this change does not appear in the commit.

### 3.5 TypeScript `unknown` Return Type from `fetch().json()`

**Problem:** The test file uses Node's built-in `fetch` API. The `Response.json()` method returns `Promise<unknown>` in TypeScript's strict mode. All 24 property accesses on the parsed response body (`body.data.items`, `body.data.unreadCount`, etc.) produced TS18046 errors.

**Mitigation:** Typed the `body` variable as `any` at the point of declaration (`let body: any = await res.json()`). This is acceptable in test code where the response shape is being asserted rather than consumed. The production controller code remains fully type-safe.

---

## 4. Test Results

```
N2 Integration Tests:  39 Passed, 0 Failed   (npm run test:n2)
N1 Foundation Tests:    8 Passed, 0 Failed   (npm run test:n1)
TypeScript Build:       0 Errors              (npx tsc --noEmit)
Prisma Client:          Generated Successfully (npx prisma generate)
```

The N2 test suite creates three distinct database users (userA, userB, author) and verifies cross-user isolation on every ownership-sensitive endpoint. Specifically:

- User B cannot list, count, or modify User A's notifications.
- User B's preference updates do not affect User A's preferences.
- All six endpoints return 401 for unauthenticated requests.
- Invalid inputs (malformed UUIDs, out-of-range limits, string booleans, extra fields) are rejected with 400.
- Idempotent operations (re-reading an already-read notification, re-marking-all when all are read) succeed without side effects.

---

## 5. What Was Not Done (Scope Boundaries)

Per the sprint brief, the following were explicitly excluded:

- No notification record generation (N3 responsibility).
- No push notification infrastructure (N4+).
- No Flutter frontend integration (separate workstream).
- No Prisma schema or migration changes.
- No test framework adoption (Jest/Vitest evaluation deferred).
- No refactoring of existing modules or authentication flow.

---

## 6. Recommendations for N3

1. **Resolve ADR-025** (author self-notification) before implementing publication-triggered notification creation. This decision affects the `WHERE` clause of the notification insertion logic.

2. **Consider a test runner migration** before N3 adds more test files. The raw `tsx` approach works but lacks parallel execution, test filtering, and structured reporting. A minimal Vitest adoption could be scoped as an N3 pre-task.

3. **The notification API contract is stable.** N3 should create notification records using `prisma.notification.create()` with the existing schema. The N2 APIs will automatically surface these records to authenticated users without any N2 code changes.

---

*End of N2 Post-Sprint Report*