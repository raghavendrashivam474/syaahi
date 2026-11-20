# ST-00.1: Offline Capability Assessment

**Sprint ID:** ST-00.1  
**Phase:** `phase_studio`  
**Status:** Completed  
**Audit Target:** Local Persistence, Connectivity Handling, and Synchronization Mechanisms  

---

## 1. Existing Storage & Cache Infrastructure

### Packages in Use (`syaahi-app/pubspec.yaml`)
- `flutter_secure_storage`: Used strictly for securely storing JWT tokens (`token_storage.dart`).
- `shared_preferences`: Used strictly for simple key-value boolean flags (e.g., `onboarding_walkthrough_seen` in `onboarding_storage.dart`).

### Local Storage Capabilities & Gaps
- **Local Relational/Document Database:** **None.** No Hive, Isar, SQLite, Drift, or Realm package is present.
- **Poem Content Caching:** **None.** All poem feeds and reader screens perform live HTTP GET requests over Dio. If network connectivity is lost, reading cached poems or viewing offline feeds is not supported.
- **Draft Persistence:** **None.** Unsaved poems written in `WriterScreen` exist purely in RAM memory inside Flutter `TextEditingController` instances. Navigating away or closing the app wipes out the text.

---

## 2. Network State & Error Resilience Handling

### Dio Network Configuration (`syaahi-app/lib/core/network/api_client.dart`)
- **Connection Timeouts:** `connectTimeout: 10s`, `receiveTimeout: 15s`.
- **Token Retrieval Resilience (UX-06.M1):** `ApiClient` wraps token retrieval in a 3-second timeout (`.timeout(const Duration(seconds: 3))`). If token retrieval fails or times out due to secure storage platform race conditions (especially on Web), the request proceeds as guest without stalling indefinitely.
- **Error Propagation:** Dio errors are caught in repository methods (e.g. `PoemsRepository._handle()`) and converted into user-friendly `PoemsException` messages ("Cannot reach Syaahi. Check your connection.").

### Outstanding Gaps for Offline Writing (Studio Initiative)
1. **No Network Connectivity Listener:** The app does not listen to `connectivity_plus` or network status events to detect when the device goes offline.
2. **No Pending Request Queue:** If a user taps "Publish" while offline, Dio immediately throws a `DioException` connection error. The poem is not queued for automatic synchronization when connectivity returns.
3. **No Local Sync Status State:** Content has no concept of local states such as `localOnly`, `synced`, `syncing`, or `conflict`.

---

## 3. Storage Architecture Recommendation for Studio

To meet the mandatory requirement ("Writing and draft management should remain usable offline without losing content"), Studio requires a dedicated local persistence layer.

### Recommended Local Storage Options Evaluated
1. **Option 1: SharedPreferences (JSON String Serialization)**
   - *Pros:* Simple, zero new heavy dependencies.
   - *Cons:* Synchronous file I/O bottleneck on large drafts, poor queryability, high risk of file corruption on sudden app kills.
2. **Option 2: Hive / Isar / SQLite (sqflite/drift)**
   - *Pros:* High performance, asynchronous, structured indexing, atomic transaction support.
   - *Cons:* Adds native binary dependencies.
3. **Option 3: Abstracted Key-Value / File-based Local Storage Engine**
   - *Pros:* Clean repository pattern (`LocalDraftRepository`), easy to mock in unit tests, minimal overhead for local drafts.

*Decision documented in ADR-ST-002.*
