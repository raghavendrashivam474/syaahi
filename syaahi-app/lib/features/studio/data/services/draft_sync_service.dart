import '../../domain/models/draft_poem.dart';
import '../repositories/local_draft_repository.dart';
import '../remote/remote_draft_repository.dart';

class DraftSyncService {
  final LocalDraftRepository _localRepo;
  final RemoteDraftRepository _remoteRepo;

  DraftSyncService(this._localRepo, this._remoteRepo);

  /// Synchronize a single local draft with the backend safely
  Future<DraftPoem> syncDraft(DraftPoem draft) async {
    if (draft.syncStatus == SyncStatus.synced) return draft;

    await _localRepo.updateSyncStatus(draft.id, SyncStatus.pendingSync);

    try {
      DraftPoem remoteDraft;
      if (draft.syncStatus == SyncStatus.localOnly) {
        // Try creating remotely
        try {
          remoteDraft = await _remoteRepo.createDraft(draft);
        } on RemoteDraftException catch (e) {
          if (e.statusCode == 409 || e.statusCode == 400) {
            // Might already exist on remote, try updating
            remoteDraft = await _remoteRepo.updateDraft(draft);
          } else {
            rethrow;
          }
        }
      } else {
        // Update existing remote draft
        remoteDraft = await _remoteRepo.updateDraft(draft);
      }

      final syncedDraft = draft.copyWith(
        syncStatus: SyncStatus.synced,
        version: remoteDraft.version,
        updatedAt: remoteDraft.updatedAt,
      );

      await _localRepo.saveDraft(syncedDraft);
      return syncedDraft;
    } catch (_) {
      await _localRepo.updateSyncStatus(draft.id, SyncStatus.syncFailed);
      return draft.copyWith(syncStatus: SyncStatus.syncFailed);
    }
  }

  /// Pull remote drafts and merge with local SQLite state
  Future<void> pullAndMergeRemoteDrafts(String ownerId) async {
    try {
      final remoteDrafts = await _remoteRepo.listDrafts(ownerId);
      for (final remote in remoteDrafts) {
        final local = await _localRepo.getDraft(remote.id, ownerId);
        // Only overwrite local if remote is newer and local is not modified locally
        if (local == null || (local.syncStatus == SyncStatus.synced && remote.updatedAt.isAfter(local.updatedAt))) {
          await _localRepo.saveDraft(remote);
        }
      }
    } catch (_) {
      // Offline / network failure during pull — retain local drafts intact
    }
  }
}
