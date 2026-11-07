import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syaahi_app/shared/models/poem.dart';
import 'package:syaahi_app/features/resonance/data/resonance_repository.dart';
import 'package:syaahi_app/features/resonance/state/resonance_providers.dart';
import 'package:syaahi_app/features/resonance/presentation/response_composer.dart';
import 'package:syaahi_app/features/resonance/presentation/response_item.dart';
import 'package:syaahi_app/features/resonance/presentation/resonance_section.dart';

class _FakeResonanceRepository extends ResonanceRepository {
  @override
  Future<ResonanceListResult> listResponses(String poemId, {String? cursor, int limit = 20}) async {
    return const ResonanceListResult(responses: [], nextCursor: null);
  }

  @override
  Future<ResonanceResponseModel> createResponse(String poemId, String content) async {
    throw UnimplementedError();
  }
}

void main() {
  final now = DateTime(2026, 11, 7);

  const mockAuthor = PoemAuthor(
    id: 'user-1',
    username: 'reader1',
    displayName: 'Reader One',
    avatarUrl: null,
  );

  const mockPoet = PoemAuthor(
    id: 'author-100',
    username: 'poet100',
    displayName: 'Poet One Hundred',
    avatarUrl: null,
  );

  final mockPoem = Poem(
    id: 'poem-99',
    title: 'Echoes',
    content: 'A silent room',
    language: PoemLanguage.english,
    author: mockPoet,
    reactionCount: 0,
    heartCount: 0,
    createdAt: now,
  );

  group('Resonance Models Test', () {
    test('ResonanceResponseModel.fromJson parses correctly', () {
      final json = {
        'id': 'resp-1',
        'poemId': 'poem-123',
        'userId': 'user-1',
        'content': 'This verse moved me deeply.',
        'user': {
          'id': 'user-1',
          'username': 'reader1',
          'displayName': 'Reader One',
          'avatarUrl': null,
        },
        'createdAt': '2026-11-07T10:00:00.000Z',
        'updatedAt': '2026-11-07T10:00:00.000Z',
        'reply': {
          'id': 'reply-1',
          'responseId': 'resp-1',
          'authorId': 'author-100',
          'content': 'Thank you for reading and connecting.',
          'author': {
            'id': 'author-100',
            'username': 'poet100',
            'displayName': 'Poet One Hundred',
            'avatarUrl': null,
          },
          'createdAt': '2026-11-07T11:00:00.000Z',
          'updatedAt': '2026-11-07T11:00:00.000Z',
        }
      };

      final response = ResonanceResponseModel.fromJson(json);

      expect(response.id, equals('resp-1'));
      expect(response.poemId, equals('poem-123'));
      expect(response.content, equals('This verse moved me deeply.'));
      expect(response.user.displayName, equals('Reader One'));
      expect(response.reply, isNotNull);
      expect(response.reply!.content, equals('Thank you for reading and connecting.'));
    });
  });

  group('ResponseComposer Widget Test', () {
    testWidgets('displays placeholder and character count UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            resonanceRepositoryProvider.overrideWithValue(_FakeResonanceRepository()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ResponseComposer(
                poemId: 'poem-1',
              ),
            ),
          ),
        ),
      );

      expect(find.text('0 / 280'), findsOneWidget);
      expect(find.text('What did this poem make you feel or remember?'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Beautiful poetry');
      await tester.pump();

      expect(find.text('16 / 280'), findsOneWidget);
    });
  });

  group('ResponseItem Widget Test', () {
    testWidgets('renders response content and author reply badge', (WidgetTester tester) async {
      final mockResponse = ResonanceResponseModel(
        id: 'resp-1',
        poemId: 'poem-1',
        userId: 'user-1',
        content: 'Echoes of silence indeed.',
        user: mockAuthor,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        reply: ResonanceReplyModel(
          id: 'reply-1',
          responseId: 'resp-1',
          authorId: 'author-100',
          content: 'Grateful for your stillness.',
          author: mockPoet,
          createdAt: now.subtract(const Duration(hours: 1)),
          updatedAt: now.subtract(const Duration(hours: 1)),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            resonanceRepositoryProvider.overrideWithValue(_FakeResonanceRepository()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ResponseItem(
                poemId: 'poem-1',
                authorId: 'author-100',
                response: mockResponse,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Reader One'), findsOneWidget);
      expect(find.text('Echoes of silence indeed.'), findsOneWidget);
      expect(find.text('Author Reply'), findsOneWidget);
      expect(find.text('Grateful for your stillness.'), findsOneWidget);
    });
  });

  group('ResonanceSection Widget Test', () {
    testWidgets('renders resonance header and empty state when no responses', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            resonanceRepositoryProvider.overrideWithValue(_FakeResonanceRepository()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ResonanceSection(
                  poem: mockPoem,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('RESONANCE'), findsOneWidget);
      expect(find.text('Share what this poem made you feel or connect with.'), findsOneWidget);
    });
  });
}