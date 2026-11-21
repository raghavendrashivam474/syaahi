# ST-02 Synchronization & Persistence Reliability

- **Module**: Studio
- **Version**: 1.0.0

---

## 1. Autosave Mechanics

- **Debounce Window**: 500 ms delay on user keypress/field updates.
- **Local Persistence First**: Local Drift SQLite update executes synchronously before any network attempt.
- **Save Flush Guarantee**: On back navigation, app backgrounding, or publish action, lushPendingAutosave() cancels active timers and flushes unpersisted edits immediately to storage.

---

## 2. Remote Sync & Newer-Wins Conflict Resolution

- **Background Sync**: Triggered on _executeSave() after local write succeeds.
- **Sync States**:
  - localOnly: Draft exists locally, not yet synced to backend.
  - pendingSync: Remote POST/PATCH operation in progress.
  - synced: Remote copy confirmed and up to date.
  - syncFailed: Network unavailable or remote error; local changes preserved without data loss.
- **Conflict Handling**: Remote pull (pullAndMergeRemoteDrafts) compares remote updatedAt with local updatedAt. Local edits marked synced are overwritten only if remote updatedAt is strictly newer. Unsynced local edits (localOnly/pendingSync/syncFailed) are preserved.
