# Syaahi Studio — Implementation Readiness Plan (Preview for ST-01)
**Sprint:** ST-00.3  
**Document Status:** Implementation Readiness & Sequence Roadmap  

---

## 1. Immediate Next Scope: Sprint ST-01 (Draft Lifecycle & Editor Foundation)

Sprint ST-01 will introduce the foundational draft lifecycle and studio editor UI without disturbing existing readers or feed operations.

### 1.1 Target Deliverables for ST-01
1. **Database Schema Extension (Backend):**
   - Add `Draft` model to Prisma schema (`prisma/schema.prisma`).
   - Run Prisma migration `add_draft_model`.
2. **Backend Studio Endpoints (`syaahi-backend`):**
   - Create `src/modules/studio/studio.routes.ts`, `studio.controller.ts`, `studio.schemas.ts`.
   - Implement `GET /api/v1/studio/drafts`, `POST /api/v1/studio/drafts`, `PATCH /api/v1/studio/drafts/:id`, `DELETE /api/v1/studio/drafts/:id`.
   - Implement transition endpoint `POST /api/v1/studio/drafts/:id/publish`.
3. **Frontend Studio Module (`syaahi-app`):**
   - Scaffold `lib/features/studio/` directory structure.
   - Implement `DraftPoem` client domain model.
   - Implement `LocalDraftRepository` persistence layer.
   - Build `StudioScreen` editor UI with stanza formatting and debounced auto-save.
   - Add `DraftsDrawer` UI for retrieving and resuming unfinished drafts.

---

## 2. Technical Prerequisites & Verification Checklist Before ST-01
- [x] Baseline git HEAD verified (`c80e157`, tag `v-ST-ST02`).
- [x] Existing Flutter tests passing (69/69 tests green).
- [x] Backend notification safety verified (`createPublicationNotifications` isolated).
- [x] ADR-ST-001, ADR-ST-002, and ADR-ST-003 reviewed and ready for engineering execution.

---

## 3. Proposed Implementation Sequence

```text
Phase 1: Backend Draft Schema & API Endpoints (/api/v1/studio/drafts)
↓
Phase 2: Local Draft Persistence Repository in Flutter (LocalDraftRepository)
↓
Phase 3: Studio Editor UI & Riverpod State Integration (studioProvider)
↓
Phase 4: Draft-to-Publication Atomic Transition & Verification
```

