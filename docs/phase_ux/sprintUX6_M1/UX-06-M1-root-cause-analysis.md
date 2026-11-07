# UX-06.M1 Root Cause Analysis

**Date:** 7 November 2026
**Branch:** hotfix/ux-06-reader-response-flow
**Analyst:** UX-06.M1 Sprint

---

## Symptoms

1. Tapping a poem card in the feed navigates to /poem/:id but the reader
   remains on "Opening poem..." indefinitely.
2. Tapping "Respond" in the feed navigates to the reader but Resonance is
   inaccessible.
3. Direct API calls to GET /api/v1/poems/:id return HTTP 200.

## Confirmed Root Causes

### RC-1 (P0): Dio Interceptor Stalls on TokenStorage Failure

**File:** syaahi-app/lib/core/network/api_client.dart
**Function:** ApiClient() constructor, onRequest interceptor

The interceptor calls await _tokenStorage.getToken() which invokes
FlutterSecureStorage.read(). On Flutter Web, this call can:
- Hang indefinitely (localStorage initialization race)
- Throw a PlatformException (unsupported browser context)

When either occurs, handler.next(options) is never called. The Dio
request remains pending forever. Since poemByIdProvider is a
FutureProvider awaiting this request, it stays in AsyncLoading
permanently.

**Evidence:**
- FlutterSecureStorage web implementation uses localStorage which
  can block on first access in some browser configurations.
- The interceptor has no try-catch and no timeout.
- handler.next() is the only exit path — no handler.reject() fallback.

### RC-2 (P0): ResonanceSection Not Wired Into Reader

**File:** syaahi-app/lib/features/poems/presentation/reader_screen.dart
**Widget:** _ReaderView

The ResonanceSection widget exists at
lib/features/resonance/presentation/resonance_section.dart and is fully
functional. However, _ReaderView never imports or renders it. The reader
column ends with _AuthorContinuity and has no Resonance section.

### RC-3 (P1): Respond Label Has No Gesture Handler

**File:** syaahi-app/lib/features/poems/presentation/feed_screen.dart
**Widget:** _PoemCard

The "Respond" element is a static Row(Icon + Text) inside the card's
bottom row. It has no GestureDetector or InkWell. Tapping it triggers
the parent card's InkWell.onTap which navigates to the poem — but
without any Resonance targeting.

## Contributing Factors

- PoemsRepository creates a new ApiClient() (and thus new Dio instance)
  on every instantiation. While not the direct cause, it means each
  provider gets its own interceptor chain.
- _loadInitialState() in _ReaderViewState uses Future.wait() for
  heart + reactions. This is acceptable since it runs AFTER the poem
  renders, but a failure in either request is silently caught.

## Proposed Fixes

| # | Fix | File | Risk |
|---|-----|------|------|
| F1 | Wrap getToken() in try-catch + timeout; always call handler.next() | api_client.dart | Low |
| F2 | Import and render ResonanceSection in _ReaderView | reader_screen.dart | Low |
| F3 | Wrap Respond in GestureDetector; navigate with ?focus=resonance | feed_screen.dart | Low |
| F4 | Add scroll-to-resonance support in reader via ScrollController | reader_screen.dart | Low |

## Regressions to Watch

- Guest users must still read poems without authentication.
- Authenticated requests must still include the Bearer token.
- Heart and reaction loading must not block poem display.
- Feed card navigation must not double-fire.
