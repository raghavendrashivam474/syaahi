# UX-03 Completion Report

**Sprint:** UX-03 — Navigation & Empty States
**Baseline:** v-UX-02 (d44ea46)
**Branch:** ux-03/navigation-and-empty-states
**Date:** 2026-11-06

---

## Sprint Objective

Deliver a consistent and predictable navigation experience across Syaahi,
accompanied by meaningful empty, loading, and error-recovery states.

## Original Problems Identified

| # | Issue | Severity |
|---|-------|----------|
| 1 | No authentication guard — unauthenticated deep links reach protected screens | HIGH |
| 2 | No error builder — unknown routes show GoRouter's default ugly page | HIGH |
| 3 | Reader error leaks raw exceptions, no retry, no 404 distinction | MEDIUM |
| 4 | Writer discards unsaved drafts on back without warning | MEDIUM |
| 5 | Feed filter empty state misleading ("Write your first poem" when filters match nothing) | LOW |
| 6 | Deep-link back navigation — context.pop() fails when screen is root of stack | LOW |

## Features Implemented

### 1. Router Auth Guard (pp_router.dart)
- Added edirect callback to GoRouter.
- Protected routes: /home, /write, /heart, /profile, /notifications.
- Public routes: /, /welcome, /auth/*, /poem/*, /profile/:username.
- Unauthenticated → redirected to /welcome.
- Authenticated on auth screens → redirected to /home.

### 2. Branded 404 Error Builder (pp_router.dart)
- Added errorBuilder to GoRouter.
- _NotFoundScreen matches Syaahi's dark theme + gold accents.
- Shows attempted path and "Go to Feed" button.

### 3. Reader Error State (eader_screen.dart)
- Replaced raw exception dump with _ReaderErrorView.
- 404 detection via PoemsException.statusCode == 404 → "Poem not found."
- Network/other errors → "Could not load this poem" + "Try Again" retry button.
- Retry calls ef.invalidate(poemByIdProvider(poemId)).

### 4. Writer Draft Guard (writer_screen.dart)
- Wrapped Scaffold in PopScope.
- canPop returns false when any text field has content.
- onPopInvokedWithResult shows "Discard draft?" confirmation dialog.
- _dismissed flag ensures successful publish still pops cleanly.
- AppBar close button routes through same draft check.

### 5. Feed Filter Empty State (eed_screen.dart)
- _EmptyFeed now accepts hasActiveFilters and onClearFilters.
- When filters active + zero results: "No poems match your filters" + "Clear Filters" CTA.
- When no filters + zero results: original "Write Your First Poem" preserved.

### 6. Safe Back Navigation (5 screens)
- ProfileScreen, AuthorProfileScreen, HeartScreen, InboxScreen, ReaderScreen.
- AppBar back: canPop() ? pop() : go('/home').
- Prevents dead-end when screens are opened via deep link.

## Screens Affected

| Screen | Changes |
|--------|---------|
| Feed (/home) | Filter-aware empty state |
| Reader (/poem/:id) | Error state + safe back |
| Writer (/write) | Draft guard |
| Own Profile (/profile) | Safe back |
| Author Profile (/profile/:username) | Safe back |
| Heart (/heart) | Safe back |
| Notifications (/notifications) | Safe back |
| All routes | Auth guard + 404 error builder |

## Files Modified

| File | Change Type |
|------|-------------|
| core/router/app_router.dart | Modified — added redirect, errorBuilder, _NotFoundScreen |
| eatures/poems/presentation/reader_screen.dart | Modified — _ReaderErrorView, PoemsException import |
| eatures/poems/presentation/writer_screen.dart | Modified — PopScope, _confirmDiscard, _dismissed flag |
| eatures/poems/presentation/feed_screen.dart | Modified — filter-aware _EmptyFeed |
| eatures/profile/profile_screen.dart | Modified — safe back |
| eatures/profile/presentation/author_profile_screen.dart | Modified — safe back |
| eatures/poems/presentation/heart_screen.dart | Modified — safe back |
| eatures/notifications/presentation/inbox_screen.dart | Modified — safe back |

## Files Added

| File | Purpose |
|------|---------|
| docs/phase_ux/sprintUX3/UX-03-reconnaissance.md | Navigation audit |
| docs/phase_ux/sprintUX3/UX-03-implementation-plan.md | Implementation sequence |
| docs/phase_ux/sprintUX3/UX-03-completion-report.md | This file |

## Files Deleted

None.

## Architectural Changes

None. All changes are within existing architectural boundaries.
No ADR required.

## Existing Functionality Preserved

| Feature | Status |
|---------|--------|
| UX-01 Heart interaction | ✅ Preserved |
| Feed card navigation | ✅ Preserved |
| Author navigation from feed | ✅ Preserved (UX-02) |
| Author navigation from reader | ✅ Preserved (UX-02) |
| Public profiles /profile/:username | ✅ Preserved |
| Own profile /profile | ✅ Preserved |
| Profile pagination | ✅ Preserved |
| Own-profile deletion | ✅ Preserved |
| Notifications inbox | ✅ Preserved |
| Authentication flow | ✅ Preserved + strengthened |
| Publishing flow | ✅ Preserved + strengthened |

## Test Results

- lutter analyze lib/ — **No issues found**
- lutter test — exit code: 0

## Known Limitations

- Auth redirect relies on uthProvider being initialized synchronously.
  If the splash screen has a delay before auth state is available, there may
  be a brief flash of /welcome before redirecting to /home. This is
  acceptable for the current architecture but could be refined with a
  dedicated "checking auth" state in a future sprint.
- The PopScope draft guard checks text field content but not
  emotion/language/theme chip selections (which have defaults). This is
  intentional — selecting an emotion without writing content is not
  considered a meaningful draft.

## Deferred Work

- HomeScreen (eatures/home/home_screen.dart) is dead code.
  Consider removing in a future cleanup sprint.
- No search/filter feature exists, so search empty states were not applicable.
- Notification deep-link destinations are limited to /poem/:id.
  If notification types expand, the navigation contract should be revisited.

## Git History

To be recorded after merge.

## Release Tag

v-UX-03 (to be created after merge approval)
