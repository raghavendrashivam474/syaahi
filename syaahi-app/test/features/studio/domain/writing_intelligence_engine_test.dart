import 'package:flutter_test/flutter_test.dart';
import 'package:syaahi_app/features/studio/domain/models/writing_intelligence_models.dart';
import 'package:syaahi_app/features/studio/domain/services/writing_intelligence_engine.dart';
import 'package:syaahi_app/features/studio/state/writing_intelligence_providers.dart';

void main() {
  group('WritingIntelligenceEngine Unit Tests', () {
    test('aggregates repetition, redundancy, and word suggestions into single snapshot', () {
      const input = '''
The night was dark, the road was dark, and my thoughts were dark.
He returned back to the beautiful room.
''';

      final result = WritingIntelligenceEngine.analyze(input);

      expect(result.totalWords, greaterThan(0));
      expect(result.uniqueWords, greaterThan(0));
      expect(result.suggestions, isNotEmpty);

      expect(result.repeatedWordCount, greaterThanOrEqualTo(1)); // dark
      expect(result.redundancyCount, greaterThanOrEqualTo(1)); // returned back
      expect(result.wordSuggestionCount, greaterThanOrEqualTo(1)); // beautiful
    });

    test('returns empty result for empty string', () {
      final result = WritingIntelligenceEngine.analyze('   ');
      expect(result.suggestions, isEmpty);
      expect(result.totalWords, equals(0));
    });
  });

  group('WritingIntelligenceNotifier Riverpod State Tests', () {
    test('manages analysis, dismissal, and tab switching', () {
      final notifier = WritingIntelligenceNotifier();
      expect(notifier.state.analysisResult.suggestions, isEmpty);

      const sample = 'The dark night was very dark. He returned back home.';
      notifier.analyzeDocument(sample);

      expect(notifier.state.activeSuggestions, isNotEmpty);
      final firstId = notifier.state.activeSuggestions.first.id;

      notifier.dismissSuggestion(firstId);
      expect(notifier.state.dismissedSuggestionIds, contains(firstId));
      expect(notifier.state.activeSuggestions.any((s) => s.id == firstId), isFalse);

      notifier.selectTab(WritingIssueType.redundancy);
      expect(notifier.state.selectedTab, equals(WritingIssueType.redundancy));

      notifier.resetDismissed();
      expect(notifier.state.dismissedSuggestionIds, isEmpty);
    });
  });
}
