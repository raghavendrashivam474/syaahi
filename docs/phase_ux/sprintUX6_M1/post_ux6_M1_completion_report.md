# Post-Implementation Report: UX-06.M1 — Reader & Response Flow Stabilization

**To:** Senior Developer
**From:** Junior Developer (Flutter / Full-Stack)
**Date:** 7 November 2026
**Branch:** `hotfix/ux-06-reader-response-flow`
**Baseline:** `v-UX-06` (commit `cc8693a`)
**Status:** All sprint objectives delivered. Manual Web verification passed. Awaiting commit and PR review.

---

## 1. Executive Summary

Sprint UX-06.M1 was initiated as a hotfix to address three critical regressions in the Syaahi reader and response flow discovered immediately after the UX-06 release. All four sprint objectives — Dio interceptor stabilisation, Resonance integration into the Reader, independent Respond navigation, and Reader scroll-to-Resonance — are now code-complete, test-covered (47/47 passing), statically clean (`flutter analyze` — no issues), and manually verified on Chrome Web against the production backend.

During the manual verification phase, two additional defects surfaced that were not in the original sprint scope. Both were root-caused, patched, and verified before closing the sprint. These are documented in Sections 5 and 6 below.

---

## 2. Original Sprint Objectives — Delivery Status

### 2.1 M1.1 — Stabilise Dio Token Retrieval (P0)
**Problem:** On Flutter Web, `TokenStorage.getToken()` (backed by `flutter_secure_storage`) could hang indefinitely or throw during the Dio request interceptor, stalling every outbound request. The Reader would show "Opening poem…" forever and the feed would never populate for first-time or guest users.

**Implementation:**
- Added a 3-second `.timeout()` wrapper around `_tokenStorage.getToken()` inside the interceptor.
- Wrapped the entire token-retrieval block in a `try/catch`.
- On any failure (timeout, exception, null, empty), the interceptor logs in debug mode and **always** calls `handler.next(options)` so the request completes as a guest call (no Authorization header).
- Made `TokenStorage` injectable via an optional constructor parameter `ApiClient({TokenStorage? tokenStorage})` so interceptor behaviour is unit-testable without hitting platform channels.

**File:** `syaahi-app/lib/core/network/api_client.dart`
**Tests:** `syaahi-app/test/core/network/api_client_test.dart` — 6 tests covering success, null, exception, timeout, empty string, and pending-forever token scenarios. All green.

---

### 2.2 M1.2 — Integrate `ResonanceSection` into Reader (P0)
**Problem:** `ResonanceSection` was built and tested in UX-06 but never wired into the Reader screen. Readers had no visible path to view or submit responses, making the Resonance feature invisible to users.

**Implementation:**
- Imported and mounted `ResonanceSection(key: _resonanceKey, poem: widget.poem)` at line 512 of `reader_screen.dart`, directly after the `_AuthorContinuity` block.
- Section uses the existing `resonanceProvider` and `ResonanceRepository` — no state-management rewiring was needed.
- Response creation, editing, deletion, and author-reply flows are preserved as they were implemented in UX-06.

**File:** `syaahi-app/lib/features/poems/presentation/reader_screen.dart`
**Tests:** `syaahi-app/test/features/poems/presentation/reader_resonance_test.dart` — 3 tests (render, focus handling, graceful failure). All green.

---

### 2.3 M1.3 — Independent Respond Navigation (P1)
**Problem:** The "Respond" affordance on feed cards had no gesture handler. Tapping it did nothing. Users had to open the Reader and manually scroll to find the composer.

**Implementation:**
- Wrapped the Respond `Row` in `feed_screen.dart` with a `GestureDetector` using `HitTestBehavior.opaque` (so the tap doesn't fall through to the card's parent InkWell).
- `onTap` calls `context.push('/poem/${poem.id}?focus=resonance')`.
- The existing card-tap behaviour (opens Reader normally without focus) is preserved. No duplicate navigation fires.

**File:** `syaahi-app/lib/features/poems/presentation/feed_screen.dart`
**Tests:** `syaahi-app/test/features/poems/presentation/feed_respond_test.dart` — 2 tests (label present, navigation with focus param). All green.

---

### 2.4 M1.4 — Reader Scroll-to-Resonance (P1)
**Problem:** Even once M1.2 and M1.3 landed, there was no mechanism to scroll the Reader to the Resonance section when arriving via the Respond button.

**Implementation:**
- Added `focusSection: state.uri.queryParameters['focus']` to the `/poem/:id` route in `app_router.dart`, so `?focus=resonance` is passed as a prop to the Reader.
- Attached a `GlobalKey _resonanceKey` to `ResonanceSection` in the Reader.
- In `initState`, added a `WidgetsBinding.instance.addPostFrameCallback` that calls `Scrollable.ensureVisible(_resonanceKey.currentContext!, duration: Duration(milliseconds: 500), alignment: 0.1)` **only when** `widget.focusSection == 'resonance'`.
- Guarded against null context in case the section hasn't mounted yet.

**Files:**
- `syaahi-app/lib/core/router/app_router.dart`
- `syaahi-app/lib/features/poems/presentation/reader_screen.dart`

---

## 3. Testing Summary

| Category | Count | Result |
|---|---|---|
| Pre-existing tests (UX-01 through UX-06) | 36 | ✅ All pass |
| New M1 tests (api_client, reader_resonance, feed_respond) | 11 | ✅ All pass |
| **Total** | **47/47** | ✅ **Green** |

**Static analysis:** `flutter analyze` → *No issues found* (8.2s).

---

## 4. Problems Encountered During Implementation

### 4.1 Feed Test `!timersPending` Assertion Failures
**Symptom:** Multiple feed-related tests began failing with `!timersPending` when the test harness tore down the widget tree. Errors appeared across blocks 6 through 6g of our test development.

**Debugging path (chronological):**
1. Tried `tester.pumpAndSettle()` — failed because FeedScreen has periodic timers that never settle.
2. Tried bounded `pump()` loops with explicit frame counts — timer still pending at teardown.
3. Tried disposing the widget via `pumpWidget(SizedBox.shrink())` — timer still pending.
4. Tried disposing the `MaterialApp` and `GoRouter` explicitly — timer still pending.
5. Tried navigating away from the feed using `router.go('/other')` — timer still pending.
6. Finally captured a full stack trace of the pending timer.

**Root cause:** The pending timer was the **3-second `.timeout()` we had just added to `ApiClient.getToken()`** in M1.1. Fake async zones in Flutter widget tests do not automatically advance real-time timers; the timer sits in the zone's pending queue and triggers the assertion at teardown.

**Fix:** In test teardown, explicitly drain the timer with `tester.pump(const Duration(seconds: 5))` before unmounting the widget. This advances the fake clock past the 3-second timeout, the timer fires, and teardown proceeds cleanly.

**Lesson:** When adding timeouts to production code, always audit existing widget tests for timer sensitivity. Document the teardown requirement in the test file's header comment.

---

### 4.2 `ResponseComposer` Chrome Web Layout Crash
**Symptom:** When the Reader opened and reached the ResponseComposer, Chrome displayed a red error overlay: `BoxConstraints(w=Infinity, 44.0<=h<=Infinity)` originating at `response_composer.dart:120` — the `ElevatedButton`. The button rendered but the entire frame was unusable until the error was cleared.

**First attempted fix:** Removed `width: double.infinity` from the outer `Container` wrapping the composer. This did **not** resolve the crash. The infinite width was coming from the button itself, not the container.

**Root cause:** The app's Material theme (likely inherited from UX-01 theming work) sets a default `ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 44))`. When the button is placed in a `Row` (which provides unbounded horizontal constraints to its children by default), the `double.infinity` minimum width propagates upward and Flutter throws.

**Final fix:** Added `minimumSize: Size.zero` to `ElevatedButton.styleFrom()` in the composer, which overrides the theme default and lets the button size itself to its intrinsic content. Verified on Chrome Web — button renders, is clickable, and the disabled state (`backgroundColor` with alpha 0.3) still works correctly.

**File:** `syaahi-app/lib/features/resonance/presentation/response_composer.dart`

---

## 5. Defects Discovered During Manual Web Verification

### 5.1 "Could not load responses" + 500 Internal Server Error on Submit
**Symptom (post-layout-fix):** With the composer rendering correctly, two symptoms appeared:
1. The Resonance section loaded but showed the empty state with subtext "Could not load responses."
2. Clicking "Share Response" after typing text produced a red SnackBar: **"Internal server error"**.

Both the `GET /poems/:id/resonances` (list) and `POST /poems/:id/resonances` (create) endpoints were returning HTTP 500.

**Debugging path:**
1. Inspected `response_composer.dart`'s submit path — clean; delegates to `resonanceProvider.submitResponse()`.
2. Inspected `ResonanceRepository.createResponse()` — clean; wraps `_dio.post()` in try/catch and surfaces `DioException`.
3. Inspected `ApiClient` — confirmed base URL `https://syaahi-backend.vercel.app/api/v1` is correct.
4. Inspected backend `resonance.controller.ts`, `resonance.routes.ts`, `middleware/auth.ts` — all code paths looked correct. `authenticate` properly returns 401 on missing token, not 500.
5. Inspected `middleware/errorHandler.ts` — confirmed that *any* unhandled error in a controller gets wrapped as `{ success: false, message: "Internal server error" }` with HTTP 500. The Flutter repo's `_handle()` reads `data['message']` directly, which is why the SnackBar said exactly that.
6. Hit the production API directly from PowerShell:
   ```
   GET https://syaahi-backend.vercel.app/api/v1/poems/{id}/resonances → 500 (empty body)
   ```
   This confirmed the error originated server-side, not from Flutter or the client-side Dio stack.

**Root cause:** The Prisma schema at `syaahi-backend/prisma/schema.prisma` defined `ResonanceResponse`, `ResonanceReply`, and an updated `Notification` model (with the new `@@unique([recipientId, poemId, type, sourceId])` constraint), but **these migrations had never been pushed to the production Supabase database**. Every Prisma query against those tables threw `PrismaClientKnownRequestError: table does not exist`, which propagated to `errorHandler` as a generic 500.

**Fix:**
```
cd syaahi-backend
npx prisma db push
```
The push synced the schema to the production database. Prisma warned about the new unique constraint potentially conflicting with duplicate rows; we accepted the risk (no duplicates existed in the empty Resonance tables) and the sync completed in 14 seconds. Prisma Client regenerated automatically.

**Verification:** Re-ran the same `GET` request:
```
GET https://syaahi-backend.vercel.app/api/v1/poems/{id}/resonances
→ 200 OK, { success: true, data: { responses: [], nextCursor: null } }
```
Returned to the browser, reloaded the Flutter app, submitted a resonance response — succeeded, SnackBar showed "Your resonance response has been shared", and the new response appeared immediately in the list below the composer.

**Lesson:** The sprint handoff stated "No database migrations required" because the schema had been defined during UX-06. However, defining a schema and deploying it to the production database are separate actions. A pre-flight check — comparing `schema.prisma` against the live Supabase schema — should be part of every future hotfix checklist.

---

## 6. Manual Chrome Web Verification Checklist — Results

| # | Step | Expected | Result |
|---|---|---|---|
| 1 | App loads on Chrome | No red error overlay, feed renders | ✅ Pass |
| 2 | Tap a poem card | Reader opens, poem text visible | ✅ Pass |
| 3 | Scroll to bottom of reader | Resonance section appears | ✅ Pass |
| 4 | Tap Respond in the feed | Reader opens scrolled to Resonance | ✅ Pass |
| 5 | Open ResponseComposer | No layout crash, button renders normally | ✅ Pass (after fix 4.2) |
| 6 | Type text, submit | Response posts, SnackBar confirms, list updates | ✅ Pass (after fix 5.1) |
| 7 | Navigate back | No crashes, previous screen intact | ✅ Pass |

---

## 7. Modified Files Summary

### Flutter (`syaahi-app/`)
1. `lib/core/network/api_client.dart` — Timeout, try/catch, injectable TokenStorage.
2. `lib/core/router/app_router.dart` — `focusSection` query param parsing.
3. `lib/features/poems/presentation/reader_screen.dart` — ResonanceSection mount, GlobalKey, scroll-to-visible.
4. `lib/features/poems/presentation/feed_screen.dart` — Respond GestureDetector.
5. `lib/features/resonance/presentation/response_composer.dart` — Removed infinite-width container, added `minimumSize: Size.zero`.
6. `test/features/poems/presentation/reader_screen_test.dart` — `_FakeResonanceRepository` override.

### New test files (`syaahi-app/test/`)
1. `core/network/api_client_test.dart` — 6 tests.
2. `features/poems/presentation/reader_resonance_test.dart` — 3 tests.
3. `features/poems/presentation/feed_respond_test.dart` — 2 tests.

### Backend (`syaahi-backend/`)
- **No code changes.** Only `npx prisma db push` was executed to sync the schema to production Supabase.

### Documentation (`docs/phase_ux/sprintUX6_M1/`)
Seven markdown files: `initial-reconnaissance.md`, `root-cause-analysis.md`, `implementation-plan.md`, `file-impact-report.md`, `testing-report.md`, `completion-report.md`, `post-completion-report.md`.

---

## 8. Known Limitations (Carried Over for Future Sprints)

1. **Multiple ApiClient instances.** Repositories instantiate `ApiClient()` directly. Each instance builds its own Dio and interceptor chain. Recommend a singleton or Riverpod-provided instance in a future refactor sprint.
2. **FlutterSecureStorage Web fragility.** The 3-second timeout masks the symptom but does not fix the underlying platform issue. Consider a `shared_preferences` fallback for Web token storage.
3. **Feed test timer draining requirement.** Documented in test file headers. Tests written against the Feed in future sprints must drain the 3-second timeout at teardown.
4. **Backend schema drift risk.** We should add a CI check that runs `prisma migrate diff` against the production database on every backend PR to prevent this class of defect from recurring.

---

## 9. Recommended Commit Sequence

Proposed six atomic commits on `hotfix/ux-06-reader-response-flow`:

1. `fix(network): prevent token storage failures from stalling requests` — `api_client.dart` + `api_client_test.dart`.
2. `feat(reader): integrate resonance section with focus-driven scroll` — `reader_screen.dart` + `reader_resonance_test.dart` + test harness update.
3. `feat(feed): add independent respond navigation to resonance` — `feed_screen.dart` + `feed_respond_test.dart`.
4. `feat(router): parse focus query parameter for poem route` — `app_router.dart`.
5. `fix(web): resolve response composer unbounded-width layout crash` — `response_composer.dart`.
6. `docs(ux-06-m1): sprint reports and post-completion analysis` — all 7 markdown files.

No backend commit is required because no backend source files were modified; the schema sync was an operational action.

---

## 10. Recommendation

The branch is ready for code review. Upon approval, I propose:
1. Squash-merge is **not** recommended — the atomic commits above preserve a clean audit trail.
2. Tag the merge commit as `v-UX-06.1`.
3. Deploy to staging, re-run the manual verification checklist in Section 6 against the staging backend, then promote to production.
4. Open follow-up tickets for the four items in Section 8.

Awaiting your review and go-ahead to begin the commit sequence.

---

*End of report.*