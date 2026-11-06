# UX-03 Navigation Reconnaissance Report

**Date:** 2026-11-06
**Baseline:** v-UX-02 (d44ea46)
**Branch:** ux-03/navigation-and-empty-states

---

## 1. Current Navigation Architecture

- **Router:** go_router (flat GoRoute list, no ShellRoute)
- **State management:** Riverpod (StateNotifier + FutureProvider)
- **Navigation shell:** None. FeedScreen at /home is the de facto home screen.
  AppBar icons provide access to Heart, Profile, Notifications. FAB opens Writer.
- **Dead code:** HomeScreen (eatures/home/home_screen.dart) is never routed.
  /home maps to FeedScreen.

## 2. Route Inventory

| Route | Screen | Auth Required | Notes |
|-------|--------|---------------|-------|
| / | SplashScreen | No | Entry point |
| /welcome | WelcomeScreen | No | Landing |
| /auth/signup | SignupScreen | No | |
| /auth/login | LoginScreen | No | |
| /home | FeedScreen | **Yes** | De facto home |
| /write | WriterScreen | **Yes** | |
| /poem/:id | ReaderScreen | No | Public content |
| /heart | HeartScreen | **Yes** | |
| /profile | ProfileScreen | **Yes** | Own profile |
| /profile/:username | AuthorProfileScreen | No | Public profile |
| /notifications | InboxScreen | **Yes** | |

## 3. Main User Journey Flows

### Journey A — Feed → Reader → Back
/home → tap poem card → context.push('/poem/:id') → context.pop() → feed preserved ✅

### Journey B — Feed → Author Profile → Back
/home → tap author avatar/name on card → context.push('/profile/:username') → context.pop() ✅
UX-02 gesture isolation preserved ✅

### Journey C — Reader → Author Profile → Back
/poem/:id → tap byline or attribution → context.push('/profile/:username') → context.pop() ✅

### Journey D — Heart → Reader → Back
/heart → tap card → context.push('/poem/:id') → context.pop() ✅

### Journey E — Profile Navigation
/profile reads uthProvider, delegates to AuthorProfileView(isOwnProfile: true) ✅
/profile/:username delegates to AuthorProfileView ✅
Distinction preserved ✅

### Journey F — Notifications → Reader
/notifications → tap notification → context.push('/poem/:id') ✅

## 4. Existing Empty-State Inventory

| Screen | Empty State | Quality | Notes |
|--------|-------------|---------|-------|
| Feed | _EmptyFeed | ✅ Good | Icon + heading + "Write Your First Poem" CTA |
| Feed (filtered) | _EmptyFeed | ⚠️ Misleading | Same "Be the first to write" message when filters return zero |
| Heart | Inline in _buildBody | ✅ Good | "Your heart is empty" + "Explore Poems" CTA |
| Own Profile | _EmptyPoemsView(isOwnProfile: true) | ✅ Good | "Write your first poem" CTA |
| Public Profile | _EmptyPoemsView(isOwnProfile: false) | ✅ Good | "No published poems yet" |
| Public Profile 404 | _NotFoundView | ✅ Good | "This writer could not be found" |
| Notifications | _EmptyInbox | ✅ Good | "All quiet" + explanation |

## 5. Existing Loading-State Inventory

| Screen | Initial Load | Pagination | Refresh | Quality |
|--------|-------------|------------|---------|---------|
| Feed | ✅ Spinner | ✅ Inline spinner | ✅ RefreshIndicator | Good |
| Reader | ✅ Spinner | N/A | N/A | Good |
| Heart | ✅ Spinner | ✅ Inline spinner | ✅ RefreshIndicator | Good |
| Profile | ✅ Spinner | ✅ Inline spinner | ✅ RefreshIndicator | Good |
| Notifications | ✅ Spinner | ✅ Inline spinner | ✅ RefreshIndicator | Good |

## 6. Existing Error-State Inventory

| Screen | Error View | Retry | Quality | Notes |
|--------|-----------|-------|---------|-------|
| Feed | _ErrorView | ✅ | Good | |
| Reader | Inline text | ❌ | ⚠️ Poor | Leaks raw exception: 'Could not load poem.\n' |
| Reader 404 | Same as above | ❌ | ⚠️ Poor | No distinction from network error |
| Heart | Inline in _buildBody | ✅ | Good | |
| Profile | _ErrorView | ✅ | Good | |
| Profile 404 | _NotFoundView | N/A | Good | Checks PoemsException.statusCode == 404 |
| Notifications | _ErrorView | ✅ | Good | |
| Writer | Inline banner | N/A | Good | Shows publish error in-place |

## 7. Identified Issues

### Issue 1 — No Authentication Guard (HIGH)
- **Screen/Route:** All authenticated routes
- **Existing behaviour:** No edirect callback on GoRouter. Unauthenticated users can navigate to /home, /write, /heart, /profile, /notifications via deep link or URL manipulation.
- **Problem:** Screens may crash or show confusing empty states when uthProvider.user is null.
- **Expected:** Unauthenticated access to protected routes redirects to /welcome.
- **Solution:** Add edirect callback to GoRouter checking uthProvider.
- **Files:** core/router/app_router.dart, possibly main.dart

### Issue 2 — No Error Builder for Unknown Routes (HIGH)
- **Screen/Route:** Any invalid URL
- **Existing behaviour:** GoRouter shows its default error page (ugly, breaks brand).
- **Problem:** Typos, stale deep links, or deleted content produce a jarring experience.
- **Expected:** A branded "Page not found" screen with a way back to Feed.
- **Solution:** Add errorBuilder to GoRouter.
- **Files:** core/router/app_router.dart

### Issue 3 — Reader Error Leaks Raw Exceptions (MEDIUM)
- **Screen/Route:** /poem/:id
- **Existing behaviour:** error: (e, _) => Text('Could not load poem.\n') — dumps the exception object to the user. No retry button. No 404 distinction.
- **Problem:** Ugly, unhelpful, potential information leak.
- **Expected:** User-friendly message, retry button, 404 not-found state (like profiles do).
- **Solution:** Replace inline error with structured error view. Check for 404 PoemsException.
- **Files:** eatures/poems/presentation/reader_screen.dart

### Issue 4 — Writer Discards Unsaved Draft on Back (MEDIUM)
- **Screen/Route:** /write
- **Existing behaviour:** Back button calls context.pop() unconditionally.
- **Problem:** User loses unsaved poem content without warning.
- **Expected:** If any field has content, show a confirmation dialog before discarding.
- **Solution:** Wrap with PopScope (Flutter 3.12+) checking for unsaved content.
- **Files:** eatures/poems/presentation/writer_screen.dart

### Issue 5 — Feed Filter Empty State Misleading (LOW)
- **Screen/Route:** /home with active filters
- **Existing behaviour:** When filters return zero results, shows "Be the first to write something beautiful."
- **Problem:** The feed isn't empty — the filter just matched nothing. The CTA to write is irrelevant.
- **Expected:** "No poems match your filters" with a "Clear filters" action.
- **Solution:** Pass filter state to empty view, show different message when filters are active.
- **Files:** eatures/poems/presentation/feed_screen.dart

### Issue 6 — Deep-Link Back Navigation (LOW)
- **Screen/Route:** Any screen opened via deep link
- **Existing behaviour:** All screens use context.pop() for back. If the screen was the first in the stack (deep link), pop() does nothing or closes the app.
- **Problem:** User is stuck or app closes unexpectedly.
- **Expected:** If canPop() is false, navigate to /home instead.
- **Solution:** Create a small helper or use context.canPop() ? context.pop() : context.go('/home').
- **Files:** Multiple screens (profile, heart, notifications, reader)

## 8. Potential Regressions & Risks

| Risk | Mitigation |
|------|-----------|
| Auth redirect could create redirect loops | Check state.matchedLocation to avoid redirecting from /welcome or /auth/* |
| PopScope on Writer could interfere with publish flow | Only guard when isPublishing is false and fields are non-empty |
| Router redirect interacts with splash screen timing | Ensure uthProvider is initialized before redirect fires |
| Error builder could mask real routing bugs | Keep error view informative with the attempted path |

## 9. What Does NOT Need Changing

- Feed loading/pagination/refresh — already correct
- Heart loading/pagination/empty/error — already correct
- Profile loading/pagination/empty/error/404 — already correct (UX-02 work is solid)
- Notifications loading/pagination/empty/error — already correct
- Author navigation from feed and reader — already correct (UX-02)
- Heart interaction — already correct (UX-01)
- Poem deletion flow — already correct
- All existing provider contracts — no changes needed
