# Proposed Syaahi Studio Target Architecture
**Sprint:** ST-00.3  
**Document Status:** Architecture Proposal  

---

## 1. Target System Overview
Syaahi Studio is designed as an **integrated creative workspace** inside the existing syaahi-app and syaahi-backend monorepo. It introduces offline-first local draft persistence, structured composition models, and optional cloud draft synchronization while maintaining 100% backward compatibility with existing readers, feeds, hearts, and notifications.

---

## 2. Structural Component Changes

### 2.1 Frontend Extensions (syaahi-app)
- **New Feature Module (lib/features/studio/):**
  - **presentation/:** StudioScreen (adaptive multi-pane editor), DraftsDrawer (draft list & resume), FragmentLibraryScreen, PreviewModal.
  - **state/:** studioProvider (active editor state, auto-save status), draftsProvider (local/remote draft CRUD), ragmentsProvider.
  - **data/:** LocalDraftRepository (abstracted interface backed by local persistence SQLite/Drift or encrypted JSON storage), RemoteDraftRepository (syncs drafts to backend).
- **Navigation Integration:**
  - Standard /write route upgraded to launch Studio editor or prompt workspace selection.
  - Route /studio/drafts added for draft management drawer/screen.

### 2.2 Backend Extensions (syaahi-backend)
- **Poem Model Lifecycle Extension:**
  - Leverage isPublished: false on the Poem model OR introduce dedicated Draft entity to decouple in-progress writing from public feed queries.
  - Add API endpoints under /api/v1/studio/drafts:
    - GET /api/v1/studio/drafts: Returns user's unpublished drafts (uthorId === req.user.userId).
    - POST /api/v1/studio/drafts: Creates an unpublished draft (isPublished: false, 0 notifications sent).
    - PATCH /api/v1/studio/drafts/:id: Updates draft text, stanza structure, or metadata.
    - POST /api/v1/studio/drafts/:id/publish: Atomic transition setting isPublished: true and firing publication notifications.

---

## 3. Diagram B — Proposed Syaahi Studio Architecture
```mermaid
graph TD
    subgraph Client ["Flutter App (syaahi-app)"]
        subgraph Studio_Module ["lib/features/studio/ [NEW/PROPOSED]"]
            UI_StudioEditor["StudioScreen Editor Workspace [NEW]"]
            UI_DraftsDrawer["DraftsDrawer / Manager [NEW]"]
            State_Studio["studioProvider & draftsProvider [NEW]"]
            Repo_LocalDraft["LocalDraftRepository (SQLite/Drift) [NEW]"]
            Engine_Intelligence["Local Writing Intelligence Engine [NEW]"]
        end

        subgraph Shared_Client ["Existing & Extended Components"]
            UI_Writer["WriterScreen [EXTENDED]"]
            UI_Feed["FeedScreen / ReaderScreen [EXISTING]"]
            Net_Dio["ApiClient / HTTP Client [EXISTING]"]
        end

        UI_StudioEditor -->|Keystroke Debounce (500ms)| State_Studio
        State_Studio -->|Auto-save local| Repo_LocalDraft
        State_Studio -->|Local rhyming/synonyms| Engine_Intelligence
        UI_StudioEditor -->|Publish Action| Net_Dio
        UI_DraftsDrawer --> State_Studio
    end

    subgraph Network ["API Transport"]
        EP_Drafts["/api/v1/studio/drafts [NEW]"]
        EP_Publish["PATCH /api/v1/poems/:id/publish [EXTENDED]"]
        EP_Public["GET /api/v1/poems [EXISTING]"]
    end

    subgraph Backend ["Backend Server (syaahi-backend)"]
        Ctrl_Studio["StudioDraftsController [NEW]"]
        Ctrl_Poem["PoemsController [EXTENDED]"]
        Svc_Noti["NotificationService [EXISTING]"]
        Prisma_ORM["Prisma Client [EXTENDED]"]

        EP_Drafts --> Ctrl_Studio
        EP_Publish --> Ctrl_Poem
        EP_Public --> Ctrl_Poem
        Ctrl_Poem -->|Only on Publish Transition| Svc_Noti
        Ctrl_Studio --> Prisma_ORM
        Ctrl_Poem --> Prisma_ORM
    end

    subgraph Database ["PostgreSQL Storage"]
        DB_Draft["Draft Entity / isPublished=false [EXTENDED]"]
        DB_Poem["Published Poem Entity [EXISTING]"]
        DB_Revision["PoemRevision Model [PROPOSED]"]
        DB_Fragment["Fragment Model [PROPOSED]"]

        Prisma_ORM --> DB_Draft
        Prisma_ORM --> DB_Poem
        Prisma_ORM --> DB_Revision
        Prisma_ORM --> DB_Fragment
    end

    Net_Dio --> Network
```

## 4. Platform Architectural Isolation Principles

   1. **Android First**: Touch-first formatting toolbar, IME virtual keyboard handling, low memory footprint.
   2. **Desktop Expansion Ready**: Multi-pane dual-canvas layout for desktop screens using standard Responsive 
      Breakpoints (LayoutBuilder / MediaQuery).
   3. **Notification Isolation**: Local and cloud draft autosaves never touch createPublicationNotifications.
