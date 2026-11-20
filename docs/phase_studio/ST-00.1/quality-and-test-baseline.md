# ST-00.1: Quality and Test Baseline

**Sprint ID:** ST-00.1  
**Phase:** `phase_studio`  
**Status:** Completed  
**Audit Target:** Verification of Existing Frontend & Backend Test Suites  

---

## 1. Test Audit Methodology & Execution

Audit execution was performed strictly on the baseline codebase without altering existing test implementations.

---

## 2. Frontend Test Suite Results (`syaahi-app`)

### Command Executed
```powershell
Set-Location syaahi-app
flutter test

```

### Execution Summary

* **Total Test Files Evaluated:** 10 test files
* **Total Test Cases Executed:** 69 test cases
* **Passed:** 69
* **Failed:** 0
* **Duration:** ~6 seconds

### Test Suites Inspected

* `test/core/network/api_client_test.dart` — Interceptor resilience and token timeout handling.
* `test/core/widgets/syaahi_brand_mark_test.dart` — Brand UI rendering.
* `test/features/onboarding/onboarding_test.dart` — Onboarding flow and preferences storage.
* `test/features/poems/presentation/feed_respond_test.dart` — Feed UI interactions and navigation.
* `test/features/poems/presentation/reader_screen_test.dart` — Reader screen UI.
* `test/features/poems/presentation/reader_resonance_test.dart` — Resonance section integration.
* `test/features/resonance/resonance_reply_test.dart` — Author reply interactions.
* `test/features/resonance/resonance_widget_test.dart` — Response composer and item widgets.
* `test/notifications/model_test.dart` — Notification data deserialization.

### Missing Test Coverage Identified for Writing

* Zero test cases exist for `WriterScreen` or `WriterNotifier`. There are no widget tests verifying input controllers, publish state transitions, or draft discard dialogs in the current baseline.

---

## 3. Backend Test Suite Results (`syaahi-backend`)

### Commands Executed

```powershell
Set-Location syaahi-backend
npm run test:n1
npm run test:n2
npm run test:n3

```

### Test Results Breakdown

* **Test Suite N1 (`notifications.foundation.test.ts`):**
* **Passed:** 7
* **Failed:** 1
* **Failure Analysis:** Test 2 (`Unique constraint [recipientId, poemId, type] blocks duplicate insert (P2002)`) failed because the database schema index was broadened to `[recipientId, poemId, type, sourceId]` in Phase Notifications. The test script expects the old 3-tuple unique constraint.
* **Pre-existing Failure Record:** Pre-existing legacy test expectation issue in `test:n1`. Preserved unmodified per Rule 2 & Rule 5.


* **Test Suite N2 (`notifications.api.test.ts`):**
* **Passed:** 39
* **Failed:** 0
* **Status:** 100% PASS


* **Test Suite N3 (`notifications.publication.test.ts`):**
* **Passed:** 19
* **Failed:** 0
* **Status:** 100% PASS (Verifies `POST /api/v1/poems` and `PATCH /api/v1/poems/:id` notification rules).



---

## 4. Stability Summary

The existing core application is stable. The Flutter test suite passes 100% (69/69 tests), and backend API integration suites (N2 & N3) pass 100%. Studio implementation must maintain this baseline and add complete unit/widget test suites for all new Studio modules.

```