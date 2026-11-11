import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:syaahi_app/shared/models/poem.dart';
import 'package:syaahi_app/shared/models/user.dart';
import 'package:syaahi_app/features/resonance/data/resonance_repository.dart';
import 'package:syaahi_app/features/resonance/state/resonance_providers.dart';
import 'package:syaahi_app/features/resonance/presentation/response_item.dart';
import 'package:syaahi_app/features/auth/state/auth_providers.dart';

// ── Fakes ─────────────────────────────────────────────────────────

class _FakeResonanceRepo extends ResonanceRepository {
  bool failReply;
  int replyCallCount = 0;

  _FakeResonanceRepo({this.failReply = false}) : super(dio: Dio());

  @override
  Future<ResonanceListResult> listResponses(
    String poemId, {
    String? cursor,
    int limit = 20,
  }) async {
    return const ResonanceListResult(responses: []);
  }

  @override
  Future<ResonanceReplyModel> createReply(
    String responseId,
    String content,
  ) async {
    replyCallCount++;
    if (failReply) {
      throw ResonanceException('Failed to post reply');
    }
    return ResonanceReplyModel(
      id: 'reply-new',
      responseId: responseId,
      authorId: 'author-100',
      content: content,
      author: const PoemAuthor(
        id: 'author-100',
        username: 'poet100',
        displayName: 'Poet One Hundred',
        avatarUrl: null,
      ),
      createdAt: DateTime(2026, 11, 7),
      updatedAt: DateTime(2026, 11, 7),
    );
  }
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(super.repo) {
    state = const AuthState(
      user: User(
        id: 'author-100',
        email: 'poet@test.com',
        username: 'poet100',
        displayName: 'Poet One Hundred',
      ),
    );
  }
}

// ── Test Data ─────────────────────────────────────────────────────

const _poet = PoemAuthor(
  id: 'author-100',
  username: 'poet100',
  displayName: 'Poet One Hundred',
  avatarUrl: null,
);

const _reader = PoemAuthor(
  id: 'user-1',
  username: 'reader1',
  displayName: 'Reader One',
  avatarUrl: null,
);

final _now = DateTime(2026, 11, 7);

ResonanceResponseModel _noReplyResponse() => ResonanceResponseModel(
      id: 'resp-1',
      poemId: 'poem-1',
      userId: 'user-1',
      content: 'This poem moved me deeply.',
      user: _reader,
      createdAt: _now,
      updatedAt: _now,
    );

ResonanceResponseModel _withReplyResponse() => ResonanceResponseModel(
      id: 'resp-1',
      poemId: 'poem-1',
      userId: 'user-1',
      content: 'This poem moved me deeply.',
      user: _reader,
      reply: ResonanceReplyModel(
        id: 'reply-1',
        responseId: 'resp-1',
        authorId: 'author-100',
        content: 'Thank you for reading.',
        author: _poet,
        createdAt: _now,
        updatedAt: _now,
      ),
      createdAt: _now,
      updatedAt: _now,
    );

// ── Helpers ───────────────────────────────────────────────────────

Widget _buildItem({
  required _FakeResonanceRepo repo,
  String authorId = 'author-100',
  ResonanceResponseModel? response,
}) {
  return ProviderScope(
    overrides: [
      resonanceRepositoryProvider.overrideWithValue(repo),
      authProvider.overrideWith(
        (ref) => _TestAuthNotifier(ref.read(authRepositoryProvider)),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: ResponseItem(
          poemId: 'poem-1',
          authorId: authorId,
          response: response ?? _noReplyResponse(),
        ),
      ),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────

void main() {
  group('Repository: createReply', () {
    test('returns ResonanceReplyModel on success', () async {
      final repo = _FakeResonanceRepo();
      final reply = await repo.createReply('resp-1', 'Thank you!');
      expect(reply.content, 'Thank you!');
      expect(reply.responseId, 'resp-1');
      expect(repo.replyCallCount, 1);
    });

    test('throws ResonanceException on failure', () async {
      final repo = _FakeResonanceRepo(failReply: true);
      expect(
        () => repo.createReply('resp-1', 'test'),
        throwsA(isA<ResonanceException>()),
      );
    });
  });

  group('Provider: submitReply lifecycle', () {
    test('initial state has isSubmitting false', () async {
      final repo = _FakeResonanceRepo();
      final container = ProviderContainer(
        overrides: [
          resonanceRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(resonanceProvider('poem-1'));
      expect(state.isSubmitting, isFalse);
    });

    test('actionError is null initially', () async {
      final repo = _FakeResonanceRepo();
      final container = ProviderContainer(
        overrides: [
          resonanceRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(resonanceProvider('poem-1'));
      expect(state.actionError, isNull);
    });
  });

  group('Widget: Reply composer visibility (AC-01, AC-08)', () {
    testWidgets('Post Reply visible for poem author with no reply',
        (tester) async {
      final repo = _FakeResonanceRepo();
      await tester.pumpWidget(_buildItem(repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('Acknowledge / Reply as Author'), findsOneWidget);

      await tester.tap(find.text('Acknowledge / Reply as Author'));
      await tester.pumpAndSettle();

      expect(find.text('Post Reply'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Reply button hidden for non-author', (tester) async {
      final repo = _FakeResonanceRepo();
      await tester.pumpWidget(
        _buildItem(repo: repo, authorId: 'someone-else'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Acknowledge / Reply as Author'), findsNothing);
      expect(find.text('Post Reply'), findsNothing);
    });

    testWidgets('Reply button hidden when reply already exists',
        (tester) async {
      final repo = _FakeResonanceRepo();
      await tester.pumpWidget(
        _buildItem(repo: repo, response: _withReplyResponse()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Acknowledge / Reply as Author'), findsNothing);
      expect(find.text('Author Reply'), findsOneWidget);
    });
  });

  group('Widget: Reply validation (AC-02)', () {
    testWidgets('Post Reply disabled when text is empty', (tester) async {
      final repo = _FakeResonanceRepo();
      await tester.pumpWidget(_buildItem(repo: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Acknowledge / Reply as Author'));
      await tester.pumpAndSettle();

      final btn = find.widgetWithText(ElevatedButton, 'Post Reply');
      expect(btn, findsOneWidget);
      expect(tester.widget<ElevatedButton>(btn).onPressed, isNull);
    });

    testWidgets('Post Reply enabled when valid text entered', (tester) async {
      final repo = _FakeResonanceRepo();
      await tester.pumpWidget(_buildItem(repo: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Acknowledge / Reply as Author'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Thank you for reading!',
      );
      await tester.pumpAndSettle();

      final btn = find.widgetWithText(ElevatedButton, 'Post Reply');
      expect(tester.widget<ElevatedButton>(btn).onPressed, isNotNull);
    });
  });

  group('Widget: Error handling (AC-07)', () {
    testWidgets('Failed submission shows error and preserves draft',
        (tester) async {
      final repo = _FakeResonanceRepo(failReply: true);
      await tester.pumpWidget(_buildItem(repo: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Acknowledge / Reply as Author'));
      await tester.pumpAndSettle();

      const draft = 'My thoughtful reply';
      await tester.enterText(find.byType(TextField), draft);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Post Reply'));
      await tester.pumpAndSettle();

      // Error SnackBar should appear
      expect(find.textContaining('Failed'), findsWidgets);

      // Draft preserved: TextField still contains the text
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.controller?.text, contains(draft));
    });
  });
}


