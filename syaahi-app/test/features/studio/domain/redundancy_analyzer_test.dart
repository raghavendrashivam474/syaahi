import 'package:flutter_test/flutter_test.dart';
import 'package:syaahi_app/features/studio/domain/models/writing_intelligence_models.dart';
import 'package:syaahi_app/features/studio/domain/services/redundancy_analyzer.dart';

void main() {
  group('RedundancyAnalyzer Unit Tests', () {
    test('detects verbal redundancy patterns', () {
      const input = 'He returned back to the city because the reason is because of fear.';
      final suggestions = RedundancyAnalyzer.analyze(input);

      final returnedBack = suggestions.firstWhere((s) => s.originalText == 'returned back');
      expect(returnedBack.type, equals(WritingIssueType.redundancy));
      expect(returnedBack.alternatives, equals(['returned']));
      expect(returnedBack.explanation, contains('Returned'));

      final reasonBecause = suggestions.firstWhere((s) => s.originalText == 'reason is because');
      expect(reasonBecause.alternatives, equals(['reason is that']));
    });

    test('detects consecutive lines with near-identical meaning', () {
      const input = '''
The shadows whispered quietly in the dark room tonight.
The shadows whispered quietly in the dark room this night.
''';

      final suggestions = RedundancyAnalyzer.analyze(input);
      final lineRedundancies = suggestions.where((s) => s.id.contains('redundancy_line'));

      expect(lineRedundancies, isNotEmpty);
      expect(lineRedundancies.first.explanation, contains('identical content'));
    });

    test('does not flag distinct poetic lines', () {
      const input = '''
The shadows whispered quietly in the dark room.
A sudden flash of lightning illuminated the sky outside.
''';

      final suggestions = RedundancyAnalyzer.analyze(input);
      final lineRedundancies = suggestions.where((s) => s.id.contains('redundancy_line'));

      expect(lineRedundancies, isEmpty);
    });

    test('returns empty list for clean input', () {
      const input = 'The silent river flows through the ancient valley under moonlight.';
      final suggestions = RedundancyAnalyzer.analyze(input);
      expect(suggestions, isEmpty);
    });
  });
}
