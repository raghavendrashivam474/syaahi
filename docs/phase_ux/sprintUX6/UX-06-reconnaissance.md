# UX-06 Reconnaissance Report

**Sprint:** UX-06 — Meaningful Interaction & Resonance
**Baseline:** v-UX-05 (commit 3054157)
**Branch:** ux-06/meaningful-interaction-resonance
**Date:** 2026-11-07

---

## 1. How does the existing heart interaction work?

**Model:** `Heart` in `prisma/schema.prisma`
- Fields: `id`, `userId`, `poemId`, `createdAt`
- Constraint: `@@unique([userId, poemId])` — one heart per user per poem
- Cascade delete on both user and poem relations

**Backend:** `syaahi-backend/src/modules/heart/heart.controller.ts`
- `POST /api/v1/poems/:id/heart` — commit to heart
- `DELETE /api/v1/poems/:id/heart` — remove from heart
- `GET /api/v1/poems/:id/heart/status` — check if current user hearted
- Uses `req.user!.userId` from JWT auth middleware

**Frontend:** `syaahi-app/lib/features/poems/presentation/reader_screen.dart`
- `_HeartSection` widget in `_ReaderViewState` (local state: `_hearted`, `_heartLoading`)
- Calls `repo.commitToHeart()` / `repo.removeFromHeart()`
- Feed card has `_HeartButton` with gesture isolation (`HitTestBehavior.opaque`)

**Verdict:** Heart is a lightweight binary toggle. Resonance is fundamentally different (text content, author replies). No overlap.

---

## 2. What exactly does the existing reaction system support?

**Model:** `Reaction` in `prisma/schema.prisma`
- Fields: `id`, `userId`, `poemId`, `type` (enum)
- Constraint: `@@unique([userId, poemId, type])` — one of each type per user per poem
- `ReactionType` enum: `FELT_THIS`, `STAYED_WITH_ME`, `BEAUTIFULLY_WRITTEN`, `MADE_ME_THINK`, `COMFORTED_ME`, `INSPIRED_ME`

**Backend:** `syaahi-backend/src/modules/reactions/reactions.controller.ts`
- `POST /api/v1/poems/:id/reactions` — add reaction (upsert, idempotent)
- `DELETE /api/v1/poems/:id/reactions/:type` — remove reaction
- `GET /api/v1/poems/:id/reactions` — summary with counts and user's own reactions

**Frontend:** `syaahi-app/lib/shared/models/poem.dart`
- `ReactionType` enum with `apiValue` and `label` extensions
- `ReactionSummary` model: `type`, `label`, `count`, `reacted`
- `_ReactionsSection` widget renders as a `Wrap` of tappable chips

**Verdict:** Reactions are typed emotional acknowledgements with NO text content. They serve a different purpose than Resonance. No reuse possible for the text-response feature. Keep reactions untouched.

---

## 3. Is there already a comment, response, reply or conversation model?

**No.** There is no comment, response, reply, thread, or conversation model anywhere in the Prisma schema or backend modules.

**Decision:** New `ResonanceResponse` and `ResonanceReply` models are required.

---

## 4. How are notifications created?

**Service:** `syaahi-backend/src/modules/notifications/notification.service.ts`
- `createPublicationNotifications(poemId, authorId)` function
- Queries `NotificationPreference` for opted-in users (excluding author)
- Uses `prisma.notification.createMany({ data, skipDuplicates: true })`
- Best-effort: failures are logged but do not roll back the poem
- Called from `poems.controller.ts` after `createPoem` and publication transitions

**Pattern for UX-06:** We will create a new `createResonanceNotification()` function following the same best-effort pattern, but targeting a single recipient (poem author or response author) rather than a broadcast.

---

## 5. How are notification types represented?

**Enum:** `NotificationType` in `prisma/schema.prisma`
- Currently only: `POEM_PUBLISHED`

**Required extension:**
- Add `RESONANCE_RESPONSE` — someone responded to your poem
- Add `AUTHOR_REPLY` — the author replied to your response

---

## 6. How does notification navigation identify the target poem?

**Backend:** `Notification` model has a `poemId` field (required, foreign key to `Poem`)

**Frontend:** `AppNotification` model in `notifications_repository.dart`
- Fields: `id`, `type`, `poemId`, `readAt`, `createdAt`, `poem` (with `id` and `title`)
- Inbox screen navigates to `/poem/\`

**For UX-06:** The `poemId` field is sufficient for navigation to the reader. For deep-linking to a specific response, we can use query parameters: `/poem/:id?responseId=xxx`. This requires a minor router adjustment but is backward-compatible.

---

## 7. How is poem ownership verified?

**Pattern in `poems.controller.ts` (`updatePoem` and `deletePoem`):**

```typescript
const existing = await prisma.poem.findUnique({
  where: { id },
  select: { authorId: true },
});
if (!existing) throw new ApiError(404, 'Poem not found');
if (existing.authorId !== req.user!.userId) {
  throw new ApiError(403, 'You can only edit your own poems');
}

```

For **UX-06**: Author reply authorization will use the same pattern — fetch the poem's `authorId` and compare it to `req.user!.userId`.

---

## 8. How are API validation and authentication implemented?

### Authentication: `syaahi-backend/src/middleware/auth.ts`

* JWT Bearer token in `Authorization` header
* `authenticate` middleware sets `req.user = { userId, email }`
* Global type declaration extends Express `Request`

### Validation: Zod schemas in `<module>.schemas.ts` files

* `poems.schemas.ts`: `createPoemSchema`, `listPoemsSchema`, `updatePoemSchema`
* `reactions.schemas.ts`: `reactionTypeSchema`
* `notifications.schemas.ts`: `listNotificationsSchema`, `updatePreferencesSchema`
* Zod errors are caught by `errorHandler.ts` and returned as `400` with field errors

### Error Handling

* `ApiError` class with `statusCode`, `message`, `details`

### Rate Limiting: `syaahi-backend/src/middleware/rateLimiter.ts`

* `globalLimiter`: 300 req/15min (applied to all `/api/` routes)
* `writeLimiter`: 30 req/hour (reusable for resonance creation)
* `loginLimiter`, `signupLimiter` (auth-specific)

---

## 9. What database relations would be affected?

### New Models Needed

* `ResonanceResponse` (`poemId` → `Poem`, `userId` → `User`)
* `ResonanceReply` (`responseId` → `ResonanceResponse`, `authorId` → `User`)

### Existing Models to Modify

* **Notification:** Add optional `sourceId` field (`String?`) to identify the specific response/reply that triggered the notification. Change unique constraint from `@@unique([recipientId, poemId, type])` to `@@unique([recipientId, poemId, type, sourceId])` to allow multiple resonance notifications per poem.
* **NotificationType enum:** Add `RESONANCE_RESPONSE` and `AUTHOR_REPLY`.
* **Poem model:** Add `resonances ResonanceResponse[]` relation.
* **User model:** Add `resonances ResonanceResponse[]` and `resonanceReplies ResonanceReply[]` relations.

### Cascade Rules

Follow existing pattern — `onDelete: Cascade` on all foreign keys. When a poem is deleted, its resonances cascade. When a response is deleted, its reply cascades.

---

## 10. Which existing files can be extended?

| File | Extension |
| --- | --- |
| `prisma/schema.prisma` | Add `ResonanceResponse`, `ResonanceReply` models; extend `NotificationType`; add `sourceId` to `Notification` |
| `syaahi-backend/src/app.ts` | Register resonance routes |
| `syaahi-backend/src/modules/notifications/notification.service.ts` | Add `createResonanceNotification()` and `createReplyNotification()` |
| `syaahi-backend/src/modules/notifications/notifications.controller.ts` | No changes needed (existing list/read endpoints handle new types automatically) |
| `syaahi-app/lib/features/poems/presentation/reader_screen.dart` | Insert `_ResonanceSection` after `_ReactionsSection`, before `_AuthorContinuity` |
| `syaahi-app/lib/features/poems/presentation/feed_screen.dart` | Add minimal resonance indicator to `_PoemCard` |
| `syaahi-app/lib/core/router/app_router.dart` | Add `?responseId` query param support to `/poem/:id` route |
| `syaahi-app/lib/features/notifications/data/notifications_repository.dart` | No changes needed (existing model handles new types via string type field) |
| `syaahi-app/lib/features/notifications/presentation/inbox_screen.dart` | Add display text for new notification types |

---

## 11. Which new files are actually necessary?

### Backend

| File | Purpose |
| --- | --- |
| `src/modules/resonance/resonance.controller.ts` | CRUD for responses and replies |
| `src/modules/resonance/resonance.routes.ts` | Route definitions |
| `src/modules/resonance/resonance.schemas.ts` | Zod validation schemas |
| `src/__tests__/resonance.api.test.ts` | Backend tests |

### Frontend

| File | Purpose |
| --- | --- |
| `lib/features/resonance/data/resonance_repository.dart` | Dio API calls |
| `lib/features/resonance/state/resonance_providers.dart` | Riverpod state management |
| `lib/features/resonance/presentation/resonance_section.dart` | Reader integration widget |
| `lib/features/resonance/presentation/response_composer.dart` | Text input with char counter |
| `lib/features/resonance/presentation/response_item.dart` | Single response + reply display |

---

## 12. Which existing tests must remain green?

| Test File | What It Covers |
| --- | --- |
| `src/__tests__/notifications.api.test.ts` | Notification inbox, read, unread count |
| `src/__tests__/notifications.foundation.test.ts` | Notification model and service basics |
| `src/__tests__/notifications.publication.test.ts` | `POEM_PUBLISHED` notification creation |
| `syaahi-app/test/features/poems/presentation/reader_screen_test.dart` | Reader rendering (if exists) |
| All existing Flutter widget tests | Feed, heart, notifications, auth |

---

## Key Architectural Decision

**Notification Unique Constraint Change:** The current `@@unique([recipientId, poemId, type])` prevents multiple notifications of the same type for the same poem. For resonance, an author needs one notification per response. We must add an optional `sourceId` field and change the constraint to `@@unique([recipientId, poemId, type, sourceId])`.

This is backward-compatible because:

* Existing `POEM_PUBLISHED` notifications have `sourceId = null`
* The new constraint still prevents duplicate publication notifications (same poem, same type, same `null` sourceId)
* New resonance notifications use the response/reply ID as `sourceId`

*This requires an ADR. Will be documented in the implementation plan.*

```