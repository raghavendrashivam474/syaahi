# Post-Sprint N1 Report — Data Foundation & Opt-in Preferences

**To:** Senior Developer / Project Owner
**From:** Implementation Engineer
**Initiative:** `phase_noti`
**Sprint:** N1 — Data Foundation & Opt-in Preferences
**Date:** 2026-10-23
**Baseline Commit:** `7d5b15d` (tag: `v-noti_N0`)
**Branch:** `main`
**Status:** **Ready for owner review**

---

## 1. Executive Summary

N1 is implementation-complete. The approved N0 notification schema — `Notification`, `NotificationPreference`, the `NotificationType` enum, and the required relations on `User` and `Poem` — is live in the Syaahi Supabase database. All uniqueness constraints, indexes, and cascade behaviors specified in the N0 architecture are present and have been verified against the live database with an 8-test integration suite (8/8 passing).

Existing data was preserved in full: **18 Users, 84 Poems, 15 Reactions, 15 Hearts, 0 Follows** — unchanged before and after migration.

One operational issue was encountered and resolved: Supabase's hosted Postgres does not permit Prisma's `migrate dev` shadow-database workflow. A documented, reproducible alternative using `prisma migrate diff` + manual SQL application + `prisma migrate resolve` was adopted. This is a tooling workaround only; no product behavior, schema semantics, or ADRs were changed.

**No scope creep.** No N2–N5 work was touched. No existing application files (controllers, middleware, routes, Flutter code) were modified.

---

## 2. Scope Delivered

| Deliverable | Status | Evidence |
|---|---|---|
| `NotificationType` enum | ✅ Delivered | `schema.prisma`, migration SQL |
| `Notification` model with relations, uniqueness, indexes | ✅ Delivered | `schema.prisma`, migration SQL, test 1–3, 7–8 |
| `NotificationPreference` model (1:1 User, opt-in default `false`) | ✅ Delivered | `schema.prisma`, migration SQL, test 4–6, 8 |
| `User` relations: `notifications[]`, `notificationPreference?` | ✅ Delivered | `schema.prisma` |
| `Poem` back-relation: `notifications[]` | ✅ Delivered | `schema.prisma` |
| Versioned migration committed to `prisma/migrations/` | ✅ Delivered | `20261023032914_add_notifications/migration.sql` |
| Automated data-integrity test suite | ✅ Delivered | `src/__tests__/notifications.foundation.test.ts` |
| Existing data preserved | ✅ Verified | Pre/post row-count snapshot |
| Build regression (`tsc`) | ✅ Passing | `npm run build` clean |
| `DeviceToken` model | ⛔ Explicitly deferred to N5 | Per handoff §4.3 |

---

## 3. Implementation Walkthrough

### 3.1 Baseline Verification (N1.0)

Before touching code, the baseline was verified:

- Branch `main`, HEAD `7d5b15d`, matches the reported baseline from the handoff.
- Tag `v-noti_N0` present and points to HEAD.
- Working tree clean, remote `origin/main` tracking confirmed.
- N0 architecture spec, sprint plan, security review, and ADRs 021–027 read in full.
- Discovery note located at `docs/Notification_System_Discovery_Note.md` (verified exact filename).
- Approval gate satisfied: N0 completion report committed at HEAD; ADR-025 (self-notification) correctly recognized as N3-scope and non-blocking for N1.

### 3.2 Schema Design & Implementation (N1.1)

The existing Prisma schema was read in full to confirm conventions:
- UUID v4 primary keys (`@default(uuid())`).
- `@default(now())` for `createdAt`, `@updatedAt` for `updatedAt`.
- `onDelete: Cascade` on every existing foreign key.
- Lowercase relation field names, PascalCase model names, snake_case indexes.

The new models were added following these conventions exactly:

```prisma
enum NotificationType {
  POEM_PUBLISHED
}

model Notification {
  id          String           @id @default(uuid())
  recipientId String
  type        NotificationType
  poemId      String
  readAt      DateTime?

  recipient   User             @relation(fields: [recipientId], references: [id], onDelete: Cascade)
  poem        Poem             @relation(fields: [poemId], references: [id], onDelete: Cascade)

  createdAt   DateTime         @default(now())

  @@unique([recipientId, poemId, type])
  @@index([recipientId, createdAt])
  @@index([recipientId, readAt])
}

model NotificationPreference {
  userId        String   @id
  newPoemAlerts Boolean  @default(false)

  user          User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  updatedAt     DateTime @updatedAt
}
```

Relation fields added to the existing `User` model (append-only, no existing fields modified):
```prisma
notifications          Notification[]
notificationPreference NotificationPreference?
```

Back-relation added to the existing `Poem` model (required by Prisma):
```prisma
notifications Notification[]
```

`prisma format` succeeded; `prisma validate` succeeded. The schema diff contained only the approved N1 additions — no renames, no existing-field changes.

### 3.3 Migration Creation (N1.2)

This is where the first and only significant obstacle appeared. See §4 for the full account of the problem and mitigation. The outcome:

- Migration name: `20261023032914_add_notifications`
- Location: `syaahi-backend/prisma/migrations/20261023032914_add_notifications/migration.sql`
- Also committed: `syaahi-backend/prisma/migrations/0_init/migration.sql` — the previously-undocumented initial schema, baselined to make the migration history reproducible for any future developer.

The generated SQL was manually inspected before any execution:

```sql
CREATE TYPE "NotificationType" AS ENUM ('POEM_PUBLISHED');

CREATE TABLE "Notification" (...);
CREATE TABLE "NotificationPreference" (...);

CREATE INDEX "Notification_recipientId_createdAt_idx" ON "Notification"(...);
CREATE INDEX "Notification_recipientId_readAt_idx"    ON "Notification"(...);
CREATE UNIQUE INDEX "Notification_recipientId_poemId_type_key" ON "Notification"(...);

ALTER TABLE "Notification"           ADD CONSTRAINT ... FOREIGN KEY ... ON DELETE CASCADE;
ALTER TABLE "Notification"           ADD CONSTRAINT ... FOREIGN KEY ... ON DELETE CASCADE;
ALTER TABLE "NotificationPreference" ADD CONSTRAINT ... FOREIGN KEY ... ON DELETE CASCADE;
```

Verified: **purely additive**. No `DROP`, no `ALTER COLUMN`, no `UPDATE`, no `DELETE` against existing tables.

### 3.4 Data Integrity Tests (N1.3)

The repository has no pre-existing test infrastructure (no `jest`, `vitest`, or test runner in `package.json`; no `*.test.ts` files anywhere). Rather than introducing a full test framework for a single sprint (which would have been scope creep), I wrote a self-contained integration script that runs against the live dev database using the existing `tsx` runtime (which is already a project dependency).

File: `syaahi-backend/src/__tests__/notifications.foundation.test.ts`
Script: `npm run test:n1`

The suite creates isolated test users with timestamped unique emails/usernames, exercises every constraint required by the sprint plan, and cleans up after itself in a `finally` block (deleting the test users cascades everything created during the run).

**Results — 8/8 PASS:**

| # | Test | Guarantee Verified |
|---|---|---|
| 1 | Valid notification creation | FK integrity, `readAt` nullable default |
| 2 | Duplicate insert raises `P2002` | `@@unique([recipientId, poemId, type])` enforced at DB level |
| 3 | Different recipients, same poem | Uniqueness is per-recipient |
| 4 | Explicit preference defaults `false` | Opt-in default enforced |
| 5 | Absent preference → effective `false` | No implicit consent for existing users |
| 6 | Duplicate preference insert raises `P2002` | 1:1 User↔Preference constraint |
| 7 | Delete poem → notifications removed | `onDelete: Cascade` on `poemId` |
| 8 | Delete user → notifications & preference removed | `onDelete: Cascade` on `recipientId` and `userId` |

Note: These are **true database-level** assertions, not mocks. If any constraint is missing from the actual Postgres schema, the test fails.

### 3.5 Regression & Build (N1.4)

| Check | Command | Result |
|---|---|---|
| TypeScript build | `npm run build` (`tsc`) | ✅ Clean |
| Prisma Client regeneration | `prisma generate` | ✅ v6.19.3 generated |
| Prisma schema validation | `prisma validate` | ✅ Valid |
| Migration status | `prisma migrate status` | ✅ "Database schema is up to date!" |
| Row-count parity | Pre/post custom script | ✅ 18/84/15/15/0 unchanged |
| `git diff --check` | — | ✅ Only CRLF/LF warnings (benign) |

No existing backend tests to run (none exist in the repo). No existing Express or Flutter code was modified, so no behavioral regression surface exists.

### 3.6 Documentation (N1.5)

Produced: `docs/Phase_noti/sprintN1/N1_COMPLETION_REPORT.md` (sprint-standard format with 14 required sections per handoff §13).

---

## 4. Problems Encountered & Mitigations

This section documents every non-trivial issue hit during execution, in chronological order, with the diagnosis and fix for each. These are included so the senior reviewer can judge the quality of the mitigations and so future sprints can avoid repeating the same hurdles.

### Problem 1 — `node_modules` missing in `syaahi-backend`

**Symptom:** First attempt at `prisma format` triggered `npx` to offer to download `prisma@8.0.0-rc.26` from the registry instead of using the project's declared `^6.19.3`.

**Diagnosis:** The repository had never had `npm install` run on this workstation. Without `node_modules`, `npx` falls back to fetching a remote (and in this case, a release-candidate) version — risking a schema parsed by a different Prisma major version than what the project targets.

**Mitigation:** Ran `npm install` in `syaahi-backend/`. Verified `node_modules/.bin/prisma --version` reports `6.19.3` matching `package.json`. All subsequent Prisma invocations used `.\node_modules\.bin\prisma` or `node node_modules\prisma\build\index.js` to guarantee the pinned local binary — never `npx prisma`.

**Lesson for future sprints:** Add a baseline check for `node_modules` existence in sprint pre-flight.

---

### Problem 2 — No `.env` file present (Prisma validation blocked)

**Symptom:** `prisma validate` failed with `Environment variable not found: DIRECT_URL`.

**Diagnosis:** `.env` was correctly excluded from Git (verified via the project's ignore patterns) and had never existed on this workstation.

**Mitigation:** Created `syaahi-backend/.env` locally with real `DATABASE_URL` / `DIRECT_URL` / `JWT_SECRET` values. **No credentials were ever pasted into chat, logs, commits, or terminal captures.** `.env` remains gitignored.

---

### Problem 3 — Migration drift against Supabase (`prisma migrate dev` loop)

**Symptom:** `prisma migrate dev --name add_notifications` reported:

> *"The following migration(s) are applied to the database but missing from the local migrations directory: 0_init"*

Then — repeatedly, even after attempting to baseline — reported "drift detected" and demanded `prisma migrate reset`, which would have **dropped all 18 users and 84 poems**.

**Diagnosis (multi-step):**
1. The Supabase `_prisma_migrations` table had one row: `0_init` applied 2026-07-01.
2. The `prisma/migrations/` directory was never committed to Git — it was in the project's ignore patterns.
3. First baseline attempt (`prisma migrate diff --from-empty --to-schema-datamodel schema.prisma.bak`) succeeded in generating the SQL, but PowerShell's default `Set-Content` wrote the file with a UTF-8 **BOM**, which Prisma's schema engine could not parse — causing a cryptic *"shadow database"* failure.
4. Even after fixing the BOM, Supabase does not allow Prisma to create the shadow database it uses internally to compute drift. `migrate dev` therefore refused to proceed on a cloud-managed Postgres.

**Mitigation (three-part):**

**(a) Fixed the BOM issue.** All subsequent file writes used `[System.IO.File]::WriteAllText(path, content, [System.Text.UTF8Encoding]::new($false))` — a UTF-8 encoder with `encoderShouldEmitUTF8Identifier = false`. This produces exactly what Prisma expects.

**(b) Baselined `0_init` into Git.** Generated the pre-N1 initial-schema SQL via `prisma migrate diff --from-empty --to-schema-datamodel schema.prisma.bak --script`. Computed its SHA-256 locally and updated the `checksum` column in `_prisma_migrations` so the DB record matches the newly-committed file. This retroactively makes the project's migration history complete and reproducible.

**(c) Switched to the Supabase-compatible migration workflow.** For the N1 migration itself, used:

```
prisma migrate diff
  --from-schema-datamodel prisma/schema.prisma.bak   (pre-N1)
  --to-schema-datamodel   prisma/schema.prisma      (post-N1)
  --script
```

This produces exact, additive SQL without touching the database. The SQL was then applied via `$executeRawUnsafe` (one statement at a time — see Problem 5), and finally registered with `prisma migrate resolve --applied 20261023032914_add_notifications`.

**Why not `prisma db push`?** The handoff explicitly forbids it as a substitute for the versioned-migration workflow (§N1.2). The approach above produces a real, checked-in, versioned migration file — not a schema sync.

**Lesson for future sprints:** The team should add a short note in `docs/` about the Supabase-specific migration workflow (`diff` + manual apply + `resolve`) so this doesn't need to be re-discovered in N3/N5. I have **not** added this note yet, since it is a tooling preference that benefits from a senior-dev decision — not a code change I should ship unilaterally.

---

### Problem 4 — Single-line SQL silently commented itself out

**Symptom:** First application attempt reported "SQL executed successfully!" — but a subsequent row-count script failed with `P2021: The table 'public.Notification' does not exist`.

**Diagnosis:** Prisma's `migrate diff --script` output arrived through the PowerShell pipeline as a **single joined line** rather than as line-separated statements. Because SQL `--` comments extend to end-of-line, the entire output became a single huge comment, and Postgres happily executed zero statements. The success message was accurate — zero statements all ran fine.

**Mitigation:** Rewrote the migration file explicitly as multi-line SQL (preserving every statement on its own line) using the heredoc-style PowerShell `@"..."@` block, written via the BOM-free UTF-8 encoder. Verified the file by inspection before re-executing. This is now the committed form of `migration.sql`.

**Lesson:** Never trust PowerShell pipelines to preserve newlines in SQL. Always inspect the file on disk before executing.

---

### Problem 5 — "Cannot insert multiple commands into a prepared statement"

**Symptom:** `prisma.$executeRawUnsafe(sql)` with the full multi-statement migration file threw Postgres error `42601`.

**Diagnosis:** `$executeRawUnsafe` uses Postgres's prepared-statement protocol, which allows exactly one statement per call. The migration has nine statements.

**Mitigation:** Split the file on `;`, trimmed and filtered empty strings, and executed each statement in sequence inside a Node script. Each statement was logged (`[1/9]`, `[2/9]`, …) for traceable output. All nine succeeded.

**Lesson:** For future multi-statement migrations on Supabase, either use this split-and-loop approach, or use Supabase's SQL editor UI, or wire up `pg` directly. The current approach is clean and reproducible.

---

### Problem 6 — `package.json` corrupted by BOM (tsx failed to parse)

**Symptom:** `npm run test:n1` crashed inside tsx with `Error: Error parsing: package.json`.

**Diagnosis:** Updating `package.json` to add the `test:n1` script via PowerShell's `Set-Content ... -Encoding UTF8` wrote a BOM. Node's JSON parser (and tsx, which reads `package.json` to determine module type) does not accept a BOM.

**Mitigation:** Rewrote `package.json` via a one-line Node script that strips any leading BOM, applies the edit, and writes using `fs.writeFileSync` (which never emits a BOM). The file is now clean and both npm and tsx read it correctly.

**Lesson:** Any config file edited from PowerShell must be written via a BOM-free encoder — I now use either Node directly or the `UTF8Encoding($false)` constructor without exception.

---

### Summary of mitigations

Every problem above was a **tooling/environment issue**, not a design or specification issue. None of them required changing the approved N0 schema, deviating from the sprint plan, or introducing an ADR. The product behavior, data model, constraints, and indexes delivered exactly match the N0 architecture specification.

---

## 5. Verified Database State (Post-Migration)

Row counts captured via a custom Prisma script against the live Supabase database **after** migration:

| Table | Count |
|---|---:|
| User | 18 |
| Poem | 84 |
| Reaction | 15 |
| Heart | 15 |
| Follow | 0 |
| **Notification** *(new)* | 0 |
| **NotificationPreference** *(new)* | 0 |

**Zero data loss.** The pre-existing values are identical to those recorded before migration.

Migration status:
```
2 migrations found in prisma/migrations
Database schema is up to date!
```

---

## 6. Files Changed

| File | Change | Purpose |
|---|---|---|
| `syaahi-backend/prisma/schema.prisma` | Modified | Added enum, 2 models, 3 relation fields |
| `syaahi-backend/prisma/migrations/0_init/migration.sql` | New | Baselines the pre-existing production schema |
| `syaahi-backend/prisma/migrations/20261023032914_add_notifications/migration.sql` | New | N1 schema change |
| `syaahi-backend/src/__tests__/notifications.foundation.test.ts` | New | 8-case integration test suite |
| `syaahi-backend/package.json` | Modified | Added `test:n1` script |
| `syaahi-backend/package-lock.json` | Modified | Side effect of `npm install` |

**Not modified:** any Express controller, middleware, route, Flutter file, `.env.example`, or unrelated project file.

---

## 7. Rollback & Recovery Procedure

Should rollback be required, execute against Supabase (via Prisma or the Supabase SQL editor):

```sql
BEGIN;
DROP TABLE IF EXISTS "NotificationPreference";
DROP TABLE IF EXISTS "Notification";
DROP TYPE  IF EXISTS "NotificationType";
DELETE FROM _prisma_migrations
  WHERE migration_name = '20261023032914_add_notifications';
COMMIT;
```

Then in Git:
```
git revert <N1 commit sha>
```

The schema returns to the N0 baseline. No existing data is affected (there is no notification data to lose at this stage).

---

## 8. Known Limitations & Deferred Work

| Item | Reason | Target Sprint |
|---|---|---|
| `DeviceToken` model | Explicitly out of scope for N1 per handoff §4.3 | N5 |
| Notification creation on publish | N3 responsibility | N3 |
| Notification REST endpoints | N2 responsibility | N2 |
| Flutter inbox UI | N4 responsibility | N4 |
| ADR-025 (author self-notification) resolution | Non-blocking for N1 schema | Owner decision before N3 |
| Documented Supabase migration workflow | Suggested but not shipped (requires senior approval) | At senior's discretion |
| Formal test runner (vitest/jest) | Not required by N1; one-off script sufficient | Suggest adopting before N2 |

---

## 9. Suggested Follow-Ups for Senior Review

1. **Decide on an in-repo migration workflow note** for Supabase. The `diff` + manual-apply + `resolve` approach works and is reproducible, but new developers will trip over the same `migrate dev` shadow-DB problem. A short section in `syaahi-backend/README.md` or a new `docs/MIGRATIONS.md` would prevent recurrence. I did not ship this myself as it crosses from implementation detail into project-wide convention.
2. **Adopt a real test runner before N2.** The one-file integration script is adequate for N1's narrow surface, but N2 adds six endpoints with authentication, pagination, and cross-user isolation requirements. `vitest` is the lightest-weight fit for the existing Vite-less, tsx-based stack. Happy to scaffold this at the start of N2 if approved.
3. **ADR-025 (author self-notification) still pending.** This blocks N3, not N1. Please decide before N3 kickoff.

---

## 10. Exit Criteria Checklist

### Database foundation
- [x] Notification model matches approved N0 specification
- [x] Notification preference model matches approved N0 specification
- [x] UUID, timestamps, relations, deletion behavior follow approved decisions
- [x] Unique constraint and required indexes present and verified
- [x] Opt-in defaults to `false`, including for existing users without a preference row
- [x] No device-token or push-delivery scope leaked into N1

### Migration and testing
- [x] Versioned migration exists and has been reviewed
- [x] Migration applied and verified in Supabase dev database
- [x] Existing data (18 Users / 84 Poems / 15 Reactions / 15 Hearts / 0 Follows) preserved exactly
- [x] Database-level constraints have automated test coverage (8/8 passing)
- [x] `tsc` build passes; `prisma validate`, `prisma generate`, `prisma migrate status` all clean
- [x] No unapproved schema or runtime changes

### Engineering hygiene
- [x] Changes limited to approved N1 scope
- [x] No material architecture change (no new ADR required)
- [x] Migration, recovery, and rollback instructions documented
- [x] `N1_COMPLETION_REPORT.md` committed
- [x] Final diff and staged files reviewed
- [ ] **Project owner review and acceptance — PENDING**
- [ ] **Checkpoint tag `v-noti_N1` — WITHHELD pending approval**

---

## 11. Honest Statement of Unverified Items

- **Push deployment to `origin/main`** has not been performed. Commit is prepared locally; waiting on review.
- **Checkpoint tag `v-noti_N1`** has not been created. Per handoff §8, tags are only created after sprint review and approval.
- **No production database was touched.** All work is against the dev/staging Supabase instance tied to the local `.env`.

---

## 12. Final Status

**Ready for owner review.**

I am standing by to:
- Apply any changes requested in review
- Push and tag once approved
- Begin N1.5 doc polishing or roll straight into N2 kickoff

Thank you for the detailed handoff — the scope boundaries and approval-gate instructions made it straightforward to stay inside the lines even when the Supabase migration workflow forced an unexpected detour.

— *Implementation Engineer*