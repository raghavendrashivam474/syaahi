# N4 Preflight

## Existing Architecture
- **State:** Riverpod `StateNotifier` + `StateNotifierProvider.autoDispose`
- **Routing:** GoRouter, flat `GoRoute` list, no ShellRoute
- **HTTP:** Dio via `ApiClient` singleton, JWT auto-injected via interceptor
- **Models:** Manual `fromJson` factories, no codegen
- **Repo pattern:** Single class per feature, optional `Dio` injection, custom exception
- **Pagination:** Cursor-based (`nextCursor` UUID string), `hasMore = nextCursor != null`
- **Design:** Dark theme, `SyaahiColors` (midnight+gold), `SyaahiSizes`, Google Fonts

## Confirmed API Contract (from controller source)
- `GET /notifications?limit=20&cursor=<uuid>` → `{success,data:{items,nextCursor}}`
  - items: `[{id, type, poemId, readAt, createdAt, poem:{id,title}}]`
  - limit: 1–50, default 20; cursor: UUID
- `GET /notifications/unread-count` → `{success,data:{unreadCount}}`
- `PATCH /notifications/:id/read` → `{success,data:{read:true}}`
- `PATCH /notifications/read-all` → `{success,data:{markedCount}}`

## Files to Create
1. `features/notifications/data/notifications_repository.dart` — model + repo
2. `features/notifications/state/notifications_providers.dart` — Riverpod state
3. `features/notifications/presentation/inbox_screen.dart` — UI

## Files to Modify
1. `core/router/app_router.dart` — add `/notifications` route
2. `features/poems/presentation/feed_screen.dart` — add bell icon + unread badge

## Decisions
- Model named `AppNotification` to avoid collision with Flutter's `Notification` widget
- Reuse `ApiClient().dio` — no new HTTP stack
- Mirror `FeedState`/`FeedNotifier` pattern for inbox pagination
- Bell goes in FeedScreen app bar (main authenticated screen)
- Mark-all-as-read included (backend supports it, fits inbox UX)
- Preference UI deferred (no existing settings screen)
