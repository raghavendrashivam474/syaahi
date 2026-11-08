import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syaahi_app/core/storage/onboarding_storage.dart';
import 'package:syaahi_app/features/welcome/welcome_screen.dart';

void main() {
  group('OnboardingStorage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('welcomeSeen defaults to false', () async {
      final storage = OnboardingStorage();
      expect(await storage.isWelcomeSeen(), isFalse);
    });

    test('markWelcomeSeen persists correctly', () async {
      final storage = OnboardingStorage();
      await storage.markWelcomeSeen();
      expect(await storage.isWelcomeSeen(), isTrue);
    });

    test('user feature defaults to false', () async {
      final storage = OnboardingStorage();
      expect(
        await storage.isUserFeatureCompleted('user1', 'walkthrough'),
        isFalse,
      );
    });

    test('markUserFeatureCompleted persists correctly', () async {
      final storage = OnboardingStorage();
      await storage.markUserFeatureCompleted('user1', 'walkthrough');
      expect(
        await storage.isUserFeatureCompleted('user1', 'walkthrough'),
        isTrue,
      );
    });

    test('clearUserStates removes only that user data', () async {
      final storage = OnboardingStorage();
      await storage.markUserFeatureCompleted('user1', 'walkthrough');
      await storage.markUserFeatureCompleted('user2', 'walkthrough');

      await storage.clearUserStates('user1');

      expect(
        await storage.isUserFeatureCompleted('user1', 'walkthrough'),
        isFalse,
      );
      expect(
        await storage.isUserFeatureCompleted('user2', 'walkthrough'),
        isTrue,
      );
    });

    test('contextual guidance persists per user per feature', () async {
      final storage = OnboardingStorage();
      await storage.markContextualSeen('user1', 'heart');

      expect(await storage.isContextualSeen('user1', 'heart'), isTrue);
      expect(await storage.isContextualSeen('user1', 'respond'), isFalse);
      expect(await storage.isContextualSeen('user2', 'heart'), isFalse);
    });

    test('clearAll removes everything', () async {
      final storage = OnboardingStorage();
      await storage.markWelcomeSeen();
      await storage.markUserFeatureCompleted('user1', 'walkthrough');

      await storage.clearAll();

      expect(await storage.isWelcomeSeen(), isFalse);
      expect(
        await storage.isUserFeatureCompleted('user1', 'walkthrough'),
        isFalse,
      );
    });
  });

  group('WelcomeScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders three pillars', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Express'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);
    });

    testWidgets('renders action buttons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Explore Syaahi'), findsOneWidget);
      expect(find.text('Join Syaahi'), findsOneWidget);
      expect(find.textContaining('Sign in'), findsOneWidget);
    });
  });
}
