# UX-03 Implementation Plan

**Date:** 2026-11-06
**Baseline:** v-UX-02 (d44ea46)
**Status:** Approved for implementation

---

## Implementation Sequence

### Step 1 — Router: Auth Guard + Error Builder (S2)
**Files:** `syaahi-app/lib/core/router/app_router.dart`

1. Add `redirect` callback to `GoRouter`:
   - Read auth state from `authProvider` (via `ref` parameter).
   - Define protected routes: `/home`, `/write`, `/heart`, `/profile`, `/notifications`.
   - If unauthenticated and targeting a protected route → redirect to `/welcome`.
   - If authenticated and targeting `/welcome` or `/auth/*` → redirect to `/home`.
   - Use `GoRouter`'s `refreshListenable` to react to auth changes.
2. Add `errorBuilder` to `GoRouter`:
   - Show a branded "Page not found" screen.
   - Include the attempted path.
   - Provide a "Go to Feed" button.
3. No new files. No new dependencies.

### Step 2 — Reader Error State (S4)
**Files:** `syaahi-app/lib/features/poems/presentation/reader_screen.dart`

1. Replace the inline error text with a structured error view:
   - Check for `PoemsException` with `statusCode == 404` → show "Poem not found" state.
   - Otherwise → show "Could not load this poem" with a retry button.
2. Retry calls `ref.invalidate(poemByIdProvider(poemId))`.
3. Match the visual style of `_ErrorView` in `author_profile_view.dart`.

### Step 3 — Writer Unsaved Draft Guard (S2)
**Files:** `syaahi-app/lib/features/poems/presentation/writer_screen.dart`

1. Wrap the `Scaffold` in a `PopScope` widget.
2. `canPop` returns `true` only when all text fields are empty OR `isPublishing` is `true`.
3. `onPopInvokedWithResult`: if `didPop` is `false` and fields have content, show a confirmation dialog.
4. If user confirms discard → `context.pop()`.
5. If user cancels → stay on screen.

### Step 4 — Feed Filter Empty State (S3)
**Files:** `syaahi-app/lib/features/poems/presentation/feed_screen.dart`

1. Modify `_buildBody` to pass `state.filters.isEmpty` to the empty view.
2. When filters are active and results are empty:
   - Show "No poems match your filters."
   - Provide a "Clear filters" button that calls `ref.read(feedProvider.notifier).clearFilters()`.
3. When no filters and results are empty:
   - Keep existing `_EmptyFeed` behaviour unchanged.

### Step 5 — Deep-Link Back Navigation (S2)
**Files:** Multiple screens (profile, author profile, heart, notifications, reader)

1. Replace `context.pop()` in `AppBar` back buttons with a safe helper:
   ```dart
   void _safeBack(BuildContext context) {
     if (context.canPop()) {
       context.pop();
     } else {
       context.go('/home');
     }
   }

```

2. Apply to: `ProfileScreen`, `AuthorProfileScreen`, `HeartScreen`, `InboxScreen`, `ReaderScreen`.
3. Do **NOT** apply to `WriterScreen` (already handled by `PopScope` in Step 3).

### Step 6 — Regression Testing & Verification (S5)

1. Run `flutter analyze` — no new issues.
2. Run `flutter test` — all existing tests pass.
3. Manual verification of all six journeys (A–F):
* **Verify auth guard:** logout → try `/home` → redirected to `/welcome`.
* **Verify error builder:** navigate to `/nonexistent` → branded 404.
* **Verify reader error:** open `/poem/invalid-id` → friendly error + retry.
* **Verify writer guard:** type content → press back → confirmation dialog.
* **Verify filter empty:** apply filter with no results → "Clear filters" CTA.



---

## Files Modified (Expected)

| File | Change |
| --- | --- |
| `core/router/app_router.dart` | Add `redirect` + `errorBuilder` |
| `features/poems/presentation/reader_screen.dart` | Improve error state |
| `features/poems/presentation/writer_screen.dart` | Add `PopScope` draft guard |
| `features/poems/presentation/feed_screen.dart` | Filter-aware empty state |
| `features/profile/profile_screen.dart` | Safe back nav |
| `features/profile/presentation/author_profile_screen.dart` | Safe back nav |
| `features/poems/presentation/heart_screen.dart` | Safe back nav |
| `features/notifications/presentation/inbox_screen.dart` | Safe back nav |

---

## Files NOT Modified

* All providers (`poems_providers.dart`, `profile_providers.dart`, `notifications_providers.dart`, `auth_providers.dart`)
* All repositories
* All models
* `author_profile_view.dart` (UX-02 work preserved as-is)
* Backend, database, API contracts
* `main.dart` (unless auth listenable requires it)

---

## Architectural Decisions

No ADR required. All changes are within existing architectural boundaries:

* Router configuration is a standard `go_router` feature.
* `PopScope` is a Flutter framework widget.
* Error/empty state improvements are presentation-only.
* No new abstractions, no new packages, no structural changes.

```