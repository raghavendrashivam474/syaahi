import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/poem.dart';
import '../../auth/state/auth_providers.dart';
import '../data/local/studio_database.dart';
import '../data/repositories/local_draft_repository.dart';
import '../data/remote/remote_draft_repository.dart';
import '../data/services/draft_sync_service.dart';
import '../domain/models/draft_poem.dart';

// Database Singleton Provider
final studioDatabaseProvider = Provider<StudioDatabase>((ref) {
  final db = StudioDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Repository Providers
final localDraftRepositoryProvider = Provider<LocalDraftRepository>((ref) {
  return LocalDraftRepository(ref.watch(studioDatabaseProvider));
});

final remoteDraftRepositoryProvider = Provider<RemoteDraftRepository>((ref) {
  return RemoteDraftRepository();
});

final draftSyncServiceProvider = Provider<DraftSyncService>((ref) {
  return DraftSyncService(
    ref.watch(localDraftRepositoryProvider),
    ref.watch(remoteDraftRepositoryProvider),
  );
});

// Editor Save Status Enum
enum SaveStatus {
  idle,
  savingLocally,
  savedLocally,
  syncing,
  synced,
  failed;

  String get label => switch (this) {
        SaveStatus.idle => '',
        SaveStatus.savingLocally => 'Saving...',
        SaveStatus.savedLocally => 'Saved locally',
        SaveStatus.syncing => 'Syncing to cloud...',
        SaveStatus.synced => 'Synced',
        SaveStatus.failed => 'Save failed',
      };
}

// Studio State Model
class StudioState {
  final List<DraftPoem> drafts;
  final DraftPoem? currentDraft;
  final bool isLoading;
  final bool isPublishing;
  final SaveStatus saveStatus;
  final String? error;

  const StudioState({
    this.drafts = const [],
    this.currentDraft,
    this.isLoading = false,
    this.isPublishing = false,
    this.saveStatus = SaveStatus.idle,
    this.error,
  });

  StudioState copyWith({
    List<DraftPoem>? drafts,
    DraftPoem? currentDraft,
    bool clearCurrentDraft = false,
    bool? isLoading,
    bool? isPublishing,
    SaveStatus? saveStatus,
    String? error,
    bool clearError = false,
  }) {
    return StudioState(
      drafts: drafts ?? this.drafts,
      currentDraft: clearCurrentDraft ? null : (currentDraft ?? this.currentDraft),
      isLoading: isLoading ?? this.isLoading,
      isPublishing: isPublishing ?? this.isPublishing,
      saveStatus: saveStatus ?? this.saveStatus,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Studio State Notifier
class StudioNotifier extends StateNotifier<StudioState> {
  static const _uuid = Uuid();
  final LocalDraftRepository _localRepo;
  final RemoteDraftRepository _remoteRepo;
  final DraftSyncService _syncService;
  final Ref _ref;
  Timer? _debounceTimer;

  StudioNotifier(this._localRepo, this._remoteRepo, this._syncService, this._ref)
      : super(const StudioState()) {
    loadDrafts();
  }

  String get _currentUserId => _ref.read(authProvider).user?.id ?? 'guest_local';

  Future<void> loadDrafts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final userId = _currentUserId;
      // 1. Load local drafts first
      final localDrafts = await _localRepo.listDrafts(userId);
      state = state.copyWith(drafts: localDrafts, isLoading: false);

      // 2. Background sync from remote
      if (userId != 'guest_local') {
        await _syncService.pullAndMergeRemoteDrafts(userId);
        final mergedDrafts = await _localRepo.listDrafts(userId);
        state = state.copyWith(drafts: mergedDrafts);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void createNewDraft() {
    final userId = _currentUserId;
    final newDraft = DraftPoem(
      id: _uuid.v4(), // or UUID
      ownerId: userId,
      title: '',
      content: '',
      language: PoemLanguage.english,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.localOnly,
    );

    state = state.copyWith(
      currentDraft: newDraft,
      saveStatus: SaveStatus.idle,
      clearError: true,
    );
  }

  void selectDraft(DraftPoem draft) {
    state = state.copyWith(
      currentDraft: draft,
      saveStatus: SaveStatus.idle,
      clearError: true,
    );
  }

  void updateTitle(String title) {
    final current = state.currentDraft;
    if (current == null) return;
    final updated = current.copyWith(
      title: title,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.localOnly,
    );
    state = state.copyWith(currentDraft: updated);
    _scheduleAutosave();
  }

  void updateContent(String content) {
    final current = state.currentDraft;
    if (current == null) return;
    final updated = current.copyWith(
      content: content,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.localOnly,
    );
    state = state.copyWith(currentDraft: updated);
    _scheduleAutosave();
  }

  void updateLanguage(PoemLanguage language) {
    final current = state.currentDraft;
    if (current == null) return;
    final updated = current.copyWith(
      language: language,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.localOnly,
    );
    state = state.copyWith(currentDraft: updated);
    _scheduleAutosave();
  }

  void updateEmotion(PoemEmotion? emotion) {
    final current = state.currentDraft;
    if (current == null) return;
    final updated = current.copyWith(
      emotion: emotion,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.localOnly,
    );
    state = state.copyWith(currentDraft: updated);
    _scheduleAutosave();
  }


  /// Immediately flushes any pending debounced autosave operation
  Future<void> flushPendingAutosave() async {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
      await _executeSave();
    }
  }
  void _scheduleAutosave() {
    state = state.copyWith(saveStatus: SaveStatus.savingLocally);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await _executeSave();
    });
  }

  Future<void> _executeSave() async {
    final draft = state.currentDraft;
    if (draft == null) return;

    try {
      // 1. Immediate local save
      await _localRepo.saveDraft(draft);
      state = state.copyWith(saveStatus: SaveStatus.savedLocally);

      // Refresh draft list
      final updatedList = await _localRepo.listDrafts(_currentUserId);
      state = state.copyWith(drafts: updatedList);

      // 2. Background Remote Sync (if authenticated)
      if (_currentUserId != 'guest_local') {
        state = state.copyWith(saveStatus: SaveStatus.syncing);
        final synced = await _syncService.syncDraft(draft);
        if (synced.syncStatus == SyncStatus.synced) {
          state = state.copyWith(
            currentDraft: synced,
            saveStatus: SaveStatus.synced,
          );
        } else {
          state = state.copyWith(saveStatus: SaveStatus.savedLocally);
        }
      }
    } catch (e) {
      state = state.copyWith(saveStatus: SaveStatus.failed);
    }
  }

  Future<void> deleteDraft(String draftId) async {
    final userId = _currentUserId;
    try {
      await _localRepo.deleteDraft(draftId, userId);
      if (userId != 'guest_local') {
        _remoteRepo.deleteDraft(draftId).catchError((_) {});
      }
      if (state.currentDraft?.id == draftId) {
        state = state.copyWith(clearCurrentDraft: true);
      }
      await loadDrafts();
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete draft: $e');
    }
  }

  Future<Poem?> publishCurrentDraft() async {
    final draft = state.currentDraft;
    if (draft == null || draft.content.trim().isEmpty) {
      state = state.copyWith(error: 'Cannot publish an empty draft');
      return null;
    }

    state = state.copyWith(isPublishing: true, clearError: true);

    try {
      // 1. Ensure latest state is saved locally
      await _localRepo.saveDraft(draft);

      // 2. Sync / Publish to backend
      final poem = await _remoteRepo.publishDraft(draft.id);

      // 3. Mark locally as published
      final publishedDraft = draft.copyWith(
        isPublished: true,
        syncStatus: SyncStatus.synced,
      );
      await _localRepo.saveDraft(publishedDraft);

      state = state.copyWith(
        isPublishing: false,
        clearCurrentDraft: true,
      );

      await loadDrafts();
      return poem;
    } catch (e) {
      state = state.copyWith(
        isPublishing: false,
        error: e.toString(),
      );
      return null;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final studioProvider = StateNotifierProvider<StudioNotifier, StudioState>((ref) {
  return StudioNotifier(
    ref.watch(localDraftRepositoryProvider),
    ref.watch(remoteDraftRepositoryProvider),
    ref.watch(draftSyncServiceProvider),
    ref,
  );
});


