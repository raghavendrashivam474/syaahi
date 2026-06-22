# 🪶 Syaahi — Progress Log

This document serves as the engineering diary for Syaahi.

It records major milestones, decisions, implementation progress, and upcoming work.

The goal is to help future contributors understand:

* What was built
* Why it was built
* What remains
* Where the project is heading

---

# 2026-06 — Foundation (v0.1.0)

## Backend

* Initialised Node.js + Express.js + TypeScript project
* Configured Prisma ORM with Supabase PostgreSQL
* Designed initial database schema
* Implemented Zod environment validation
* Created modular project structure
* Added health check endpoint
* Added Helmet security middleware
* Added CORS middleware
* Added Morgan request logging
* Created ApiError utility
* Created asyncHandler utility

## Decisions Made

* Feature-based architecture selected
* Prisma selected as ORM
* Zod selected for validation
* Supabase selected for PostgreSQL hosting

## Outcome

Foundation established for MVP development.

---

# 2026-06 — MVP Implementation (v0.2.0)

## Backend

### Authentication

* User signup
* User login
* JWT generation
* JWT verification
* Session recovery endpoint
* Logout endpoint
* Password hashing using bcrypt

### Poems

* Create poem
* Retrieve poem by ID
* Feed endpoint
* Author joins on feed responses

### Users

* Public profile endpoint

### Security

* Global rate limiting
* Auth-specific rate limiting
* Request validation via Zod

---

## Flutter Application

### Architecture

* Riverpod
* Dio
* go_router
* flutter_secure_storage

### Authentication

* Login screen
* Signup screen
* Session recovery
* Secure token storage

### Poems

* Feed screen
* Reader screen
* Writer screen

### Architecture Patterns

* Repository pattern
* Feature-based structure
* Separation of UI and data layers

---

## Decisions Made

* JWT authentication selected
* Flutter Web selected for MVP
* express-rate-limit selected for abuse prevention

---

## Known Gaps

* No refresh tokens
* No email verification
* No profile editing
* No poem deletion
* No pagination
* No automated testing
* No deployment

Accepted for MVP stage.

---

# 2026-06 — Documentation Sprint (v0.2.1)

## Documentation Created

* README.md
* Backend README
* Frontend README
* ARCHITECTURE.md
* API_CONTRACT.md
* ROADMAP.md
* DECISIONS.md
* PROGRESS.md
* VISION.md
* CONTRIBUTING.md
* FOUNDER_HANDOVER.md

---

## Project Governance

Established:

* Development standards
* Handover procedures
* Roadmap ownership
* Architecture documentation
* Product vision documentation

---

## Outcome

Project became self-documenting and maintainable by future developers.

---

# 2026-06 — Local Verification Sprint

## Full User Journey Verified

Successfully tested:

```text
Register
↓
Login
↓
Create Poem
↓
View Feed
↓
Read Poem
```

Status:

PASS

---

## CORS Issue Identified

### Problem

Flutter Web runs on dynamic localhost ports.

Backend only allowed:

```text
localhost:3000
localhost:5000
```

### Resolution

Development mode now automatically allows localhost origins.

Production remains controlled via:

```env
CORS_ORIGIN
```

### Outcome

Local development workflow stabilized.

---

# 2026-06 — Seed Content Sprint (v0.2.2)

## Initial Dataset Expanded

Previous:

```text
5 Accounts
15 Poems
```

Current:

```text
10 Accounts
30 Poems
```

---

## Writer Personas Added

* raghav_writes
* midnight_writer
* sara_writes
* arjun_kavya
* zara_lafz
* aarav_thinks
* meera_writes
* kabir_outdoors
* ananya_heals
* rizwan_recalls

---

## Coverage

Languages:

* Hindi
* English

Emotions:

* Love
* Longing
* Hope
* Solitude
* Gratitude

---

## Seed Automation

Created:

```text
scripts/cleanup-and-reseed.ts
```

Capabilities:

* Reset seed accounts
* Reset poems
* Recreate dataset
* Randomize feed order
* Create realistic timestamps

---

## Outcome

Development environment became repeatable and demonstration-ready.

---

# 2026-06 — Pagination Sprint (v0.2.2)

## Problem

Feed was limited and could not scale beyond initial content.

Only a portion of poems were visible.

---

## Solution

Implemented cursor-based pagination.

API:

```text
GET /api/v1/poems?cursor=&limit=
```

---

## Frontend Changes

Introduced FeedNotifier.

State managed:

```text
poems
isLoading
isLoadingMore
hasMore
nextCursor
error
```

---

## Infinite Scroll

Implemented automatic loading at approximately 85% scroll position.

Added:

```text
Pull To Refresh
End Of Feed Indicator
```

---

## Outcome

Feed now scales naturally with content growth.

---

# Current Project State

## Version

```text
v0.2.2
```

---

## Completed

```text
Authentication
Poem Publishing
Poem Reading
Session Persistence
Pagination
Infinite Scroll
Seed Content
Documentation
Founder Handover
Local Verification
```

---

## Pending

```text
Railway Deployment
Vercel Deployment
Staging Verification
Automated Testing
```

---

# Next Milestone — v0.3.0

## Deployment Sprint

### Backend

* Deploy to Railway
* Configure environment variables
* Verify database connectivity
* Verify health endpoint

### Frontend

* Deploy Flutter Web to Vercel
* Configure API_BASE_URL
* Verify routing

### Validation

Complete full user journey on staging.

---

# Future Milestones

## v0.4.0 — Testing Sprint

* API tests
* Repository tests
* Widget tests
* Integration tests

---

## v0.5.0 — Journals

Planned:

* Create journal entry
* Edit journal entry
* Archive journal entry
* Search journal entries

Private by default.

---

## Future Phases

* Personal Archive
* Letters After Midnight
* Time Capsules
* Community Circles
* Audio Poetry

---

# Engineering Notes

## High Priority

* Refresh tokens
* Email verification
* Production deployment

## Medium Priority

* Profile editing
* Poem editing
* Poem deletion

## Low Priority

* Redis rate limiting
* Token blacklist
* Advanced moderation tooling

---

# Current Status

```text
MVP Complete
Documentation Complete
Locally Verified
Seeded
Paginated
Deployment Pending
```

Syaahi is currently awaiting deployment to a public staging environment.
