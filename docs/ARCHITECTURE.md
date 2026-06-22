# 🪶 Syaahi — Architecture

## Version: v0.2.2

## Status: MVP Complete, Seeded & Locally Verified

---

# System Overview

Syaahi is a client-server application designed for emotional expression, poetry, memory preservation, and reflective writing.

```text
┌─────────────────────┐
│   Flutter Web App   │
│      (Vercel)       │
└────────┬────────────┘
         │ HTTPS (REST API)
         ▼
┌─────────────────────┐
│    Express API      │
│      (Railway)      │
└────────┬────────────┘
         │ Prisma ORM
         ▼
┌─────────────────────┐
│ PostgreSQL Database │
│     (Supabase)      │
└─────────────────────┘
```

Current status:

```text
✓ Authentication
✓ Session Persistence
✓ Poetry Feed
✓ Infinite Scroll Pagination
✓ Poem Reader
✓ Poem Publishing
✓ Seed Content System
✓ Local Verification
```

---

# Frontend Architecture

Technology Stack:

```text
Flutter Web
│
├── go_router
├── Riverpod
├── Dio
├── flutter_secure_storage
│
└── features/
```

Directory Structure:

```text
lib/
│
├── core/
│   ├── routing/
│   ├── theme/
│   ├── constants/
│   └── network/
│
├── features/
│   │
│   ├── auth/
│   │   ├── data/
│   │   ├── state/
│   │   └── presentation/
│   │
│   └── poems/
│       ├── data/
│       ├── state/
│       └── presentation/
│
└── shared/
```

---

# Frontend Design Principle

UI never communicates directly with the backend.

```text
Screen
  ↓
Riverpod Provider / StateNotifier
  ↓
Repository
  ↓
Dio
  ↓
REST API
```

Benefits:

* Testability
* Separation of concerns
* Easier maintenance
* Consistent error handling

---

# Feed Architecture

The poem feed uses cursor-based pagination.

State is managed by a dedicated FeedNotifier.

```text
Feed Screen
     ↓
FeedNotifier
     ↓
PoemsRepository
     ↓
Dio
     ↓
GET /api/v1/poems
```

Feed State:

```text
poems
isLoading
isLoadingMore
hasMore
nextCursor
error
```

---

# Infinite Scroll Lifecycle

```text
Initial Load
      ↓
Fetch First 10 Poems
      ↓
User Scrolls Past 85%
      ↓
loadMore()
      ↓
Fetch Next Page
      ↓
Append Results
      ↓
Update Cursor
      ↓
Repeat Until hasMore = false
      ↓
"You have read everything"
```

Pull-to-refresh resets state and reloads from the first page.

---

# Backend Architecture

```text
Express App
│
├── Middleware
│   ├── helmet
│   ├── cors
│   ├── morgan
│   ├── rateLimiter
│   └── errorHandler
│
└── Modules
    ├── auth/
    ├── poems/
    └── users/
```

Directory Structure:

```text
src/
│
├── config/
├── middleware/
├── modules/
│   ├── auth/
│   ├── poems/
│   └── users/
│
├── utils/
└── server.ts
```

---

# Backend Design Principle

Each module owns:

```text
Routes
Validation
Business Logic
```

Example:

```text
auth/
├── auth.routes.ts
├── auth.schemas.ts
└── auth.controller.ts
```

Shared concerns belong only in:

```text
middleware/
utils/
config/
```

---

# Database Schema

## User

```text
User
├── id
├── email
├── username
├── displayName
├── passwordHash
├── bio
├── avatarUrl
└── poems[]
```

---

## Poem

```text
Poem
├── id
├── authorId
├── title
├── content
├── language
├── emotion
├── isPublished
├── createdAt
└── author
```

---

# Future Schema Models

Defined but not active:

```text
Reaction
Follow
Room
RoomMember
PoemRoom
```

Purpose:

Future-proof schema evolution and reduce migration risk.

These models are not currently exposed through APIs.

---

# Authentication Flow

```text
User Login
      ↓
Zod Validation
      ↓
Find User
      ↓
bcrypt Compare
      ↓
JWT Generation
      ↓
Return Token
      ↓
flutter_secure_storage
      ↓
Authorization Header
      ↓
Protected Route Access
```

Current Authentication Features:

```text
✓ Signup
✓ Login
✓ Session Recovery
✓ Logout
✓ JWT Authentication
✓ Password Hashing
```

Known Limitation:

```text
✗ Refresh Tokens
✗ Token Revocation
✗ Email Verification
```

Logout currently removes the token from the client only.

---

# Request Lifecycle

```text
Incoming Request
      ↓
helmet
      ↓
cors
      ↓
morgan
      ↓
rateLimiter
      ↓
Router
      ↓
authenticate (protected routes)
      ↓
Controller
      ↓
Prisma
      ↓
Database
      ↓
JSON Response
      ↓
errorHandler (if needed)
```

---

# CORS Strategy

Development:

```text
Allow all localhost origins
```

Reason:

Flutter Web uses dynamic localhost ports.

Example:

```text
localhost:3000
localhost:5000
localhost:59837
```

Production:

```text
Allow only CORS_ORIGIN
```

Configured through environment variables.

This behaviour is documented in ADR-010.

---

# Seed Content System

Purpose:

Provide realistic data for development, demos, testing, and UI validation.

Current Dataset:

```text
10 Users
30 Poems
2 Languages
5 Core Emotions
```

Writer Personas:

```text
raghav_writes
midnight_writer
sara_writes
arjun_kavya
zara_lafz
aarav_thinks
meera_writes
kabir_outdoors
ananya_heals
rizwan_recalls
```

---

# Seed Script

Location:

```text
scripts/cleanup-and-reseed.ts
```

Usage:

```bash
npx tsx scripts/cleanup-and-reseed.ts
```

Actions:

```text
Delete old seed data
Create accounts
Create poems
Shuffle authors
Stagger timestamps
```

Used for development only.

---

# Environment Validation

All environment variables are validated using Zod at startup.

If validation fails:

```text
Server startup is aborted.
```

Benefits:

* Prevents misconfiguration
* Detects missing secrets early
* Safer deployments

---

# Required Environment Variables

Backend:

```env
DATABASE_URL=
DIRECT_URL=
JWT_SECRET=
JWT_EXPIRES_IN=
CORS_ORIGIN=
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
```

Frontend:

```env
API_BASE_URL=
```

---

# Current Limitations

Accepted technical debt:

```text
No refresh tokens
No email verification
No profile editing
No poem deletion
No automated tests
No production deployment yet
```

These are documented and intentionally deferred.

---

# Deployment Targets

```text
Frontend → Vercel
Backend  → Railway
Database → Supabase
```

Current Status:

```text
Deployment Ready
Not Yet Deployed
```

---

# Guiding Principles

1. Feature-based architecture.
2. Repository pattern everywhere.
3. UI never calls APIs directly.
4. Validate all inputs.
5. Validate all environment variables.
6. Prefer simplicity over complexity.
7. Preserve emotional-first product philosophy.

---

# Architecture Summary

```text
Flutter Web
     ↓
Riverpod
     ↓
Repository
     ↓
Dio
     ↓
Express API
     ↓
Prisma
     ↓
PostgreSQL
```

Current Version:

```text
v0.2.2
MVP Complete
Seeded
Paginated
Documented
Locally Verified
Deployment Pending
```
