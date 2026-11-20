# Syaahi Studio — Risk and Security Review
**Sprint:** ST-00.3  
**Document Status:** Risk & Security Assessment  

---

## 1. Security & Privacy Boundaries

### 1.1 Unpublished Draft Confidentiality
- **Risk:** Unauthorized users accessing another user's in-progress, unpublished writing.
- **Threat Model:** Direct API path enumeration (`GET /api/v1/poems/:id` or `/api/v1/studio/drafts/:id`) or database queries.
- **Mitigation:**
  1. `getPoem` controller explicitly returns `404 Not Found` if `isPublished === false` unless `req.user!.userId === poem.authorId`.
  2. All `/api/v1/studio/drafts` endpoints strictly filter by `where: { authorId: req.user!.userId }`.
  3. No draft content is ever served in feed listing (`listPoems`), public search, or author profile endpoints (`getUserPoems`).

### 1.2 Zero Cloud AI Data Leakage
- **Risk:** User creative writing transmitted to third-party LLMs/AI vendors for training without explicit consent.
- **Constraint:** Syaahi operates under a zero-paid-AI-budget constraint.
- **Mitigation:** All writing intelligence (syllables, rhymes, synonyms) executes strictly on-device inside client Dart Isolates using open-source dictionary assets. Zero keystroke or draft text payload is transmitted to third-party endpoints.

---

## 2. Integrity & Operational Risk Matrix

| Risk Event | Severity | Impact | Mitigation Strategy |
|---|---|---|---|
| **Accidental Notification Trigger** | High | Draft auto-save fires spurious `POEM_PUBLISHED` notifications to followers | Draft creation uses separate `/studio/drafts` API or `isPublished: false`. `createPublicationNotifications` is strictly guarded behind `existing.isPublished === false && updated.isPublished === true`. |
| **Feed Pollution** | High | Unpublished drafts appear in public feed / Syaahi Flow | Prisma feed query hardcodes `where: { isPublished: true }` before running the `syaahiFlow` sequencing algorithm. |
| **Offline Sync Data Loss** | High | Device app kill / OS low-memory kill wipes unsaved text | 500ms debounced autosave to local persistence (`LocalDraftRepository`) ensures keystrokes are committed to disk instantly. |
| **Sync Conflict Overwrite** | Medium | Multi-device editing overwrites newer text with older draft | Timestamp-based Last-Write-Wins with automatic creation of a "Conflict Copy" draft if divergence > 60 seconds. |
| **Destructive Migration** | High | Adding Prisma schema models corrupts existing `Poem` table | Migration scripts strictly add new tables (`Draft`, `PoemRevision`, `Fragment`) or additive optional fields (`structuredContent Json?`). Zero column drops or renames. |
