# UX-06.M1 — Implementation Plan

**Date:** 2026-11-07

## Pre-existing Work Assessment

The working tree already contained correct implementations for all four sprint objectives. The code was reviewed, verified against root causes, and confirmed to match the sprint requirements.

## Additional Work Performed

### 1. TokenStorage Injectability (api_client.dart)
- **Change:** Added optional `tokenStorage` parameter to `ApiClient` constructor.
- **Reason:** Enable unit testing of the interceptor with fake token storage.
- **Impact:** Zero — backward-compatible default parameter.

### 2. API Client Interceptor Tests (new file)
- **File:** `test/core/network/api_client_test.dart`
- **Tests:** 6 scenarios covering success, null, exception, timeout, empty string, and pending-request verification.

### 3. Reader Resonance Integration Tests (new file)
- **File:** `test/features/poems/presentation/reader_resonance_test.dart`
- **Tests:** 3 scenarios verifying ResonanceSection renders, focus parameter accepted, poem renders despite interaction failures.

### 4. Feed Respond Navigation Tests (new file)
- **File:** `test/features/poems/presentation/feed_respond_test.dart`
- **Tests:** 2 scenarios verifying Respond label presence and `?focus=resonance` navigation.

## Implementation Sequence

1. Verify existing fixes against root-cause analysis ✅
2. Make TokenStorage injectable for testability ✅
3. Write API client interceptor tests ✅
4. Write Reader/Resonance integration tests ✅
5. Write Feed/Respond navigation tests ✅
6. Fix test timer issues (3s timeout drain) ✅
7. Full regression verification ✅
8. Documentation ✅