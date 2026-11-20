> [CORRECTION] Field-level details in earlier drafts of this summary (Draft columns, publish semantics, SyncStatus values, test runner) were revised in ST-01-Completion-Report.md, which is authoritative for ST-01.

# Sprint ST-01 Summary: Draft Lifecycle and Editor Foundation

**Status:** COMPLETE. This file is a compact overview; ST-01-Completion-Report.md is the authoritative record.

## Overview
Delivered the full Studio draft journey: Open Studio, Create Draft, Write (500ms debounced autosave), Save locally (SQLite), Close, Reopen, Continue Writing, Publish. Public surface (WriterScreen, Poem feed, reader, Hearts, Reactions, Notifications) untouched.

## Backend
- Draft model (Prisma/PostgreSQL): language, emotion, theme, isPublished, version; indexes on ownerId and [ownerId, updatedAt].
- Endpoints under /api/v1/studio/drafts: create, list, get, patch, delete, publish.
- Publish is atomic and idempotent: creates Poem with draftId link, marks draft isPublished, invokes createPublicationNotifications exactly once; re-publish returns the existing poem.
- Owner isolation from req.user.userId; Zod validation; unauthenticated requests rejected 401.
- Test suite: npm run test:studio (tsx runner) - 14/14 PASS against live Supabase PostgreSQL.

## Flutter
- Drift/SQLite local store (StudioDatabase, LocalDrafts) with LocalDraftRepository, RemoteDraftRepository, DraftSyncService.
- Riverpod StudioNotifier with 500ms debounced autosave; SaveStatus lifecycle; guest mode (zero network).
- StudioHomeScreen (/studio) and StudioEditorScreen (/studio/editor) registered in app_router.dart.
- Test suite: flutter test - 82/82 PASS, including a 6-leg journey integration test on a file-backed SQLite database across two simulated app sessions (create, debounce-collapse, restart persistence, continue writing, publish guard, publish success).
