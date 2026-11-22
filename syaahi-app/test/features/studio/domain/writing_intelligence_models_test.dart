import 'package:flutter_test/flutter_test.dart';
import 'package:syaahi_app/features/studio/domain/models/writing_intelligence_models.dart';

void main() {
  group('WritingSuggestion Model Tests', () {
    test('supports value equality and copyWith', () {
      final s1 = WritingSuggestion(
        id: 's1',
        type: WritingIssueType.repeatedWord,
        originalText: 'dark',
        explanation: 'Appears 3 times',
        startOffset: 10,
        endOffset: 14,
        alternatives: ['shadowed', 'dim'],
        contextSnippet: 'the night was dark',
      );

      final s2 = WritingSuggestion(
        id: 's1',
        type: WritingIssueType.repeatedWord,
        originalText: 'dark',
        explanation: 'Appears 3 times',
        startOffset: 10,
        endOffset: 14,
        alternatives: ['shadowed', 'dim'],
        contextSnippet: 'the night was dark',
      );

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));

      final copy = s1.copyWith(originalText: 'gloomy');
      expect(copy.originalText, equals('gloomy'));
      expect(copy.id, equals('s1'));
      expect(s1 == copy, isFalse);
    });

    test('serializes to and from JSON correctly', () {
      final suggestion = WritingSuggestion(
        id: 's_json',
        type: WritingIssueType.redundancy,
        originalText: 'returned back',
        explanation: 'Redundant phrasing',
        startOffset: 5,
        endOffset: 18,
        alternatives: ['returned'],
        contextSnippet: 'He returned back home',
      );

      final json = suggestion.toJson();
      final restored = WritingSuggestion.fromJson(json);

      expect(restored, equals(suggestion));
      expect(restored.type, equals(WritingIssueType.redundancy));
      expect(restored.alternatives, equals(['returned']));
    });
  });

  group('WritingAnalysisResult Model Tests', () {
    test('correctly calculates counts and filtering', () {
      final suggestions = [
        WritingSuggestion(
          id: '1',
          type: WritingIssueType.repeatedWord,
          originalText: 'dark',
          explanation: '3 times',
          startOffset: 0,
          endOffset: 4,
        ),
        WritingSuggestion(
          id: '2',
          type: WritingIssueType.repeatedPhrase,
          originalText: 'the dark night',
          explanation: '2 times',
          startOffset: 10,
          endOffset: 24,
        ),
        WritingSuggestion(
          id: '3',
          type: WritingIssueType.redundancy,
          originalText: 'returned back',
          explanation: 'Redundant',
          startOffset: 30,
          endOffset: 43,
        ),
      ];

      final result = WritingAnalysisResult(
        suggestions: suggestions,
        totalWords: 100,
        uniqueWords: 60,
        analyzedAt: DateTime.now(),
      );

      expect(result.repeatedWordCount, equals(1));
      expect(result.repeatedPhraseCount, equals(1));
      expect(result.redundancyCount, equals(1));
      expect(result.wordSuggestionCount, equals(0));
      expect(result.vocabularyRichness, equals(0.6));
    });

    test('handles empty result cleanly', () {
      final empty = WritingAnalysisResult.empty();
      expect(empty.suggestions, isEmpty);
      expect(empty.totalWords, equals(0));
      expect(empty.vocabularyRichness, equals(1.0));
    });
  });
}

