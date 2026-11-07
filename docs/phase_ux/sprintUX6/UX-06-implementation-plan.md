# UX-06 Implementation Plan

**Sprint:** UX-06 — Meaningful Interaction & Resonance
**Baseline:** v-UX-05 (commit 3054157)
**Branch:** ux-06/meaningful-interaction-resonance

---

## Architecture Decision: Notification Constraint Extension

**Problem:** The current `@@unique([recipientId, poemId, type])` on Notification prevents multiple notifications of the same type per poem. Resonance requires one notification per response.

**Decision:** Add optional `sourceId` field to Notification. Change constraint to `@@unique([recipientId, poemId, type, sourceId])`.

**Backward compatibility:**
- Existing POEM_PUBLISHED records have `sourceId = null` — constraint still prevents duplicates
- New resonance notifications use the response/reply UUID as `sourceId`
- No data migration needed for existing records
- The `listNotifications` query does not filter by `sourceId`, so existing frontend code is unaffected

**Files affected:** `prisma/schema.prisma`, `notification.service.ts` (new functions only)

---

## Stage S1: Backend Foundation

### 1.1 Prisma Schema Changes

**File:** `syaahi-backend/prisma/schema.prisma`

#### Extend `NotificationType` enum:
```prisma
enum NotificationType {
  POEM_PUBLISHED
  RESONANCE_RESPONSE
  AUTHOR_REPLY
}

```

#### Add `sourceId` to `Notification` model:

```prisma
model Notification {
  ...
  sourceId  String? // ID of the response or reply that triggered this
  ...
  @@unique([recipientId, poemId, type, sourceId]) // was [recipientId, poemId, type]
}

```

#### Add new models:

```prisma
model ResonanceResponse {
  id        String   @id @default(uuid())
  poemId    String
  userId    String
  content   String   @db.VarChar(280)

  poem      Poem     @relation(fields: [poemId], references: [id], onDelete: Cascade)
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  reply     ResonanceReply?

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([poemId])
  @@index([userId])
}

model ResonanceReply {
  id         String            @id @default(uuid())
  responseId String            @unique
  authorId   String
  content    String            @db.VarChar(280)

  response   ResonanceResponse @relation(fields: [responseId], references: [id], onDelete: Cascade)
  author     User              @relation(fields: [authorId], references: [id], onDelete: Cascade)

  createdAt  DateTime          @default(now())
  updatedAt  DateTime          @updatedAt
}

```

#### Add relations to existing models:

* **`User`:** add `resonances ResonanceResponse[]` and `resonanceReplies ResonanceReply[]`
* **`Poem`:** add `resonances ResonanceResponse[]`

---

### 1.2 Migration

```bash
npx prisma migrate dev --name add_resonance_and_notification_source

```
---


### 1.3 Backend Module: Resonance

New files under `syaahi-backend/src/modules/resonance/`:

**resonance.schemas.ts** — Zod schemas:
- `createResponseSchema`: `{ content: z.string().trim().min(1).max(280) }`
- `updateResponseSchema`: `{ content: z.string().trim().min(1).max(280) }`
- `createReplySchema`: `{ content: z.string().trim().min(1).max(280) }`
- `updateReplySchema`: `{ content: z.string().trim().min(1).max(280) }`

**resonance.controller.ts** — Handlers:
- `createResponse`: Validate poem exists + published, create response, notify poem author
- `listResponses`: Fetch responses for a poem with user info and optional reply
- `updateResponse`: Verify ownership, update content
- `deleteResponse`: Verify ownership, delete (cascades reply)
- `createReply`: Verify requester is poem author, verify no existing reply, create reply, notify responder
- `updateReply`: Verify ownership (poem author), update content
- `deleteReply`: Verify ownership, delete

**resonance.routes.ts** — Route definitions:
- `POST /api/v1/poems/:poemId/resonances` (authenticate, writeLimiter)
- `GET /api/v1/poems/:poemId/resonances` (public — same as poem reading)
- `PATCH /api/v1/resonances/:responseId` (authenticate)
- `DELETE /api/v1/resonances/:responseId` (authenticate)
- `POST /api/v1/resonances/:responseId/reply` (authenticate, writeLimiter)
- `PATCH /api/v1/resonance-replies/:replyId` (authenticate)
- `DELETE /api/v1/resonance-replies/:replyId` (authenticate)

### 1.4 Notification Service Extension

File: `syaahi-backend/src/modules/notifications/notification.service.ts`

Add two new functions:
- `createResonanceNotification(poemId, authorId, responderId, responseId)`: Creates a RESONANCE_RESPONSE notification for the poem author. Skips if responder is the author (no self-notification).
- `createReplyNotification(poemId, responseUserId, replyId)`: Creates an AUTHOR_REPLY notification for the original responder.

### 1.5 Register Routes

File: `syaahi-backend/src/app.ts`
- Import and mount resonance routes

### 1.6 Backend Tests

File: `syaahi-backend/src/__tests__/resonance.api.test.ts`
- Response CRUD with auth checks
- Reply CRUD with author-only checks
- Validation (empty, too long, whitespace-only)
- Notification creation
- Self-notification prevention

**Exit condition:** All API operations work with authorization and integrity tests passing.

---

## Stage S2: Flutter Domain Integration

### 2.1 New Feature Module

Directory: `syaahi-app/lib/features/resonance/`

**data/resonance_repository.dart:**
- `ResonanceException` class (mirrors `PoemsException`)
- `ResonanceResponse` model: id, poemId, userId, content, user (id, username, displayName, avatarUrl), reply, createdAt, updatedAt
- `ResonanceReply` model: id, responseId, authorId, content, author (id, displayName, avatarUrl), createdAt, updatedAt
- `ResonanceRepository` class with Dio calls mirroring `PoemsRepository` pattern

**state/resonance_providers.dart:**
- `resonanceRepositoryProvider`
- `ResonanceState`: responses list, isLoading, isSubmitting, error
- `ResonanceNotifier` (StateNotifier): load, submit, edit, delete, submitReply, editReply, deleteReply

### 2.2 Presentation Widgets

**presentation/resonance_section.dart:**
- `_ResonanceSection` — container widget for the reader
- Shows "Resonance" heading with explanation text
- Renders response list or empty state
- Includes composer for authenticated users

**presentation/response_composer.dart:**
- Text input with 280-char limit
- Character counter
- Submit button with loading state
- Prevents duplicate submissions

**presentation/response_item.dart:**
- Displays response content, author info, timestamp
- Edit/delete controls for own response
- Displays author reply if present
- Reply composer for poem author only

**Exit condition:** Frontend communicates with backend, all states handled.

---

## Stage S3: Reader Integration

**File:** `syaahi-app/lib/features/poems/presentation/reader_screen.dart`

**Insertion point:** In `_ReaderViewState.build()`, after `_ReactionsSection` and before `_AuthorContinuity`:

```dart
// After reactions section:
const SizedBox(height: SyaahiSizes.xxl),
_ResonanceSection(poem: widget.poem),

```

> **Preserved:** All existing UX-05 layout, stanza rendering, heart, reactions, author continuity.

**Exit condition:** Full response lifecycle works in the reader.

---

## Stage S4: Feed & Notifications Integration

### 4.1 Feed Entry Point

**File:** `syaahi-app/lib/features/poems/presentation/feed_screen.dart`

Add a small resonance indicator to `_PoemCard` — a subtle icon/text showing response count or "Respond" prompt next to the heart button. Tapping navigates to `/poem/:id` (existing behavior).

### 4.2 Notifications

**File:** `syaahi-app/lib/features/notifications/presentation/inbox_screen.dart`

Add display text for new notification types:

* `RESONANCE_RESPONSE`: "Someone responded to your poem"
* `AUTHOR_REPLY`: "The author replied to your response"

### 4.3 Router

**File:** `syaahi-app/lib/core/router/app_router.dart`

Extend `/poem/:id` route to accept optional `responseId` query parameter for deep-linking from notifications.

**Exit condition:** End-to-end interaction loop works.

---

## Stage S5: Verification & Release

1. Run `flutter analyze` and `flutter test`
2. Run backend test suite
3. Manual responsive verification
4. Security and authorization checks
5. Write completion report
6. Merge and tag `v-UX-06`

---

## File Impact Summary

### Modified Files (7)

* `syaahi-backend/prisma/schema.prisma`
* `syaahi-backend/src/app.ts`
* `syaahi-backend/src/modules/notifications/notification.service.ts`
* `syaahi-app/lib/features/poems/presentation/reader_screen.dart`
* `syaahi-app/lib/features/poems/presentation/feed_screen.dart`
* `syaahi-app/lib/features/notifications/presentation/inbox_screen.dart`
* `syaahi-app/lib/core/router/app_router.dart`

### New Files (9)

#### Backend

* `syaahi-backend/src/modules/resonance/resonance.controller.ts`
* `syaahi-backend/src/modules/resonance/resonance.routes.ts`
* `syaahi-backend/src/modules/resonance/resonance.schemas.ts`
* `syaahi-backend/src/__tests__/resonance.api.test.ts`

#### Frontend

* `syaahi-app/lib/features/resonance/data/resonance_repository.dart`
* `syaahi-app/lib/features/resonance/state/resonance_providers.dart`
* `syaahi-app/lib/features/resonance/presentation/resonance_section.dart`
* `syaahi-app/lib/features/resonance/presentation/response_composer.dart`
* `syaahi-app/lib/features/resonance/presentation/response_item.dart`

### Deleted Files

* None

```
