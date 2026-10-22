# N4 Completion Report — Flutter In-App Notification Inbox

**Sprint:** N4 — Flutter In-App Inbox
**Phase:** `phase_noti`
**Baseline:** `v-noti_N3` at `de72b72`
**Status:** Awaiting owner review before release tagging

---

## 1. Summary

Implemented a production-quality in-app notification inbox inside the existing
Syaahi Flutter application. An authenticated user can open the inbox from a bell
icon on the feed screen, view paginated notifications fetched from the real
backend, distinguish read from unread items, mark individual or all notifications
as read, and tap a notification to open the associated poem in the existing
reader screen.

No backend code, schema, migrations, or dependencies were changed.

---

## 2. Existing Architecture Reused

| Concern | Existing pattern | How N4 reuses it |
|---|---|---|
| State management | Riverpod `StateNotifier` + `StateNotifierProvider.autoDispose` | `InboxNotifier`/`InboxState` mirror `FeedNotifier`/`FeedState` exactly |
| Routing | GoRouter, flat `GoRoute` list | Added single `/notifications` route |
| HTTP client | Dio via `ApiClient` singleton, JWT interceptor | `NotificationsRepository` uses `ApiClient().dio` |
| Models | Manual `fromJson` factories, no codegen | `AppNotification.fromJson` follows `Poem.fromJson` pattern |
| Repository | Single class per feature, optional Dio injection, custom exception | `NotificationsRepository` mirrors `PoemsRepository` |
| Pagination | Cursor-based, `nextCursor` UUID, `hasMore = nextCursor != null` | Identical pattern with deduplication |
| Error handling | `DioException` → custom exception with envelope parsing | `NotificationsException._handle` copies `PoemsException._handle` |
| Design system | `SyaahiColors` (midnight+gold), `SyaahiSizes`, Google Fonts | All inbox UI uses existing tokens |
| Poem detail | `ReaderScreen(poemId: …)` at `/poem/:id` | Notification tap navigates to existing route |

---

## 3. Files Created

| File | Purpose |
|---|---|
| `N4_PREFLIGHT.md` | Preflight architecture and contract notes |
| `syaahi-app/lib/features/notifications/data/notifications_repository.dart` | `AppNotification` model, `NotificationPoem` model, `NotificationsException`, `NotificationsRepository` with 4 API methods |
| `syaahi-app/lib/features/notifications/state/notifications_providers.dart` | `inboxProvider` (autoDispose), `unreadCountProvider` (persistent), `InboxNotifier`, `UnreadCountNotifier` |
| `syaahi-app/lib/features/notifications/presentation/inbox_screen.dart` | Full inbox UI: loading, empty, error, pagination, read/unread styling, mark-all, poem navigation |
| `syaahi-app/test/notifications/model_test.dart` | 7 unit tests for model parsing and read-state logic |

## 4. Files Modified

| File | Change | Lines |
|---|---|---|
| `syaahi-app/lib/core/router/app_router.dart` | Added `InboxScreen` import + `/notifications` GoRoute | +7 |
| `syaahi-app/lib/features/poems/presentation/feed_screen.dart` | Added notification provider import, unread count refresh in `initState`, `_BellButton` widget with badge | +49 |

---

## 5. Confirmed API Contract

Verified against backend controller source (`notifications.controller.ts`):
GET /api/v1/notifications?limit=20&cursor=<uuid>
→ { success: true, data: { items: [{id, type, poemId, readAt, createdAt, poem:{id,title}}], nextCursor } }

GET /api/v1/notifications/unread-count
→ { success: true, data: { unreadCount } }

PATCH /api/v1/notifications/:id/read
→ { success: true, data: { read: true } }

PATCH /api/v1/notifications/read-all
→ { success: true, data: { markedCount } }

text


Pagination: limit 1–50 (default 20), cursor is notification UUID, ordered by `createdAt desc, id desc`.

---

## 6. Feature Behavior

### Inbox
- Opens via bell icon in FeedScreen app bar
- Fetches authenticated user's notifications on open (autoDispose = fresh each visit)
- Displays poem title (or "Untitled"), "New poem published" message, relative timestamp
- Unread: gold left border + gold dot + bold title
- Read: muted styling, no indicators
- Pull-to-refresh resets and reloads
- Scroll-to-bottom triggers pagination with deduplication
- Empty state: "All quiet." with explanation
- Error state: retry button

### Unread Count
- Bell badge on FeedScreen shows count from backend
- `null` (not fetched) → no badge; `0` → no badge; `1–99` → count; `100+` → "99+"
- Refreshes on FeedScreen `initState` (every visit to feed)
- Decrements locally after confirmed individual read
- Zeros after confirmed mark-all
- No polling, no background loops, no WebSockets

### Read Operations
- **Individual:** Tap notification → server PATCH → local state update → count decrement → navigate to poem
- **Mark all:** AppBar "Read all" button → server PATCH → local state update → count zero
- Both are server-first (no optimistic updates)
- Duplicate taps guarded by `isMarkingAllRead` flag and `isLoading`/`isLoadingMore` checks
- Failures show error without falsely claiming success

### Poem Navigation
- Tapping a notification navigates to `/poem/:id` using existing `ReaderScreen`
- Deleted/unavailable poems handled by ReaderScreen's existing error state

---

## 7. Test Results
$ flutter test test/notifications/model_test.dart
00:12 +7: All tests passed!

$ flutter test
00:02 +8: All tests passed!

text


All 8 tests pass (7 new model tests + 1 pre-existing).

## 8. Analysis Results
$ flutter analyze
Analyzing syaahi-app...
No issues found! (ran in 5.0s)

text


---

## 9. Backend / Schema / Migration Changes

**None.** No backend files, Prisma schema, migrations, or API contracts were modified.

---

## 10. Dependency Changes

**None.** No new packages added to `pubspec.yaml`. All N4 code uses existing dependencies:
`flutter_riverpod`, `go_router`, `dio`, `google_fonts`, `intl`.

---

## 11. Git State

**Branch:** `main`
**Working tree changes:**
M syaahi-app/lib/core/router/app_router.dart
M syaahi-app/lib/features/poems/presentation/feed_screen.dart
?? N4_PREFLIGHT.md
?? syaahi-app/lib/features/notifications/
?? syaahi-app/test/notifications/

text


2 files modified (+55 lines, -1 line), 5 new files/directories.

No N0–N3 tags moved. No force-push. No history rewrite.

---

## 12. Known Limitations & Deferred Work

| Item | Reason |
|---|---|
| Notification preference UI (`newPoemAlerts` toggle) | No existing settings screen in the app. Deferred to a future sprint. |
| Widget/integration tests for inbox UI | Requires mock Dio or widget test harness not yet established in the project. Model tests cover the critical parsing layer. |
| Real-device verification | Not performed in this sprint. Owner should verify on a physical device or emulator with a running backend. |
| Offline/queued read operations | Out of scope per brief. Read mutations require network connectivity. |
| Push notifications | Explicitly out of scope for N4. |

---

## 13. Architecture Decisions

| Decision | Rationale |
|---|---|
| Model named `AppNotification` | Avoids collision with Flutter's built-in `Notification` widget class |
| `unreadCountProvider` is NOT autoDispose | Bell badge needs the count even when inbox screen is closed |
| `inboxProvider` IS autoDispose | Fresh load each visit, mirrors `feedProvider` pattern |
| Server-first mutations (no optimistic) | Brief explicitly forbids falsely claiming success; simpler rollback |
| Bell in FeedScreen app bar | FeedScreen is the main authenticated screen; natural entry point |
| Mark-all-as-read included | Backend supports it, fits inbox UX, small addition |

No architecture change proposals were needed. All work fits within the existing design.

---

## 14. Acceptance Criteria Status

### Core functionality
- [x] Inbox accessible through existing app navigation (bell on feed)
- [x] Authenticated user's notifications load from real API
- [x] Notification content uses verified response contract
- [x] Read and unread visually distinguishable (gold border + dot)
- [x] Empty state displayed ("All quiet.")
- [x] Loading and error states usable and recoverable
- [x] Pagination follows backend cursor contract
- [x] Repeated pagination does not create duplicates (dedup by ID)
- [x] Notification opens associated poem via existing ReaderScreen
- [x] Missing poems handled by ReaderScreen's existing error state

### Read-state behavior
- [x] Individual notifications markable as read via API
- [x] Mark-all-as-read works
- [x] Successful reads update inbox state
- [x] Unread count reflects server state after operations
- [x] Failed mutations do not falsely report success
- [x] Repeated taps do not create duplicate requests

### Authentication and user isolation
- [x] Requests use established authenticated API client
- [x] Unauthorized responses follow existing behavior (Dio interceptor)
- [x] No client-side recipient ID passed
- [x] No new auth mechanism introduced

### Quality and regression
- [x] `flutter analyze` — No issues found
- [x] New tests cover model parsing (7 tests, all pass)
- [x] Full test suite passes (8/8)
- [x] No backend/schema/migration changes
- [x] No unapproved architecture changes or dependencies

### Handoff
- [x] Completion report exists (this file)
- [x] Test commands and results recorded
- [x] Git state recorded
- [x] Limitations and follow-ups listed
- [ ] **Owner review requested — awaiting approval before `v-noti_N4` tag**
