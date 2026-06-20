# 🪶 Syaahi — Architecture

## System Overview

Syaahi is a client-server application.

```text
┌─────────────────────┐
│   Flutter Web App   │
│   (Vercel)          │
└────────┬────────────┘
         │ HTTPS (REST API)
         ▼
┌─────────────────────┐
│   Express API       │
│   (Railway)         │
└────────┬────────────┘
         │ Prisma ORM
         ▼
┌─────────────────────┐
│   PostgreSQL        │
│   (Supabase)        │
└─────────────────────┘
Frontend Architecture
text

Flutter Web
│
├── go_router           → Navigation and routing
├── Riverpod            → State management
├── Dio                 → HTTP client
│
└── features/
    ├── auth/
    │   ├── data/       → AuthRepository (API calls)
    │   ├── state/      → Auth providers (Riverpod)
    │   └── presentation/ → Login, Signup screens
    │
    └── poems/
        ├── data/       → PoemRepository (API calls)
        ├── state/      → Poem providers (Riverpod)
        └── presentation/ → Feed, Reader, Writer screens
Key Principle
UI never calls the API directly.

text

Screen → Provider → Repository → Dio → API
Backend Architecture
text

Express App (app.ts)
│
├── Middleware (applied globally)
│   ├── helmet          → Security headers
│   ├── cors            → Cross-origin requests
│   ├── morgan          → Request logging
│   ├── rateLimiter     → Abuse prevention
│   └── errorHandler    → Centralised error responses
│
└── Modules
    ├── auth/
    │   ├── auth.schemas.ts     → Zod input validation
    │   ├── auth.controller.ts  → Business logic
    │   └── auth.routes.ts      → Route definitions
    │
    ├── poems/
    │   ├── poems.schemas.ts
    │   ├── poems.controller.ts
    │   └── poems.routes.ts
    │
    └── users/
        ├── users.schemas.ts
        ├── users.controller.ts
        └── users.routes.ts
Key Principle
Each module owns its own routes, validation, and logic.
Shared concerns live in middleware and utils only.

Database Schema
Core models currently in use:

text

User
├── id           UUID
├── email        String (unique)
├── username     String (unique)
├── displayName  String
├── passwordHash String
├── bio          String?
├── avatarUrl    String?
└── poems        Poem[]

Poem
├── id           UUID
├── authorId     String → User
├── title        String?
├── content      Text
├── language     ENGLISH | HINDI | URDU
├── emotion      LOVE | LONGING | HOPE | SOLITUDE | ANGER | GRATITUDE
├── isPublished  Boolean
└── author       User
Schema models defined but not yet implemented in API:

text

Reaction    → Meaningful reactions to poems
Follow      → User following system
Room        → Poetry rooms / circles
RoomMember  → Room membership
PoemRoom    → Poems shared in rooms
These exist in the schema to avoid future migrations breaking production.
They will be activated as features are built.

Authentication Flow
text

1. User submits email + password
2. Server validates input (Zod)
3. Server checks email exists
4. Server compares password with bcrypt hash
5. Server signs JWT with userId and email
6. Client stores JWT in flutter_secure_storage
7. Client sends JWT in Authorization header on every request
8. authenticate middleware verifies JWT on protected routes
Token expiry is configured via JWT_EXPIRES_IN.
Token revocation is not yet implemented. Logout is client-side only.

Request Lifecycle
text

Incoming Request
      ↓
helmet (security headers)
      ↓
cors (origin check)
      ↓
morgan (log request)
      ↓
rateLimiter (abuse check)
      ↓
Router (match route)
      ↓
authenticate (if protected route)
      ↓
asyncHandler (catch async errors)
      ↓
Controller (business logic)
      ↓
Prisma (database query)
      ↓
JSON Response
      ↓
errorHandler (if anything threw)
Environment Configuration
All environment variables are validated at startup using Zod.

If any required variable is missing or invalid, the server refuses to start.

This prevents silent misconfiguration in production.

See .env.example in the backend for the full variable list.

