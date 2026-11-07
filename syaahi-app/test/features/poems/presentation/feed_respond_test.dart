import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:syaahi_app/shared/models/poem.dart';
import 'package:syaahi_app/features/poems/state/poems_providers.dart';
import 'package:syaahi_app/features/poems/data/poems_repository.dart';
import 'package:syaahi_app/features/poems/presentation/feed_screen.dart';
import 'package:syaahi_app/features/resonance/data/resonance_repository.dart';
import 'package:syaahi_app/features/resonance/state/resonance_providers.dart';
import 'package:dio/dio.dart';

// ── Fakes ─────────────────────────────────────────────────────────

class _FakePoemsRepository extends PoemsRepository {
  _FakePoemsRepository() : super(dio: Dio());

  @override
  Future<bool> getHeartStatus(String poemId) async => false;

  @override
  Future<List<ReactionSummary>> getReactions(String poemId) async => [];

  @override
  Future<PoemFeedResult> listPoems({
    String? cursor,
    int limit = 10,
    FeedFilters? filters,
  }) async => PoemFeedResult(poems: [_testPoem]);
}

class _FakeResonanceRepository extends ResonanceRepository {
  _FakeResonanceRepository() : super(dio: Dio());

  @override
  Future<ResonanceListResult> listResponses(
    String poemId, {
    String? cursor,
    int limit = 20,
  }) async => const ResonanceListResult(responses: []);
}

// ── Test Data ─────────────────────────────────────────────────────

final _now = DateTime(2025, 6, 15);

const _testAuthor = PoemAuthor(
  id: 'author-1',
  username: 'testpoet',
  displayName: 'Test Poet',
  avatarUrl: null,
  bio: 'A test poet',
);

final _testPoem = Poem(
  id: 'poem-1',
  title: 'Midnight Ink',
  content: 'The stars write letters\nin silver light.',
  language: PoemLanguage.english,
  emotion: PoemEmotion.solitude,
  theme: 'night',
  author: _testAuthor,
  reactionCount: 0,
  heartCount: 0,
  createdAt: _now,
);

// ── Helpers ───────────────────────────────────────────────────────

Future<void> _pumpFrames(WidgetTester tester, {int frames = 20}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Drain all pending timers including the ApiClient 3-second
/// token-retrieval timeout, then dispose the widget tree.
Future<void> _tearDown(WidgetTester tester) async {
  // The ApiClient interceptor uses .timeout(Duration(seconds: 3)).
  // If a real Dio request was triggered during the test, that timer
  // is still pending in the fake async zone. Pump past it.
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

// ── Tests ─────────────────────────────────────────────────────────

void main() {
  group('Feed Respond action', () {
    testWidgets('Respond text is present in poem card', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => ProviderScope(
              overrides: [
                poemsRepositoryProvider.overrideWithValue(
                    _FakePoemsRepository()),
                resonanceRepositoryProvider.overrideWithValue(
                    _FakeResonanceRepository()),
              ],
              child: const FeedScreen(),
            ),
          ),
          GoRoute(
            path: '/poem/:id',
            builder: (_, state) => Text(
              'Poem ${state.pathParameters["id"]}',
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      await _pumpFrames(tester);

      // Assert WHILE the tree is alive.
      expect(find.text('Respond'), findsWidgets);

      // Drain timers and dispose.
      await _tearDown(tester);
    });

    testWidgets('tapping Respond navigates with focus=resonance',
        (tester) async {
      String? navigatedLocation;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => ProviderScope(
              overrides: [
                poemsRepositoryProvider.overrideWithValue(
                    _FakePoemsRepository()),
                resonanceRepositoryProvider.overrideWithValue(
                    _FakeResonanceRepository()),
              ],
              child: const FeedScreen(),
            ),
          ),
          GoRoute(
            path: '/poem/:id',
            builder: (_, state) {
              navigatedLocation =
                  '/poem/${state.pathParameters["id"]}'
                  '?focus=${state.uri.queryParameters["focus"]}';
              return const Scaffold(body: Text('Reader'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      await _pumpFrames(tester);

      // Tap Respond.
      final respondFinder = find.text('Respond').first;
      await tester.tap(respondFinder);
      await _pumpFrames(tester);

      // Assert WHILE the tree is alive.
      expect(navigatedLocation, contains('poem-1'));
      expect(navigatedLocation, contains('focus=resonance'));

      // Drain timers and dispose.
      await _tearDown(tester);
    });
  });
}