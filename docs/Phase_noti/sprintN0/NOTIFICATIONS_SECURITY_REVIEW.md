# Syaahi Notifications — Security and Threat Review

**Initiative:** `phase_noti`
**Version:** v0.1 (N0 Design)
**Date:** 2026-10
**Status:** Awaiting owner approval

---

## 1. Threat Model

### 1.1 Cross-user notification access

| Attribute | Detail |
|---|---|
| **Threat** | User A reads, modifies, or deletes User B's notifications |
| **Likelihood** | Medium (active attempt) |
| **Impact** | High (privacy violation, data leak) |
| **Mitigation** | Every notification query includes `WHERE recipientId = req.user.userId`. The `:id` parameter in PATCH endpoints is combined with the authenticated user ID: `WHERE id = :id AND recipientId = req.user.userId`. No endpoint accepts a client-supplied `recipientId`. |
| **Verification** | Integration test: authenticate as User A, attempt to read/mark User B's notification by ID → expect 404. |
| **Evidence** | Consistent with existing poem ownership enforcement in `poems.controller.ts` lines: `existing.authorId !== req.user.userId → 403`. |

### 1.2 Forged recipient IDs

| Attribute | Detail |
|---|---|
| **Threat** | Client sends a crafted `recipientId` to receive another user's notifications or inject notifications |
| **Likelihood** | Low (requires knowledge of UUIDs) |
| **Impact** | High |
| **Mitigation** | The API contract has no `recipientId` parameter in any client-facing endpoint. Recipient identity is derived exclusively from `req.user.userId` in the `authenticate` middleware. Notification creation is server-side only (no client endpoint). |
| **Verification** | Code review: confirm no route accepts `recipientId` from request body or query. |

### 1.3 Unauthenticated API access

| Attribute | Detail |
|---|---|
| **Threat** | Unauthenticated user accesses notification endpoints |
| **Likelihood** | High (automated scanning) |
| **Impact** | High |
| **Mitigation** | All notification routes use the `authenticate` middleware as the first handler. This middleware rejects requests without a valid `Authorization: Bearer <jwt>` header with a 401 response. The JWT is verified against `env.JWT_SECRET` using `jsonwebtoken`. |
| **Verification** | Integration test: call each notification endpoint without a token → expect 401. Call with an expired token → expect 401. |
| **Evidence** | `auth.ts`: `jwt.verify(token, env.JWT_SECRET)` throws on invalid/expired tokens. |

### 1.4 Privileged database access and accidental policy bypass

| Attribute | Detail |
|---|---|
| **Threat** | Backend code accidentally reads/writes notifications for the wrong user due to missing WHERE clause |
| **Likelihood** | Low (single developer, careful review) |
| **Impact** | High |
| **Mitigation** | (1) All Prisma queries in the notification controller explicitly include `recipientId: req.user.userId` in the `where` clause. (2) No RLS policies exist (confirmed: no SQL files in repo), so all isolation is application-level. (3) Code review checklist for N2 requires verifying every query includes the user filter. |
| **Verification** | Code review of `notifications.controller.ts` before N2 merge. Integration tests with multiple users. |
| **Note** | The absence of RLS is a known limitation of the current architecture (not introduced by notifications). Adding RLS is a future proposal, not a v0.1 requirement. |

### 1.5 Duplicate publication events

| Attribute | Detail |
|---|---|
| **Threat** | A single poem publication generates multiple notifications for the same recipient |
| **Likelihood** | Medium (Vercel retries, network retries, double-tap) |
| **Impact** | Medium (user annoyance, data bloat) |
| **Mitigation** | Database unique constraint `@@unique([recipientId, poemId, type])`. Prisma `createMany` with `skipDuplicates: true`. The controller catches `P2002` errors and treats them as no-ops. |
| **Verification** | Integration test: call the publication endpoint twice with the same poem data → verify only one notification per recipient. |

### 1.6 Notification spam through repeated requests

| Attribute | Detail |
|---|---|
| **Threat** | An author publishes many poems rapidly to flood opted-in users' inboxes |
| **Likelihood** | Low (requires authenticated account) |
| **Impact** | Medium (inbox clutter, push fatigue) |
| **Mitigation** | (1) The existing `writeLimiter` on poem creation (verified in `poems.routes.ts`) limits how fast poems can be published. (2) Each poem generates at most one notification per recipient. (3) Users can opt out at any time. (4) No additional rate limit is needed for v0.1; the write limiter is sufficient. |
| **Verification** | Load test: publish 10 poems in rapid succession → verify rate limiter engages. |

### 1.7 Exposure of private poem content in push notifications

| Attribute | Detail |
|---|---|
| **Threat** | Push notification displays poem content on the device lock screen, visible to anyone |
| **Likelihood** | High (default push behavior) |
| **Impact** | High (privacy violation — poetry can be deeply personal) |
| **Mitigation** | Push payloads contain only: `title` (author display name), `body` (poem title or generic "A new poem was published"), and `data` (UUIDs). **No poem content, excerpts, or private text is included.** This is enforced in the push service code and documented in Section 8.5 of the architecture. |
| **Verification** | Code review of push payload construction. Manual test: receive a push on a locked Android device → verify no poem content is visible. |

### 1.8 Stale or reused device tokens

| Attribute | Detail |
|---|---|
| **Threat** | A device token belonging to a previous user or uninstalled app receives push notifications |
| **Likelihood** | Medium (device resale, app reinstall) |
| **Impact** | Medium (wrong user receives push) |
| **Mitigation** | (1) FCM returns `UNREGISTERED` for invalid tokens; the backend deletes these from the `DeviceToken` table. (2) Tokens are deleted on logout. (3) Tokens are scoped to `userId` via FK relation. (4) Token refresh callbacks update the stored token. |
| **Verification** | Integration test: invalidate a token → publish a poem → verify the stale token is cleaned up. |

### 1.9 Inaccessible or deleted poems

| Attribute | Detail |
|---|---|
| **Threat** | A notification references a poem that has been deleted or unpublished |
| **Likelihood** | Low (cascade deletes handle this) |
| **Impact** | Low (broken link in inbox) |
| **Mitigation** | (1) `onDelete: Cascade` on the `poemId` FK means deleting a poem automatically deletes all related notifications. (2) If an author unpublishes a poem (sets `isPublished: false`), the notification remains but the `GET /poem/:id` endpoint returns 404 for unpublished poems (verified in `poems.controller.ts`: `if (!poem \|\| !poem.isPublished) throw new ApiError(404)`). (3) The inbox API defensively returns `poem: null` if the join fails. The Flutter UI displays "Poem no longer available." |
| **Verification** | Integration test: publish poem → notification created → delete poem → verify notification is cascade-deleted. |

### 1.10 Leaked provider credentials

| Attribute | Detail |
|---|---|
| **Threat** | FCM service account key is exposed in client code, logs, or Git |
| **Likelihood** | Low (if handled correctly) |
| **Impact** | Critical (attacker can send push to any user) |
| **Mitigation** | (1) FCM credentials (`FCM_PROJECT_ID`, `FCM_CLIENT_EMAIL`, `FCM_PRIVATE_KEY`) are server-side environment variables only. (2) They are validated in `env.ts` using the existing Zod schema pattern (ADR-002). (3) They are never sent to the client. (4) `.env` is in `.gitignore`. (5) The Flutter app uses `google-services.json` which is not a secret (it contains the project ID and API key, which are public by design). |
| **Verification** | Code review: grep for FCM variables in Flutter code → zero hits. Check `.gitignore` includes `.env`. |

### 1.11 Excessive inbox queries and unbounded pagination

| Attribute | Detail |
|---|---|
| **Threat** | A client requests extremely large pages or rapid-fire inbox queries, degrading database performance |
| **Likelihood** | Low (requires custom client) |
| **Impact** | Medium (database load) |
| **Mitigation** | (1) `limit` parameter is capped at 50 via Zod validation (`z.coerce.number().int().min(1).max(50)`). (2) Global rate limiter applies (100 req / 15 min). (3) The `[recipientId, createdAt]` index ensures efficient cursor pagination. (4) The unread count query uses the `[recipientId, readAt]` index. |
| **Verification** | Integration test: request `limit=1000` → expect 400 validation error. |

### 1.12 Sensitive information in application logs

| Attribute | Detail |
|---|---|
| **Threat** | Logs contain poem content, user tokens, device tokens, or other private data |
| **Likelihood** | Medium (developer oversight) |
| **Impact** | High (data exposure in log storage) |
| **Mitigation** | Logging policy documented in Section 10.2 of the architecture. Only counts, UUIDs, and error codes are logged. Code review checklist for N3 and N5 includes verifying log statements. |
| **Verification** | Code review of all `console.log` / `console.error` calls in notification modules. |

---

## 2. Security Summary

| Severity | Count | Status |
|---|---|---|
| Critical | 0 unresolved | — |
| High | 0 unresolved | All mitigated by design |
| Medium | 0 unresolved | All mitigated by existing controls |
| Low | 0 unresolved | — |

### Unresolved blockers

**None.** All identified threats have documented mitigations that are achievable within the N1–N6 sprint plan.

### Recommendations for future consideration (not v0.1)

1. **Row-Level Security (RLS):** The current architecture has no RLS policies. All isolation is application-level. This is consistent with the existing system but represents a defense-in-depth gap. Consider adding RLS policies for all user-scoped tables before production launch.
2. **Token revocation:** JWT tokens cannot be revoked (ADR-003). A stolen token grants access to notifications for up to 7 days. Consider implementing a token blacklist before production.
3. **Push payload encryption:** If poem titles become sensitive, consider encrypting push payloads. Not needed for v0.1.

---

## 3. Verification Checklist

- [ ] All notification queries include `recipientId = req.user.userId`
- [ ] No endpoint accepts client-supplied `recipientId`
- [ ] All endpoints require `authenticate` middleware
- [ ] Unique constraint prevents duplicate notifications
- [ ] Push payloads contain no poem content or private data
- [ ] FCM credentials are server-side only
- [ ] Pagination limit is capped at 50
- [ ] Logs contain no sensitive data
- [ ] Cascade deletes handle orphan notifications
- [ ] Cross-user isolation tested with multiple accounts
