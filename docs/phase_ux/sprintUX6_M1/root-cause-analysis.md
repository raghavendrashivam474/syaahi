# UX-06.M1 — Root Cause Analysis

**Date:** 2026-11-07
**Status:** Confirmed against current source code

## RC-1 (P0): Dio Interceptor Stalls on TokenStorage Failure

**File:** `lib/core/network/api_client.dart`
**Confirmed:** Yes.

The original `onRequest` interceptor called `await _tokenStorage.getToken()` with no timeout or error handling. On Flutter Web, `FlutterSecureStorage.read()` can hang indefinitely or throw `PlatformException` in certain browser contexts. When this happens, `handler.next(options)` is never called, leaving the Dio request permanently pending.

**Evidence:** `poemByIdProvider` remains in `AsyncLoading` state. Reader displays loading spinner forever.

**Fix applied:** 3-second `.timeout()` + try/catch. `handler.next()` always executes outside the try/catch block.

## RC-2 (P0): ResonanceSection Not Integrated into Reader

**File:** `lib/features/poems/presentation/reader_screen.dart`
**Confirmed:** Yes (was confirmed in original code, now fixed in working tree).

`_ReaderView` did not import or render `ResonanceSection`. The widget existed at `lib/features/resonance/presentation/resonance_section.dart` but was unreachable from the Reader.

**Fix applied:** Import added, `ResonanceSection(key: _resonanceKey, poem: widget.poem)` placed after `_AuthorContinuity`.

## RC-3 (P1): Respond Action Has No Independent Gesture Handler

**File:** `lib/features/poems/presentation/feed_screen.dart`
**Confirmed:** Yes (was confirmed in original code, now fixed in working tree).

The Respond label was a static `Row` inside the card's `InkWell`. Tapping it triggered the parent card's navigation (open Reader normally) instead of targeting Resonance.

**Fix applied:** `GestureDetector(behavior: HitTestBehavior.opaque)` wrapping the Respond Row, navigating to `/poem/${poem.id}?focus=resonance`.

## Contributing Factor: Multiple ApiClient Instances

`PoemsRepository` creates a new `ApiClient()` on instantiation. This results in multiple Dio instances. Not a direct cause of the reported issues but noted for future optimization. No action taken per sprint scope constraints.