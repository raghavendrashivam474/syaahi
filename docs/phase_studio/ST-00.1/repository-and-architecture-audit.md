# ST-00.1: Repository and Architecture Audit

**Sprint ID:** ST-00.1  
**Phase:** `phase_studio`  
**Status:** Completed  
**Audit Target:** Syaahi Monorepo Repository Structure & Architecture Baseline  

---

## 1. Directory & Repository Overview

Syaahi is structured as a monorepo containing a Flutter mobile/web client, an Express/Prisma backend server, and standardized architectural documentation.
syaahi/
├── syaahi-app/ # Flutter Client (Dart 3, Riverpod 2.6, GoRouter 14.6)
├── syaahi-backend/ # Node.js/Express API (Express 5.2, Prisma 6.19, Zod 4, Supabase PG)
└── docs/ # Architectural documentation and phase records
├── architecture/ # Global ADRs
├── phase_stability/ # Phase stability artifacts
├── phase_ux/ # Phase UX artifacts (UX-01 through UX-08)
├── Phase_noti/ # Phase notification artifacts
└── phase_studio/ # Studio Phase discovery & architecture docs

text


---

## 2. Frontend Architecture Inspection (`syaahi-app`)

### Dependencies Overview (`syaahi-app/pubspec.yaml`)
- **Framework & SDK:** Flutter SDK (Dart 3.x)
- **State Management:** `flutter_riverpod: ^2.6.1` (using `StateNotifier`, `StateNotifierProvider`, and `FutureProvider`)
- **Navigation:** `go_router: ^14.6.2` (utilizing `StatefulShellRoute.indexedStack` for bottom shell tabs and root navigator key for pushed routes)
- **HTTP Client:** `dio: ^5.7.0` (wrapped via `ApiClient` with async bearer token interceptors)
- **Storage:**
  - `flutter_secure_storage: ^9.2.2` (used for JWT auth token storage in `TokenStorage`)
  - `shared_preferences: ^2.3.3` (used for simple flags such as `OnboardingStorage`)
  - **No local database** (`hive`, `isar`, `sqflite`, or `drift` are currently **absent**).
- **Text & UI Component Libraries:**
  - `google_fonts: ^6.2.1`
  - **No rich text/WYSIWYG editor library** (`flutter_quill`, `super_editor`, `zefyr` are currently **absent**).

### Frontend Folder Boundaries (`syaahi-app/lib`)
lib/
├── core/
│ ├── constants/ # Colors, sizes, strings (SyaahiColors, SyaahiSizes, SyaahiStrings)
│ ├── navigation/ # AppNavigationShell (4 bottom tabs: Home, Discover, Heart, Profile)
│ ├── network/ # ApiClient (Dio with 3s timeout token retrieval)
│ ├── router/ # AppRouter (GoRouter setup, auth redirect guard, 404 handler)
│ ├── storage/ # TokenStorage, OnboardingStorage
│ └── theme/ # AppTheme (Dark midnight theme, Cormorant Garamond & Inter typography)
├── features/
│ ├── auth/ # LoginScreen, SignupScreen, AuthRepository, AuthNotifier
│ ├── discovery/ # DiscoveryScreen, search widgets, discovery_providers
│ ├── home/ # HomeScreen
│ ├── notifications/ # InboxScreen, NotificationsRepository, notifications_providers
│ ├── onboarding/ # ContextualTip, AuthPrompt, OnboardingWalkthrough
│ ├── poems/ # FeedScreen, ReaderScreen, WriterScreen, HeartScreen, PoemsRepository
│ ├── profile/ # ProfileScreen, AuthorProfileScreen, ProfileRepository
│ ├── resonance/ # ResonanceSection, ResponseComposer, ResonanceRepository
│ ├── splash/ # SplashScreen
│ └── welcome/ # WelcomeScreen
└── shared/
└── models/ # Poem, PoemAuthor, ReactionSummary, User, AuthorProfile

text


---

## 3. Backend Architecture Inspection (`syaahi-backend`)

### Tech Stack & Runtime (`syaahi-backend/package.json`)
- **Runtime & Language:** Node.js, TypeScript 6.0, `tsx` 4.22
- **Framework:** Express 5.2.1
- **Database & ORM:** PostgreSQL (hosted on Supabase) accessed via Prisma Client 6.19.3
- **Validation:** Zod 4.4.3
- **Security:** `bcryptjs` 3.0.3, `jsonwebtoken` 9.0.3, `helmet` 8.2.0, `express-rate-limit` 8.5.2

### Backend Architecture Layout (`syaahi-backend/src`)
src/
├── api.ts # Main API router mounting /api/v1 sub-routers
├── app.ts # Express app setup, CORS, Helmet, Morgan, global error handling
├── server.ts # Process listener and port binding
├── config/
│ ├── env.ts # Validated environment variables (Zod)
│ └── prisma.ts # Singleton PrismaClient instance
├── middleware/
│ ├── auth.ts # JWT authentication middleware (attaches req.user)
│ ├── rateLimiter.ts # Global, auth, and write rate limiters
│ └── validate.ts # Zod validation middleware
├── modules/
│ ├── auth/ # Login, signup, me
│ ├── heart/ # Hearting/unhearting endpoints
│ ├── notifications/ # Inbox, unread count, read-all, notification preferences
│ ├── poems/ # Create, list (Syaahi Flow), get, update (PATCH), delete
│ ├── reactions/ # 6-type emotional reactions
│ ├── resonance/ # Line/poem level responses and author replies
│ └── users/ # Author profiles and published poem listing
└── utils/
├── ApiError.ts # Custom operational error class
├── asyncHandler.ts # Async route handler wrapper
└── feed.ts # Syaahi Flow algorithm (interleaving & sequencing)

text


---

## 4. Current Module Boundaries & Reusability Assessment

1. **Poems Domain Boundary:** Currently, all poem operations (feed reading, single poem reading, writing/creation) reside within `lib/features/poems/`.
2. **State Management Boundary:** Riverpod state notifiers are decoupled from UI:
   - `feedProvider`: Feed state, pagination, and heart hydration.
   - `writerProvider`: Poem creation state (`isPublishing`, `error`).
   - `poemByIdProvider`: Family provider fetching individual poems.
3. **Storage Boundary:** Storage is strictly token/preference key-value pair (`flutter_secure_storage` and `shared_preferences`).
4. **API Layer Boundary:** All API calls route through `ApiClient` singleton with automatic `Bearer` JWT insertion and connection timeout handling (10s connect, 15s receive).

---

## 5. Summary Findings for Studio Architecture

- **Clean Layering:** The application exhibits crisp separation between Presentation (widgets), State (Riverpod StateNotifiers), Data Access (Repositories), and Models.
- **Missing Infrastructure for Studio:**
  1. No rich text formatting structure or Quill delta model.
  2. No local offline cache/database engine.
  3. No draft management UI or local draft persistence in `syaahi-app`.
  4. Backend already supports `PATCH /api/v1/poems/:id` and `isPublished: false` drafts in Prisma schema, but frontend repository (`PoemsRepository`) does not implement `updatePoem` or draft APIs.
