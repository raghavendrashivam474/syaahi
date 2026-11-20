# ST-00.1: Data and API Audit

**Sprint ID:** ST-00.1  
**Phase:** `phase_studio`  
**Status:** Completed  
**Audit Target:** Data Models, Database Schemas, and API Contracts for Poems  

---

## 1. Backend Data Schema Inspection (`syaahi-backend/prisma/schema.prisma`)

The Prisma `Poem` model is defined as follows:

```prisma
model Poem {
  id          String   @id @default(uuid())
  authorId    String
  title       String?
  content     String   @db.Text
  language    Language @default(ENGLISH)
  emotion     Emotion?
  theme       String?
  audioUrl    String?
  isPublished Boolean  @default(true)

  author        User           @relation(fields: [authorId], references: [id], onDelete: Cascade)
  reactions     Reaction[]
  hearts        Heart[]
  rooms         PoemRoom[]
  notifications Notification[]
  resonances    ResonanceResponse[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([authorId])
  @@index([language, emotion])
  @@index([createdAt])
}
```

## 1. Schema Analysis for Studio Requirements

* **`isPublished` Flag:** `Boolean @default(true)`. The schema already supports server-side draft storage when `isPublished = false`.
* **Content Storage:** `content String @db.Text` stores raw text up to the PostgreSQL text limit.
* **Audio Draft Support:** `audioUrl String?` field is present, allowing voice draft attachment.

### Missing Models for Advanced Studio Features
* **No `PoemVersion` or `RevisionHistory` model:** Reverting to previous drafts is not currently modeled in Prisma.
* **No `WritingFragment` or `Snippet` model:** Reusable writing fragments are not modeled.
* **No JSON/RichText structure:** Content is stored purely as a plain text string.

---

## 2. Existing API Contracts (`syaahi-backend/src/modules/poems/`)

### Endpoints Matrix

| HTTP Method | Route | Auth Required | Controller Method | Validation Schema | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/poems` | No | `listPoems` | `listPoemsSchema` | Returns published poems ordered by Syaahi Flow |
| `GET` | `/api/v1/poems/:id` | No | `getPoem` | Params ID (UUID) | Fetches single published poem |
| `POST` | `/api/v1/poems` | Yes (JWT) | `createPoem` | `createPoemSchema` | Creates new poem (`isPublished: true`), triggers notifications |
| `PATCH` | `/api/v1/poems/:id` | Yes (JWT) | `updatePoem` | `updatePoemSchema` | Updates own poem fields; triggers notifications if `isPublished` transitions `false -> true` |
| `DELETE` | `/api/v1/poems/:id` | Yes (JWT) | `deletePoem` | Params ID (UUID) | Deletes author's own poem |

### Validation Rules (`poems.schemas.ts`)

* **`createPoemSchema`:**
  * `title`: optional string, max 200 chars.
  * `content`: required string, min 1 char, max 10,000 chars.
  * `language`: enum (`ENGLISH`, `HINDI`, `URDU`), default `ENGLISH`.
  * `emotion`: optional enum (`LOVE`, `LONGING`, `HOPE`, `SOLITUDE`, `ANGER`, `GRATITUDE`).
  * `theme`: optional string, max 50 chars.

* **`updatePoemSchema`:**
  * `title`: optional nullable string, max 200 chars.
  * `content`: optional string, min 1, max 10,000 chars.
  * `language`: optional enum (`ENGLISH`, `HINDI`, `URDU`).
  * `emotion`: optional nullable enum.
  * `theme`: optional nullable string, max 50 chars.
  * `isPublished`: optional boolean.

---

## 3. Frontend Data Model Mapping (`syaahi-app/lib/shared/models/poem.dart`)

The Dart model `Poem` mirrors the backend JSON response:

* `id`: `String`
* `title`: `String?`
* `content`: `String`
* `language`: `PoemLanguage`
* `emotion`: `PoemEmotion?`
* `theme`: `String?`
* `author`: `PoemAuthor`
* `reactionCount`: `int`
* `heartCount`: `int`
* `createdAt`: `DateTime`

### Frontend Repository Layer (`syaahi-app/lib/features/poems/data/poems_repository.dart`)

* **Responsibility:** Maps API responses to `Poem` models.
* **Implemented methods:** `listPoems`, `getPoem`, `createPoem`, `deletePoem`, `commitToHeart`, `removeFromHeart`, `getHeartStatus`, `getMyHeart`, `getUserPoems`, `getReactions`, `addReaction`, `removeReaction`.
* **Gap:** `PoemsRepository` lacks an `updatePoem` method, even though the backend already supports `PATCH /api/v1/poems/:id`.