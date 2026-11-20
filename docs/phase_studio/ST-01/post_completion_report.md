**Subject: ST-01 Complete — Draft Lifecycle & Editor Foundation (Syaahi Studio) — Implementation Report & Closure**

**Sprint:** ST-01 · **Baseline:** `main` @ `v-ST-ST03` (`0d2c1d94db73d59cc8de5958744aac5b17fbd890`)
**Closure:** commit `ST-01: draft lifecycle and editor foundation…` @ `[commit hash]`, tag `v-ST-ST01`
**Author:** `[your name]` · **Docs:** `docs/phase_studio/ST-01/` (Implementation Plan, Summary, Completion Report — authoritative)

---

## 1. Executive Summary

ST-01 delivers the Studio writing surface end-to-end: **Open Studio → Create Draft → Write (500 ms debounced autosave) → Save locally (SQLite) → Close → Reopen → Continue Writing → Publish**. Drafts are a first-class, dedicated entity — never rows in the public `Poem` table — persisted offline-first on-device (Drift/SQLite), synced in the background to the backend, and converted to a public Poem via a controlled, atomic, idempotent publish transition that reuses the existing publication notification pipeline exactly once.

Public surface is untouched: the pre-existing Flutter suite (69 tests — WriterScreen `/write`, feed, reader, Hearts, Reactions, Notifications, API client) passes unchanged alongside the 13 new tests.

**Final test evidence:** Backend 14/14 · Flutter 82/82 (69 baseline + 13 new) · Journey integration 6/6.

---

## 2. Scope Delivered

### 2.1 Backend (`syaahi-backend`, Node/Express/Prisma/PostgreSQL)

**Data model — `Draft` (dedicated entity, own endpoint namespace `/api/v1/studio/drafts`):**

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | client-generated in Flutter; server accepts |
| ownerId | FK → User | always derived server-side from `req.user.userId` |
| title | String? | |
| content | String | |
| language | Language enum | |
| emotion | Emotion enum? | |
| theme | String? | |
| isPublished | Bool, default false | set `true` on publish; draft retained |
| version | Int, default 1 | bumped on PATCH |
| createdAt / updatedAt | DateTime | indexed `[ownerId]` and `[ownerId, updatedAt]` |

**Endpoints (Zod-validated, auth-gated, owner-isolated):**

| Method | Path | Verified behavior |
|---|---|---|
| POST | `/api/v1/studio/drafts` | 201 create; unauthenticated → 401 |
| GET | `/api/v1/studio/drafts` | owner-scoped list, `isPublished = false`, newest-first |
| GET | `/:id` | owner-scoped; cross-user access → 404 (no existence leak) |
| PATCH | `/:id` | update title/content/language/emotion/theme; bumps `version` |
| DELETE | `/:id` | owner-scoped; cross-user → 404 |
| POST | `/:id/publish` | atomic: creates public `Poem` with `draftId` link, marks draft `isPublished`, invokes existing `createPublicationNotifications(poem.id, authorId)` **exactly once**; **idempotent** — re-publish returns the existing poem (200, same id); 400 on empty title/content; 404 cross-user |

**Security model:** identity is never trusted from the client — every handler scopes on `req.user.userId` from the existing auth middleware. The 14-test suite explicitly proves cross-user isolation on list/get/patch/delete/publish, 401 gating, and that an unpublished draft does **not** leak into `/api/v1/poems` while the published poem does.

### 2.2 Flutter Client (`syaahi-app`, offline-first)

- **Persistence (ADR-ST-002):** `drift` + `sqlite3_flutter_libs` + `path_provider`; `StudioDatabase` / `LocalDrafts` table (generated `studio_database.g.dart`). `LocalDraftRepository`: `insertOnConflictUpdate` writes, owner-scoped queries filtered `isPublished = false`, newest-first, plus a reactive `watchDrafts` stream.
- **Sync (`DraftSyncService`):** `syncDraft` — new local rows (`localOnly`) attempt remote create with 409/400 fallback to update; existing rows update; `pendingSync → synced` on success, `syncFailed` on failure. `pullAndMergeRemoteDrafts` — remote overwrites local **only** when local is absent or (local `synced` AND remote newer). Network failure degrades silently; local data is never destroyed.
- **State (ADR-ST-003):** Riverpod `StateNotifierProvider` (`studioProvider`). `StudioNotifier` implements the **500 ms debounced autosave** (timer cancelled on every keystroke), `SaveStatus` lifecycle (`idle → savingLocally → savedLocally → (syncing → synced | failed)`), and guest mode (`guest_local` — fully functional local writing with **zero** network calls).
- **UI:** `StudioHomeScreen` (`/studio`) — draft list with sync badges; `StudioEditorScreen` (`/studio/editor`) — title/body editing, word count, live save/sync indicator, publish dialog. Routes appended in `app_router.dart`; no existing route modified.

---

## 3. Key Engineering Decisions (the "how")

1. **Dedicated `Draft` entity, separate namespace.** Per constraint, drafts never touch the public `Poem` table. The only crossing point is the publish transition, which inserts into `Poem` and links back via `Poem.draftId`.
2. **Publish retains the draft (`isPublished = true`) rather than deleting it.** This gives traceability and makes re-publish naturally idempotent (publish resolves the existing `Poem` by `draftId`). User-facing behavior is equivalent because all draft lists filter `isPublished = false`.
3. **Notification reuse, not duplication.** Publish calls the existing `createPublicationNotifications(poem.id, authorId)` exactly once — verified in test logs via the `NotificationPreference` query firing during the publish request. No second notification path was created.
4. **Offline-first write path.** Every keystroke goes only to Riverpod state; the 500 ms debounce collapses bursts into a single SQLite write; remote sync is strictly a background follow-up when authenticated. Guests never hit the network.
5. **Journey test designed to prove real behavior, not happy paths:**
   - **File-backed** SQLite (temp dir), not in-memory — "close → reopen" genuinely exercises persistence across a fresh `StudioDatabase` + fresh `ProviderContainer`.
   - A **counting repository wrapper** (`implements LocalDraftRepository`, delegates + counts) proves debounce structurally: two keystrokes inside the window → **exactly one** write containing the *final* content.
   - A **deterministic fake** `implements RemoteDraftRepository` asserts the guest journey makes zero remote calls and publish calls remote exactly once.
   - Publish-guard leg proves a blank draft is rejected locally with no remote call.

---

## 4. Problems Encountered & Mitigations

**4.1 — Supabase migration blocked (P1001) on direct connection**
`prisma db push` failed: `Can't reach database server at db.…supabase.co:5432` — port 5432 is network-blocked in this environment.
*Mitigation:* generated the SQL migration file (`prisma/migrations/20261120_add_draft_model/migration.sql`) and applied it programmatically via `Prisma.$executeRawUnsafe` over the Supabase **connection pooler** (port 6543). The migration file is committed so future environments can use standard `prisma migrate deploy`. *Residual:* deployment pipeline should adopt `migrate deploy` as normal path.

**4.2 — PowerShell multi-line string edits corrupted source files**
Early structured edits via multi-line PowerShell string replacement injected stray backslashes and interpolated `$` variables, corrupting `schema.prisma`, `package.json`, and `app_router.dart`.
*Mitigation:* all subsequent structured file edits were executed as standalone Node.js scripts (`node script.js`) with **fail-loud guards** — the script exits non-zero without writing if the target block isn't found verbatim. This became a standing rule for the sprint. *Lesson:* treat structured code edits as program operations with verification, not shell text substitution.

**4.3 — Drift code generation not running**
`dart run build_runner` failed because `build_runner` was not cleanly present under `dev_dependencies`.
*Mitigation:* pinned `build_runner: ^2.4.12` and `drift_dev: ^2.20.0` in `pubspec.yaml`, `flutter pub get`, regenerated `studio_database.g.dart`.

**4.4 — Journey test publish leg: fixture didn't match the real `Poem.fromJson` contract**
The publish-success leg failed (`poem == null`). Root cause: the notifier's `catch` block had correctly converted a thrown `TypeError` into `state.error` — my fake's JSON used a flat `authorId` and lowercase language, while `Poem.fromJson` requires a **nested `author` map** (`id`, `username`, `displayName`) and case-insensitive enum matching.
*Mitigation:* dumped the real `shared/models/poem.dart` contract and rebuilt the fixture to match it exactly (nested author map, `ENGLISH`); additionally added `expect(state.error, isNull)` **before** the result assertion in every publish-path test so any future swallowed exception surfaces its message directly. *Lesson:* assert error state before result state when testing through code paths that catch-and-record; the notifier itself behaved correctly and needed no change.

**4.5 — `[System.IO.File]::WriteAllText` CWD mismatch**
A patch script was written with a **relative** path: .NET resolves it against the process working directory (repo root) while `node` inherits the PowerShell location (`syaahi-app/`) — so `node` couldn't find the file. Patch never executed; the test file was untouched.
*Mitigation:* absolute paths for all file writes and all tool invocations; stray artifacts swept and removed. *Lesson:* same-command, different-CWD resolution rules between .NET and native executables — always qualify paths explicitly.

**4.6 — Phantom artifact: `ST-01-Summary.md` reported created but absent on disk**
An earlier session step logged `[OK] Created …ST-01-Summary.md`, but the final banner script failed with `ENOENT` — the file never existed. The fail-loud script caught it instead of silently skipping.
*Mitigation:* resilient script — prepend the corrections banner if the file exists, otherwise create a corrected compact Summary; verified with a directory listing afterwards. Every closure step now ends with an on-disk verification, not just an `[OK]` log line.

**4.7 — Documentation drift vs. implementation**
The initial summary doc (written ahead of detailed review) misstated three things: Draft fields (`tags` — actual: `language/emotion/theme/isPublished/version`), publish semantics (delete — actual: retain + idempotent re-publish), and the test runner (jest — actual: tsx via `npm run test:studio`).
*Mitigation:* `ST-01-Completion-Report.md` is the authoritative record with the corrected field-level detail; the Summary carries a corrections banner deferring to it. Cross-checked against actual query logs and source signatures, not memory.

---

## 5. Verification & Test Evidence

| Suite | Command | Result |
|---|---|---|
| Backend Studio API | `npm run test:studio` (tsx runner) | **14/14 PASS** — against live Supabase PostgreSQL |
| Flutter full suite | `flutter test` | **82/82 PASS** (69 pre-existing + 3 `draft_poem` + 4 `local_draft_repository` + 6 journey) |
| Journey integration | `flutter test test/features/studio/studio_journey_test.dart` | **6/6 PASS** |

Journey legs proved: (1) guest creation stays in-memory, zero remote calls; (2) keystroke burst collapses to exactly one SQLite write with final content; (3) draft survives app restart via file-backed SQLite across two simulated sessions; (4) continue-writing persists; (5) publish guard rejects blank draft with zero remote calls; (6) publish succeeds exactly once, editor clears, persisted row marked `isPublished`/`synced`, draft leaves the working list.

---

## 6. Known Limitations & Deliberate Trade-offs

- **Draft retention on publish** is intentional (traceability + idempotency); all lists filter `isPublished = false` so UX is unaffected.
- **Sync merge is row-level** (newer-wins on `synced` rows). No field-level merge or multi-device concurrent-edit resolution — appropriate for ST-01; a candidate for a future sync sprint.
- **Hard app kill within a live 500 ms window** can lose final keystrokes — the accepted debounce trade-off per ADR-ST-003. (Flush-on-background hooks are a cheap future hardening.)
- **No widget tests** for the two screens — scoped out of ST-01; editor behavior is covered by the journey integration test. Logged as a limitation, not silently skipped.
- **Guest-mode publish** intentionally surfaces the offline/error path; production publish requires an authenticated session.

---

## 7. Constraints Honored

- Drafts live in a dedicated `Draft` entity and `/api/v1/studio/drafts` namespace — never the public `Poem` table.
- `createPublicationNotifications` reused exactly once; no parallel notification system introduced.
- Identity derived exclusively from auth middleware (`req.user.userId`); client-supplied identity never trusted.
- Existing modules (WriterScreen, Poem model, feed, reader, Hearts, Reactions, Notifications, public routes) untouched — evidenced by all 69 baseline tests passing unchanged.

**ADR compliance:** ADR-ST-001 (studio module layering) ✅ · ADR-ST-002 (Drift/SQLite + sync strategy) ✅ · ADR-ST-003 (Riverpod + 500 ms debounced autosave) ✅ — debounce compliance proven by integration test, not assertion.

---

## 8. Closure

- **Docs:** `docs/phase_studio/ST-01/` — `IMPLEMENTATION_PLAN.md`, `README.md`, `ST-01-Summary.md` (compact overview, corrections banner), `ST-01-Completion-Report.md` (authoritative).
- **Git:** commit `ST-01: draft lifecycle and editor foundation (drafts API, Drift offline store, 500ms debounced autosave, studio screens, tests)` @ `[commit hash]`, tagged `v-ST-ST01` — rollback point established per Phase 0 convention.

Happy to walk through the sync conflict-resolution strategy or the journey test design in the next sync. Flagging ST-02 candidates: flush-on-background autosave hardening, multi-device field-level merge, and editor widget tests.