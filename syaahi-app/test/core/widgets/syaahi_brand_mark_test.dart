import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syaahi_app/core/widgets/syaahi_brand_mark.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyaahiBrandMark Widget Tests', () {
    testWidgets('renders logo image asset and semantics label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyaahiBrandMark(showWordmark: false),
          ),
        ),
      );

      // Verify Semantics label 'Syaahi Home' is present
      expect(find.bySemanticsLabel('Syaahi Home'), findsOneWidget);

      // Verify Image.asset is rendered
      expect(find.byType(Image), findsOneWidget);

      // Wordmark explicitly disabled -> no Text('Syaahi')
      expect(find.text('Syaahi'), findsNothing);
    });

    testWidgets('renders wordmark when showWordmark is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyaahiBrandMark(showWordmark: true),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Syaahi'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyaahiBrandMark(
              showWordmark: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SyaahiBrandMark));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
