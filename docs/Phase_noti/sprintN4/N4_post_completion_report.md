# Post-N4 Implementation Report

**To:** Senior Developer
**From:** N4 Implementation
**Project:** Syaahi — Flutter In-App Notification Inbox
**Phase:** `phase_noti`
**Sprint:** N4
**Baseline:** `v-noti_N3` @ `de72b72`
**Status:** Implementation complete; awaiting review before `v-noti_N4` tag
**Branch:** `main` (uncommitted at time of writing; see §9)

---

## 1. Executive Summary

N4 delivers the first production-quality in-app notification inbox in the Syaahi Flutter application. The sprint integrated the existing N1–N3 backend notification infrastructure with the Flutter client without introducing new dependencies, modifying backend code, or altering the established application architecture.

An authenticated user can now:

- Open an inbox from a bell icon on the feed screen
- See their paginated notifications fetched from the real backend
- Visually distinguish read from unread items
- Mark individual notifications as read, or all at once
- Tap a notification to open the associated poem in the existing reader
- See an unread count badge on the bell that stays in sync with the server

`flutter analyze` reports no issues. All 8 unit tests pass (7 new + 1 pre-existing).

---

## 2. Scope Interpretation

The brief emphasized this as an **integration sprint, not a greenfield feature**. We treated this literally:

- Zero new packages added to `pubspec.yaml`
- Zero changes to backend code, Prisma schema, or migrations
- Zero changes to existing authentication, HTTP, routing, or state-management infrastructure
- All new code mirrors established patterns (specifically the Poems feature) rather than inventing new ones

The core deliverable was defined as inbox + read-state + unread count. Notification preferences UI was explicitly deferred per §3.6 of the brief, because the app has no existing settings screen that would make it a "small, consistent extension."

---

## 3. Preflight & Discovery Process

Before writing any production code, we performed a structured inspection of both the Flutter app and the backend, following §4 of the brief. The complete findings are in `N4_PREFLIGHT.md` at the repo root.

### Discovered architecture

| Concern | Established in codebase |
|---|---|
| State management | Riverpod — `StateNotifier<T>` + `StateNotifierProvider.autoDispose` |
| Routing | GoRouter — flat `GoRoute` list, no ShellRoute, no auth guards |
| HTTP | Dio via `ApiClient` singleton; JWT auto-injected via `InterceptorsWrapper` reading from `TokenStorage` (flutter_secure_storage) |
| Models | Manual `fromJson` factories, no code generation |
| Repository pattern | One class per feature, optional `Dio` injection via constructor, custom typed exception class |
| Pagination | Cursor-based — `nextCursor` is a UUID string; `hasMore = nextCursor != null` |
| Design system | `SyaahiColors` (midnight blue + gold palette), `SyaahiSizes` (8pt scale), Google Fonts (Cormorant Garamond + Inter) |
| Base URL | `SyaahiStrings.apiBaseUrl` constant |

### Confirmed API contract

Verified directly against `syaahi-backend/src/modules/notifications/notifications.controller.ts`:

```
GET  /api/v1/notifications?limit=20&cursor=<uuid>
  → { success, data: { items: [{id,type,poemId,readAt,createdAt,poem:{id,title}}], nextCursor } }

GET  /api/v1/notifications/unread-count
  → { success, data: { unreadCount } }

PATCH /api/v1/notifications/:id/read
  → { success, data: { read: true } }

PATCH /api/v1/notifications/read-all
  → { success, data: { markedCount } }
```

Pagination parameters confirmed: `limit` 1–50 (default 20), `cursor` must be a UUID.

---

## 4. Implementation Details

### 4.1 Files created

```
N4_PREFLIGHT.md
N4_COMPLETION_REPORT.md
syaahi-app/lib/features/notifications/
    data/notifications_repository.dart          (~150 lines)
    state/notifications_providers.dart          (~175 lines)
    presentation/inbox_screen.dart              (~290 lines)
syaahi-app/test/notifications/
    model_test.dart                             (~75 lines, 7 tests)
```

### 4.2 Files modified

```
syaahi-app/lib/core/router/app_router.dart              (+7 lines)
syaahi-app/lib/features/poems/presentation/feed_screen.dart (+49 lines)
```

### 4.3 Data layer — `notifications_repository.dart`

Three model classes and one repository:

- **`NotificationPoem`** — lightweight nested model matching the backend's `select: { id, title }`
- **`AppNotification`** — intentionally named `AppNotification` (not `Notification`) to avoid collision with Flutter's built-in `Notification` widget class in `package:flutter/widgets.dart`. Exposes an `isRead` getter derived from `readAt != null`
- **`NotificationInboxResult`** — wrapper for paginated response (items + nextCursor)
- **`NotificationsException`** — custom exception matching `PoemsException` shape
- **`NotificationsRepository`** — four methods (`listNotifications`, `getUnreadCount`, `markAsRead`, `markAllAsRead`) using the existing `ApiClient().dio` singleton

The `_handle(DioException)` method is a direct port of `PoemsRepository._handle` — same error envelope parsing, same user-facing message strategy.

### 4.4 State layer — `notifications_providers.dart`

Two providers with intentionally different lifetimes:

| Provider | Lifetime | Why |
|---|---|---|
| `inboxProvider` | `autoDispose` | Fresh load on every inbox visit; mirrors `feedProvider` |
| `unreadCountProvider` | Persistent | Bell badge needs the count even when inbox is closed |

Key design: **server-first mutations**. We update local state only after the API call succeeds. This directly addresses the brief's rule (§3.3, §8) against falsely claiming server success. The tradeoff is a slight UI delay on tap, but it eliminates optimistic-rollback complexity and prevents the badge from ever lying.

The `UnreadCountNotifier` exposes `decrement()` and `zero()` methods so the inbox can reconcile the count after confirmed mutations without triggering a redundant API round-trip.

`int?` is used for the unread count: `null` = not yet fetched (no badge), `0` = fetched and zero (no badge), `>0` = show badge. This prevents a flash of "0" during initial load.

### 4.5 UI layer — `inbox_screen.dart`

A single `ConsumerStatefulWidget` with scroll-based pagination (triggered 300px before end, matching `FeedScreen`'s pattern). Handles all required states:

| State | UI |
|---|---|
| Loading (first page) | Centered `CircularProgressIndicator` in gold |
| Loading more | Trailing spinner in list |
| Empty | "All quiet." + explanation |
| Error (first page) | Icon + message + "Try Again" button |
| Loaded | Scrollable list with pull-to-refresh |
| Marking all read | Spinner in the AppBar button |

**Unread visual language:**
- Gold left border (3px)
- Gold circular dot on the left
- Bold title in primary text color
- Faint gold tint on the card background (4% opacity)

**Read visual language:**
- No border, no dot
- Normal weight, secondary text color
- Standard surface card background

**Timestamp formatting** uses `intl` (already in pubspec): "Just now", "5m ago", "3h ago", "2d ago", then falls back to `MMM d`.

**Mark-all button** appears in the AppBar only when `hasUnread` is true, disappears cleanly when nothing to mark.

### 4.6 Integration — router and feed screen

Added a single `GoRoute` for `/notifications` to `AppRouter`.

Added `_BellButton` as a private `ConsumerWidget` in `feed_screen.dart` (consistent with the file's existing pattern of private widget classes like `_PoemCard`, `_EmotionBadge`). The badge logic:
- Watches `unreadCountProvider`
- Shows no badge for `null` or `0`
- Shows the number for 1–99
- Shows "99+" for ≥100

A single line (`ref.read(unreadCountProvider.notifier).refresh()`) in `_FeedScreenState.initState()` ensures the count refreshes every time the user lands on the feed. No polling, no background timers.

---

## 5. Problems Encountered & Mitigations

This is the honest part. Three real issues came up during execution.

### 5.1 PowerShell regex failed on multi-line insertions

**Problem.** During Block 7 (wiring), I used `-replace` with multi-line regex patterns to insert both the `/notifications` GoRoute and the `_BellButton()` widget call. The import lines (single-line replacements) succeeded, but the multi-line patterns silently failed. The initial "verification" step only grep'd for the word "notifications" and found the import, giving a false positive.

**Root cause.** PowerShell file reads normalize to `\r\n` on Windows, but my regex used `\n` as separator. The regex engine matched across lines only when the exact `\r\n` sequence happened to line up — which it didn't for 4-line insertions.

**Discovery.** `flutter analyze` surfaced it immediately:

```
warning - Unused import: '...inbox_screen.dart'. - unused_import
warning - The declaration '_BellButton' isn't referenced. - unused_element
```

Two unused symbols is exactly the signature of a failed insertion: the import and the widget class were added, but nothing referenced them.

**Mitigation.** Replaced the regex approach entirely with line-array insertion:

```powershell
$lines = [System.Collections.ArrayList]@(Get-Content $path)
# ... find target line by content match ...
$lines.Insert($index, $newLine)
$lines | Set-Content -Path $path -Encoding UTF8
```

This is bulletproof regardless of line endings. All subsequent file edits used this pattern.

**Lesson.** For multi-line insertions in PowerShell file manipulation, never trust regex. Use line-array `.Insert()` and verify by grepping for the actual inserted content, not just a nearby keyword.

### 5.2 Working directory drift between blocks

**Problem.** Block 8c failed with `Cannot find path '...\syaahi-app\syaahi-app\lib\...'`. The script used `$APP = "syaahi-app\lib"` as a relative prefix, but a previous block had already `Push-Location`d into `syaahi-app/` and never popped back out, so the prefix was doubled.

**Mitigation.** Rewrote the failing block to use `lib\...` paths directly, assuming the already-shifted working directory.

**Lesson.** Scripts spanning multiple blocks should either always pin to an absolute path or always start with an explicit `Set-Location`. Mixing `Push-Location` without a matching `Pop-Location` is a trap.

### 5.3 Name collision risk with Flutter's `Notification` widget

**Problem.** The obvious model name — `Notification` — collides with Flutter's built-in `Notification` class from `package:flutter/widgets.dart` (part of the Notifications/Listener widget tree). Using it would have forced import prefixing (`as model`) throughout the app, or worse, silent shadowing bugs.

**Mitigation.** Named the model `AppNotification` from the start. The nested poem model is `NotificationPoem`. No prefixing or aliasing needed anywhere in the codebase.

**Lesson.** When choosing names for cross-cutting domain concepts in Flutter, always grep the framework namespace first.

### 5.4 Unread count badge: avoiding dishonest UI

**Problem.** The brief is strict about never falsely clearing the unread badge (§3.4, §8). Common optimistic patterns — set count to 0 immediately, roll back on failure — can leave users confused if the network call fails silently.

**Mitigation.** Three-state typing with `int?`:
- `null` → not yet fetched; show no badge (prevents badge flash on cold start)
- `0` → confirmed zero from server; show no badge
- `>0` → confirmed count; show badge

Mutations update the count **only after** the server confirms success. Failures leave the previous count untouched. The `UnreadCountNotifier.refresh()` method catches all exceptions silently to preserve the last known good state rather than wiping it to `null`.

---

## 6. Verification Evidence

### 6.1 Static analysis

```
$ flutter analyze
Analyzing syaahi-app...
No issues found! (ran in 5.0s)
```

### 6.2 Tests

```
$ flutter test test/notifications/model_test.dart
00:12 +7: All tests passed!

$ flutter test
00:02 +8: All tests passed!
```

The 7 new tests cover:
- `NotificationPoem` with and without title (nullable field handling)
- `AppNotification` full parsing including nested poem
- `isRead` getter: `true` when `readAt` set, `false` when null
- Null poem title inside a notification (end-to-end nullable chain)
- `NotificationInboxResult` construction

These are pure unit tests — no Dio mocking, no widget tree, no Riverpod container. They validate the JSON contract boundary, which is the highest-value test surface for an integration sprint. Widget tests for the inbox UI were considered but deferred (see §8).

### 6.3 What was NOT verified

In the interest of accuracy:

- **No physical device verification.** The app was not deployed to a device or emulator. Owner verification against a live backend is required before tagging.
- **No end-to-end API test against a running backend.** All API behavior is inferred from reading the controller source and the N2 test files.
- **No widget tests for the inbox screen.** The project does not yet have an established widget test harness with Dio mocking.

---

## 7. Compliance with Brief's Preservation Rules (§8)

| Rule | Compliance |
|---|---|
| No N1 database models or migrations modified | ✅ |
| No N2 endpoints, envelopes, or auth rules changed | ✅ |
| No N3 publication triggers changed | ✅ |
| No push delivery or retry infrastructure | ✅ |
| No weakened authentication or client-supplied recipient ID | ✅ |
| No replacement of app architecture | ✅ |
| No parallel auth/token storage | ✅ |
| No hardcoded secrets, URLs, or test credentials | ✅ |
| No rewrites of poem list/detail screens | ✅ |
| No hardcoded mock notification data | ✅ |
| No silent opt-in to preferences | ✅ (preferences UI not implemented) |
| No local clearing of unread state on failure | ✅ (server-first) |
| No unbounded polling or background loops | ✅ |
| No existing N0–N3 tags moved | ✅ |
| No force-push | ✅ |
| No lockfile changes | ✅ |
| No new dependencies | ✅ |

---

## 8. Known Limitations & Deferred Work

| Item | Reason | Suggested follow-up |
|---|---|---|
| Notification preferences UI (`newPoemAlerts` toggle) | No existing settings screen; brief §3.6 says defer unless it's a "small, consistent extension" | Address when a settings screen is introduced |
| Widget/integration tests for the inbox | Project has no established Dio mock pattern | Introduce as part of a broader testing initiative, not a one-off |
| Physical device verification | Not part of this sprint's scope | Owner to verify before `v-noti_N4` tag |
| Offline queueing of read mutations | Explicitly out of scope | Only relevant if offline mode becomes a product requirement |
| Real-time inbox updates (sockets/polling) | Explicitly out of scope (§12) | Would require a dedicated sprint |
| Pull-to-refresh haptics | Minor polish | Low priority |

---

## 9. Git State at Time of Report

```
Branch: main
Tags unchanged: v-noti_N0, v-noti_N1, v-noti_N2, v-noti_N3

Working tree:
 M syaahi-app/lib/core/router/app_router.dart
 M syaahi-app/lib/features/poems/presentation/feed_screen.dart
?? N4_PREFLIGHT.md
?? N4_COMPLETION_REPORT.md
?? syaahi-app/lib/features/notifications/
?? syaahi-app/test/notifications/

Diff summary: 2 files changed, +55 insertions, -1 deletion
             + 5 new files/directories
```

Commit has not been created yet — pending your review of this report and the diff.

Suggested commit message:

```
feat(notifications): N4 in-app notification inbox

- Add notification model, repository, and API integration
- Add Riverpod state management (inbox + persistent unread count)
- Add inbox screen with loading, empty, error, pagination states
- Add read/unread visual styling and mark-all-as-read
- Add bell badge on feed screen with unread count
- Wire /notifications route into existing GoRouter
- Navigate to existing ReaderScreen on notification tap
- Add 7 unit tests for model parsing (all pass)
- flutter analyze: no issues; all 8 tests pass
- No backend, schema, or dependency changes
```

---

## 10. Request

Please review:

1. The architectural decisions in §4 (particularly the `autoDispose` vs. persistent provider split)
2. The server-first mutation strategy and its UX implications
3. The visual design of the inbox (gold border + dot for unread)
4. The deferral of notification preferences UI
5. The acceptability of deferring widget tests

Once approved, I will:

1. Commit with the suggested message above
2. Push to `main`
3. Tag `v-noti_N4` only after your explicit confirmation

I will not self-tag per the brief's §8 release protection rules.

---

*End of report.*