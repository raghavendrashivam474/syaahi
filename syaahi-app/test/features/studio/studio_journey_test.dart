import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syaahi_app/features/studio/data/local/studio_database.dart';
import 'package:syaahi_app/features/studio/data/remote/remote_draft_repository.dart';
import 'package:syaahi_app/features/studio/data/repositories/local_draft_repository.dart';
import 'package:syaahi_app/features/studio/data/services/draft_sync_service.dart';
import 'package:syaahi_app/features/studio/domain/models/draft_poem.dart';
import 'package:syaahi_app/features/studio/state/studio_providers.dart';
import 'package:syaahi_app/shared/models/poem.dart';

const String guestId = 'guest_local';

/// Delegates to a real SQLite-backed repo and counts write operations,
/// so the 500ms debounce can be proven structurally (one write, final content).
class CountingLocalRepo implements LocalDraftRepository {
  final LocalDraftRepository inner;
  int saveCalls = 0;

  CountingLocalRepo(this.inner);

  @override
  Future<void> saveDraft(DraftPoem draft) async {
    saveCalls++;
    await inner.saveDraft(draft);
  }

  @override
  Future<DraftPoem?> getDraft(String id, String ownerId) =>
      inner.getDraft(id, ownerId);

  @override
  Future<List<DraftPoem>> listDrafts(String ownerId) =>
      inner.listDrafts(ownerId);

  @override
  Future<void> deleteDraft(String id, String ownerId) =>
      inner.deleteDraft(id, ownerId);

  @override
  Future<void> updateSyncStatus(String id, SyncStatus status) =>
      inner.updateSyncStatus(id, status);

  @override
  Stream<List<DraftPoem>> watchDrafts(String ownerId) =>
      inner.watchDrafts(ownerId);
}

/// Deterministic offline stub for the backend.
/// The guest journey must perform zero remote writes; only publish is allowed.
class FakeRemoteRepo implements RemoteDraftRepository {
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  int publishCalls = 0;
  int listCalls = 0;

  Poem _builtPoem() {
    final now = DateTime.now().toIso8601String();
    return Poem.fromJson(<String, dynamic>{
      'id': 'poem-from-st-01-test',
      'title': 'First Verse',
      'content': 'final lines',
      'language': 'ENGLISH',
      'author': <String, dynamic>{
        'id': guestId,
        'username': 'guest_poet',
        'displayName': 'Guest Poet',
      },
      'createdAt': now,
    });
  }

  @override
  Future<DraftPoem> createDraft(DraftPoem draft) async {
    createCalls++;
    return draft.copyWith(version: draft.version + 1);
  }

  @override
  Future<List<DraftPoem>> listDrafts(String ownerId) async {
    listCalls++;
    return <DraftPoem>[];
  }

  @override
  Future<DraftPoem> updateDraft(DraftPoem draft) async {
    updateCalls++;
    return draft.copyWith(version: draft.version + 1);
  }

  @override
  Future<void> deleteDraft(String id) async {
    deleteCalls++;
  }

  @override
  Future<Poem> publishDraft(String id) async {
    publishCalls++;
    return _builtPoem();
  }
}

void main() {
  Directory? tempDir;
  late String dbPath;

  // Session 1 — first app run
  StudioDatabase? db1;
  ProviderContainer? container1;
  CountingLocalRepo? local1;
  FakeRemoteRepo? remote1;
  late StudioNotifier notifier1;
  String draftId = '';

  // Session 2 — app restart against the same device storage
  StudioDatabase? db2;
  ProviderContainer? container2;
  CountingLocalRepo? local2;
  FakeRemoteRepo? remote2;
  late StudioNotifier notifier2;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('studio_journey');
    dbPath = tempDir!.path + Platform.pathSeparator + 'journey.db';
  });

  tearDownAll(() async {
    // Dispose containers first so notifier debounce timers are cancelled
    // before their database handles are closed.
    container1?.dispose();
    container2?.dispose();
    await db1?.close();
    await db2?.close();
    final dir = tempDir;
    if (dir != null && dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  });

  group('ST-01 draft journey (guest, offline-first)', () {
    test('creates a new local draft in guest mode', () async {
      db1 = StudioDatabase(NativeDatabase(File(dbPath)));
      local1 = CountingLocalRepo(LocalDraftRepository(db1!));
      remote1 = FakeRemoteRepo();
      container1 = ProviderContainer(overrides: [
        studioDatabaseProvider.overrideWithValue(db1!),
        localDraftRepositoryProvider.overrideWithValue(local1!),
        remoteDraftRepositoryProvider.overrideWithValue(remote1!),
        draftSyncServiceProvider.overrideWithValue(
          DraftSyncService(local1!, remote1!),
        ),
      ]);

      notifier1 = container1!.read(studioProvider.notifier);
      await notifier1.loadDrafts();

      expect(notifier1.state.drafts, isEmpty);
      expect(notifier1.state.currentDraft, isNull);

      notifier1.createNewDraft();

      final draft = notifier1.state.currentDraft;
      expect(draft, isNotNull);
      expect(draft!.ownerId, guestId);
      expect(draft.title, isEmpty);
      expect(draft.content, isEmpty);
      expect(draft.syncStatus, SyncStatus.localOnly);
      expect(draft.isPublished, isFalse);
      draftId = draft.id;

      // Creation stays in memory; the first debounced autosave persists.
      expect(local1!.saveCalls, 0);
      expect(remote1!.createCalls, 0);
    });

    test('500ms debounced autosave persists final content exactly once', () async {
      notifier1.updateTitle('First Verse');
      notifier1.updateContent('line one');
      // Keystrokes inside the debounce window must collapse into one write.
      notifier1.updateContent('line one\nline two');

      await Future<void>.delayed(const Duration(milliseconds: 800));

      expect(notifier1.state.saveStatus, SaveStatus.savedLocally);
      expect(local1!.saveCalls, 1);

      final persisted = await local1!.inner.getDraft(draftId, guestId);
      expect(persisted, isNotNull);
      expect(persisted!.title, 'First Verse');
      expect(persisted.content, 'line one\nline two');
      expect(persisted.syncStatus, SyncStatus.localOnly);

      expect(notifier1.state.drafts.length, 1);

      // Offline-first: guest session performed zero remote calls.
      expect(remote1!.createCalls, 0);
      expect(remote1!.updateCalls, 0);
    });

    test('close app and reopen: draft survives restart via SQLite', () async {
      container1!.dispose();
      await db1!.close();
      container1 = null;
      db1 = null;

      db2 = StudioDatabase(NativeDatabase(File(dbPath)));
      local2 = CountingLocalRepo(LocalDraftRepository(db2!));
      remote2 = FakeRemoteRepo();
      container2 = ProviderContainer(overrides: [
        studioDatabaseProvider.overrideWithValue(db2!),
        localDraftRepositoryProvider.overrideWithValue(local2!),
        remoteDraftRepositoryProvider.overrideWithValue(remote2!),
        draftSyncServiceProvider.overrideWithValue(
          DraftSyncService(local2!, remote2!),
        ),
      ]);

      notifier2 = container2!.read(studioProvider.notifier);
      await notifier2.loadDrafts();

      expect(notifier2.state.drafts.length, 1);
      final reopened = notifier2.state.drafts.first;
      expect(reopened.id, draftId);
      expect(reopened.title, 'First Verse');
      expect(reopened.content, 'line one\nline two');
    });

    test('continue writing after reopen persists again', () async {
      final reopened = notifier2.state.drafts.first;
      notifier2.selectDraft(reopened);
      expect(notifier2.state.currentDraft!.id, draftId);

      notifier2.updateContent('line one\nline two\nline three');
      await Future<void>.delayed(const Duration(milliseconds: 800));

      expect(notifier2.state.saveStatus, SaveStatus.savedLocally);
      final persisted = await local2!.inner.getDraft(draftId, guestId);
      expect(persisted!.content, 'line one\nline two\nline three');
    });

    test('publish guard rejects a blank draft without any remote call', () async {
      notifier2.updateContent('   ');
      await Future<void>.delayed(const Duration(milliseconds: 800));

      final result = await notifier2.publishCurrentDraft();

      expect(result, isNull);
      expect(notifier2.state.error, 'Cannot publish an empty draft');
      expect(notifier2.state.currentDraft, isNotNull);
      expect(remote2!.publishCalls, 0);
    });

    test('publish success clears editor and marks persisted draft published', () async {
      notifier2.updateContent('final lines');
      await Future<void>.delayed(const Duration(milliseconds: 800));

      final poem = await notifier2.publishCurrentDraft();

      expect(notifier2.state.error, isNull);
      expect(poem, isNotNull);
      expect(poem!.id, 'poem-from-st-01-test');
      expect(remote2!.publishCalls, 1);
      expect(notifier2.state.currentDraft, isNull);
      expect(notifier2.state.isPublishing, isFalse);
      expect(notifier2.state.error, isNull);

      final persisted = await local2!.inner.getDraft(draftId, guestId);
      expect(persisted, isNotNull);
      expect(persisted!.isPublished, isTrue);
      expect(persisted.syncStatus, SyncStatus.synced);

      // Published drafts drop out of the working list.
      await notifier2.loadDrafts();
      expect(notifier2.state.drafts.any((d) => d.id == draftId), isFalse);
    });
  });
}