import 'package:flutter_test/flutter_test.dart';
import 'package:syaahi_app/features/notifications/data/notifications_repository.dart';

void main() {
  group('NotificationPoem', () {
    test('parses with title', () {
      final json = {'id': 'poem-1', 'title': 'Midnight Ink'};
      final poem = NotificationPoem.fromJson(json);
      expect(poem.id, 'poem-1');
      expect(poem.title, 'Midnight Ink');
    });

    test('parses with null title', () {
      final json = {'id': 'poem-2', 'title': null};
      final poem = NotificationPoem.fromJson(json);
      expect(poem.id, 'poem-2');
      expect(poem.title, isNull);
    });
  });

  group('AppNotification', () {
    final fullJson = {
      'id': 'noti-1',
      'type': 'POEM_PUBLISHED',
      'poemId': 'poem-1',
      'readAt': '2025-01-15T10:30:00.000Z',
      'createdAt': '2025-01-15T09:00:00.000Z',
      'poem': {'id': 'poem-1', 'title': 'Midnight Ink'},
    };

    test('parses full notification', () {
      final n = AppNotification.fromJson(fullJson);
      expect(n.id, 'noti-1');
      expect(n.type, 'POEM_PUBLISHED');
      expect(n.poemId, 'poem-1');
      expect(n.readAt, isNotNull);
      expect(n.createdAt, DateTime.parse('2025-01-15T09:00:00.000Z'));
      expect(n.poem.id, 'poem-1');
      expect(n.poem.title, 'Midnight Ink');
    });

    test('isRead returns true when readAt is set', () {
      final n = AppNotification.fromJson(fullJson);
      expect(n.isRead, isTrue);
    });

    test('isRead returns false when readAt is null', () {
      final unreadJson = Map<String, dynamic>.from(fullJson)
        ..['readAt'] = null;
      final n = AppNotification.fromJson(unreadJson);
      expect(n.isRead, isFalse);
      expect(n.readAt, isNull);
    });

    test('handles null poem title', () {
      final json = Map<String, dynamic>.from(fullJson)
        ..['poem'] = {'id': 'poem-1', 'title': null};
      final n = AppNotification.fromJson(json);
      expect(n.poem.title, isNull);
    });
  });

  group('NotificationInboxResult', () {
    test('constructs correctly', () {
      final result = NotificationInboxResult(
        items: const [],
        nextCursor: 'cursor-abc',
      );
      expect(result.items, isEmpty);
      expect(result.nextCursor, 'cursor-abc');
    });
  });
}
