import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syaahi_app/features/studio/presentation/widgets/writing_intelligence_sheet.dart';
import 'package:syaahi_app/features/studio/state/writing_intelligence_providers.dart';

void main() {
  group('WritingIntelligenceSheet Widget Tests', () {
    testWidgets('renders overview metrics and category tabs correctly', (tester) async {
      const sampleText = 'The dark night was dark and quiet.';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            writingIntelligenceProvider.overrideWith((ref) {
              final notifier = WritingIntelligenceNotifier();
              notifier.analyzeDocument(sampleText);
              return notifier;
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: WritingIntelligenceSheet(
                currentText: sampleText,
                onApplyReplacement: (start, end, replacement) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Writing Intelligence'), findsOneWidget);
      expect(find.text('Total Words'), findsOneWidget);
      expect(find.text('Unique'), findsOneWidget);
      expect(find.text('Suggestions'), findsOneWidget);

      // Verify category tab chips
      expect(find.textContaining('Repeated Words'), findsOneWidget);
      expect(find.textContaining('Phrases'), findsOneWidget);
      expect(find.textContaining('Redundancies'), findsOneWidget);
    });
  });
}

