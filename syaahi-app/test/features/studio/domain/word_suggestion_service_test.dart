import 'package:flutter_test/flutter_test.dart';
import 'package:syaahi_app/features/studio/domain/models/writing_intelligence_models.dart';
import 'package:syaahi_app/features/studio/domain/services/word_suggestion_service.dart';

void main() {
  group('WordSuggestionService Unit Tests', () {
    test('provides alternatives for highlighted word', () {
      const text = 'She looked beautiful standing under the moonlight.';
      const start = 11;
      const end = 20; // "beautiful"

      final suggestions = WordSuggestionService.findSuggestionsForSelection(
        text,
        selectionStart: start,
        selectionEnd: end,
      );

      expect(suggestions, hasLength(1));
      final s = suggestions.first;
      expect(s.type, equals(WritingIssueType.wordSuggestion));
      expect(s.originalText, equals('beautiful'));
      expect(s.alternatives, containsAll(['elegant', 'radiant', 'graceful']));
    });

    test('resolves word under cursor when start == end', () {
      const text = 'The dark night descended.';
      const cursorOffset = 5; // inside "dark"

      final suggestions = WordSuggestionService.findSuggestionsForSelection(
        text,
        selectionStart: cursorOffset,
        selectionEnd: cursorOffset,
      );

      expect(suggestions, hasLength(1));
      expect(suggestions.first.originalText, equals('dark'));
      expect(suggestions.first.alternatives, contains('dim'));
    });

    test('returns empty list for unrecognized words', () {
      const text = 'The xylophone played softly.';
      final suggestions = WordSuggestionService.findSuggestionsForSelection(
        text,
        selectionStart: 4,
        selectionEnd: 13,
      );

      expect(suggestions, isEmpty);
    });

    test('analyzes full document and identifies customizable words', () {
      const text = 'The dark night brought beautiful silence.';
      final suggestions = WordSuggestionService.analyzeDocument(text);

      expect(suggestions.length, greaterThanOrEqualTo(3)); // dark, night, beautiful, silence
      expect(suggestions.any((s) => s.originalText == 'beautiful'), isTrue);
    });
  });
}
