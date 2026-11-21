# ST-02 Gap Analysis Report

- **Date**: 2026-11-21 20:36:43
- **Milestone**: ST-02 (Studio Lifecycle & Publishing)

---

## 1. Identified Lifecycle & Sync Gaps

### Gap 1: ID Generation Strategy & Remote Duplicate Risk (ST-02.1 / ST-02.2)
- **Current Behavior**: createNewDraft() in StudioNotifier generates string ID using DateTime.now().microsecondsSinceEpoch.toString().
- **Impact**: While usable locally, non-UUID identifiers or high-frequency creations can produce formatting discrepancies when persisting to PostgreSQL/Prisma or syncing remotely.
- **Resolution**: Use standard Uuid().v4() for deterministic client-side ID generation that seamlessly aligns with backend UUID primary keys.

### Gap 2: In-Flight Navigation & Unsaved Edits Loss (ST-02.2)
- **Current Behavior**: Autosave uses a 500 ms debounce timer. If a user types and immediately presses the back button (context.pop()) or navigates away within 500 ms, the debounce timer gets cancelled without flushing pending edits to local Drift DB.
- **Impact**: Potential loss of the last few keystrokes on rapid screen exit.
- **Resolution**: Implement an explicit lushPendingSave() / lushAutosave() on StudioNotifier that triggers immediately when exiting the editor screen or initiating publication.

### Gap 3: Deleted Draft Remote Persistence & Ghost Sync (ST-02.3)
- **Current Behavior**: When deleting a draft while offline or when remote request fails (_remoteRepo.deleteDraft(draftId).catchError((_) {})), the deletion error is swallowed silently without recording a soft-delete / tombstoned status locally.
- **Impact**: On the next pullAndMergeRemoteDrafts(), the remote draft will be re-downloaded and resurrected locally ("ghost draft").
- **Resolution**: Ensure deleted draft IDs are tombstoned locally or synced cleanly so offline deletions survive reconnection.

### Gap 4: Unsynced Draft Pre-Publishing Race Condition (ST-02.4)
- **Current Behavior**: When user clicks **Publish**, publishCurrentDraft() attempts _remoteRepo.publishDraft(draft.id). If the draft has not yet been created remotely (e.g. offline edits or pending sync), backend will return 404 Draft not found.
- **Impact**: Publishing fails for freshly created local drafts that haven't completed background cloud sync.
- **Resolution**: Ensure publishCurrentDraft() explicitly triggers a remote sync (_syncService.syncDraft(draft)) prior to calling publishDraft(draft.id).

### Gap 5: Post-Publication Route & Local State Cleanup (ST-02.4)
- **Current Behavior**: After successful publication, publishCurrentDraft() updates local isPublished = true, clears current draft, and navigates to /poem/:id. However, if the user re-opens Studio, listDrafts correctly filters out isPublished = true, but if the user hits Back from the published poem screen, editor state could be ambiguous.
- **Impact**: Mild UI state inconsistency upon back-navigation after publishing.
- **Resolution**: Cleanly replace route and reset editor state upon publication confirmation.

---

## 2. Proposed Implementation Workstreams

1. **ST-02.1**: Harden Draft Model & Identity (UUID generation, owner state isolation).
2. **ST-02.2**: Flush pending debounced autosave on editor exit; refine local save indicators.
3. **ST-02.3**: Fix deleted draft tombstoning and sync conflict protection.
4. **ST-02.4**: Harden publish workflow: sync-before-publish sequence and idempotent state handling.
5. **ST-02.5**: Complete automated regression & end-to-end verification tests.
