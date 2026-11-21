# ST-02 Baseline Audit Report

- **Date**: 2026-11-21 20:36:43
- **Baseline Tag**: v-ST-MS2
- **Baseline Commit**: b3dddab7aa0013b58f4fb044dfb24b4460abc3b5
- **Target Branch**: feature/st-st02-studio-lifecycle-publishing

---

## 1. Verified Baseline Test Results

| Test Area | Executed Command | Results | Status |
| :--- | :--- | :--- | :--- |
| **Backend Studio Tests** | 
pm run test:studio | 14 Passed, 0 Failed | PASS |
| **Flutter Static Analysis** | flutter analyze | 0 Errors, 0 Warnings, 6 Info/Lints | PASS |
| **Flutter Unit/Widget Tests** | flutter test | 82 Passed, 0 Failed | PASS |

---

## 2. Component Inventory & Existing Architecture

### Backend (syaahi-backend)
- **Database Schema**: Prisma Draft and Poem models with 1-to-1 draft-to-poem relationship (draftId on Poem).
- **Endpoints**:
  - POST /api/v1/studio/drafts: Draft creation (supports client-provided UUID or generates new ID).
  - GET /api/v1/studio/drafts: Lists unpublished drafts (isPublished = false) for authenticated owner.
  - GET /api/v1/studio/drafts/:id: Retrieves draft by ID with owner isolation check.
  - PATCH /api/v1/studio/drafts/:id: Updates title, content, language, emotion, theme, incrementing version. Rejects edits if isPublished == true.
  - DELETE /api/v1/studio/drafts/:id: Deletes owned draft.
  - POST /api/v1/studio/drafts/:id/publish: Controlled idempotent publication inside Prisma transaction. Creates Poem, marks Draft.isPublished = true, triggers notification service. Repeated calls return existing Poem gracefully.

### Flutter App (syaahi-app)
- **Local Persistence**: Drift SQLite database (StudioDatabase) with native SQLite support on mobile/desktop and Drift Web storage on Web.
- **Data Repositories**:
  - LocalDraftRepository: CRUD and state queries on localDrafts table.
  - RemoteDraftRepository: Dio REST client communicating with /api/v1/studio/drafts.
  - DraftSyncService: Syncs local-only/pending drafts and pulls remote changes with newer-wins merge rules.
- **State Management**:
  - StudioNotifier / studioProvider using Riverpod StateNotifier.
  - Debounced autosave (500 ms) triggered on edit.
