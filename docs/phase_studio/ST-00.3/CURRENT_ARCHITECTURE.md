# Current Syaahi Architecture — Code-Verified Assessment
**Sprint:** ST-00.3  
**Document Status:** Verified Baseline  
**Baseline Commit:** c80e157  

---

## 1. System Context & Overview
Syaahi is structured as a client-server web and mobile poetry application. The stack consists of:
- **Mobile/Client App (syaahi-app):** Developed using Flutter (SDK ^3.5.0).
- **Backend API Server (syaahi-backend):** Node.js runtime with Express.js written in TypeScript.
- **Database & ORM:** Managed PostgreSQL database accessed via Prisma ORM (Client ^6.19.3).

---

## 2. Component Breakdown

### 2.1 Frontend Architecture (syaahi-app)
- **State Management:** lutter_riverpod (^2.6.1) using StateNotifierProvider and FutureProvider.
- **Navigation:** go_router (^14.6.2) using StatefulShellRoute.indexedStack with 4 shell branches (/home, /discover, /heart, /profile) and root-pushed routes (/write, /poem/:id, /profile/:username, /notifications).
- **HTTP Client:** dio (^5.7.0) wrapped in a singleton ApiClient handling JWT header injection and guest fallback.
- **Storage:** lutter_secure_storage for token management and shared_preferences for basic key-value data. **No local database (SQLite/Drift/Hive) exists.**
- **Writer Interface (lib/features/poems/presentation/writer_screen.dart):**
  - Standard Material TextField controls for Title, Content, and Theme.
  - ChoiceChips for PoemEmotion (6 values) and PoemLanguage (3 hardcoded values).
  - Draft state resides **exclusively in RAM** inside Flutter TextEditingController objects.
  - Exiting the screen without publishing triggers a PopScope modal dialog asking to discard work.

### 2.2 Backend Architecture (syaahi-backend)
- **API Surface (src/app.ts):** Express application mounting routes under /api/v1/:
  - /auth: Login, registration, token refresh.
  - /poems: Poem CRUD (GET /, GET /:id, POST /, PATCH /:id, DELETE /:id), heart routes, reaction routes.
  - /users: Profile retrieval, author poems (GET /users/:username/poems), user hearts.
  - /notifications & /notification-preferences: Activity alerts.
- **Validation Layer:** Zod schemas (src/modules/poems/poems.schemas.ts). createPoemSchema enforces content length (1-10,000 chars) and language enum (ENGLISH, HINDI, URDU), but **does not expose isPublished to clients**.
- **Publication Logic (src/modules/poems/poems.controller.ts):**
  - createPoem: Creates a poem record, setting isPublished: true by Prisma default. Triggers createPublicationNotifications() immediately.
  - getPoem: Rejects access (404 Not Found) if isPublished === false.
  - listPoems: Queries Prisma with where: { isPublished: true }, then passes results through syaahiFlow() feed algorithm.
  - updatePoem: Accepts isPublished: z.boolean().optional(). Triggers createPublicationNotifications() **only** if existing.isPublished === false and poem.isPublished === true.

### 2.3 Database Schema Baseline (prisma/schema.prisma)
- **Poem Entity:**
  - Attributes: id (UUID), uthorId, 	itle (Nullable), content (Text), language (Enum: ENGLISH, HINDI, URDU), emotion (Nullable Enum), 	heme (Nullable), udioUrl (Nullable String), isPublished (Boolean @default(true)), createdAt, updatedAt.
  - Indexes: uthorId, [language, emotion], createdAt.
- **Notification Entity:**
  - Attributes: id, ecipientId, 	ype (POEM_PUBLISHED, RESONANCE_RESPONSE, AUTHOR_REPLY), sourceId, poemId, eadAt, createdAt.
  - Unique constraint: @@unique([recipientId, poemId, type, sourceId]).

---

## 3. Diagram A — Current Syaahi Architecture
`mermaid
graph TD
    subgraph Client ["Flutter Client (syaahi-app)"]
        UI_Feed["FeedScreen / ReaderScreen"]
        UI_Writer["WriterScreen (Material TextFields)"]
        State_Riverpod["Riverpod Providers (writerProvider, feedProvider)"]
        Repo_Poem["PoemsRepository"]
        Net_Dio["ApiClient (Dio Singleton)"]

        UI_Writer -->|Keystrokes in RAM| UI_Writer
        UI_Writer -->|Publish Tap| State_Riverpod
        State_Riverpod --> Repo_Poem
        Repo_Poem --> Net_Dio
        UI_Feed --> State_Riverpod
    end

    subgraph Transport ["HTTP / REST Network Boundary"]
        API_POST["POST /api/v1/poems"]
        API_GET["GET /api/v1/poems"]
        API_PATCH["PATCH /api/v1/poems/:id"]
    end

    subgraph Server ["Backend (syaahi-backend Node/Express)"]
        MW_Auth["Auth & RateLimiter Middleware"]
        Val_Zod["Zod Validation Schemas (createPoemSchema)"]
        Ctrl_Poem["PoemsController (createPoem, listPoems, updatePoem)"]
        Svc_Noti["NotificationService (createPublicationNotifications)"]
        Prisma_ORM["Prisma Client"]

        API_POST --> MW_Auth
        API_GET --> MW_Auth
        API_PATCH --> MW_Auth
        MW_Auth --> Val_Zod
        Val_Zod --> Ctrl_Poem
        Ctrl_Poem --> Svc_Noti
        Ctrl_Poem --> Prisma_ORM
    end

    subgraph Storage ["Database (PostgreSQL)"]
        DB_Poem["Poem Model (isPublished: default true)"]
        DB_User["User Model"]
        DB_Noti["Notification Model"]
        DB_Heart["Heart Model"]
        DB_React["Reaction Model"]

        Prisma_ORM --> DB_Poem
        Prisma_ORM --> DB_User
        Prisma_ORM --> DB_Noti
        Prisma_ORM --> DB_Heart
        Prisma_ORM --> DB_React
    end

    Net_Dio -->|JSON HTTP Request| Transport
