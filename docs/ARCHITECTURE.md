# 🪶 Syaahi — Architecture

## Version: v0.3.0-beta

## Status: Internal Beta • Locally Verified • Deployment Ready

---

# System Overview

Syaahi is a client-server application built for emotional expression, poetry, memory preservation, and reflective writing.

Unlike traditional social platforms, Syaahi does not optimize for engagement. Every architectural decision prioritizes simplicity, longevity, and meaningful user experiences.

```text
┌─────────────────────┐
│   Flutter App       │
│ (Web / Android)     │
└────────┬────────────┘
         │ HTTPS (REST API)
         ▼
┌─────────────────────┐
│    Express API      │
│  (Node.js + TS)     │
└────────┬────────────┘
         │ Prisma ORM
         ▼
┌─────────────────────┐
│ PostgreSQL Database │
│     (Supabase)      │
└─────────────────────┘
```

Current platform capabilities:

```text
✓ Authentication
✓ Session Recovery
✓ User Profiles
✓ Poetry Feed
✓ Cursor Pagination
✓ Infinite Scroll
✓ Feed Filters
✓ Heart System
✓ Meaningful Reactions
✓ Syaahi Flow Feed Engine
✓ Seed Content System
✓ Local Verification
```

---

# Application Flow

The current user journey follows:

```text
App Launch
      ↓
Splash Screen
      ↓
Session Recovery
      ↓
Welcome / Feed
      ↓
Feed
 ├── Read Poem
 ├── Write Poem
 ├── Profile
 ├── Commit to Heart
 └── Meaningful Reactions
```

---

# Frontend Architecture

Technology Stack:

```text
Flutter
│
├── go_router
├── Riverpod
├── Dio
├── flutter_secure_storage
│
└── Feature Modules
```

Directory Structure:

```text
lib/
│
├── core/
│   ├── router/
│   ├── network/
│   ├── storage/
│   ├── theme/
│   └── constants/
│
├── features/
│   ├── splash/
│   ├── welcome/
│   ├── auth/
│   ├── poems/
│   ├── profile/
│   ├── heart/
│   ├── reactions/
│   └── home/
│
├── shared/
│   ├── models/
│   └── widgets/
│
└── main.dart
```

---

# Frontend Design Principles

UI never communicates directly with backend services.

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

- Clear separation of concerns
- Highly testable architecture
- Easier maintenance
- Consistent error handling
- Scalable feature development

---

# Feed Architecture

The feed is powered by cursor pagination and the Syaahi Flow engine.

```text
Feed Screen
      ↓
FeedNotifier
      ↓
PoemsRepository
      ↓
GET /api/v1/poems
      ↓
Syaahi Flow
      ↓
Cursor Pagination
      ↓
Append Results
```

Feed state maintains:

```text
poems
isLoading
isLoadingMore
hasMore
nextCursor
error
```

---

# Syaahi Flow

Before poems are returned to the client, they pass through the **Syaahi Flow** sequencing engine.

```text
Database
      ↓
Recent Poems
      ↓
Syaahi Flow
      ↓
Cursor Pagination
      ↓
API Response
```

Responsibilities:

- Preserve overall recency
- Distribute authors naturally
- Prevent consecutive poems by the same author whenever possible
- Never rank content using popularity
- Never use reactions or Hearts for ranking
- Produce deterministic ordering

Syaahi Flow is a literary sequencing engine, not a recommendation algorithm.

---

# Infinite Scroll Lifecycle

```text
Initial Load
      ↓
Fetch First Page
      ↓
Receive nextCursor
      ↓
User Scrolls
      ↓
loadMore()
      ↓
Fetch Next Page
      ↓
Append Results
      ↓
Repeat
      ↓
nextCursor = null
      ↓
"You have read everything"
```

Pull-to-refresh clears the current feed state and reloads from the beginning.

---

# Backend Architecture

```text
Express Application
│
├── Middleware
│   ├── helmet
│   ├── cors
│   ├── morgan
│   ├── rateLimiter
│   ├── authenticate
│   └── errorHandler
│
├── Auth Module
├── Users Module
├── Poems Module
├── Hearts Module
├── Reactions Module
│
└── Feed Engine
    └── Syaahi Flow
```

Directory Structure:

```text
src/
│
├── config/
├── middleware/
├── modules/
│   ├── auth/
│   ├── users/
│   ├── poems/
│   ├── hearts/
│   └── reactions/
│
├── utils/
│   ├── feed/
│   │   └── syaahiFlow.ts
│   ├── ApiError.ts
│   └── asyncHandler.ts
│
├── app.ts
└── server.ts
```

---

# Backend Design Principles

Every feature owns its:

```text
Routes
Validation
Business Logic
Repositories
```

Example:

```text
poems/
├── poems.routes.ts
├── poems.schemas.ts
├── poems.controller.ts
└── poems.repository.ts
```

Shared behaviour belongs only in:

```text
config/
middleware/
utils/
```

---

# Database Model Overview

## Active Models

```text
User
│
├── Poems
├── Hearts
└── Reactions

Poem
│
├── Author
├── Hearts
└── Reactions

Heart

Reaction
```

---

## Future Models

Reserved for future releases:

```text
Journal

TimeCapsule

Letter

Circle

Follow
```

These remain outside the current API until their respective roadmap phases begin.

---

# Heart System

Readers may privately preserve poems.

Characteristics:

- Private
- No notifications
- No public counts
- Personal archive only
- Does not influence feed ranking

```text
Reader
      ↓
Commit to Heart
      ↓
Private Collection
```

---

# Meaningful Reactions

Syaahi intentionally avoids Like buttons.

Readers acknowledge how a poem affected them.

Supported reactions:

```text
FELT_THIS

STAYED_WITH_ME

BEAUTIFULLY_WRITTEN

MADE_ME_THINK

COMFORTED_ME

INSPIRED_ME
```

These reactions communicate emotional impact rather than popularity.

---

# Authentication Flow

```text
User Login
      ↓
Zod Validation
      ↓
User Lookup
      ↓
bcrypt Verification
      ↓
JWT Generation
      ↓
Secure Storage
      ↓
Authorization Header
      ↓
Protected API Access
```

Current capabilities:

```text
✓ Signup
✓ Login
✓ Session Recovery
✓ Logout
✓ JWT Authentication
✓ Password Hashing
```

Current limitations:

```text
No Refresh Tokens

No Token Blacklist

No Email Verification
```

Logout currently removes the token from the client only.

---

# Request Lifecycle

```text
Incoming Request
      ↓
Helmet
      ↓
CORS
      ↓
Morgan
      ↓
Rate Limiter
      ↓
Authentication
      ↓
Zod Validation
      ↓
Controller
      ↓
Prisma
      ↓
Database
      ↓
Syaahi Flow (Feed Only)
      ↓
Cursor Pagination
      ↓
JSON Response
      ↓
Error Handler (if required)
```

---

# CORS Strategy

Development:

```text
Allow all localhost origins
```

Reason:

Flutter development uses dynamic localhost ports.

Production:

```text
Allow only configured CORS_ORIGIN values
```

Configured entirely through environment variables.

---

# Seed Content System

Purpose:

- Local development
- UI validation
- Feed testing
- Pagination testing
- Demonstrations

Current dataset:

```text
10 Writers

30 Poems

Multiple Languages

Multiple Themes

Multiple Emotions
```

Seed script:

```text
scripts/cleanup-and-reseed.ts
```

Usage:

```bash
npx tsx scripts/cleanup-and-reseed.ts
```

Operations performed:

```text
Delete previous seed data
Create seed accounts
Create poems
Distribute authors naturally
Stagger timestamps
```

---

# Environment Validation

All backend environment variables are validated at startup using Zod.

If validation fails:

```text
Server startup is aborted immediately.
```

Benefits:

- Prevents invalid deployments
- Detects missing configuration early
- Eliminates silent runtime failures

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
No Refresh Tokens

No Email Verification

No Token Blacklist

No Automated Test Suite

Redis-backed Rate Limiting Pending

Production Deployment Pending
```

These limitations are documented and intentionally deferred.

---

# Deployment Targets

```text
Android APK  → Internal Beta Distribution

Backend      → Railway (or alternative)

Database     → Supabase
```

Current status:

```text
Deployment Ready

Awaiting Production Deployment
```

---

# Architectural Principles

1. Feature-based architecture.
2. Repository pattern throughout the application.
3. UI never communicates directly with APIs.
4. Every request is validated.
5. Every environment variable is validated.
6. Shared logic belongs only in common utilities.
7. Feed ordering is handled exclusively by Syaahi Flow.
8. Emotional interactions never influence ranking.
9. Prefer simplicity over cleverness.
10. Preserve the product's emotional-first philosophy.

---

# Architecture Summary

```text
Flutter App
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
      ↓
Syaahi Flow
      ↓
Cursor Pagination
      ↓
Client
```

Current Release:

```text
v0.3.0-beta

Internal Beta

Locally Verified

Documentation Complete

Deployment Ready
```