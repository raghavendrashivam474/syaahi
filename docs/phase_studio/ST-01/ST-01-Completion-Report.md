# ST-01 Completion Report — Draft Lifecycle & Editor Foundation

**Status:** COMPLETE · **Baseline:** `v-ST-ST03` (`0d2c1d94`) · **Closure tag:** `v-ST-ST01`

## 1. Scope & Outcome
The target journey is delivered end-to-end: Open Studio -> Create Draft -> Write (500ms debounced autosave) -> Save locally (SQLite) -> Close -> Reopen -> Continue Writing -> Publish (atomic, existing notification pipeline reused exactly once). Public surface (`/write`, Poem feed, reader, Hearts, Reactions, Notifications) is untouched.

## 2. Backend Deliverables (`syaahi-backend`)
### 2.1 Data model (authoritative)
`Draft` (Prisma, PostgreSQL):
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| ownerId | FK User | set server-side from `req.user.userId` |
| title | String? | |
| content | String | |
| language | Language enum | |
| emotion | Emotion enum? | |
| theme | String? | |
| isPublished | Bool default false | set true on publish; draft is retained |
| version | Int default 1 | bumped on PATCH |
| createdAt / updatedAt | DateTime | index `[ownerId, updatedAt]` plus `[ownerId]` |

Migration `prisma/migrations/20261120_add_draft_model/migration.sql` applied programmatically via `Prisma.$executeRawUnsafe` over the Supabase pooler (port 6543) because direct 5432 is network-blocked (P1001). The migration file is committed for future `prisma migrate deploy`.

### 2.2 Endpoints — `/api/v1/studio/drafts`
| Method & path | Behavior (verified) |
|---|---|
| POST `/` | 201 create; owner derived from auth session; unauthenticated -> 401 |
| GET `/` | Owner-scoped list, `isPublished = false`, newest-first |
| GET `/:id` | Owner-scoped detail; cross-user access -> 404 (no existence leak) |
| PATCH `/:id` | Update title/content/language/emotion/theme; bumps `version` |
| DELETE `/:id` | Owner-scoped delete; cross-user -> 404 |
| POST `/:id/publish` | Creates public `Poem` with `draftId` link, marks Draft `isPublished = true`, invokes `createPublicationNotifications(poem.id, authorId)` exactly once; **idempotent** — re-publish returns the existing poem (200, same id); 400 on empty title/content; 404 cross-user |

### 2.3 Security
Identity exclusively from authentication middleware (`req.user.userId`); Zod request validation; owner isolation verified on GET/PATCH/DELETE/publish.

### 2.4 Backend test suite
`src/__tests__/studio.drafts.test.ts` via `npm run test:studio` (tsx runner; `package.json` updated). **14/14 PASS** against live Supabase PostgreSQL, including: 401 gating, per-user isolation, draft non-leakage into public feed before publish, published-poem presence after publish, idempotent re-publish, and full cleanup.

## 3. Flutter Deliverables (`syaahi-app`)
### 3.1 Local persistence (ADR-ST-002)
`drift` + `sqlite3_flutter_libs` + `path_provider`; `StudioDatabase` / `LocalDrafts` table with generated `studio_database.g.dart`. `LocalDraftRepository`: `insertOnConflictUpdate` writes, owner-scoped queries filtered to `isPublished = false`, newest-first ordering, and a `watchDrafts` stream.

### 3.2 Sync (`DraftSyncService`)
- `syncDraft`: `localOnly` -> remote create (409/400 fallback to update); otherwise update; `pendingSync` -> `synced` on success, `syncFailed` on failure.
- `pullAndMergeRemoteDrafts`: remote row overwrites local only when local is absent or (local `synced` and remote newer). Network failure degrades silently — local state is never destroyed.

### 3.3 Editor state (ADR-ST-003)
Riverpod `StateNotifierProvider` (`studioProvider`). `StudioNotifier` implements the **500ms debounced autosave** (timer cancelled on each keystroke), guest mode (`guest_local`, zero network), and `SaveStatus` lifecycle `idle -> savingLocally -> savedLocally -> (syncing -> synced | failed)`.

### 3.4 UI & routing
- `StudioHomeScreen` (`/studio`): draft list with sync badges, draft creation.
- `StudioEditorScreen` (`/studio/editor`): title/body editing, counters, live save/sync indicator, publish dialog.
- Routes appended in `app_router.dart`; `WriterScreen` (`/write`) and all public routes untouched.

## 4. Test Evidence
| Suite | Command | Result |
|---|---|---|
| Backend Studio API | `npm run test:studio` | **14/14 PASS** |
| Flutter full suite | `flutter test` | **82/82 PASS** (69 pre-existing + 3 `draft_poem` + 4 `local_draft_repository` + 6 journey) |

Integration journey test (`test/features/studio/studio_journey_test.dart`) proves, on a **file-backed** SQLite database across two simulated app sessions:
1. Guest draft creation stays in-memory (no premature persistence or remote calls).
2. Keystrokes inside the 500ms window collapse to **exactly one** SQLite write containing the final content (counting repository wrapper).
3. App restart against the same database file recovers the draft (true persistence, not in-memory).
4. Continue-writing after reopen persists again.
5. Publish guard: blank draft rejected locally, zero remote calls.
6. Publish success: remote called once, editor cleared, persisted row marked `isPublished`/`synced`, published draft drops out of the working list.

## 5. Corrections to `ST-01-Summary.md`
The summary doc predates implementation detail review; the following corrections are authoritative here (a banner has been prepended to the summary file):
- Draft columns are `language / emotion / theme / isPublished / version` — **not** `tags`.
- Publish **retains** the Draft (`isPublished = true` + `Poem.draftId`); it does not delete it. Idempotent re-publish returns the existing poem.
- `SyncStatus` = `localOnly / pendingSync / synced / syncFailed` (plus a separate editor-level `SaveStatus` enum).
- `test:studio` runs via **tsx**, not jest.

## 6. Deviations & Known Limitations
- Draft retention on publish is a deliberate design choice (traceability + idempotency); user-facing behavior is equivalent because all draft lists filter `isPublished = false`.
- Migration applied via script rather than `prisma migrate deploy` (network workaround, documented above).
- Sync merge is row-level (newer-wins on synced rows); no field-level merge or multi-device concurrent-edit resolution.
- Publishing in guest mode surfaces the offline error path by design; production publish requires an authenticated session.
- Widget tests for the two screens are out of ST-01 scope; editor behavior is covered by the journey integration test.
- A hard app kill within a live 500ms window can lose the final keystrokes (accepted debounce trade-off per ADR-ST-003).

## 7. ADR Compliance
- **ADR-ST-001** (module structure): `features/studio` layered `data / domain / presentation / state` — compliant.
- **ADR-ST-002** (Drift/SQLite + sync): compliant, file-backed store with graceful offline degradation.
- **ADR-ST-003** (Riverpod + 500ms debounced autosave): compliant, verified by integration test leg 2.

## 8. Record
Commit: `ST-01: draft lifecycle and editor foundation (drafts API, Drift offline store, 500ms debounced autosave, studio screens, tests)` · Tag: `v-ST-ST01`.