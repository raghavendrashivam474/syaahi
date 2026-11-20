import 'package:flutter_test/flutter_test.dart';
import 'package:syaahi_app/features/studio/domain/models/draft_poem.dart';
import 'package:syaahi_app/shared/models/poem.dart';

void main() {
  group('DraftPoem Domain Model Tests', () {
    test('DraftPoem instantiates with default values', () {
      final now = DateTime.now();
      final draft = DraftPoem(
        id: 'draft-1',
        ownerId: 'user-1',
        content: 'Unspoken thoughts...',
        createdAt: now,
        updatedAt: now,
      );

      expect(draft.id, equals('draft-1'));
      expect(draft.ownerId, equals('user-1'));
      expect(draft.content, equals('Unspoken thoughts...'));
      expect(draft.language, equals(PoemLanguage.english));
      expect(draft.isPublished, isFalse);
      expect(draft.syncStatus, equals(SyncStatus.localOnly));
      expect(draft.version, equals(1));
    });

    test('DraftPoem copyWith correctly overrides fields', () {
      final now = DateTime.now();
      final draft = DraftPoem(
        id: 'draft-1',
        ownerId: 'user-1',
        content: 'Original content',
        createdAt: now,
        updatedAt: now,
      );

      final updated = draft.copyWith(
        title: 'New Title',
        content: 'Updated content',
        syncStatus: SyncStatus.synced,
        version: 2,
      );

      expect(updated.id, equals('draft-1'));
      expect(updated.title, equals('New Title'));
      expect(updated.content, equals('Updated content'));
      expect(updated.syncStatus, equals(SyncStatus.synced));
      expect(updated.version, equals(2));
    });

    test('SyncStatus labels map correctly', () {
      expect(SyncStatus.localOnly.label, equals('Local'));
      expect(SyncStatus.pendingSync.label, equals('Syncing...'));
      expect(SyncStatus.synced.label, equals('Synced'));
      expect(SyncStatus.syncFailed.label, equals('Sync Failed'));
    });
  });
}
