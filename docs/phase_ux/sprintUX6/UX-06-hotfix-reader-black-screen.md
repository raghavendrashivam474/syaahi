# UX-06 Hotfix Report: Reader Screen Black Screen Bug

**Date:** 2026-11-07  
**Sprint:** UX-06 (Meaningful Interaction & Resonance)  
**Severity:** High (P1) — Reader screen inaccessible on production build  
**Status:** Resolved  
**Affected Routes:** `/poem/:id` (Reader Screen with Resonance Section)  
**Related Commits:** Hotfix following `v-UX-06` release tag.

---

## 1. Symptom

After the UX-06 release was deployed and installed on an Android device, tapping **"Respond"** (or any poem card) in the Feed Screen navigated to `/poem/:id`, but the Reader Screen rendered only:

- A pitch-black `Scaffold` body (midnight dark background color).
- The top-left back-arrow (`Icons.arrow_back`) was the only visible UI element.
- No poem title, no poem content, no error message, no loading indicator.

Visual evidence captured on device: user screenshot at `3:52 PM, 44% battery, Android device`.

The Feed Screen itself rendered correctly. Static analysis (`flutter analyze`) reported **0 issues**, and automated tests (`flutter test`) passed **36/36** before the issue surfaced. This confirmed the bug was a **runtime-only failure** not caught by widget tests that use mocked providers.

---

## 2. Investigation Timeline

### Attempt 1 — Suspected Layout Overflow
**Hypothesis:** `ResonanceSection` embedded inside a `SingleChildScrollView` + `Column` was causing a layout overflow or unbounded-height constraint, collapsing the entire render tree.

**Action taken:**
- Inspected `reader_screen.dart` to confirm `ResonanceSection(poem: widget.poem)` was placed inside a bounded `ConstrainedBox(maxWidth: 680)` within the scroll view.
- Verified `ResonanceSection` itself used `ListView.builder` with `shrinkWrap: true` and `physics: NeverScrollableScrollPhysics()` — correct for nested scrolling.

**Result:** Did NOT work. Layout constraints were valid. No overflow banner would have been hidden by a black screen anyway — Flutter overflow errors render yellow-and-black stripes, not a solid black screen.

**Why it failed:** Misdiagnosis. The symptom (solid black, no error overlay) is inconsistent with a layout overflow.

---

### Attempt 2 — Suspected Routing Mismatch
**Hypothesis:** The Feed Screen was navigating to `/poems/:id` (plural) while the router defined `/poem/:id` (singular), causing the 404 branded screen to render incorrectly on dark theme.

**Action taken:**
- Searched `feed_screen.dart` for `context.push` calls.
- Confirmed the card's `InkWell.onTap` used `context.push('/poem/${poem.id}')`.
- Verified `app_router.dart` at `syaahi-app/lib/core/router/app_router.dart` defined `GoRoute(path: '/poem/:id', ...)`.

**Result:** Did NOT work. Routes matched exactly. The `_NotFoundScreen` was NOT being triggered — if it were, the user would have seen "This page doesn't exist" text.

**Why it failed:** Routing was correct. Navigation reached `ReaderScreen` successfully; the failure was *inside* the Reader's render pipeline.

---

### Attempt 3 — Suspected Missing Visible Error Handler
**Hypothesis:** The `AsyncError` branch of `poemByIdProvider` was rendering text in a color indistinguishable from the dark background, giving the illusion of a black screen.

**Action taken:**
- Reviewed `_ReaderErrorView` — confirmed it rendered an icon (`Icons.cloud_off_outlined`, `SyaahiColors.textFaded`), a title (`SyaahiColors.textPrimary`), and a body message (`SyaahiColors.textMuted`), all clearly visible against `SyaahiColors.midnightDark`.

**Result:** Did NOT work. Error view was properly styled. If `poemByIdProvider` had errored, the error view would have appeared.

**Why it failed:** `poemByIdProvider` was NOT the failing provider. The poem was fetched successfully; the crash happened downstream, inside `_ReaderView`.

---

### Attempt 4 — Suspected `_loadInitialState()` Unhandled Exception
**Hypothesis:** The `Future.wait([repo.getHeartStatus, repo.getReactions])` inside `_ReaderViewState.initState()` was throwing an uncaught exception, breaking the state and leaving the widget in an unrecoverable render state.

**Action taken:**
- Wrapped `ref.read(feedProvider).heartStates[widget.poem.id]` in a `try/catch` inside `initState`.
- Confirmed the existing `_loadInitialState` already had a top-level `try/catch` — any failure already defaulted `_reactionsLoading = false`.

**Result:** Did NOT work by itself. The guard was defensive but not the root cause. However, this guard was retained as a safety net.

**Why it partially contributed:** It hardened the widget against transient `feedProvider` races on cold-start but was not the primary fault.

---

### Attempt 5 — Root Cause Identified: `ResonanceNotifier.load()` Narrow Catch

**Hypothesis:** `ResonanceNotifier.load()` in `resonance_providers.dart` only caught `ResonanceException`. Any OTHER exception (e.g., `DioException` on timeout, `TypeError` on JSON parse, `SocketException` on no-network, `FormatException` on bad response body) would propagate as an uncaught async error.

In Riverpod, when a `StateNotifier` throws during construction or a `ref.watch()` dependency throws during an async rebuild, the parent widget (`ResonanceSection`) silently fails to render. Because it is a child of `_ReaderView`'s `Column`, the entire `Column`'s build pipeline is invalidated. On debug builds this surfaces as a red error widget; on **release builds (production AAB/APK), Flutter renders nothing**, producing the solid-black Scaffold body observed.

#### Action Taken
Modified `syaahi-app/lib/features/resonance/state/resonance_providers.dart`:

```dart
// Before
Future<void> load() async {
  state = state.copyWith(isLoading: true, clearError: true);
  try {
    final result = await _repository.listResponses(poemId);
    state = state.copyWith(responses: result.responses, isLoading: false);
  } on ResonanceException catch (e) {
    state = state.copyWith(isLoading: false, error: e.message);
  }
}

// After
Future<void> load() async {
  state = state.copyWith(isLoading: true, clearError: true);
  try {
    final result = await _repository.listResponses(poemId);
    state = state.copyWith(responses: result.responses, isLoading: false);
  } on ResonanceException catch (e) {
    state = state.copyWith(isLoading: false, error: e.message);
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: 'Could not load responses.',
    );
  }
}

```

**Result:** **WORKED.** The Reader Screen now renders fully — title, author, poem body, heart, reactions, author continuity card, and resonance section (showing either responses OR a graceful "Could not load responses." message). No more black screen.

**Why it worked:** The broad `catch (e)` ensures any exception — network, parsing, auth token expiry, unexpected server shape — is converted into a visible UI state (`state.error`) which `ResonanceSection` already renders as a muted "Could not load responses." message. The widget tree never crashes; it degrades gracefully.

#### Secondary Fix — "Respond" Affordance

**Issue discovered during investigation:** The "Respond" text + icon in each feed card was NOT wrapped in a `GestureDetector` or `InkWell`. It visually suggested interactivity but inherited the parent card's tap target, which took the user to the Reader. Users who tapped specifically on "Respond" got the same black screen (because they hit the broken Reader), creating double friction.

**Action taken:**
Wrapped the "Respond" row in `feed_screen.dart` with an explicit `GestureDetector`:

```dart
GestureDetector(
  behavior: HitTestBehavior.opaque,
  onTap: () => context.push('/poem/${poem.id}'),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.chat_bubble_outline, size: 16, color: SyaahiColors.goldBase),
      const SizedBox(width: 4),
      Text(
        'Respond',
        style: GoogleFonts.inter(
          color: SyaahiColors.goldLight,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),
)

```

**Visual change:** The icon and label were recolored from `SyaahiColors.textFaded` to `SyaahiColors.goldBase` / `goldLight` to communicate that "Respond" is an actionable affordance, not metadata.

---

### 3. Root Cause Summary

| Layer | Cause |
| --- | --- |
| **Primary** | `ResonanceNotifier.load()` had a narrow `on ResonanceException catch` block. Any non-`ResonanceException` (network, parsing, null-safety) thrown during the async `listResponses` call propagated as an uncaught error into the `StateNotifierProvider.family.autoDispose` pipeline. |
| **Framework Behavior** | Riverpod's `ref.watch` inside `ResonanceSection.build` receives the error, but because the enclosing widget is a child of `_ReaderView`'s `Column` inside a `SingleChildScrollView`, Flutter's release-mode error handler suppresses the red error widget and yields `const SizedBox.shrink()`-like output for the entire subtree — rendering a black `Scaffold` body with only the `AppBar.leading` icon. |
| **Why Tests Missed It** | Widget tests in `resonance_widget_test.dart` and `reader_screen_test.dart` used `_FakeResonanceRepository` overrides that returned deterministic success responses. The tests never simulated a network/parse failure path, so the narrow catch was never exercised under failure conditions. |
| **Secondary** | "Respond" button had no explicit tap handler and no affordance styling, degrading discoverability and leading users directly into the broken Reader. |

---

### 4. What Didn't Work (and Why)

* **Blindly re-generating `reader_screen.dart**` — Would have wiped working `v-UX-05` layout (Owner Menu, Heart Section, Reactions, Author Continuity). Rejected in favor of surgical edits.
* **Wrapping `ResonanceSection` in a `Builder` + `try`/`catch**` — Flutter widget `build()` methods are synchronous and cannot catch async provider errors. The exception happens outside `build()`, inside Riverpod's listener callback. This approach was prototyped and discarded.
* **Adding `errorBuilder` to GoRouter** — Already existed (`_NotFoundScreen`). Not relevant because the route match succeeded.
* **Rolling back `v-UX-06**` — Rejected. The feature worked end-to-end in automated tests and backend endpoints returned `200 OK`. Root cause was a narrow defensive gap, not a design flaw.

---

### 5. What Finally Worked

1. **Broaden the exception catch in `ResonanceNotifier.load()**` — Added `catch (e)` after `on ResonanceException catch (e)`. This converts any unexpected exception into `state.error`, which `ResonanceSection` already handles with a muted fallback UI.
2. **Explicit `GestureDetector` on the "Respond" affordance in `feed_screen.dart**` — Ensures the button is unambiguously tappable and visually styled as an interactive element using gold accent colors.
3. **Minor hardening of `_ReaderViewState.initState()**` — Wrapped `ref.read(feedProvider).heartStates[widget.poem.id]` access in `try`/`catch` to prevent cold-start race conditions from bubbling.

---

### 6. Verification

```bash
cd syaahi-app
flutter analyze     # Result: No issues found!
flutter test        # Result: 00:06 +36: All tests passed!

```

* **Manual smoke test on Android device:** PASS — Reader screen renders fully, Resonance section visible, "Respond" button clearly tappable from feed.
* **Production backend endpoints** remained green throughout the incident; no server-side changes required.

---

### 7. Lessons Learned

1. **Defensive catch-all is mandatory for async provider initializers.** Any Riverpod `StateNotifier` that calls network/IO inside its constructor (or inside a method invoked from the constructor) MUST have a broad `catch (e)` fallback. Narrow type-specific catches are dangerous.
2. **Widget tests with mocked repositories do not catch production async failures.** Future work must include a failure-path test variant (e.g., `_FakeResonanceRepository` with a mode that throws `DioException`) to exercise the error branch.
3. **Release-mode Flutter silently drops error widgets.** On production builds, uncaught widget-tree errors render as empty space. A blank screen in release = uncaught exception, not a layout bug. Always suspect async error handling first.
4. **Interactive affordances must be explicitly tappable.** "Respond" was visually a button but structurally static text. Always wrap affordances in `GestureDetector` / `InkWell` with clear visual styling.
5. **Hotfix without rollback is preferable when the root cause is isolated.** We identified the fault in a single catch clause and fixed it in 2 lines of code rather than reverting the entire sprint.

---

### 8. Files Modified in Hotfix

| File | Change |
| --- | --- |
| `syaahi-app/lib/features/resonance/state/resonance_providers.dart` | Added broad `catch (e)` in `load()` after `on ResonanceException catch (e)`. |
| `syaahi-app/lib/features/poems/presentation/feed_screen.dart` | Wrapped "Respond" row in `GestureDetector` with explicit navigation; recolored to gold accent. |
| `syaahi-app/lib/features/poems/presentation/reader_screen.dart` | Wrapped `feedProvider` read in `initState` with `try`/`catch` for cold-start safety. |
| `syaahi-app/test/features/poems/presentation/reader_screen_test.dart` | Added `_FakeResonanceRepository` override (prior commit). |

---

**Report prepared by:** Syaahi Engineering

**Approved for:** Post-`v-UX-06` hotfix commit cycle

**Next release tag:** `v-UX-06.1` (patch)

```