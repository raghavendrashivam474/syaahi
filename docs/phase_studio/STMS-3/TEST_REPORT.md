# Test Report: Microsprint STMS-3 (Studio Entry & Draft Access)

**Branch**: `fix/studio-entry-draft-access`  
**Date**: November 2026  
**Execution Environment**: Local Development (Windows 11 / Flutter 3.29.0 / Node.js v24.9+)  

---

## 1. Test Execution Summary

| Test Suite | Total Tests | Passed | Failed | Skipped | Status |
|---|---|---|---|---|---|
| Flutter Unit & Widget Tests (`syaahi-app`) | 104 | 104 | 0 | 0 | **PASS** |
| Backend Studio Draft API (`syaahi-backend`) | 14 | 14 | 0 | 0 | **PASS** |
| Backend Notification Tests (`syaahi-backend`) | 65 | 65 | 0 | 0 | **PASS** |
| Web Release Build (`flutter build web`) | 1 build | 1 build | 0 | 0 | **PASS** |
| Static Analysis (`flutter analyze`) | 0 errors | 0 errors | 0 | 0 | **PASS** |

---

## 2. Flutter App Test Results

Command: `flutter test`
Result: `00:45 +104: All tests passed!`

Key test coverage includes:
- `test/core/network/api_client_test.dart`: Token retrieval interceptors and guest degradation.
- `test/features/poems/presentation/feed_respond_test.dart`: Feed navigation and resonance flows.
- `test/features/studio/draft_sync_service_test.dart`: Local/remote sync, collision handling, debounce flushes.
- `test/features/studio/studio_database_test.dart`: In-memory SQLite persistence and DAO operations.
- `test/features/studio/studio_journey_test.dart`: Complete end-to-end user drafting, debounced autosave, intelligence advice, and controlled publishing.

---

## 3. Backend Test Results

### 3.1 Studio Draft API (`npm run test:studio`)
Result: `RESULTS: 14 Passed, 0 Failed`
- Unauthenticated draft access rejection (`401`)
- User draft creation, listing, retrieval, update, and deletion
- Owner draft isolation (User B cannot access or modify User A drafts -> `404`)
- Unpublished draft leakage prevention into public feed
- Controlled draft publication to public `Poem`
- Idempotent re-publication returning existing `Poem` without duplicate rows

### 3.2 Notification Foundations & Publications (`npm run test:n1`, `n2`, `n3`)
- Foundation integrity tests: Passed
- API integration & pagination tests: 39 Passed, 0 Failed
- Publication event notification tests: 19 Passed, 0 Failed

---

## 4. Production Web Build Verification

Command: `flutter build web --release`
Result: `√ Built build\web` (Compiling lib\main.dart for the Web completed in 108.1s)
- Assets verified in web output: `sql-wasm.js`, `sql-wasm.wasm`, `flutter_bootstrap.js`, `manifest.json`.

---

## 5. Conclusion

All automated unit, integration, and release verification checks have passed without any regressions or warnings.
