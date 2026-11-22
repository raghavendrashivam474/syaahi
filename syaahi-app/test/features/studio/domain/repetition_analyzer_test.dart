import 'package:flutter_test/flutter_test.dart';
import 'package:syaahi_app/features/studio/domain/models/writing_intelligence_models.dart';
import 'package:syaahi_app/features/studio/domain/services/repetition_analyzer.dart';

void main() {
  group('RepetitionAnalyzer Unit Tests', () {
    test('identifies repeated words beyond threshold', () {
      const input = 'The night was dark, the road was dark, and my thoughts were dark.';
      final suggestions = RepetitionAnalyzer.analyze(input, minWordOccurrences: 3);

      final darkSuggestions = suggestions.where(
        (s) => s.type == WritingIssueType.repeatedWord && s.originalText.toLowerCase() == 'dark',
      );

      expect(darkSuggestions.length, equals(3));
      expect(darkSuggestions.first.explanation, contains('appears 3 times'));
    });

    test('ignores stop words like "the", "and", "was"', () {
      const input = 'The night and the road and the sky were dark.';
      final suggestions = RepetitionAnalyzer.analyze(input, minWordOccurrences: 2);

      final stopWordSuggestions = suggestions.where(
        (s) => ['the', 'and', 'were'].contains(s.originalText.toLowerCase()),
      );

      expect(stopWordSuggestions, isEmpty);
    });

    test('detects consecutive duplicate words', () {
      const input = 'It was a very very quiet dark dark night.';
      final suggestions = RepetitionAnalyzer.analyze(input);

      final consec = suggestions.where((s) => s.explanation.contains('Consecutive'));
      expect(consec.length, equals(2));
      expect(consec.map((s) => s.originalText), containsAll(['very very', 'dark dark']));
    });

    test('detects repeated phrases across poem lines', () {
      const input = '''
The lonely wind whispers in the dark,
The lonely wind whispers under the stars.
''';

      final suggestions = RepetitionAnalyzer.analyze(input, minPhraseOccurrences: 2);
      final phrases = suggestions.where((s) => s.type == WritingIssueType.repeatedPhrase);

      expect(phrases, isNotEmpty);
      expect(phrases.any((s) => s.originalText.toLowerCase().contains('lonely wind whispers')), isTrue);
    });

    test('returns empty list on empty or whitespace input', () {
      expect(RepetitionAnalyzer.analyze(''), isEmpty);
      expect(RepetitionAnalyzer.analyze('   \n\t  '), isEmpty);
    });

    test('preserves valid start and end offsets', () {
      const input = 'Shadows fall, dark shadows rise, dark shadows remain.';
      final suggestions = RepetitionAnalyzer.analyze(input, minWordOccurrences: 2);

      for (final s in suggestions) {
        final extracted = input.substring(s.startOffset, s.endOffset);
        expect(extracted.toLowerCase(), equals(s.originalText.toLowerCase()));
      }
    });
  });
}
