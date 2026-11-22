import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/writing_intelligence_models.dart';
import '../domain/services/writing_intelligence_engine.dart';
import '../domain/services/word_suggestion_service.dart';

/// State of the Writing Intelligence system.
class WritingIntelligenceState {
  final WritingAnalysisResult analysisResult;
  final Set<String> dismissedSuggestionIds;
  final bool isAnalyzing;
  final WritingIssueType selectedTab;
  final WritingSuggestion? activeSelectionSuggestion;

  const WritingIntelligenceState({
    required this.analysisResult,
    this.dismissedSuggestionIds = const {},
    this.isAnalyzing = false,
    this.selectedTab = WritingIssueType.repeatedWord,
    this.activeSelectionSuggestion,
  });

  factory WritingIntelligenceState.initial() {
    return WritingIntelligenceState(
      analysisResult: WritingAnalysisResult.empty(),
    );
  }

  /// Filtered active (non-dismissed) suggestions.
  List<WritingSuggestion> get activeSuggestions {
    return analysisResult.suggestions
        .where((s) => !dismissedSuggestionIds.contains(s.id))
        .toList();
  }

  /// Suggestions for the currently active UI tab.
  List<WritingSuggestion> get activeTabSuggestions {
    return activeSuggestions.where((s) => s.type == selectedTab).toList();
  }

  WritingIntelligenceState copyWith({
    WritingAnalysisResult? analysisResult,
    Set<String>? dismissedSuggestionIds,
    bool? isAnalyzing,
    WritingIssueType? selectedTab,
    WritingSuggestion? activeSelectionSuggestion,
    bool clearActiveSelection = false,
  }) {
    return WritingIntelligenceState(
      analysisResult: analysisResult ?? this.analysisResult,
      dismissedSuggestionIds: dismissedSuggestionIds ?? this.dismissedSuggestionIds,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      selectedTab: selectedTab ?? this.selectedTab,
      activeSelectionSuggestion: clearActiveSelection
          ? null
          : (activeSelectionSuggestion ?? this.activeSelectionSuggestion),
    );
  }
}

/// Riverpod StateNotifier controlling Writing Intelligence actions.
class WritingIntelligenceNotifier extends StateNotifier<WritingIntelligenceState> {
  WritingIntelligenceNotifier() : super(WritingIntelligenceState.initial());

  /// Runs full document analysis pass.
  void analyzeDocument(String text) {
    state = state.copyWith(isAnalyzing: true);
    final result = WritingIntelligenceEngine.analyze(text);
    state = state.copyWith(
      analysisResult: result,
      isAnalyzing: false,
    );
  }

  /// Analyzes specific selection range for word suggestions.
  void analyzeSelection(String text, int start, int end) {
    final selectionSuggestions = WordSuggestionService.findSuggestionsForSelection(
      text,
      selectionStart: start,
      selectionEnd: end,
    );

    if (selectionSuggestions.isNotEmpty) {
      state = state.copyWith(
        activeSelectionSuggestion: selectionSuggestions.first,
        selectedTab: WritingIssueType.wordSuggestion,
      );
    } else {
      state = state.copyWith(clearActiveSelection: true);
    }
  }

  /// Dismisses a specific suggestion by ID.
  void dismissSuggestion(String id) {
    final updated = Set<String>.from(state.dismissedSuggestionIds)..add(id);
    state = state.copyWith(dismissedSuggestionIds: updated);
  }

  /// Restores all dismissed suggestions.
  void resetDismissed() {
    state = state.copyWith(dismissedSuggestionIds: const {});
  }

  /// Switches active category tab.
  void selectTab(WritingIssueType tab) {
    state = state.copyWith(selectedTab: tab);
  }

  /// Clears active selection popover.
  void clearSelection() {
    state = state.copyWith(clearActiveSelection: true);
  }
}

/// Main Riverpod provider for Writing Intelligence.
final writingIntelligenceProvider =
    StateNotifierProvider<WritingIntelligenceNotifier, WritingIntelligenceState>((ref) {
  return WritingIntelligenceNotifier();
});
