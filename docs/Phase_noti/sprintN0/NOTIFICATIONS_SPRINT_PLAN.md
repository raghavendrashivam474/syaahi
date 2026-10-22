# Syaahi Notifications — N1–N6 Implementation Plan

**Initiative:** `phase_noti`
**Date:** 2026-10
**Status:** Awaiting N0 approval before N1 begins
**Architecture reference:** `docs/NOTIFICATIONS_ARCHITECTURE.md`
**Security reference:** `docs/NOTIFICATIONS_SECURITY_REVIEW.md`

---

## N1 — Notification Data Foundation and Opt-in Preferences

**Goal:** Database schema and seed infrastructure for notifications.

**Depends on:** N0 approval, ADR-025 resolution (author self-notification).

### Tasks

| # | Task | Files | Tests |
|---|---|---|---|
| 1.1 | Add `NotificationType` enum to Prisma schema | `syaahi-backend/prisma/schema.prisma` | — |
| 1.2 | Add `Notification` model with relations, unique constraint, and indexes | `syaahi-backend/prisma/schema.prisma` | — |
| 1.3 | Add `NotificationPreference` model | `syaahi-backend/prisma/schema.prisma` | — |
| 1.4 | Add relation fields to existing `User` model (`notifications`, `notificationPreference`) | `syaahi-backend/prisma/schema.prisma` | — |
| 1.5 | Run `prisma migrate dev --name add_notifications` | `syaahi-backend/prisma/migrations/` | Verify migration applies cleanly |
| 1.6 | Run `prisma generate` | Generated client | — |
| 1.7 | Verify migration on local database | — | `prisma studio` visual check |
| 1.8 | Update `.env.example` with any new variables (none expected for N1) | `syaahi-backend/.env.example` | — |

### Acceptance criteria

- [ ] `prisma migrate dev` succeeds without errors.
- [ ] `Notification` table exists with `id`, `recipientId`, `type`, `poemId`, `readAt`, `createdAt`.
- [ ] Unique constraint on `[recipientId, poemId, type]` is enforced (test: insert duplicate → P2002).
- [ ] Indexes on `[recipientId, createdAt]` and `[recipientId, readAt]` exist.
- [ ] `NotificationPreference` table exists with `userId` as PK, `newPoemAlerts` defaulting to `false`.
- [ ] Cascade deletes work: delete a user → their notifications and preferences are removed.
- [ ] Cascade deletes work: delete a poem → related notifications are removed.
- [ ] No existing tables, columns, or behaviors are modified.
- [ ] `prisma generate` produces updated client types.

### Rollback

```bash
prisma migrate resolve --rolled-back <migration_name>
# Or: prisma db push to revert schema
```

### Deployment

- Apply migration to staging database before production.
- No downtime expected (additive schema change only).

## N2 — Secure Notification and Preference APIs

**Goal:** All six notification endpoints implemented, tested, and secured.

**Depends on:** N1 complete.

### Tasks

| # | Task | Files | Tests |
|---|---|---|---|
| 2.1 | Create notifications.schemas.ts with Zod schemas for all endpoints | `syaahi-backend/src/modules/notifications/notifications.schemas.ts` (proposed) | Unit: schema validation |
| 2.2 | Create notifications.controller.ts with all 6 handlers | `syaahi-backend/src/modules/notifications/notifications.controller.ts` (proposed) | Integration: each endpoint |
| 2.3 | Create notifications.routes.ts with authenticate middleware on all routes | `syaahi-backend/src/modules/notifications/notifications.routes.ts` (proposed) | Integration: auth required |
| 2.4 | Register notification routes in app.ts | `syaahi-backend/src/app.ts` | — |
| 2.5 | Implement cursor pagination for GET /notifications | Controller | Integration: multi-page |
| 2.6 | Implement unread count query | Controller | Integration: count accuracy |
| 2.7 | Implement idempotent mark-read (single and all) | Controller | Integration: idempotency |
| 2.8 | Implement preference get (with default fallback) and upsert | Controller | Integration: create-on-first-update |
| 2.9 | Cross-user isolation tests | Test file (proposed) | Critical: User A cannot access User B |
| 2.10 | Unauthenticated access tests | Test file | All endpoints return 401 |
| 2.11 | Validation error tests | Test file | Invalid cursor, limit > 50, etc. |

### Acceptance criteria

- GET /api/v1/notifications returns paginated results for the authenticated user only.
- GET /api/v1/notifications/unread-count returns accurate count.
- PATCH /api/v1/notifications/:id/read marks the notification and is idempotent.
- PATCH /api/v1/notifications/read-all marks all and returns count.
- GET /api/v1/notification-preferences returns defaults when no record exists.
- PATCH /api/v1/notification-preferences upserts correctly.
- All endpoints return 401 without a valid token.
- Cross-user access returns 404 (not 403, to avoid leaking existence).
- All responses follow { success, data } envelope.
- Pagination limit is capped at 50.

### Rollback

- Remove route registration from app.ts.
- Delete the modules/notifications/ directory.
- No database changes in N2.

## N3 — Publication Event Handling and Reliable Record Creation

**Goal:** Poem publication triggers notification creation for opted-in recipients.

**Depends on:** N1, N2 complete. ADR-025 approved.

### Tasks

| # | Task | Files | Tests |
|---|---|---|---|
| 3.1 | Create notificationService.ts with createPublicationNotifications(poem) | `syaahi-backend/src/modules/notifications/notificationService.ts` (proposed) | Unit: recipient selection |
| 3.2 | Implement recipient query: opted-in users excluding author | Service | Integration: correct recipients |
| 3.3 | Implement bulk insert with skipDuplicates: true | Service | Integration: idempotency |
| 3.4 | Handle P2002 unique constraint errors gracefully | Service | Unit: error handling |
| 3.5 | Integrate into createPoem controller (after poem persisted) | `syaahi-backend/src/modules/poems/poems.controller.ts` | Integration: end-to-end |
| 3.6 | Integrate into updatePoem controller (detect isPublished false→true) | `syaahi-backend/src/modules/poems/poems.controller.ts` | Integration: transition detection |
| 3.7 | Ensure ordinary edits do NOT trigger notifications | Controller | Integration: edit without event |
| 3.8 | Ensure isPublished: true on already-published poem does NOT trigger | Controller | Integration: no-op |
| 3.9 | Add logging for event processing (counts, not content) | Service | Verify log output |
| 3.10 | Test with multiple opted-in users | Test file | Integration: bulk creation |
| 3.11 | Test with zero opted-in users | Test file | Integration: no-op |
| 3.12 | Test publication failure does not affect poem | Test file | Integration: poem survives |

### Acceptance criteria

- Creating a new poem generates one notification per opted-in recipient.
- The author does not receive a self-notification (per ADR-025).
- Updating isPublished from false to true generates notifications.
- Editing an already-published poem does NOT generate notifications.
- Setting isPublished: true on an already-published poem does NOT generate notifications.
- Duplicate publication attempts do not create duplicate notifications.
- A notification creation failure does not prevent the poem from being created.
- Logs contain counts and IDs, not poem content or user lists.

### Rollback

- Remove the createPublicationNotifications call from poems.controller.ts.
- Delete notificationService.ts.
- Existing notifications remain in the database (harmless).

### Deployment

- No new environment variables.
- No new dependencies.
- Deploy during low-traffic period to minimize edge cases.

## N4 — Flutter In-App Inbox and User Controls

**Goal:** Users can view, read, and manage notifications in the Flutter app.

**Depends on:** N2, N3 complete (API must be functional).

### Tasks

| # | Task | Files | Tests |
|---|---|---|---|
| 4.1 | Create Notification and NotificationPreference models | `syaahi-app/lib/shared/models/notification.dart` (proposed) | Unit: fromJson |
| 4.2 | Create NotificationRepository | `syaahi-app/lib/features/notifications/data/notifications_repository.dart` (proposed) | Unit: API calls |
| 4.3 | Create NotificationNotifier (StateNotifier) | `syaahi-app/lib/features/notifications/state/notifications_providers.dart` (proposed) | Unit: state transitions |
| 4.4 | Create InboxScreen with cursor pagination | `syaahi-app/lib/features/notifications/presentation/inbox_screen.dart` (proposed) | Widget test |
| 4.5 | Create NotificationSettingsScreen with opt-in toggle | `syaahi-app/lib/features/notifications/presentation/notification_settings_screen.dart` (proposed) | Widget test |
| 4.6 | Add routes to app_router.dart: /notifications, /notifications/settings | `syaahi-app/lib/core/router/app_router.dart` | Navigation test |
| 4.7 | Add unread badge to home screen / navigation | `syaahi-app/lib/features/home/home_screen.dart` | Widget test |
| 4.8 | Implement tap-to-navigate: notification → /poem/:id | InboxScreen | Integration test |
| 4.9 | Handle deleted/unavailable poem gracefully | InboxScreen | Widget test: null poem |
| 4.10 | Implement mark-read on tap and mark-all-read button | InboxScreen + Notifier | Integration test |
| 4.11 | Pull-to-refresh inbox | InboxScreen | Widget test |
| 4.12 | Error handling and empty state UI | InboxScreen | Widget test |

### Acceptance criteria

- [ ] Inbox displays notifications in reverse chronological order.
- [ ] Cursor pagination loads more on scroll.
- [ ] Tapping a notification marks it read and navigates to the poem.
- [ ] "Mark all read" button clears the unread badge.
- [ ] Unread badge on home screen reflects accurate count.
- [ ] Settings screen shows and toggles `newPoemAlerts`.
- [ ] Deleted poem shows "Poem no longer available" (not a crash).
- [ ] Empty inbox shows a friendly message.
- [ ] All API errors are handled gracefully (no unhandled exceptions).
- [ ] Follows existing Riverpod `StateNotifier` pattern (ADR-013).

#### Rollback
1. Remove notification routes from `app_router.dart`.
2. Remove unread badge from home screen.
3. Delete `features/notifications/` directory.
4. No backend changes.

---

### N5 — Push Delivery and Device Lifecycle

**Goal:** Push notifications delivered via FCM to opted-in Android devices.

**Depends on:** N3, N4 complete. Firebase project created.

**Prerequisite approvals:**
* Firebase project created and configured.
* `google-services.json` obtained.
* FCM service account key generated.
* Environment variables (`FCM_PROJECT_ID`, `FCM_CLIENT_EMAIL`, `FCM_PRIVATE_KEY`) added to Vercel.

#### Tasks

| # | Task | Files | Tests |
| :-: | :--- | :--- | :--- |
| **5.1** | Add `DeviceToken` model to Prisma schema | `syaahi-backend/prisma/schema.prisma` | — |
| **5.2** | Run migration for `DeviceToken` | `syaahi-backend/prisma/migrations/` | Verify migration |
| **5.3** | Add FCM env vars to `env.ts` Zod schema | `syaahi-backend/src/config/env.ts` | Startup validation |
| **5.4** | Create device token endpoints (register, update, delete) | `syaahi-backend/src/modules/notifications/notifications.routes.ts` | Integration |
| **5.5** | Create `pushService.ts` with FCM HTTP v1 integration | `syaahi-backend/src/modules/notifications/pushService.ts` | Unit: payload construction |
| **5.6** | Integrate push into `notificationService.ts` (fire-and-forget) | Service | Integration: push sent |
| **5.7** | Handle FCM error responses (invalid token cleanup) | Service | Unit: error handling |
| **5.8** | Add `firebase_messaging` to Flutter `pubspec.yaml` | `syaahi-app/pubspec.yaml` | — |
| **5.9** | Add `google-services.json` to Android project | `syaahi-app/android/app/` | Build succeeds |
| **5.10** | Implement FCM initialization and token management in Flutter | `syaahi-app/lib/features/notifications/data/push_service.dart` | Integration |
| **5.11** | Implement permission request UX | Flutter | Manual test |
| **5.12** | Implement token registration on login and token refresh | Flutter | Integration |
| **5.13** | Implement token deletion on logout | Flutter | Integration |
| **5.14** | Handle push tap → navigate to poem | Flutter | Integration |
| **5.15** | Verify push payload contains no private data | Service + Flutter | Code review + manual |

#### Acceptance criteria
- [ ] Opted-in user with a registered device receives a push when a poem is published.
- [ ] Push title shows author name, body shows poem title or generic text.
- [ ] Push payload contains no poem content, email, or credentials.
- [ ] Tapping the push opens the app and navigates to the poem.
- [ ] Invalid tokens are cleaned up automatically.
- [ ] Logout removes the device token.
- [ ] Multiple devices per user all receive push.
- [ ] Push failure does not affect the in-app inbox.
- [ ] Permission denied → no token registered, inbox still works.

#### Rollback
1. Remove FCM integration from `notificationService.ts`.
2. Remove device token endpoints.
3. Remove `firebase_messaging` from Flutter.
4. Revert `DeviceToken` migration.
5. Inbox continues to work without push.

---

### N6 — End-to-End Integration, Security Verification, and Release

**Goal:** Full system verification, security audit, documentation update, and release.

**Depends on:** N1–N5 complete.

#### Tasks

| # | Task | Tests |
| :-: | :--- | :--- |
| **6.1** | End-to-end test: opt in → publish → receive notification → read → verify inbox | Full flow |
| **6.2** | End-to-end test: opt out → publish → verify no notification | Full flow |
| **6.3** | Security test: cross-user isolation (all endpoints) | Security suite |
| **6.4** | Security test: unauthenticated access (all endpoints) | Security suite |
| **6.5** | Security test: push payload privacy | Manual + code review |
| **6.6** | Security test: forged recipient ID | Security suite |
| **6.7** | Performance test: publish with 100 opted-in users | Load test |
| **6.8** | Performance test: inbox with 1000 notifications | Load test |
| **6.9** | Verify cascade deletes (user deletion, poem deletion) | Integration |
| **6.10** | Verify idempotency (duplicate publication) | Integration |
| **6.11** | Update `docs/API_CONTRACT.md` with notification endpoints | Documentation |
| **6.12** | Update `docs/ARCHITECTURE.md` with notification architecture | Documentation |
| **6.13** | Update `docs/DECISIONS.md` status (ADR-025 resolved) | Documentation |
| **6.14** | Write release notes | Documentation |
| **6.15** | Tag release `v-noti_v0.1` | Git |
| **6.16** | Deploy to staging → verify → deploy to production | Deployment |

#### Acceptance criteria
- [ ] All N1–N5 acceptance criteria still pass.
- [ ] Security review checklist (`NOTIFICATIONS_SECURITY_REVIEW.md` Section 3) is fully checked.
- [ ] No critical or high-severity unresolved issues.
- [ ] Documentation is up to date.
- [ ] Release tag created on the approved commit.
- [ ] Staging deployment verified before production.

#### Rollback
1. Revert to the pre-N1 commit.
2. Drop notification tables via `prisma migrate resolve`.
3. Remove FCM configuration.

---

### Prerequisite Approvals Summary

| Decision | Owner | Required before | Status |
| :--- | :--- | :--- | :--- |
| **N0 architecture approval** | Project owner | N1 | Pending |
| **ADR-025: Author self-notification** | Project owner | N3 | Pending |
| **Firebase project setup** | Project owner | N5 | Not started |
| **Production deployment authorization** | Project owner | N6 | Not started |