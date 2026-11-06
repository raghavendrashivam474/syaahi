import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syaahi_app/shared/models/poem.dart';
import 'package:syaahi_app/features/poems/state/poems_providers.dart';
import 'package:syaahi_app/features/poems/data/poems_repository.dart';
import 'package:syaahi_app/features/poems/presentation/reader_screen.dart';

// ── Fake Repository ───────────────────────────────────────────────
// Overrides the network methods that _ReaderViewState calls in
// initState so that widget tests never hit a real HTTP endpoint.

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
  }) async => const PoemFeedResult(poems: []);
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
  content:
      'The stars write letters\nin silver light.\n\nI read them slowly\nthrough the night.',
  language: PoemLanguage.english,
  emotion: PoemEmotion.solitude,
  theme: 'night',
  author: _testAuthor,
  reactionCount: 3,
  heartCount: 7,
  createdAt: _now,
);

final _testPoemNoTitle = Poem(
  id: 'poem-2',
  title: null,
  content: 'A single stanza poem\nwith two lines.',
  language: PoemLanguage.hindi,
  emotion: null,
  theme: null,
  author: _testAuthor,
  reactionCount: 0,
  heartCount: 0,
  createdAt: _now,
);

final _testPoemEmpty = Poem(
  id: 'poem-3',
  title: 'Empty Vessel',
  content: '   ',
  language: PoemLanguage.english,
  emotion: null,
  theme: null,
  author: _testAuthor,
  reactionCount: 0,
  heartCount: 0,
  createdAt: _now,
);

final _testPoemLongTitle = Poem(
  id: 'poem-4',
  title:
      'This Is an Exceptionally Long Poem Title That Should Wrap Gracefully on All Screen Sizes',
  content: 'Short body.',
  language: PoemLanguage.urdu,
  emotion: PoemEmotion.love,
  theme: 'devotion',
  author: _testAuthor,
  reactionCount: 1,
  heartCount: 2,
  createdAt: _now,
);

// ── Helpers ───────────────────────────────────────────────────────

Widget _buildReader(String poemId, Poem poem) {
  return ProviderScope(
    overrides: [
      poemsRepositoryProvider.overrideWithValue(_FakePoemsRepository()),
      poemByIdProvider(poemId).overrideWith((ref) => Future.value(poem)),
    ],
    child: MaterialApp(home: ReaderScreen(poemId: poemId)),
  );
}

Widget _buildReaderError(String poemId, Object error) {
  return ProviderScope(
    overrides: [
      poemsRepositoryProvider.overrideWithValue(_FakePoemsRepository()),
      poemByIdProvider(poemId).overrideWith((ref) => Future.error(error)),
    ],
    child: MaterialApp(home: ReaderScreen(poemId: poemId)),
  );
}

Widget _buildReaderLoading(String poemId) {
  return ProviderScope(
    overrides: [
      poemsRepositoryProvider.overrideWithValue(_FakePoemsRepository()),
      poemByIdProvider(poemId).overrideWith(
        (ref) => Future.delayed(const Duration(seconds: 10), () => _testPoem),
      ),
    ],
    child: MaterialApp(home: ReaderScreen(poemId: poemId)),
  );
}

// ── Tests ─────────────────────────────────────────────────────────

void main() {
  group('Poem model', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'p1',
        'title': 'Test',
        'content': 'Hello world',
        'language': 'ENGLISH',
        'emotion': 'LOVE',
        'theme': 'nature',
        'author': {
          'id': 'a1',
          'username': 'poet',
          'displayName': 'Poet',
          'avatarUrl': null,
          'bio': null,
        },
        '_count': {'reactions': 5, 'hearts': 10},
        'createdAt': '2025-01-01T00:00:00.000Z',
      };
      final poem = Poem.fromJson(json);
      expect(poem.id, 'p1');
      expect(poem.title, 'Test');
      expect(poem.content, 'Hello world');
      expect(poem.language, PoemLanguage.english);
      expect(poem.emotion, PoemEmotion.love);
      expect(poem.theme, 'nature');
      expect(poem.author.username, 'poet');
      expect(poem.reactionCount, 5);
      expect(poem.heartCount, 10);
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'p2',
        'title': null,
        'content': 'No title poem',
        'language': 'HINDI',
        'emotion': null,
        'theme': null,
        'author': {
          'id': 'a1',
          'username': 'poet',
          'displayName': 'Poet',
        },
        'createdAt': '2025-01-01T00:00:00.000Z',
      };
      final poem = Poem.fromJson(json);
      expect(poem.title, isNull);
      expect(poem.emotion, isNull);
      expect(poem.theme, isNull);
      expect(poem.reactionCount, 0);
      expect(poem.heartCount, 0);
    });

    test('PoemEmotion emoji and label mapping is complete', () {
      for (final e in PoemEmotion.values) {
        expect(e.emoji, isNotEmpty, reason: '${e.name} missing emoji');
        expect(e.label, isNotEmpty, reason: '${e.name} missing label');
      }
    });

    test('PoemLanguage label and apiValue mapping is complete', () {
      for (final l in PoemLanguage.values) {
        expect(l.label, isNotEmpty, reason: '${l.name} missing label');
        expect(l.apiValue, isNotEmpty, reason: '${l.name} missing apiValue');
      }
    });
  });

  group('Poem content formatting', () {
    test('stanzas split correctly on double newlines', () {
      const content = 'Stanza one\nline two.\n\nStanza two\nline two.';
      final stanzas = content.split(RegExp(r'\n\s*\n'));
      expect(stanzas.length, 2);
      expect(stanzas[0], contains('Stanza one'));
      expect(stanzas[1], contains('Stanza two'));
    });

    test('single stanza poem produces one block', () {
      const content = 'Just one stanza\nwith two lines.';
      final stanzas = content.split(RegExp(r'\n\s*\n'));
      expect(stanzas.length, 1);
    });

    test('empty content is detected', () {
      expect('   '.trim().isEmpty, isTrue);
      expect(''.trim().isEmpty, isTrue);
      expect('Hello'.trim().isEmpty, isFalse);
    });

    test('unicode and emoji content preserved', () {
      const content = 'dil ki baat \u2764\uFE0F\n\nhindi shayari \uD83C\uDF19';
      expect(content, contains('\u2764\uFE0F'));
      expect(content, contains('\uD83C\uDF19'));
    });
  });

  group('FeedFilters', () {
    test('isEmpty returns true when no filters set', () {
      const filters = FeedFilters();
      expect(filters.isEmpty, isTrue);
    });

    test('isEmpty returns false when emotion set', () {
      const filters = FeedFilters(emotion: PoemEmotion.love);
      expect(filters.isEmpty, isFalse);
    });

    test('copyWith clearEmotion works', () {
      const filters = FeedFilters(emotion: PoemEmotion.love);
      final cleared = filters.copyWith(clearEmotion: true);
      expect(cleared.emotion, isNull);
      expect(cleared.isEmpty, isTrue);
    });

    test('toQueryParams only includes set filters', () {
      const filters = FeedFilters(emotion: PoemEmotion.hope);
      final params = filters.toQueryParams();
      expect(params.containsKey('emotion'), isTrue);
      expect(params.containsKey('language'), isFalse);
      expect(params.containsKey('theme'), isFalse);
    });
  });

  group('HeartStatus', () {
    test('isHearted only for hearted state', () {
      expect(HeartStatus.hearted.isHearted, isTrue);
      expect(HeartStatus.notHearted.isHearted, isFalse);
      expect(HeartStatus.unknown.isHearted, isFalse);
    });

    test('isLoading for loading and updating', () {
      expect(HeartStatus.loading.isLoading, isTrue);
      expect(HeartStatus.updating.isLoading, isTrue);
      expect(HeartStatus.hearted.isLoading, isFalse);
    });

    test('isInteractive for hearted and notHearted', () {
      expect(HeartStatus.hearted.isInteractive, isTrue);
      expect(HeartStatus.notHearted.isInteractive, isTrue);
      expect(HeartStatus.loading.isInteractive, isFalse);
      expect(HeartStatus.unknown.isInteractive, isFalse);
    });
  });

  group('ReaderScreen widget', () {
    testWidgets('renders calm loading state', (tester) async {
      await tester.pumpWidget(_buildReaderLoading('poem-1'));
      // Pump one frame to trigger the build, but do NOT settle
      // because the future is intentionally delayed.
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('Opening poem'), findsOneWidget);

      // Flush the pending 10-second timer so the test framework
      // does not complain about a dangling timer.
      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('renders poem content on success', (tester) async {
      await tester.pumpWidget(_buildReader('poem-1', _testPoem));
      await tester.pumpAndSettle();

      expect(find.text('Midnight Ink'), findsOneWidget);
      expect(find.textContaining('Test Poet'), findsWidgets);
      expect(find.textContaining('The stars write letters'), findsOneWidget);
      expect(find.textContaining('I read them slowly'), findsOneWidget);
    });

    testWidgets('renders error state with retry', (tester) async {
      await tester.pumpWidget(
        _buildReaderError('poem-1', PoemsException('Network error')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load this poem.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('renders 404 state without retry', (tester) async {
      await tester.pumpWidget(
        _buildReaderError(
          'poem-1',
          PoemsException('Not found', statusCode: 404),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Poem not found.'), findsOneWidget);
      expect(find.text('Try Again'), findsNothing);
    });

    testWidgets('handles poem with no title', (tester) async {
      await tester.pumpWidget(_buildReader('poem-2', _testPoemNoTitle));
      await tester.pumpAndSettle();

      expect(find.textContaining('Test Poet'), findsWidgets);
      expect(find.textContaining('A single stanza poem'), findsOneWidget);
    });

    testWidgets('handles empty poem content gracefully', (tester) async {
      await tester.pumpWidget(_buildReader('poem-3', _testPoemEmpty));
      await tester.pumpAndSettle();

      expect(find.text('Empty Vessel'), findsOneWidget);
      expect(find.text('This poem has no content.'), findsOneWidget);
    });

    testWidgets('renders long title without overflow', (tester) async {
      await tester.pumpWidget(_buildReader('poem-4', _testPoemLongTitle));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('This Is an Exceptionally Long'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows heart section', (tester) async {
      await tester.pumpWidget(_buildReader('poem-1', _testPoem));
      await tester.pumpAndSettle();

      expect(find.text('Commit to Heart'), findsOneWidget);
    });

    testWidgets('shows author continuity card', (tester) async {
      await tester.pumpWidget(_buildReader('poem-1', _testPoem));
      await tester.pumpAndSettle();

      expect(find.text('More from Test Poet'), findsOneWidget);
      expect(find.text('Explore their poetry'), findsOneWidget);
    });
  });
}