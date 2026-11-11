# UX-08 Reconnaissance Report

## 1. Existing Route Inventory

| Route | Screen | Auth | Type |
|---|---|---|---|
| `/` | SplashScreen | Public | Entry |
| `/welcome` | WelcomeScreen | Public | Onboarding |
| `/auth/signup` | SignupScreen | Public | Auth |
| `/auth/login` | LoginScreen | Public | Auth |
| `/home` | FeedScreen | Protected | **Primary** |
| `/discover` | DiscoveryScreen | Public | **Primary** |
| `/write` | WriterScreen | Protected | **Primary (push)** |
| `/heart` | HeartScreen | Protected | **Primary** |
| `/profile` | ProfileScreen | Protected | **Primary** |
| `/profile/:username` | AuthorProfileScreen | Public | Detail |
| `/poem/:id` | ReaderScreen | Public | Detail |
| `/notifications` | InboxScreen | Protected | Detail |

**Note:** Brief references `/feed` but actual route is `/home`.
Keeping `/home` to avoid breaking auth redirects and existing `context.go('/home')` calls.

## 2. Screen-to-Route Mapping

| File | Route | Notes |
|---|---|---|
| `features/poems/presentation/feed_screen.dart` | `/home` | 685 lines |
| `features/discovery/presentation/discovery_screen.dart` | `/discover` | Author search |
| `features/poems/presentation/writer_screen.dart` | `/write` | PopScope + draft |
| `features/poems/presentation/heart_screen.dart` | `/heart` | Saved poems |
| `features/profile/profile_screen.dart` | `/profile` | Delegates to AuthorProfileView |
| `features/profile/presentation/author_profile_screen.dart` | `/profile/:username` | Public |
| `features/poems/presentation/reader_screen.dart` | `/poem/:id` | Detail + resonance |
| `features/notifications/presentation/inbox_screen.dart` | `/notifications` | Inbox |
| `features/home/home_screen.dart` | **UNUSED** | Legacy, not in router |

## 3. Current Navigation Entry Points

- No ShellRoute — all 12 routes are flat GoRoutes
- No bottom navigation bar
- No navigation rail
- FAB on FeedScreen only → `context.push('/write')`

## 4. AppBar Action Inventory

### FeedScreen (`/home`) — 7 actions + FAB
| Action | Icon | Behaviour |
|---|---|---|
| Title | SyaahiBrandMark | Brand (responsive) |
| Search | search | `push('/discover')` → **MOVE to nav** |
| Filter | filter_list | Toggle filter bar → **KEEP** |
| Bell | notifications_none | `push('/notifications')` → **KEEP** |
| Heart | favorite_outline | `push('/heart')` → **MOVE to nav** |
| Help | help_outline | Walkthrough → **MOVE to overflow** |
| Profile | person_outline | `push('/profile')` → **MOVE to nav** |
| Logout | logout | `logout()` → `/welcome` → **MOVE to Profile** |
| FAB | edit_outlined | `push('/write')` → **REPLACE with nav** |

### Other Screens
- **Discover:** Back + title "Discover Writers" + search in body
- **Heart:** Back + title "My Heart"
- **Profile:** Back + title "Profile" (NO logout)
- **Writer:** Close + title "Write" + Publish button
- **Reader:** Back + owner overflow (delete)
- **Inbox:** Back + dynamic title

## 5. FAB Behaviour

- FeedScreen only, gold background, `context.push('/write')`
- Replaced by central bottom nav Write button

## 6. Auth & Guest Access

- Public: `/`, `/welcome`, `/auth/*`, `/poem/:id`, `/profile/:username`, `/discover`
- Protected: `/home`, `/write`, `/heart`, `/profile`, `/notifications`
- Unauth → protected: redirect `/welcome`
- Auth → auth screens: redirect `/home`
- Logout: `authProvider.notifier.logout()` → clears state + onboarding → `go('/welcome')`

## 7. Responsive Layout

- SyaahiBrandMark: 600px breakpoint (icon vs icon+wordmark)
- No other responsive navigation exists

## 8. Reusable Components

| Component | Location | Plan |
|---|---|---|
| SyaahiBrandMark | `core/widgets/` | Keep in Feed AppBar |
| OnboardingWalkthrough.show() | `features/onboarding/` | Call from overflow |
| authProvider.notifier.logout() | `features/auth/state/` | Move to Profile |
| _BellButton | `feed_screen.dart` | Keep in Feed AppBar |
| SyaahiColors.goldBase | `core/constants/` | Write button |

## 9. Proposed Architecture

### Router

```text
GoRouter
├── / (SplashScreen)
├── /welcome (WelcomeScreen)
├── /auth/signup, /auth/login
├── StatefulShellRoute.indexedStack (AppNavigationShell)
│ ├── Branch 0: /home (FeedScreen)
│ ├── Branch 1: /discover (DiscoveryScreen)
│ ├── Branch 2: /heart (HeartScreen)
│ └── Branch 3: /profile (ProfileScreen)
├── /write (WriterScreen) — pushed on top
├── /poem/:id (ReaderScreen) — pushed on top
├── /profile/:username (AuthorProfileScreen) — pushed on top
└── /notifications (InboxScreen) — pushed on top
```

### Why 4 branches, not 5
- Write has PopScope + draft confirmation + `context.pop()` after publish
- Shell branch would preserve stale editor state across tab switches
- Write replaces FAB behaviour (`context.push('/write')`)
- Bottom nav shows 5 items; Write pushes on top of shell

### Bottom Nav
- 5 items: Home, Discover, Write, My Heart, Profile
- Items 0,1,3,4 → `navigationShell.goBranch()`
- Item 2 (Write) → `context.push('/write')`
- Selected state from `navigationShell.currentIndex` + route check

## 10. Migration Risks

| Risk | Mitigation |
|---|---|
| Auth redirect breaks | `state.matchedLocation` returns child paths in shell |
| AppBar conflicts | Remove redundant back buttons from shell children |
| Feed state lost | StatefulShellRoute preserves via IndexedStack |
| WriterScreen PopScope | Write is pushed, not in shell — works as-is |
| Deep links | GoRouter handles natively with StatefulShellRoute |
| Guest Discover access | Auth guard still allows `/discover` as public |
| Logout removed from Feed | Add to Profile BEFORE removing from Feed |
