# Syaahi Studio — Draft Persistence & Synchronization Review
**Sprint:** ST-00.3  
**Document Status:** Technical Evaluation & Architectural Recommendation  
**Related ADR:** ADR-ST-002  

---

## 1. Context & Objectives
Drafts are strictly confidential, in-progress literary compositions. Studio must guarantee:
1. **Zero Content Loss:** Every keystroke is saved locally without network dependency.
2. **Offline-First Capabilities:** Full create, edit, list, and delete operations offline.
3. **Notification Isolation:** Draft autosaves must never fire public notifications to followers.

---

## 2. Evaluation of Persistence Options

### 2.1 Storage Mechanism Matrix
| Option | Storage Engine | Pros | Cons | Recommendation |
|---|---|---|---|---|
| **Option A** | SharedPreferences (Raw JSON) | Simple key-value setup | Synchronous, main-thread bottleneck for large manuscripts | Rejected for primary storage |
| **Option B** | Abstracted LocalDraftRepository (SQLite/Drift or encrypted local file storage) | Asynchronous, structured CRUD, indexed searches | Requires initial repository interface setup | **ACCEPTED (ADR-ST-002)** |
| **Option C** | Direct Cloud-Only Persistence | Simple server model | Fails offline, introduces high HTTP write traffic | Rejected |

---

## 3. Synchronization & Data Seam Strategy
- **Local-First Draft Ownership:** Drafts originate locally on the device with a generated UUID.
- **Backend Model Representation:**
  - Stored either in a dedicated Draft table OR as Poem with isPublished: false.
  - **Publishing Seam:** When the user taps "Publish", the client issues PATCH /api/v1/poems/:id/publish (or POST /api/v1/poems with transition). The backend updates isPublished: true and triggers createPublicationNotifications() **only on that transition**.

---

## 4. Conflict Resolution Protocol
For multi-device editing (Android mobile + Desktop):
- Use **Deterministic Last-Write-Wins (LWW)** based on UTC timestamps.
- If timestamp divergence > 60 seconds and content differs, store a local backup revision as [Draft Title] (Conflict Copy - [Timestamp]) to prevent silent overwrites.
