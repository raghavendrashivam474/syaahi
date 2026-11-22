# ST-03 — Writing Intelligence Baseline Audit

**Date:** 2026-11-22  
**Baseline Commit:** fdd0ed4720ece06ac19e54e23eaf80c60e095bc9  
**Branch:** feature/st-st03-writing-intelligence  
**Status:** Approved & Verified  

---

## 1. Baseline Verification Results

| Verification Check | ST-02 Historical Baseline | ST-03 Pre-flight Result | Status |
|---|---|---|---|
| Flutter Static Analysis | 0 errors, 0 warnings | 0 errors, 0 warnings (6 deprecation/style infos) | PASS |
| Flutter Unit/Widget Tests | 82 passed | 82 passed (0 failed) | PASS |
| Backend TypeScript Compilation | 0 errors | 0 errors (	sc --noEmit) | PASS |
| Studio Backend API Tests | 14 passed | 14 passed (
pm run test:studio) | PASS |

---

## 2. Existing Studio Architecture

### 2.1 State & Persistence Layer
- **Local Persistence:** Drift / SQLite database (StudioDatabase) maintaining draft entity records.
- **Autosave Engine:** Debounced by 500 ms in StudioNotifier. Explicit flushing occurs during navigation and publication.
- **Remote Sync:** DraftSyncService syncs local changes to Node.js/Prisma backend without blocking local persistence.
- **Publication:** Idempotent controlled publication converting local/remote drafts into public Poem items.

### 2.2 UI Layer
- **StudioHomeScreen:** Draft management list, draft creation trigger, pull-to-refresh, status indicators.
- **StudioEditorScreen:** Core editing screen using Flutter TextEditingController wired to StudioNotifier. Debounced autosave triggers on text changes.

---

## 3. Existing Integration Points & Reusable Utilities

- **Editor Integration Point:** StudioEditorScreen app bar actions area and bottom bar. Writing Intelligence trigger will be integrated as a dedicated action icon in the app bar / toolbar.
- **State Boundary:** Writing Intelligence state will be managed independently by writingIntelligenceProvider in lib/features/studio/state/writing_intelligence_providers.dart, preventing any pollution of StudioNotifier or draft persistence.
- **Existing Text Utilities:** Regular Dart string/regexp functions with custom tokenizers for sentence, line, word, and phrase extraction.

---

## 4. Proposed Files to Add / Modify

### 4.1 New Files (Domain, Data, Presentation, Tests)
1. syaahi-app/lib/features/studio/domain/models/writing_intelligence_models.dart
   - WritingIssueType (epeatedWord, epeatedPhrase, edundancy, wordSuggestion)
   - WritingSuggestion (id, type, originalText, explanation, startOffset, endOffset, alternatives)
   - WritingAnalysisResult (summary, list of suggestions, timestamps)
2. syaahi-app/lib/features/studio/domain/services/repetition_analyzer.dart
   - Repetition detection logic (repeated words, repeated phrases, consecutive word repetition, configurable stop-word filtering).
3. syaahi-app/lib/features/studio/domain/services/redundancy_analyzer.dart
   - Explainable rule-based pattern matching for tautologies, unnecessary verbal redundancies, and duplicate poetic meaning.
4. syaahi-app/lib/features/studio/domain/services/word_suggestion_service.dart
   - Local offline dictionary & synonym resource supporting context-preserving word alternative exploration.
5. syaahi-app/lib/features/studio/domain/services/writing_intelligence_engine.dart
   - Master orchestrator aggregating analyzers on text snapshots.
6. syaahi-app/lib/features/studio/state/writing_intelligence_providers.dart
   - Riverpod providers managing intelligence analysis state, active tab, dismissed suggestions, and replacement actions.
7. syaahi-app/lib/features/studio/presentation/widgets/writing_intelligence_sheet.dart
   - Bottom sheet / side panel UI allowing tabbed navigation (Overview, Repetition, Redundancy, Word Suggestions), suggestion review, accept, and dismiss actions.
8. syaahi-app/test/features/studio/writing_intelligence_test.dart
   - Direct unit tests for all analyzers, models, word resources, and replacement mechanisms.

### 4.2 Files to Modify
1. syaahi-app/lib/features/studio/presentation/screens/studio_editor_screen.dart
   - Add Writing Intelligence action button to App Bar.
   - Connect active text controller selection to contextual word suggestion trigger.
   - Apply accepted suggestions safely through TextEditingController update pathway, triggering standard debounced autosave.

---

## 5. Potential Regression Risks & Mitigation Strategies

1. **Unintended Text Mutation / Autosave Side Effects:**
   - *Risk:* Automated suggestions altering text without explicit writer intent.
   - *Mitigation:* Writing Intelligence operates strictly on a read-only snapshot string. Suggestions can only modify the editor controller if the writer explicitly clicks "Accept".

2. **Performance Lag on Long Texts:**
   - *Risk:* Running regex/tokenizers on every keystroke causing UI stutter.
   - *Mitigation:* Execution is manual (on action click) or debounced on demand, executing off the main UI thread where appropriate.

3. **Stale Text Offsets during Active Typing:**
   - *Risk:* Suggestion offsets calculated before subsequent user edits pointing to wrong positions.
   - *Mitigation:* Strict offset verification prior to applying any suggestion. If original text at offset range no longer matches expected originalText, replacement is aborted with a graceful notice.

4. **External API or Cost Dependency Risk:**
   - *Risk:* Inadvertent reliance on paid/remote LLMs.
   - *Mitigation:* Entire engine is 100% offline, local-first Dart algorithm with zero third-party network API calls.

---

## 6. Ambiguity & Clarifications
- No architectural ambiguities identified. All requirements align with local-first, writer-centric Studio principles established in ST-01 and ST-02.
