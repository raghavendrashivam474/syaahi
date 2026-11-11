---

# Post-Implementation Report: UX-08 — Navigation Shell & Information Architecture

**To:** Senior Engineering  
**From:** UX-08 Implementation  
**Date:** 11 November 2026  
**Branch:** `feature/ux-08-navigation-shell`  
**Target Release:** `v-UX-08`  
**Status:** Implementation Complete — Awaiting Review, Test Verification & Merge

---

## 1. Executive Summary

UX-08 restructured Syaahi's navigation from a flat, 12-route GoRouter configuration with an overcrowded Feed AppBar into a destination-oriented navigation shell. The application now exposes five primary destinations through a persistent bottom navigation bar (mobile) and navigation rail (desktop), with contextual AppBars on each screen.

No existing business logic, domain models, API contracts, authentication mechanisms, or feature implementations were modified. All changes are confined to navigation composition, AppBar action redistribution, and responsive layout.

**Static analysis result:** `flutter analyze` — **No issues found.**

---

## 2. What Was Implemented

### 2.1 Navigation Shell

A `StatefulShellRoute.indexedStack` was introduced into the GoRouter configuration, wrapping four primary destinations:

| Branch | Route | Screen | Auth |
|---|---|---|---|
| 0 | `/home` | FeedScreen | Protected |
| 1 | `/discover` | DiscoveryScreen | Public |
| 2 | `/heart` | HeartScreen | Protected |
| 3 | `/profile` | ProfileScreen | Protected |

Four additional routes remain outside the shell and are pushed on top via `parentNavigatorKey: _rootNavigatorKey`:

- `/write` — WriterScreen (protected)
- `/poem/:id` — ReaderScreen (public)
- `/profile/:username` — AuthorProfileScreen (public)
- `/notifications` — InboxScreen (protected)

### 2.2 AppNavigationShell Widget

**File:** `lib/core/navigation/presentation/app_navigation_shell.dart`

A single widget that receives GoRouter's `StatefulNavigationShell` and composes the appropriate layout:

- **Mobile (< 600px):** `Scaffold` with a custom 5-item bottom navigation bar. The central Write action is a 52px elevated gold circle. Safe area insets are respected via `MediaQuery.padding.bottom`.
- **Desktop (≥ 600px):** `Scaffold` with a Material `NavigationRail` on the left, a vertical divider, and the shell content expanded to fill remaining space.

The 600px breakpoint matches the existing `SyaahiBrandMark` responsive convention.

### 2.3 Five-Item Bottom Navigation

The bottom navigation presents five visual items mapped to four shell branches:

| Visual Position | Label | Behaviour |
|---|---|---|
| 1 | Home | `goBranch(0)` |
| 2 | Discover | `goBranch(1)` |
| 3 | Write | `context.push('/write')` |
| 4 | My Heart | `goBranch(2)` |
| 5 | Profile | `goBranch(3)` |

Selected state is derived exclusively from `navigationShell.currentIndex`. No independent tab index is maintained.

### 2.4 Feed AppBar Simplification

**Before:** 7 AppBar actions (Search, Filter, Bell, Heart, Help, Profile, Logout) + FloatingActionButton.

**After:** 3 AppBar actions (Filter, Bell, Overflow menu).

The overflow menu contains a single item — "How Syaahi Works" — which calls the existing `OnboardingWalkthrough.show(context)` method delivered in UX-07.

The FloatingActionButton was removed. Its functionality is fully replaced by the central Write button in the bottom navigation.

### 2.5 Profile as Account Management Destination

The ProfileScreen AppBar now includes a Logout action that reuses the existing `authProvider.notifier.logout()` mechanism. This preserves session cleanup, onboarding state invalidation, and post-logout redirect to `/welcome`.

The back button was removed since Profile is now a shell branch.

### 2.6 Shell Branch AppBar Cleanup

Back buttons were removed from HeartScreen, DiscoveryScreen, and ProfileScreen. These screens are shell branches — navigation between them is handled by the bottom nav/rail, not by back-stack popping.

ReaderScreen and WriterScreen retained their back buttons because they are pushed on top of the shell via the root navigator.

### 2.7 Documentation

Seven documents were produced under `docs/phase_ux/sprintUX8/`:

- `RECONNAISSANCE.md` — Full route inventory, screen mapping, AppBar audit, risk assessment
- `ARCHITECTURE.md` — Final route hierarchy, shell composition, responsive strategy, state ownership
- `IMPLEMENTATION.md` — File-level change log, component inventory, behavioural diff
- `TESTING.md` — Analysis results, manual verification checklist, known limitations
- `HANDOFF.md` — Git state, release tag, deferred work
- `README.md` — Sprint overview and acceptance criteria tracking
- `decisions/ADR-UX08-001-navigation-shell.md` — Architecture decision record

---

## 3. How It Was Implemented

### 3.1 Reconnaissance Phase

Before any code changes, the existing codebase was inspected across 15+ files to establish:

- The complete route inventory (12 flat GoRoutes, no ShellRoute)
- The actual route paths (notably `/home`, not `/feed` as the brief assumed)
- Every AppBar action across all screens
- The FAB target and behaviour
- The authentication guard logic and public/protected classification
- The existing responsive breakpoint (600px in SyaahiBrandMark)
- The logout mechanism and its dependencies

This produced `RECONNAISSANCE.md` and informed the architecture decision to use 4 shell branches rather than 5.

### 3.2 Router Migration

The router was migrated from 12 flat `GoRoute` entries to a hybrid structure:

1. Four auth/onboarding routes remain flat and outside the shell.
2. Four primary destinations are wrapped in `StatefulShellRoute.indexedStack` with dedicated `GlobalKey<NavigatorState>` per branch.
3. Four detail/action routes use `parentNavigatorKey: _rootNavigatorKey` to push on top of the shell.

The auth redirect logic was preserved verbatim. `state.matchedLocation` correctly returns leaf paths (e.g., `/home`, `/discover`) inside the shell, so no guard changes were needed.

### 3.3 Screen Modifications

Each screen modification was surgical:

- **FeedScreen (685 → 678 lines):** Replaced the `actions` array and removed the `floatingActionButton` property. The `_BellButton` widget, `_FilterBar`, and all body content remain untouched.
- **ProfileScreen (full rewrite, 47 lines):** Replaced the AppBar configuration. The `AuthorProfileView` delegation and null-user fallback are identical.
- **HeartScreen:** Removed the `leading` property from the AppBar. Body, scroll controller, pagination, and refresh logic are untouched.
- **DiscoveryScreen:** Removed the `leading` property from the AppBar. Search field, result tiles, and state management are untouched.

### 3.4 Incremental Verification

After each change, `flutter analyze` was run to confirm zero new issues. The router was verified with a 15-pattern existence check. Brace counting confirmed structural integrity. Each screen modification was individually verified before proceeding.

---

## 4. Problems Faced and Mitigations

### 4.1 Monorepo Project Structure

**Problem:** The brief referenced `lib/core/router/app_router.dart`, but the Flutter project lives inside a `syaahi-app/` subdirectory within a monorepo (`syaahi-app/`, `syaahi-backend/`, `docs/`, `.vercel/`). Initial file reads failed with `PathNotFound`.

**Mitigation:** Ran a filesystem discovery pass to locate `pubspec.yaml` and the actual `lib/` tree. All subsequent paths were adjusted to `syaahi-app/lib/...`. This also revealed the `syaahi-backend/` directory, confirming the monorepo structure.

### 4.2 Route Path Mismatch

**Problem:** The brief specified `/feed` as the home route. The actual route is `/home`. Changing it would have broken the auth redirect (`return '/home'`), the 404 screen's "Go to Feed" button, and multiple `context.go('/home')` calls across HeartScreen, ProfileScreen, DiscoveryScreen, and InboxScreen.

**Mitigation:** Kept `/home` as the route path. The bottom navigation label reads "Home" which is semantically consistent. The brief's `/feed` reference was treated as a naming suggestion, not a mandate. This was documented in `RECONNAISSANCE.md`.

### 4.3 Write as Shell Branch — Architectural Conflict

**Problem:** The initial architecture plan considered 5 shell branches. However, `WriterScreen` uses `PopScope` with draft-discard confirmation and calls `context.pop()` after successful publish. Placing it inside a shell branch would:
- Preserve stale editor state across tab switches (IndexedStack keeps widgets alive)
- Conflict with the pop-based navigation flow (pop would exit the branch, not the shell)
- Break the existing `canPop: !_hasUnsavedContent` guard

**Mitigation:** Reduced to 4 shell branches. Write remains a pushed route via `parentNavigatorKey: _rootNavigatorKey`. The bottom nav still shows 5 items; the Write button calls `context.push('/write')` instead of `goBranch()`. This preserves the exact existing WriterScreen behaviour. Documented in `ADR-UX08-001`.

### 4.4 String.Replace() Silent Failures

**Problem:** When modifying ProfileScreen, HeartScreen, and DiscoveryScreen, the initial approach used PowerShell's `String.Replace()` with multi-line expected strings. All three replacements failed silently — the files were written back unchanged. The root cause was whitespace mismatch: the actual files used different indentation patterns (trailing spaces, varying indent depth) than the expected strings.

**Mitigation:** Switched to regex-based replacement with `(?s)` (single-line mode) and flexible `\s*` quantifiers for HeartScreen and DiscoveryScreen. Both succeeded on the second attempt. ProfileScreen's regex also failed due to deeply nested braces in the `leading: IconButton(...)` block that exceeded the regex's matching capability. Since ProfileScreen was only 47 lines, the entire file was rewritten from scratch, preserving all logic.

### 4.5 Linter Cascade in Test File

**Problem:** A pre-existing `info`-level linter issue in `test/features/resonance/resonance_reply_test.dart` flagged `_TestAuthNotifier(AuthRepository repo) : super(repo)` as a candidate for super parameter shorthand. When fixed to `_TestAuthNotifier(super.repo)`, the explicit `import 'package:syaahi_app/features/auth/data/auth_repository.dart'` became unused, triggering a new `unused_import` warning.

**Mitigation:** Removed the now-unnecessary import. The super parameter shorthand infers the type from the parent class constructor. Final result: `flutter analyze` — **No issues found** (down from 1 pre-existing info).

### 4.6 Unused Legacy File Discovery

**Problem:** `features/home/home_screen.dart` exists in the file tree but is not referenced in the router. It contains a placeholder screen with the text "Feed coming next. For now — you are signed in." This is a legacy artifact from early development.

**Mitigation:** Left untouched. It is not in the router, not imported by any active code, and modifying it is outside UX-08 scope. Documented in `RECONNAISSANCE.md` as "UNUSED."

### 4.7 Back Button Removal Scope

**Problem:** Removing back buttons from shell branch screens required careful scoping. ReaderScreen and InboxScreen also had back buttons, but they are pushed routes (not shell branches). Removing their back buttons would break the navigation stack.

**Mitigation:** Only removed back buttons from the four shell branch screens (Heart, Discover, Profile, and the Feed which never had one). ReaderScreen, WriterScreen, and InboxScreen retained their existing back/close buttons. The `parentNavigatorKey: _rootNavigatorKey` ensures these pushed routes sit on top of the shell's navigator, so `context.pop()` correctly returns to the shell.

---

## 5. Files Changed Summary

| Category | File | Nature of Change |
|---|---|---|
| **New** | `lib/core/navigation/presentation/app_navigation_shell.dart` | Navigation shell widget (256 lines) |
| **Modified** | `lib/core/router/app_router.dart` | ShellRoute + navigator keys (223 lines) |
| **Modified** | `lib/features/poems/presentation/feed_screen.dart` | AppBar simplification, FAB removal |
| **Modified** | `lib/features/poems/presentation/heart_screen.dart` | Back button removal |
| **Modified** | `lib/features/discovery/presentation/discovery_screen.dart` | Back button removal |
| **Modified** | `lib/features/profile/profile_screen.dart` | Full rewrite (logout, no back) |
| **Modified** | `test/features/resonance/resonance_reply_test.dart` | Linter fix (super param + import) |
| **Backup** | `lib/core/router/app_router.dart.bak` | Original router preserved |
| **Docs** | `docs/phase_ux/sprintUX8/` (7 files) | Full sprint documentation |

**No new dependencies were added.** The existing `go_router: ^14.6.2` already supports `StatefulShellRoute.indexedStack`.

---

## 6. Verification Status

| Check | Result |
|---|---|
| `flutter analyze` | ✅ No issues found |
| Pattern verification (15 router patterns) | ✅ All present |
| Brace balance (router) | ✅ 8/8 |
| Feed FAB removed | ✅ Confirmed |
| Feed logout removed | ✅ Confirmed |
| Profile logout added | ✅ Confirmed |
| Profile back button removed | ✅ Confirmed |
| Heart back button removed | ✅ Confirmed |
| Discover back button removed | ✅ Confirmed |
| `flutter test` | ⏳ Pending — run before merge |

---

## 7. Known Limitations and Deferred Work

1. **Navigation rail Write button** uses standard Material rail styling rather than the elevated gold circle seen on mobile. This is cosmetic and can be refined in a future sprint.
2. **Shell branch back navigation** — users cannot use browser back to return to a previous tab. Tab switching is handled exclusively through the nav bar/rail. This is standard behaviour for shell-based navigation.
3. **Navigation-specific widget tests** have not been written yet. The existing test suite should be run to confirm no regressions, and dedicated navigation tests should be added before or during the next sprint.
4. **Manual viewport verification** on physical devices and a range of browser widths is recommended before production release.

---

## 8. Recommendation

The implementation is ready for code review. The recommended next steps are:

1. Run `flutter test` to confirm all existing tests pass.
2. Perform manual verification on mobile and desktop viewports.
3. Review the ADR (`ADR-UX08-001`) for the shell architecture decision.
4. Merge `feature/ux-08-navigation-shell` into `main`.
5. Tag `v-UX-08`.

No domain logic, authentication, persistence, or API changes were made. The risk surface is confined to navigation composition and AppBar layout.

---

**End of Report**