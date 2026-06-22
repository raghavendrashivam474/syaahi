# 🪶 Syaahi

# Founder Handover & Continuity Document

### Version: v0.2.2

### Prepared By: Raghavendra Singh

### Purpose: Long-Term Project Continuity

---

# 1. Executive Summary

Syaahi is a platform for emotional expression, memory preservation, poetry, journals, letters, and personal reflection.

The project exists because modern digital platforms optimize for attention.

Syaahi optimizes for meaning.

The objective is not to maximize engagement.

The objective is to help users:

* Express emotions
* Preserve memories
* Revisit personal history
* Create lasting written artifacts

If future development ever drifts away from these goals, it is likely moving away from the intended vision.

---

# 2. Why Syaahi Exists

The founder observed:

* Social media rewards visibility
* Most platforms optimize for reactions
* Few platforms help users preserve emotional experiences

People write:

* Poems
* Letters
* Journals
* Reflections

But those writings become scattered across notebooks, chats, notes applications, and social feeds.

Syaahi exists to become:

> A personal archive of human expression.

---

# 3. Product Philosophy

Every feature should satisfy at least one of the following:

1. Helps users express emotions
2. Helps users preserve memories
3. Helps users revisit past experiences

If a feature satisfies none of these, it should be questioned.

---

# 4. What Syaahi Is Not

Syaahi is NOT:

* Instagram
* Twitter / X
* LinkedIn
* Medium
* Reddit
* A creator economy platform

The following are intentionally excluded:

* Follower counts
* Influencer mechanics
* Algorithmic feeds
* Trending pages
* Engagement farming
* Virality systems

These are exclusions by design.

---

# 5. Current Product State

### Version

v0.2.2

### Status

MVP Complete

Documentation Complete

Locally Verified

Deployment Pending

### Current User Journey

```text
Register
↓
Login
↓
Session Recovery
↓
Browse Feed
↓
Create Poem
↓
Read Poem
↓
Logout
```

### Features Available Today

* Registration
* Login
* JWT Authentication
* Session Persistence
* Poem Publishing
* Poem Reading
* User Profiles
* Cursor Pagination
* Infinite Scroll
* Pull To Refresh
* Seed Content System
* Documentation Suite

---

# 6. Technical Architecture

## Frontend

Flutter Web

Architecture:

```text
UI
↓
Riverpod
↓
Repository
↓
Dio
```

## Backend

```text
Node.js
↓
Express
↓
Prisma
```

## Database

```text
Supabase PostgreSQL
```

## Data Flow

```text
User Action
↓
Repository
↓
API
↓
Prisma
↓
Database
↓
Response
↓
State
↓
UI
```

---

# 7. Architectural Decisions

### ADR-001

Feature-Based Architecture

Reason:

Scalable and maintainable code organization.

---

### ADR-002

Repository Pattern

Reason:

UI should never directly call APIs.

---

### ADR-003

JWT Authentication

Reason:

Stateless and mobile friendly.

---

### ADR-004

Flutter Web

Reason:

Single codebase for Web and future Mobile support.

---

### ADR-005

Supabase + Prisma

Reason:

Rapid development while retaining PostgreSQL ownership.

---

### ADR-011

Cursor Pagination

Reason:

Feed scalability and infinite scroll support.

---

### ADR-012

Seed Content System

Reason:

Repeatable development and demonstration environment.

---

# 8. Current Folder Structure

## Backend

```text
src/
├── config/
├── middleware/
├── modules/
│   ├── auth/
│   ├── poems/
│   └── users/
└── utils/
```

## Frontend

```text
lib/
├── core/
├── features/
│   ├── auth/
│   └── poems/
└── shared/
```

Future features should follow the same structure.

---

# 9. Known Technical Debt

Accepted limitations:

* No refresh tokens
* No email verification
* No profile editing
* No poem editing
* No poem deletion
* No automated tests
* No token blacklist
* In-memory rate limiting

These are accepted trade-offs for the current stage.

---

# 10. Product Roadmap

## v0.3.0

Deployment Sprint

Goal:

Public staging environment.

---

## v0.4.0

Testing Sprint

Goal:

Reliability and regression prevention.

---

## v0.5.0

Journals

Goal:

Private emotional reflection.

Features:

* Create
* Edit
* Archive
* Search

Private by default.

---

## v0.6.0

Personal Archive

Goal:

Memory preservation.

Features:

* Timeline
* Memory View
* Writing History
* On This Day

---

## v0.7.0

Letters After Midnight

Goal:

Anonymous emotional communication.

Important:

Requires moderation architecture before implementation.

---

## v0.8.0

Time Capsules

Goal:

Long-term emotional preservation.

Users write messages to their future selves.

---

## v0.9.0

Community Circles

Goal:

Belonging through shared writing.

Examples:

* Midnight Thoughts
* Healing
* Monsoon Poetry
* First Love

No follower mechanics.

---

## v1.0.0

First Public Release

Requirements:

* Stable deployment
* Testing coverage
* Journals
* Personal Archive
* Core moderation tooling

---

# 11. Features Requiring Founder Review

Do not implement without explicit review:

* AI-generated poetry
* AI co-writing
* Creator monetization
* NFT integration
* Blockchain concepts
* Algorithmic ranking
* Paid subscriptions
* Advertising systems
* Trending feeds

These can fundamentally alter product direction.

---

# 12. Deployment Information

## Backend

Railway

## Frontend

Vercel

## Database

Supabase

### Backend Environment Variables

```text
DATABASE_URL
DIRECT_URL
JWT_SECRET
JWT_EXPIRES_IN
CORS_ORIGIN
SUPABASE_URL
SUPABASE_ANON_KEY
SUPABASE_SERVICE_ROLE_KEY
```

### Frontend Environment Variables

```text
API_BASE_URL
```

---

# 13. Definition of Done

A feature is complete only if:

```text
✓ Implemented
✓ Validated
✓ Error handling added
✓ Documented
✓ Reviewed
✓ Verified manually
✓ Works on staging
```

Local-only functionality is not complete.

---

# 14. Development Rules

1. Keep architecture simple
2. Prefer maintainability over cleverness
3. Avoid premature optimization
4. Document decisions
5. Commit frequently
6. Preserve product philosophy
7. Do not build features because competitors have them
8. Build features only if they strengthen the mission

---

# 15. Success Metrics

## Short Term

* Public staging deployment
* 10 active users
* 100 poems

## Medium Term

* 100 users
* 1,000 poems
* Journal adoption

## Long Term

* Meaningful personal archives
* Returning users revisiting old writing
* Time Capsule engagement
* Letters After Midnight participation

---

# 16. If The Founder Is Unavailable

If future contributors must make decisions without founder input:

1. Preserve emotional depth over engagement
2. Preserve simplicity over feature count
3. Prefer reflection over consumption
4. Prefer meaning over metrics
5. Prefer permanence over novelty

When uncertain:

> Choose the option that makes Syaahi feel more like a journal and less like a social network.

---

# 17. Final Founder Note

The value of Syaahi is not the technology.

Any competent engineer can rebuild the codebase.

The difficult part is preserving the intent.

The project should always feel like:

* A quiet library
* A journal
* A collection of letters
* A personal archive

If a future version begins to feel like a social network, something important has been lost.

Protect the experience.

Protect the simplicity.

Protect the reason it exists.

---

**— Raghavendra Singh**
Founder, Syaahi

*"Where emotions become words."*
