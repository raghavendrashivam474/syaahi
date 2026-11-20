import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syaahi_app/features/studio/data/local/studio_database.dart';
import 'package:syaahi_app/features/studio/data/repositories/local_draft_repository.dart';
import 'package:syaahi_app/features/studio/domain/models/draft_poem.dart';
import 'package:syaahi_app/shared/models/poem.dart';

void main() {
  late StudioDatabase db;
  late LocalDraftRepository repo;

  setUp(() {
    // In-memory SQLite database for rapid, isolated testing
    db = StudioDatabase(NativeDatabase.memory());
    repo = LocalDraftRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('LocalDraftRepository SQLite Operations', () {
    test('saveDraft inserts and retrieves draft', () async {
      final now = DateTime.now();
      final draft = DraftPoem(
        id: 'draft-101',
        ownerId: 'user-a',
        title: 'Memory Verse',
        content: 'Stored in local SQLite...',
        language: PoemLanguage.hindi,
        createdAt: now,
        updatedAt: now,
      );

      await repo.saveDraft(draft);

      final retrieved = await repo.getDraft('draft-101', 'user-a');
      expect(retrieved, isNotNull);
      expect(retrieved!.title, equals('Memory Verse'));
      expect(retrieved.content, equals('Stored in local SQLite...'));
      expect(retrieved.language, equals(PoemLanguage.hindi));
    });

    test('listDrafts returns owner-scoped unpublished drafts sorted newest-first', () async {
      final baseTime = DateTime.now();
      final draft1 = DraftPoem(
        id: 'draft-1',
        ownerId: 'user-a',
        content: 'Older draft',
        createdAt: baseTime,
        updatedAt: baseTime.add(const Duration(minutes: 1)),
      );
      final draft2 = DraftPoem(
        id: 'draft-2',
        ownerId: 'user-a',
        content: 'Newer draft',
        createdAt: baseTime,
        updatedAt: baseTime.add(const Duration(minutes: 5)),
      );
      final draftB = DraftPoem(
        id: 'draft-b',
        ownerId: 'user-b',
        content: 'User B draft',
        createdAt: baseTime,
        updatedAt: baseTime,
      );

      await repo.saveDraft(draft1);
      await repo.saveDraft(draft2);
      await repo.saveDraft(draftB);

      final draftsA = await repo.listDrafts('user-a');
      expect(draftsA.length, equals(2));
      expect(draftsA[0].id, equals('draft-2')); // newest first
      expect(draftsA[1].id, equals('draft-1'));

      final draftsB = await repo.listDrafts('user-b');
      expect(draftsB.length, equals(1));
      expect(draftsB[0].id, equals('draft-b'));
    });

    test('deleteDraft removes specified draft from SQLite', () async {
      final now = DateTime.now();
      final draft = DraftPoem(
        id: 'draft-to-delete',
        ownerId: 'user-a',
        content: 'Will be deleted',
        createdAt: now,
        updatedAt: now,
      );

      await repo.saveDraft(draft);
      expect(await repo.getDraft('draft-to-delete', 'user-a'), isNotNull);

      await repo.deleteDraft('draft-to-delete', 'user-a');
      expect(await repo.getDraft('draft-to-delete', 'user-a'), isNull);
    });

    test('updateSyncStatus updates syncStatus column', () async {
      final now = DateTime.now();
      final draft = DraftPoem(
        id: 'draft-sync',
        ownerId: 'user-a',
        content: 'Sync test',
        syncStatus: SyncStatus.localOnly,
        createdAt: now,
        updatedAt: now,
      );

      await repo.saveDraft(draft);
      await repo.updateSyncStatus('draft-sync', SyncStatus.synced);

      final updated = await repo.getDraft('draft-sync', 'user-a');
      expect(updated!.syncStatus, equals(SyncStatus.synced));
    });
  });
}
