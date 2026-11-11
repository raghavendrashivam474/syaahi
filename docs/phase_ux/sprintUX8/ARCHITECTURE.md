# UX-08: Navigation Architecture

## Route Hierarchy

```text
GoRouter (rootNavigatorKey)
├── / SplashScreen (public)
├── /welcome WelcomeScreen (public)
├── /auth/signup SignupScreen (public)
├── /auth/login LoginScreen (public)
│
├── StatefulShellRoute.indexedStack
│ │ builder: AppNavigationShell
│ │
│ ├── Branch 0 (homeNavigatorKey)
│ │ └── /home FeedScreen (protected)
│ │
│ ├── Branch 1 (discoverNavigatorKey)
│ │ └── /discover DiscoveryScreen (public)
│ │
│ ├── Branch 2 (heartNavigatorKey)
│ │ └── /heart HeartScreen (protected)
│ │
│ └── Branch 3 (profileNavigatorKey)
│ └── /profile ProfileScreen (protected)
│
├── /write WriterScreen (protected, pushed)
├── /poem/:id ReaderScreen (public, pushed)
├── /profile/:username AuthorProfileScreen (public, pushed)
└── /notifications InboxScreen (protected, pushed)
```

## Shell Composition

### AppNavigationShell (`core/navigation/presentation/app_navigation_shell.dart`)

- Receives `StatefulNavigationShell` from GoRouter
- Uses `LayoutBuilder` for responsive breakpoint (600px)
- Mobile: `Scaffold` with `_BottomNav`
- Desktop: `Scaffold` with `_NavRail` + `VerticalDivider`

### Branch Mapping (4 branches, 5 visual items)

| Visual Index | Label | Action | Branch Index |
|---|---|---|---|
| 0 | Home | `goBranch(0)` | 0 |
| 1 | Discover | `goBranch(1)` | 1 |
| 2 | Write | `context.push('/write')` | — (pushed) |
| 3 | My Heart | `goBranch(2)` | 2 |
| 4 | Profile | `goBranch(3)` | 3 |

### Why Write Is Not a Shell Branch

1. WriterScreen uses `PopScope` with draft-discard confirmation
2. WriterScreen calls `context.pop()` after successful publish
3. A shell branch would preserve stale editor state across tab switches
4. Write replaces the existing FAB behaviour (`context.push`)
5. The bottom nav shows 5 items; Write pushes on top of the shell

## Responsive Strategy

| Viewport | Treatment | Breakpoint |
|---|---|---|
| < 600px | Bottom navigation bar | — |
| >= 600px | Navigation rail (left side) | Matches SyaahiBrandMark |

Both use the same destinations, same route semantics, same `goBranch`/`push` logic.

## State Ownership

- **Navigation state**: GoRouter `StatefulNavigationShell.currentIndex` — no independent tab index
- **Tab stacks**: `IndexedStack` preserves each branch's widget tree
- **Auth state**: `authProvider` (Riverpod) — unchanged
- **Feed state**: `feedProvider` — unchanged, preserved by IndexedStack

## Auth Guard

Unchanged from pre-UX-08 implementation:
- Public: `/`, `/welcome`, `/auth/*`, `/poem/:id`, `/profile/:username`, `/discover`
- Protected: `/home`, `/write`, `/heart`, `/profile`, `/notifications`
- `state.matchedLocation` correctly returns child paths inside the shell
