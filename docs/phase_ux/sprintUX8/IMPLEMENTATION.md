# UX-08: Implementation Details

## Files Created

| File | Purpose |
|---|---|
| `lib/core/navigation/presentation/app_navigation_shell.dart` | Navigation shell with bottom nav and nav rail |
| `docs/phase_ux/sprintUX8/RECONNAISSANCE.md` | Route inventory and architecture baseline |
| `docs/phase_ux/sprintUX8/ARCHITECTURE.md` | Final navigation architecture |
| `docs/phase_ux/sprintUX8/IMPLEMENTATION.md` | This file |
| `docs/phase_ux/sprintUX8/TESTING.md` | Test results |
| `docs/phase_ux/sprintUX8/HANDOFF.md` | Release handoff |
| `docs/phase_ux/sprintUX8/decisions/ADR-UX08-001-navigation-shell.md` | Architecture decision record |

## Files Modified

| File | Change |
|---|---|
| `lib/core/router/app_router.dart` | Added StatefulShellRoute, navigator keys, parentNavigatorKey for pushed routes |
| `lib/features/poems/presentation/feed_screen.dart` | Removed 5 AppBar actions + FAB; added overflow menu |
| `lib/features/poems/presentation/heart_screen.dart` | Removed back button (shell branch) |
| `lib/features/discovery/presentation/discovery_screen.dart` | Removed back button (shell branch) |
| `lib/features/profile/profile_screen.dart` | Removed back button; added logout action |
| `test/features/resonance/resonance_reply_test.dart` | Fixed pre-existing linter issue (super parameter) |

## Files Backed Up

| File | Reason |
|---|---|
| `lib/core/router/app_router.dart.bak` | Original router before shell migration |

## Components Introduced

### AppNavigationShell
- Entry point widget receiving `StatefulNavigationShell`
- Responsive layout selection via `LayoutBuilder`

### _BottomNav (mobile)
- 5-item row: Home, Discover, Write, Heart, Profile
- Elevated gold Write button (52px circle)
- Safe area padding via `MediaQuery.padding.bottom`

### _NavRail (desktop)
- Material `NavigationRail` with 5 destinations
- Same selection semantics as mobile

### Feed Overflow Menu
- `PopupMenuButton` with "How Syaahi Works" item
- Calls existing `OnboardingWalkthrough.show(context)`

## Components Reused (Unchanged)

| Component | Location |
|---|---|
| `SyaahiBrandMark` | `core/widgets/syaahi_brand_mark.dart` |
| `OnboardingWalkthrough.show()` | `features/onboarding/presentation/onboarding_walkthrough.dart` |
| `_BellButton` | `features/poems/presentation/feed_screen.dart` |
| `authProvider.notifier.logout()` | `features/auth/state/auth_providers.dart` |
| `WriterScreen` | `features/poems/presentation/writer_screen.dart` |
| `SyaahiColors` | `core/constants/colors.dart` |

## Behavioural Changes

| Before | After |
|---|---|
| Flat GoRouter with 12 routes | StatefulShellRoute with 4 branches + 4 pushed routes |
| Feed: 7 AppBar actions + FAB | Feed: 3 actions (Filter, Bell, Overflow) |
| Logout in Feed AppBar | Logout in Profile AppBar |
| No bottom navigation | 5-item bottom nav (mobile) + nav rail (desktop) |
| Heart/Discover/Profile: back buttons | Shell branches: no back buttons |
| Write via FAB | Write via central nav button |

## Dependencies

No new dependencies added. Existing `go_router: ^14.6.2` supports `StatefulShellRoute.indexedStack`.
