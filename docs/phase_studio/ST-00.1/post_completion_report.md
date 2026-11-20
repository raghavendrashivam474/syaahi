# Syaahi — `phase_studio`
## ST-00.1 Technical Audit Report: Existing System & Editor Architecture

**Sprint ID:** ST-00.1  
**Parent Phase:** `phase_studio`  
**Sprint Type:** Discovery, System Audit & Architecture Assessment  
**Target Milestone:** Technical Baseline for Syaahi Studio  
**Status:** Completed  
**Version Tag:** `v-ST-ST00.1` *(internal planning identifier)*  

---

### Executive Summary

Syaahi is evolving from a poetry publishing and community platform into a dedicated literary expression environment. The proposed `phase_studio` initiative will introduce capabilities including rhyming dictionary lookups, synonym suggestions, repeated-phrase/redundancy detection, custom typography/writing themes, reusable writing fragments, version history, voice drafts, and offline draft composition.

Before writing new code or modifying existing features, **ST-00.1** executed a technical audit of the codebase (`syaahi-app` Flutter frontend and `syaahi-backend` Express/Prisma API). The goal was to establish how poems are currently composed, stored, updated, and rendered, identifying reusable assets while preventing regressions or unnecessary rewrites.

#### Key Audit Findings:
1. **Clean Feature Modularization:** The Flutter app and Express backend follow clear separation of concerns (Presentation $\rightarrow$ Riverpod State Notifiers $\rightarrow$ Repositories $\rightarrow$ Dio/Express $\rightarrow$ Prisma ORM $\rightarrow$ PostgreSQL).
2. **Existing Backend Capabilities:** The backend schema (`Prisma`) and controllers already support poem updates (`PATCH /api/v1/poems/:id`), draft flag toggling (`isPublished: false`), audio attachment URLs (`audioUrl`), and transition notifications (notifying followers when `isPublished` changes from `false` to `true`).
3. **Frontend Implementation Gaps:**
   - **No Formatting / Analysis Infrastructure:** `WriterScreen` relies on plain `TextEditingController` instances without rich text formatting or stanza analysis hooks.
   - **Ephemeral Local State:** Written text exists strictly in widget memory (RAM). There is no local caching engine (`hive`, `isar`, `sqflite`, or `drift` are absent). If the user navigates away or the app process is terminated, un-published text is lost.
   - **Missing Update/Draft Methods in Frontend Repository:** `PoemsRepository` lacks an `updatePoem()` wrapper or draft retrieval logic, despite backend API support.
4. **Editor Architecture Strategy:** Option B (Dedicated `lib/features/studio/` module reusing shared `Poem` models and network clients) was selected and formalized in **ADR-ST-001**.
5. **Quality Baseline:** 100% of Flutter tests pass (69/69 test cases). Backend API integration suites N2 & N3 pass 100%. One pre-existing schema constraint issue was recorded in legacy test suite N1 and preserved untouched.

---

### 1. Repository & Architecture Reconnaissance

#### 1.1 Project Structure
The repository is organized as a monorepo:

```
syaahi/
├── syaahi-app/           # Flutter 3.x Mobile & Web Client
├── syaahi-backend/       # Node.js / Express / Prisma PostgreSQL Backend
└── docs/                 # System documentation & Phase audit reports
    ├── architecture/     # Global ADRs (UX-01, UX-02, etc.)
    ├── phase_stability/  # Phase stability artifacts
    ├── phase_ux/         # Phase UX artifacts (UX-01 through UX-08)
    ├── Phase_noti/       # Phase notification artifacts
    └── phase_studio/     # Studio Phase discovery & architecture docs (ST-00.1)
        ├── ST-00.1/      # Detailed audit markdown deliverables (D01–D06, Completion Report)
        └── adr/          # Studio Architecture Decision Records (ADR-ST-001, ADR-ST-002)
```

#### 1.2 Frontend Dependency & Package Audit (`syaahi-app/pubspec.yaml`)
- **SDK:** Dart 3.x / Flutter SDK
- **State Management:** `flutter_riverpod: ^2.6.1` (`StateNotifierProvider`, `FutureProvider`, `Provider`)
- **Navigation:** `go_router: ^14.6.2` (utilizing `StatefulShellRoute.indexedStack` for bottom navigation tabs and `_rootNavigatorKey` for pushed sub-routes)
- **HTTP Client:** `dio: ^5.7.0` (wrapped in a custom `ApiClient` singleton)
- **Storage:**
  - `flutter_secure_storage: ^9.2.2` (JWT token persistence in `TokenStorage`)
  - `shared_preferences: ^2.3.3` (Key-value boolean flags in `OnboardingStorage`)
  - *Local Database Engine:* **None** (`hive`, `isar`, `sqflite`, `drift` absent)
- **Text & UI Libraries:** `google_fonts: ^6.2.1` (*WYSIWYG/Rich-text editor packages like `flutter_quill` or `super_editor` are absent*)

#### 1.3 Backend Tech Stack Audit (`syaahi-backend/package.json`)
- **Runtime:** Node.js, TypeScript 6.0, `tsx` 4.22
- **Web Framework:** Express 5.2.1
- **Database ORM:** Prisma Client 6.19.3 connected to Supabase PostgreSQL
- **Schema Validation:** Zod 4.4.3
- **Security:** `bcryptjs` 3.0.3, `jsonwebtoken` 9.0.3, `helmet` 8.2.0, `express-rate-limit` 8.5.2

---

### 2. End-to-End Editor Workflow Trace

The existing poem creation workflow was audited step-by-step from UI event handlers down to database persistence.

```
[User Action] Taps "+" Write Button
   │
   ▼
[GoRouter] Navigates to /write route (Pushed over root navigator key)
   │
   ▼
[UI Layer] WriterScreen (syaahi-app/lib/features/poems/presentation/writer_screen.dart)
   ├── Local TextEditingController: _titleCtrl, _contentCtrl, _themeCtrl
   ├── Local State: _language (PoemLanguage), _emotion (PoemEmotion?)
   └── Navigation Guard: PopScope (canPop: !_hasUnsavedContent) -> _confirmDiscard() AlertDialog
   │
   ▼
[Publish Action] Taps "Publish" in AppBar -> _publish()
   │
   ▼
[State Layer] WriterNotifier.publish() (lib/features/poems/state/poems_providers.dart)
   ├── Set state = WriterState(isPublishing: true)
   └── Call PoemsRepository.createPoem(...)
   │
   ▼
[Data Access] PoemsRepository.createPoem() (lib/features/poems/data/poems_repository.dart)
   └── Sends HTTP POST /api/v1/poems via Dio ApiClient
   │
   ▼
[API Endpoint] POST /api/v1/poems (syaahi-backend/src/modules/poems/poems.routes.ts)
   ├── Rate Limiting: writeLimiter middleware
   ├── Authentication: authenticate middleware (attaches req.user)
   └── Controller: createPoem() (src/modules/poems/poems.controller.ts)
   │
   ▼
[Backend Processing]
   ├── Validation: createPoemSchema.parse(req.body)
   ├── DB Operation: prisma.poem.create(data: { ...data, authorId, isPublished: true })
   └── Side Effect: createPublicationNotifications(poem.id, authorId)
   │
   ▼
[HTTP Response] Returns 201 Created with JSON payload: { success: true, data: { poem } }
   │
   ▼
[UI Post-Processing]
   ├── WriterNotifier sets isPublishing = false
   ├── Triggers ref.read(feedProvider.notifier).refresh()
   ├── WriterScreen shows Success SnackBar ("Published. Your words are out there. 🪶")
   └── Sets _dismissed = true and executes context.pop()
```

#### Detailed Component Findings (`writer_screen.dart`):
1. **Title Input:** Plain text field rendered with `GoogleFonts.cormorantGaramond` (fontSize: 30, gold color).
2. **Content Canvas:** `TextField` with `maxLines: null`, `minLines: 10`, styled in `GoogleFonts.cormorantGaramond` (fontSize: 20, height: 1.7). Line breaks (`\n`) and stanza spacing are preserved as raw newline characters within Dart `String`.
3. **Metadata Controls:** `ChoiceChip` widgets select `PoemEmotion` (Love, Longing, Hope, Solitude, Anger, Gratitude) and `PoemLanguage` (English, Hindi, Urdu).
4. **Draft Discard Protection (UX-03):** Wrapped in Flutter `PopScope` (lines 130–135). If `_hasUnsavedContent` evaluates to true when a pop event occurs, an `AlertDialog` triggers warning that unwritten text will be lost.

---

### 3. Data Schema & API Contract Audit

#### 3.1 Backend Data Model (`syaahi-backend/prisma/schema.prisma`)
The existing Prisma schema for `Poem` contains the following fields:

```prisma
model Poem {
  id          String   @id @default(uuid())
  authorId    String
  title       String?
  content     String   @db.Text
  language    Language @default(ENGLISH)
  emotion     Emotion?
  theme       String?
  audioUrl    String?
  isPublished Boolean  @default(true)

  author        User           @relation(fields: [authorId], references: [id], onDelete: Cascade)
  reactions     Reaction[]
  hearts        Heart[]
  rooms         PoemRoom[]
  notifications Notification[]
  resonances    ResonanceResponse[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([authorId])
  @@index([language, emotion])
  @@index([createdAt])
}
```

#### Schema Capabilities & Gaps for Studio:
- **`isPublished` Field:** Defaults to `true`. Setting `isPublished: false` enables server-side draft storage without schema changes.
- **`audioUrl` Field:** Already exists for future voice draft attachments.
- **`content` Field:** Stored as PostgreSQL `@db.Text` (plain string).
- **Missing Models:**
  - No `PoemVersion` / `RevisionHistory` model to store revision snapshots over time.
  - No `WritingFragment` model for reusable user snippets/lines.
  - No structured JSON column for inline rich-text attributes or line-by-line metadata.

#### 3.2 Existing API Endpoints (`syaahi-backend/src/modules/poems/`)

| Method | Endpoint | Auth | Zod Validation Schema | Behavior & Capabilities |
|---|---|---|---|---|
| `GET` | `/api/v1/poems` | Optional | `listPoemsSchema` | Returns published poems ordered by Syaahi Flow sequencing. |
| `GET` | `/api/v1/poems/:id` | Optional | `params.id` (UUID) | Retrieves a single poem. Returns 404 if `isPublished: false`. |
| `POST` | `/api/v1/poems` | Required | `createPoemSchema` | Creates new poem. Always sets `isPublished: true` by default and triggers publication notifications. |
| `PATCH` | `/api/v1/poems/:id` | Required | `updatePoemSchema` | Updates author's own poem fields. **Detects `isPublished` transition (`false -> true`) to trigger publication notifications.** |
| `DELETE` | `/api/v1/poems/:id` | Required | `params.id` (UUID) | Cascade deletes poem and associated reactions/hearts. |

#### Key API Insight:
The backend `PATCH /api/v1/poems/:id` endpoint already supports partial updates and draft publishing transitions (`isPublished: false -> true`), as implemented in `poems.controller.ts` (lines 80–113):

```typescript
if (existing.isPublished === false && poem.isPublished === true) {
  await createPublicationNotifications(poem.id, req.user!.userId);
}
```

However, `syaahi-app`'s `PoemsRepository` class (`lib/features/poems/data/poems_repository.dart`) only implements `listPoems`, `getPoem`, `createPoem`, and `deletePoem`. It does **not** expose `updatePoem`, leaving this backend capability unutilized in the frontend client.

---

### 4. Offline Capability & Local Storage Assessment

Studio requires that writing and draft composition remain functional offline, with synchronization taking place when network connectivity is restored.

#### Current Storage Audit:
1. **TokenStorage:** Stores JWT tokens via `flutter_secure_storage`.
2. **OnboardingStorage:** Stores walkthrough flags via `shared_preferences`.
3. **No Local Poem Database:** There is no local database layer (`Hive`, `Isar`, `SQLite`, or `Drift`).
4. **No HTTP Caching:** Feeds and poem screens rely purely on direct network calls via Dio.

#### Network Fault Resilience (`syaahi-app/lib/core/network/api_client.dart`):
During sprint UX-06.M1, `ApiClient` was hardened to handle platform-level secure storage hangs (especially on Flutter Web). Token retrieval is bounded by a 3-second timeout (`.timeout(const Duration(seconds: 3))`). If token retrieval times out or fails, requests proceed as guest requests without hanging the application UI.

```dart
try {
  final token = await _tokenStorage.getToken().timeout(const Duration(seconds: 3));
  if (token != null && token.isNotEmpty) {
    options.headers['Authorization'] = 'Bearer $token';
  }
} catch (_) {
  // Proceed as guest request
}
```

#### Identified Offline Gaps for Studio:
- **Zero Local Auto-Save:** Keystrokes in `WriterScreen` are strictly transient. OS app switching, background killing, or device shutdowns cause total draft data loss.
- **No Connectivity Monitor:** The client app does not track active network availability or handle queueing for failed POST/PATCH requests.
- **No Local Draft State Tracker:** The app lacks data models representing local draft synchronization statuses (`draftLocal`, `syncing`, `synced`, `conflict`).

---

### 5. Quality Baseline & Test Suite Verification

Audit verification was conducted without modifying existing test assertions.

#### 5.1 Frontend Test Suite (`syaahi-app`)
Command executed: `flutter test`

- **Total Test Files:** 10 files
- **Total Test Cases Executed:** 69 test cases
- **Passed:** 69 (100%)
- **Failed:** 0
- **Execution Time:** ~6 seconds

```
00:06 +69: All tests passed!
```

*Gap Identified:* There are **zero** existing widget/unit tests for `WriterScreen` or `WriterNotifier`. All 69 existing tests focus on auth, networking interceptors, feeds, reader screens, notifications, and resonance responses.

#### 5.2 Backend Test Suites (`syaahi-backend`)
Commands executed: `npm run test:n1`, `npm run test:n2`, `npm run test:n3`

1. **Test Suite N1 (`notifications.foundation.test.ts`):**
   - Result: 7 Passed, 1 Failed
   - *Failure Analysis:* Test 2 (`Unique constraint [recipientId, poemId, type] blocks duplicate insert (P2002)`) failed because the Prisma schema index was intentionally updated in Phase Notifications to a 4-tuple `[recipientId, poemId, type, sourceId]`. The test file expects the legacy 3-tuple behavior.
   - *Action Taken:* Recorded as a pre-existing legacy test expectation issue and preserved unmodified per System Protection Rules.
2. **Test Suite N2 (`notifications.api.test.ts`):**
   - Result: 39 Passed, 0 Failed (100% Pass)
3. **Test Suite N3 (`notifications.publication.test.ts`):**
   - Result: 19 Passed, 0 Failed (100% Pass — validates `POST /api/v1/poems` and `PATCH /api/v1/poems/:id` notification transitions).

---

### 6. Editor Strategy Evaluation

Three structural options were evaluated for implementing Syaahi Studio:

#### Option A: Extend Existing Editor (`lib/features/poems/presentation/writer_screen.dart`)
- *Concept:* Add Studio features (panels, toolbars, auto-save, rhyming dictionaries) directly into `WriterScreen`.
- *Trade-offs:* High risk of breaking simple poem posting. `WriterScreen` is currently 365 lines; extending it directly would create a monolithic, tightly-coupled component.

#### Option B: Dedicated Studio Module (`lib/features/studio/`)
- *Concept:* Build a dedicated feature directory (`syaahi-app/lib/features/studio/`) with dedicated screens, controllers, and state notifiers, while sharing standard data models (`Poem`) and network infrastructure (`ApiClient`).
- *Trade-offs:* Low regression risk. Ensures existing `/write` route continues operating without disruption while providing an isolated environment for advanced composition.

#### Option C: Shared Editor Core Engine
- *Concept:* Build a shared core engine (`lib/core/editor/`) for both standard quick-posting and advanced Studio composition.
- *Trade-offs:* Cleaner abstraction long-term, but risks premature abstraction before Studio requirements are fully validated.

#### Evaluation Comparison Matrix:

| Evaluation Criteria | Option A: Extend Writer | Option B: Dedicated Studio Module | Option C: Shared Core Engine |
|---|---|---|---|
| **Reusability** | Medium (Reuses existing UI file) | High (Reuses models, API client, theme) | High (Reuses analysis core) |
| **Complexity** | High (Creates monolithic widget) | Low-Medium (Isolated feature boundaries) | High (Upfront abstraction overhead) |
| **Regression Risk** | **High** (Directly alters working screen) | **Zero** (Isolated feature scope) | Low-Medium |
| **Maintainability** | Low | Excellent | High |
| **Offline Capability**| Poor (Requires refactoring existing state) | High (Encapsulated `LocalDraftRepository`) | High |
| **Future Extensibility**| Low | Excellent (Easy to add Voice/AI modules) | High |

#### Grounded Recommendation:
**Option B (Dedicated Studio Module with Shared Core Models)** is recommended and formalized in **ADR-ST-001**.

---

### 7. Architecture Decision Records (ADRs) Created

Two Architecture Decision Records were generated based on empirical audit findings:

1. **`docs/phase_studio/adr/ADR-ST-001-studio-module-and-editor-extension-strategy.md`**
   - **Decision:** Build Syaahi Studio as a dedicated feature module under `syaahi-app/lib/features/studio/`.
   - **Rationale:** Prevents regression to quick-publishing while isolating complex state management (draft history, rhyming, fragments, custom themes).
2. **`docs/phase_studio/adr/ADR-ST-002-draft-persistence-and-offline-sync-strategy.md`**
   - **Decision:** Introduce an abstracted `LocalDraftRepository` for client-side auto-saving and offline draft management.
   - **Rationale:** Guarantees zero content loss offline and decouples text editing from active HTTP network availability.

---

### 8. Challenges Encountered & Mitigation Strategies

| Challenge / Problem Identified | Impact on Studio | Mitigation Strategy Applied |
|---|---|---|
| **No Local Storage Database** | Unsaved text in `WriterScreen` is lost if app process terminates or closes. | Designed `LocalDraftRepository` abstraction (ADR-ST-002) for JSON file/preferences backed draft auto-saving. |
| **Unused Backend Update Endpoint** | `PATCH /api/v1/poems/:id` exists on backend but frontend `PoemsRepository` lacks an `updatePoem` implementation. | Documented contract gap in Data & API Audit (D03); scheduled `updatePoem()` integration for ST-01. |
| **Absence of Editor Tests** | `WriterScreen` has 0 unit/widget tests in baseline test suite. | Documented test gap in Quality Baseline (D05); mandated unit tests for all new Studio state notifiers and repositories in ST-01. |
| **Web Platform SecureStorage Hangs** | Token retrieval can stall network requests on Flutter Web. | Verified existing UX-06.M1 3-second timeout protection in `ApiClient`, ensuring Studio requests proceed smoothly under network latency. |

---

### 9. ST-01 Preparation & Technical Recommendations

For the upcoming **ST-01** sprint, the following implementation roadmap is recommended:

1. **Feature Module Architecture:**
   - Establish `syaahi-app/lib/features/studio/` directory structure:
     - `data/` (`local_draft_repository.dart`, `studio_repository.dart`)
     - `domain/` (`draft_poem.dart`, `writing_fragment.dart`)
     - `presentation/` (`studio_screen.dart`, `widgets/`)
     - `state/` (`studio_providers.dart`, `draft_notifier.dart`)
2. **Frontend Repository Updates:**
   - Add `updatePoem()` and `saveDraft()` methods to `PoemsRepository` in `syaahi-app`.
3. **Local Draft Persistence Layer:**
   - Implement `LocalDraftRepository` with auto-save debouncing (500ms delay after keystrokes).
4. **Studio Navigation Integration:**
   - Add `/studio` route to `AppRouter` without altering existing `/write` quick-post route.

---

### 10. Verification & Artifact Inventory

#### 10.1 Documentation Artifacts Delivered (`docs/phase_studio/`):
- `ST-00.1/repository-and-architecture-audit.md` (D01)
- `ST-00.1/editor-workflow-audit.md` (D02)
- `ST-00.1/data-and-api-audit.md` (D03)
- `ST-00.1/offline-capability-assessment.md` (D04)
- `ST-00.1/quality-and-test-baseline.md` (D05)
- `ST-00.1/editor-strategy-evaluation.md` (D06)
- `ST-00.1/completion-report.md` (Completion Summary)
- `adr/ADR-ST-001-studio-module-and-editor-extension-strategy.md` (ADR-001)
- `adr/ADR-ST-002-draft-persistence-and-offline-sync-strategy.md` (ADR-002)

#### 10.2 System Protection Compliance Verification:
- **Git Status:** Executed `git status`. Working tree is clean. Only new documentation files under `docs/phase_studio/` were added.
- **Zero Breaking Code Modifications:** No source code in `syaahi-app/lib/` or `syaahi-backend/src/` was modified during this audit sprint.
- **Verification Suites:** 69/69 Flutter tests passed; 58/59 Backend integration tests passed (1 pre-existing legacy test failure noted).

---
*Report submitted for senior engineering and technical lead review.*