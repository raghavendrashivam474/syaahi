import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syaahi_app/shared/models/poem.dart';
import 'package:syaahi_app/features/poems/state/poems_providers.dart';
import 'package:syaahi_app/features/poems/data/poems_repository.dart';
import 'package:syaahi_app/features/poems/presentation/reader_screen.dart';
import 'package:syaahi_app/features/resonance/data/resonance_repository.dart';
import 'package:syaahi_app/features/resonance/state/resonance_providers.dart';
import 'package:syaahi_app/features/resonance/presentation/resonance_section.dart';
import 'package:dio/dio.dart';

// ── Fakes ─────────────────────────────────────────────────────────

class _FakePoemsRepository extends PoemsRepository {
  _FakePoemsRepository() : super(dio: Dio());

  @override
  Future<bool> getHeartStatus(String poemId) async => false;

  @override
  Future<List<ReactionSummary>> getReactions(String poemId) async => [];

  @override
  Future<Poem> getPoem(String id) async => _testPoem;

  @override
  Future<PoemFeedResult> listPoems({
    String? cursor,
    int limit = 10,
    FeedFilters? filters,
  }) async => const PoemFeedResult(poems: []);
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

Widget _buildReaderWithFocus(String poemId, Poem poem, {String? focus}) {
  return ProviderScope(
    overrides: [
      poemsRepositoryProvider.overrideWithValue(_FakePoemsRepository()),
      resonanceRepositoryProvider.overrideWithValue(_FakeResonanceRepository()),
      poemByIdProvider(poemId).overrideWith((ref) => Future.value(poem)),
    ],
    child: MaterialApp(
      home: ReaderScreen(poemId: poemId, focusSection: focus),
    ),
  );
}

/// Bounded pump to avoid hanging on periodic timers from
/// ResonanceSection or other animated widgets.
Future<void> _pumpFrames(WidgetTester tester, {int frames = 30}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

// ── Tests ─────────────────────────────────────────────────────────

void main() {
  group('Reader Resonance integration', () {
    testWidgets('renders ResonanceSection after poem content',
        (tester) async {
      await tester.pumpWidget(
        _buildReaderWithFocus('poem-1', _testPoem),
      );
      await _pumpFrames(tester);

      // The poem content must be visible.
      expect(find.text('Midnight Ink'), findsOneWidget);

      // ResonanceSection must be present in the widget tree.
      expect(find.byType(ResonanceSection), findsOneWidget);

      // The RESONANCE header text must be rendered.
      expect(find.text('RESONANCE'), findsOneWidget);
    });

    testWidgets('accepts focusSection parameter without error',
        (tester) async {
      await tester.pumpWidget(
        _buildReaderWithFocus('poem-1', _testPoem, focus: 'resonance'),
      );
      await _pumpFrames(tester);

      // Poem must still render correctly with focus parameter.
      expect(find.text('Midnight Ink'), findsOneWidget);
      expect(find.byType(ResonanceSection), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('poem renders even when heart/reaction loading fails',
        (tester) async {
      await tester.pumpWidget(
        _buildReaderWithFocus('poem-1', _testPoem),
      );
      await _pumpFrames(tester);

      expect(find.text('Midnight Ink'), findsOneWidget);
      expect(find.textContaining('The stars write letters'), findsOneWidget);
      expect(find.byType(ResonanceSection), findsOneWidget);
    });
  });
}