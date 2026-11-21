# ST-02 Draft Lifecycle Design

- **Module**: Studio
- **Document Version**: 1.0.0
- **Status**: Approved Implementation Specification

---

## 1. Core Lifecycle States & Transitions

The Studio Draft lifecycle consists of 6 logical states mapped into local persistence (Drift) and remote storage (Prisma PostgreSQL):

```text
[ Draft Created ] ---> ( Local Persistence ) ---> [ Draft Editing / Autosave ]
| |
| v
+----------------------------------------> [ Pending Remote Sync ]
|
v
[ Draft Published ] <--- ( Publish Transaction ) <--- [ Synced / Cloud Persisted ]
|
v
[ Content Read-Only / Archived ]
```

### Logical States & Persistent Flags

| Logical State | Local syncStatus | Local isPublished | Backend isPublished | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Created** | localOnly | false | *Not on remote yet* | Draft initialized locally with valid client UUID v4. |
| **Editing / Local Saved** | localOnly / pendingSync | false | *Not on remote / stale* | Active content edits persisted to local Drift database. |
| **Syncing** | pendingSync | false | *In-flight PATCH/POST* | Remote sync job actively pushing draft to /api/v1/studio/drafts. |
| **Synced** | synced | false | false | Local and cloud copies match in version and timestamps. |
| **Publishing** | synced | false -> 	rue | false -> 	rue | In-flight atomic transaction converting Draft to public Poem. |
| **Published** | synced | 	rue | 	rue | Immutable draft linked to published Poem (draftId). Filtered from active draft lists. |

---

## 2. Deterministic Identity & Owner Isolation

1. **Client Identity**: Every draft created locally generates a standard UUID v4 string (uuid package).
2. **Owner Scope**: Every query (local Drift & backend Prisma) strictly filters by ownerId == userId.
3. **Idempotency**: Pushing a draft with an existing id is handled by backend POST or PATCH gracefully without creating duplicates.

---

## 3. Publication Integrity Rules

1. **Pre-publish Validation**: Draft content must be non-empty (content.trim().length > 0).
2. **Pre-publish Flush**: Any pending debounced autosave is flushed before publication API call.
3. **Pre-publish Remote Sync**: Freshly created local drafts (localOnly) are synced remotely before POST /studio/drafts/:id/publish is invoked.
4. **Idempotent Recovery**: Re-publishing a previously published draft returns HTTP 200 with the existing Poem object.
