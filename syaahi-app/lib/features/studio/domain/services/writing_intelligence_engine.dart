import '../models/writing_intelligence_models.dart';
import 'redundancy_analyzer.dart';
import 'repetition_analyzer.dart';
import 'word_suggestion_service.dart';

/// Orchestrates all Writing Intelligence analyzers on a text snapshot.
class WritingIntelligenceEngine {
  /// Runs a complete analysis pass over the provided text.
  /// Operates purely on a snapshot without document mutation.
  static WritingAnalysisResult analyze(
    String text, {
    int minWordOccurrences = 3,
    int minPhraseOccurrences = 2,
    Set<String>? stopWords,
    bool includeWordSuggestions = true,
  }) {
    if (text.trim().isEmpty) {
      return WritingAnalysisResult.empty();
    }

    final words = RegExp(r'\b[a-zA-Z\u0900-\u097F]+\b').allMatches(text);
    final totalWords = words.length;
    final uniqueWords = words.map((m) => m.group(0)!.toLowerCase()).toSet().length;

    final suggestions = <WritingSuggestion>[];

    // 1. Repetition Analysis
    suggestions.addAll(RepetitionAnalyzer.analyze(
      text,
      minWordOccurrences: minWordOccurrences,
      minPhraseOccurrences: minPhraseOccurrences,
      stopWords: stopWords,
    ));

    // 2. Redundancy Analysis
    suggestions.addAll(RedundancyAnalyzer.analyze(text));

    // 3. Document-wide Word Suggestions (optional pass)
    if (includeWordSuggestions) {
      final docSuggestions = WordSuggestionService.analyzeDocument(text);
      for (final s in docSuggestions) {
        // Avoid duplicate suggestion overlaps if word is already flagged for repetition
        if (!suggestions.any((existing) => existing.startOffset == s.startOffset)) {
          suggestions.add(s);
        }
      }
    }

    // Sort suggestions sequentially by position in text
    suggestions.sort((a, b) => a.startOffset.compareTo(b.startOffset));

    return WritingAnalysisResult(
      suggestions: List.unmodifiable(suggestions),
      totalWords: totalWords,
      uniqueWords: uniqueWords,
      analyzedAt: DateTime.now(),
    );
  }
}
