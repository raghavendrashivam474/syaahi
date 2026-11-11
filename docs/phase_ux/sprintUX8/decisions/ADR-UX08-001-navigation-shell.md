# ADR-UX08-001: Navigation Shell Architecture

## Status

Accepted

## Context

Syaahi's router consisted of 12 flat `GoRoute` entries with no shared navigation shell. Each screen managed its own AppBar and navigation actions. The FeedScreen accumulated 7 AppBar actions plus a FAB, creating a crowded interface on mobile.

There was no persistent navigation mechanism (no bottom bar, no rail). Users could only reach destinations through AppBar icons or the FAB, making the information architecture unclear.

## Decision

Introduce a `StatefulShellRoute.indexedStack` wrapping four primary destinations (Home, Discover, Heart, Profile) with a shared `AppNavigationShell` widget providing:

- Mobile: 5-item bottom navigation bar
- Desktop: Navigation rail

Write is deliberately excluded from the shell branches and remains a pushed route.

## Alternatives Considered

### 1. Five shell branches (including Write)
**Rejected.** WriterScreen uses `PopScope` with draft-discard confirmation and calls `context.pop()` after publish. A shell branch would preserve stale editor state and conflict with the pop-based workflow.

### 2. Simple `ShellRoute` (non-stateful)
**Rejected.** Would lose tab state on switching (e.g., Feed scroll position, filter state). `StatefulShellRoute.indexedStack` preserves each branch via `IndexedStack`.

### 3. Custom tab controller with manual state
**Rejected.** Duplicates GoRouter's built-in capability. Would create an independent selected-tab index that could desynchronise from the actual route.

### 4. No shell, just add a bottom nav widget to each screen
**Rejected.** Would require modifying every screen, duplicating navigation logic, and manually synchronising selected states.

## Consequences

### Positive
- Predictable navigation architecture for future features
- Tab state preserved across switches
- Route-aware selected state (no independent index)
- Responsive behaviour with single code path
- Cleaner Feed AppBar

### Negative
- Slightly more complex router configuration
- Shell children must not use back buttons (handled by shell navigation)
- Pushed routes need `parentNavigatorKey: _rootNavigatorKey`

### Risks Mitigated
- Auth guard: `state.matchedLocation` returns child paths correctly inside shell
- Guest access: `/discover` remains public, auth redirect unchanged
- Deep links: GoRouter handles natively with StatefulShellRoute
- WriterScreen: unchanged, pushed on top of shell via root navigator
