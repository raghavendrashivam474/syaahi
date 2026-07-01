# 🪶 Syaahi

# Founder Handover & Continuity Document

**Version:** v0.3.0-beta

**Prepared By:** Raghavendra Singh

**Purpose:** Long-Term Project Continuity & Product Stewardship

---

# 1. Executive Summary

Syaahi is a platform for poetry, journals, letters, memory preservation, and emotional reflection.

It exists because modern digital platforms optimize for attention.

Syaahi optimizes for meaning.

The objective has never been to maximize engagement.

The objective is to help people:

- Express emotions
- Preserve memories
- Revisit personal history
- Build a lifelong archive of their own words

Every significant product decision should strengthen one or more of these goals.

If future development moves away from them, the project has likely drifted from its intended purpose.

---

# 2. Why Syaahi Exists

Most digital platforms encourage people to perform.

Visibility becomes success.

Engagement becomes validation.

Algorithms determine what deserves attention.

Writing slowly shifts from expression to performance.

People write:

- Poems
- Journals
- Letters
- Reflections

Yet these writings become scattered across:

- Notebooks
- Notes applications
- Chat histories
- Social media
- Forgotten folders

Very few platforms exist to preserve these moments.

Syaahi exists to become:

> **A personal archive of human expression.**

---

# 3. Product Philosophy

Every feature should satisfy at least one of the following:

1. Help people express emotions.
2. Help people preserve memories.
3. Help people revisit their past.

If a feature satisfies none of these goals, it should probably not exist.

Technology serves the philosophy.

The philosophy never serves the technology.

---

# 4. What Syaahi Is Not

Syaahi is intentionally **not**:

- Instagram
- X (Twitter)
- LinkedIn
- Reddit
- Medium
- A creator economy platform

The following are deliberately excluded:

- Followers
- Public Like counts
- Trending feeds
- Viral mechanics
- Endless engagement loops
- Audience building
- Influencer mechanics
- Engagement farming

These exclusions are product decisions, not missing features.

---

# 5. Current Product State

## Version

```text
v0.3.0-beta
```

## Status

```text
Internal Beta

Feature Complete

Documentation Complete

Locally Verified

Deployment Ready

Awaiting Internal User Testing
```

---

## Current User Journey

```text
Register
      ↓
Login
      ↓
Session Recovery
      ↓
Browse Feed
      ↓
Filter Feed
      ↓
Read Poem
      ↓
Meaningful Reactions
      ↓
Commit to Heart
      ↓
Write Poem
      ↓
Visit Profiles
      ↓
Logout
```

---

## Features Available

### Authentication

- Registration
- Login
- JWT Authentication
- Session Recovery
- Logout

### Feed

- Cursor Pagination
- Infinite Scroll
- Pull-to-Refresh
- Feed Filters
- Syaahi Flow sequencing

### Poems

- Publish
- Read
- Author Profiles

### Emotional Features

- Meaningful Reactions
- Commit to Heart

### Platform

- User Profiles
- Seed Content System
- Documentation Suite

---

# 6. Technical Architecture

## Frontend

Flutter

Architecture:

```text
Screen
      ↓
Riverpod
      ↓
Repository
      ↓
Dio
```

---

## Backend

```text
Express
      ↓
Controllers
      ↓
Prisma
      ↓
PostgreSQL
```

---

## Database

```text
Supabase PostgreSQL
```

---

## Complete Data Flow

```text
User
      ↓
Flutter UI
      ↓
Riverpod
      ↓
Repository
      ↓
Dio
      ↓
REST API
      ↓
Controller
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

# 7. Major Architectural Decisions

## ADR-001

Feature-Based Architecture

Reason:

Independent, maintainable modules.

---

## ADR-002

Repository Pattern

Reason:

UI never communicates directly with APIs.

---

## ADR-003

JWT Authentication

Reason:

Stateless authentication compatible with mobile and web.

---

## ADR-004

Flutter

Reason:

Single codebase for Android, iOS, and Web.

---

## ADR-005

Prisma + PostgreSQL

Reason:

Type-safe development while retaining SQL ownership.

---

## ADR-006

Cursor Pagination

Reason:

Infinite scrolling without offset performance problems.

---

## ADR-007

Seed Content System

Reason:

Repeatable demonstrations and development environments.

---

## ADR-008

Syaahi Flow

Reason:

Feeds should encourage reading, not scrolling.

Ordering priorities:

- Preserve freshness
- Balance authors
- Never use popularity
- Avoid consecutive poems by the same writer whenever possible

---

## ADR-009

Meaningful Reactions

Reason:

Replace Likes with emotional acknowledgement.

---

## ADR-010

Commit to Heart

Reason:

Bookmarks are private emotional keepsakes rather than engagement metrics.

---

# 8. Repository Structure

## Backend

```text
src/
├── config/
├── middleware/
├── modules/
│   ├── auth/
│   ├── poems/
│   ├── users/
│   ├── hearts/
│   └── reactions/
└── utils/
```

---

## Frontend

```text
lib/
├── core/
├── features/
│   ├── auth/
│   ├── poems/
│   ├── hearts/
│   ├── reactions/
│   └── profiles/
└── shared/
```

Future features should continue following the same modular structure.

---

# 9. Current Technical Debt

Accepted limitations:

- Refresh tokens
- Email verification
- Automated testing
- Production deployment
- Production monitoring
- Redis-backed rate limiting
- Token blacklist

These are intentional trade-offs while validating the product.

---

# 10. Product Roadmap

## v0.3.x

Internal Beta

Objectives:

- Deploy backend
- Generate Android APK
- Invite first writers
- Collect qualitative feedback

---

## v0.4.0

Reliability

Objectives:

- Automated testing
- Monitoring
- Logging
- Production hardening

---

## v0.5.0

Journals

Features:

- Create
- Edit
- Archive
- Search

Private by default.

---

## v0.6.0

Personal Archive

Features:

- Timeline
- Memory View
- Emotional History
- On This Day

---

## v0.7.0

Letters After Midnight

Anonymous emotional conversations.

Requires moderation before release.

---

## v0.8.0

Time Capsules

Messages delivered to one's future self.

Locked after sealing.

---

## v0.9.0

Community Circles

Small writing communities.

No follower mechanics.

---

## v1.0.0

First Stable Public Release

Requirements:

- Stable deployment
- Automated testing
- Journals
- Personal Archive
- Moderation
- Monitoring

---

# 11. Features Requiring Founder Review

The following require explicit approval before implementation:

- AI-generated poetry
- AI co-writing
- Creator monetization
- Paid subscriptions
- Advertisements
- Blockchain
- NFTs
- Trending feeds
- Algorithmic ranking
- Followers
- Public Like counts

These fundamentally change the product philosophy.

---

# 12. Deployment Information

## Backend

Preferred:

```text
Railway
```

Alternatives:

- Render
- Fly.io
- Coolify
- DigitalOcean

---

## Frontend

Internal beta:

```text
Android APK
```

Future:

```text
Flutter Web
```

---

## Database

```text
Supabase PostgreSQL
```

---

## Backend Environment Variables

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

---

## Frontend

```text
API_BASE_URL
```

---

# 13. Definition of Done

A feature is complete only when:

```text
✓ Implemented

✓ Input Validated

✓ Error Handling Added

✓ Manually Verified

✓ Documentation Updated

✓ Proper Commit Created

✓ Works On Deployment Target
```

Code that works only on a local machine is not complete.

---

# 14. Development Rules

1. Preserve simplicity.
2. Prefer readability over cleverness.
3. Avoid premature optimization.
4. Document significant decisions.
5. Commit frequently.
6. Keep modules independent.
7. Preserve product philosophy.
8. Never add features simply because competitors have them.
9. Build only what strengthens emotional expression.

---

# 15. Success Metrics

## Short Term

- Successful internal beta
- First 20–50 genuine writers
- Meaningful qualitative feedback

---

## Medium Term

- Active journals
- Returning readers
- Growing personal archives

---

## Long Term

The most important metric is not usage.

It is return.

People returning months or years later to rediscover their own words.

That is success.

---

# 16. If The Founder Is Unavailable

When difficult decisions arise:

Choose the option that makes Syaahi feel more like:

- A journal
- A quiet library
- A collection of letters
- A memory archive

And less like:

- A social network
- An attention platform
- A creator economy

When uncertain:

> **Choose meaning over engagement.**

---

# 17. Final Founder Note

Technology will evolve.

Frameworks will change.

Databases will be replaced.

The codebase can always be rewritten.

The difficult part is preserving intent.

Protect the quietness.

Protect the honesty.

Protect the simplicity.

Protect the experience of someone opening Syaahi years later and finding a forgotten piece of themselves waiting there.

If that experience survives,

Syaahi has succeeded.

---

**— Raghavendra Singh**

Founder, Syaahi

> **"Where emotions become words."**