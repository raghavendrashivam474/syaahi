# UX-06.M3 — Implementation Details

## Summary of Changes

The existing codebase already contained the full reply chain:
`ResponseItem._submitReply()` → `ResonanceNotifier.submitReply()` →
`ResonanceRepository.createReply()` → `POST /resonances/:id/reply`.

The Post Reply button and Cancel button were already rendered in the widget
tree. The gaps were in the **submission lifecycle** — missing loading state,
no duplicate prevention, no error feedback, and no reactive button validation.

## Modified Files

### 1. `lib/features/resonance/state/resonance_providers.dart`

**Method:** `ResonanceNotifier.submitReply()`

**Changes:**
- Added `isSubmitting` guard at method entry (prevents duplicate calls)
- Added `isSubmitting: true` + `clearActionError: true` on start
- Added `isSubmitting: false` on success path
- Added `isSubmitting: false` on error path

**Diff:**
```diff
  Future<bool> submitReply(String responseId, String content) async {
+   if (state.isSubmitting) return false;
+   state = state.copyWith(isSubmitting: true, clearActionError: true);
    try {
      final reply = await _repository.createReply(responseId, content);
      state = state.copyWith(
        responses: state.responses.map((r) { ... }).toList(),
+       isSubmitting: false,
      );
      return true;
    } on ResonanceException catch (e) {
-     state = state.copyWith(actionError: e.message);
+     state = state.copyWith(isSubmitting: false, actionError: e.message);
      return false;
    }
  }
This mirrors the existing submitResponse() pattern exactly.

2. lib/features/resonance/presentation/response_item.dart
Changes:

a) Added initState() with controller listener
dart

@override
void initState() {
  super.initState();
  _replyController.addListener(() {
    if (mounted) setState(() {});
  });
}
Required so the Builder widget re-evaluates canSubmit as the user types.
Without this, the button remained permanently disabled after the composer
opened. Mirrors the pattern used in ResponseComposer.

b) Updated _submitReply() with error feedback
Added else if (mounted) branch that reads actionError from the provider
and displays a SnackBar with the error message. Preserves the draft (does
not clear the controller on failure).

c) Replaced Post Reply button with reactive Builder
The button now:

Watches resonanceProvider for isSubmitting state
Reads _replyController.text.trim() for validation
Computes canSubmit = text.isNotEmpty && text.length <= 280 && !isSubmitting
Shows CircularProgressIndicator during submission
Uses disabledBackgroundColor for visual feedback when disabled
Unchanged Files (Verified)
resonance_repository.dart — createReply() contract unchanged
response_composer.dart — Response composer unaffected
resonance_section.dart — Section layout unaffected
Auth/authorization logic — No changes to permission checks
Architecture Compliance
✅ Reuses existing POST /resonances/:id/reply endpoint
✅ No new dependencies introduced
✅ No new API endpoints or parallel architecture
✅ Preserves one-author-reply-per-response rule
✅ Stays within Flutter/Dio/Riverpod architecture
