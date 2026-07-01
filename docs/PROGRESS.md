# 🪶 Syaahi — Progress Log

This document serves as the engineering diary for Syaahi.

It records significant milestones, engineering decisions, implementation progress, architectural evolution, and future direction.

Its purpose is to help every future contributor understand:

- What was built
- Why it was built
- What changed
- What remains
- Where the product is heading

---

# 2026-06 — Foundation (v0.1.0)

## Backend

### Infrastructure

- Initialised Node.js + Express.js + TypeScript project
- Configured Prisma ORM
- Connected PostgreSQL via Supabase
- Implemented Zod environment validation
- Established feature-based architecture
- Added global error handling
- Added async request handling utilities

### Middleware

Implemented:

- Helmet
- CORS
- Morgan
- Environment validation
- Health endpoint

### Decisions

- Feature-based architecture
- Prisma as ORM
- PostgreSQL via Supabase
- Zod for validation

### Outcome

A scalable backend foundation ready for feature development.

---

# 2026-06 — MVP Sprint (v0.2.0)

## Backend

### Authentication

Implemented:

- User registration
- Login
- JWT authentication
- Session recovery
- Logout
- Password hashing with bcrypt

### Poems

Implemented:

- Publish poem
- Read poem
- Public feed
- Author information

### Users

Implemented:

- Public profile endpoint

### Security

Added:

- Global rate limiting
- Authentication rate limiting
- Request validation

---

## Flutter Application

### Foundation

- Flutter project
- Riverpod
- Dio
- go_router
- flutter_secure_storage

### Authentication

Implemented:

- Welcome screen
- Login
- Signup
- Session persistence

### Poems

Implemented:

- Feed
- Reader
- Writer

### Architecture

Adopted:

- Repository Pattern
- Feature-based architecture
- Separation of UI and business logic

### Outcome

The first complete user journey became operational.

```text
Register
      ↓
Login
      ↓
Create Poem
      ↓
Browse Feed
      ↓
Read Poem
```

---

# 2026-06 — Documentation Sprint (v0.2.1)

## Documentation

Created:

- README.md
- Backend README
- App README
- ARCHITECTURE.md
- API_CONTRACT.md
- ROADMAP.md
- DECISIONS.md
- PROGRESS.md
- VISION.md
- CONTRIBUTING.md
- FOUNDER_HANDOVER.md
- SEED_CONTENT.md

---

## Governance

Established:

- Engineering standards
- Contributor guidelines
- Documentation standards
- Architecture documentation
- Founder continuity documentation

### Outcome

The project became maintainable, transferable, and contributor-friendly.

---

# 2026-06 — Local Verification Sprint

## End-to-End Verification

Successfully validated:

```text
Register
      ↓
Login
      ↓
Session Recovery
      ↓
Create Poem
      ↓
Browse Feed
      ↓
Read Poem
      ↓
Logout
```

Result:

```text
PASS
```

---

## Development Improvements

### CORS

Problem:

Flutter Web uses dynamic localhost ports.

Solution:

Development mode now automatically permits localhost origins.

Production continues to use:

```env
CORS_ORIGIN
```

### Outcome

Local development became significantly smoother.

---

# 2026-06 — Feed & Seed Sprint (v0.2.2)

## Seed Content

Expanded dataset.

Previous:

```text
5 Writers
15 Poems
```

Current:

```text
10 Writers
30 Poems
```

Writer personas:

- raghav_writes
- midnight_writer
- sara_writes
- arjun_kavya
- zara_lafz
- aarav_thinks
- meera_writes
- kabir_outdoors
- ananya_heals
- rizwan_recalls

Coverage:

- Multiple languages
- Multiple themes
- Multiple emotions

---

## Seed Automation

Implemented:

```text
scripts/cleanup-and-reseed.ts
```

Capabilities:

- Delete existing seed data
- Recreate writers
- Recreate poems
- Distribute authors naturally
- Generate realistic timestamps

---

## Feed Improvements

Implemented:

- Cursor pagination
- Infinite scrolling
- Pull-to-refresh
- End-of-feed indicator

Feed State:

```text
poems
isLoading
isLoadingMore
hasMore
nextCursor
error
```

### Outcome

The platform became scalable, demo-ready, and easier to develop.

---

# 2026-07 — Internal Beta Sprint (v0.3.0-beta)

The focus shifted from feature completion to improving the overall reading experience.

Rather than introducing engagement mechanics, new capabilities were designed around emotional preservation.

---

## Syaahi Flow

Designed and implemented the **Syaahi Flow** literary sequencing engine.

Objectives:

- Preserve chronological freshness
- Distribute different writers naturally
- Avoid consecutive poems by the same author whenever possible
- Never use engagement metrics
- Produce deterministic ordering

Result:

The feed now feels closer to reading a curated anthology than scrolling a social platform.

---

## Feed Filters

Implemented support for filtering by:

- Language
- Emotion
- Theme

Filters integrate seamlessly with:

- Cursor pagination
- Infinite scrolling
- Syaahi Flow

---

## Heart System

Implemented **Commit to Heart**.

Characteristics:

- Private
- No notifications
- No public counts
- No influence on feed ranking

Purpose:

Allow readers to preserve poems that resonated personally.

---

## Meaningful Reactions

Traditional Like buttons were intentionally excluded.

Implemented expressive reactions:

```text
FELT_THIS
STAYED_WITH_ME
BEAUTIFULLY_WRITTEN
MADE_ME_THINK
COMFORTED_ME
INSPIRED_ME
```

Purpose:

Encourage emotional acknowledgement rather than popularity.

---

## User Profiles

Expanded profile capabilities.

Profiles now surface:

- Published writing
- Languages used
- Themes explored
- Writing summary

Without introducing followers or audience metrics.

---

## Documentation Synchronization

Updated:

- README
- Backend README
- App README
- ARCHITECTURE.md
- API_CONTRACT.md
- ROADMAP.md
- DECISIONS.md
- PROGRESS.md
- VISION.md
- CONTRIBUTING.md
- SEED_CONTENT.md
- FOUNDER_HANDOVER.md

Documentation now accurately reflects the implementation.

---

## Engineering Decisions

New architectural decisions introduced:

- Syaahi Flow
- Commit to Heart
- Meaningful Reactions
- Private emotional interactions
- Continued feature-first architecture

---

## Outcome

Syaahi evolved beyond a functional MVP into an internally validated beta focused on meaningful reading experiences.

---

# Current Project State

## Version

```text
v0.3.0-beta
```

---

## Completed

```text
Authentication

Session Recovery

Poem Publishing

Poem Reading

User Profiles

Cursor Pagination

Infinite Scroll

Feed Filters

Syaahi Flow

Commit to Heart

Meaningful Reactions

Seed Content System

Documentation Suite

Founder Handover

Internal Beta Preparation
```

---

## Current Technical Debt

Accepted and intentionally deferred:

```text
Refresh Tokens

Email Verification

Token Blacklist

Automated Test Suite

Redis-backed Rate Limiting

Production Monitoring

Public Deployment
```

---

# Next Milestone

## Internal Beta Deployment

### Infrastructure

- Deploy backend
- Configure production environment
- Configure production database
- Production CORS
- Health monitoring

### Distribution

- Generate Android APK
- Internal beta distribution
- Invite first writers
- Gather qualitative feedback

### Validation

- Verify complete user journey
- Validate Syaahi Flow
- Validate Heart system
- Validate Meaningful Reactions
- Performance testing

### Success Criteria

- Stable deployment
- Successful internal beta
- Actionable user feedback
- Production-ready foundation

---

# Future Milestones

## v0.4.0 — Reliability & Testing

Backend:

- API tests
- Repository tests
- Authentication tests
- Integration tests

Frontend:

- Widget tests
- Riverpod tests
- End-to-end tests

Infrastructure:

- Monitoring
- Logging
- Error reporting

---

## v0.5.0 — Journals

Planned:

- Create journal
- Edit journal
- Archive journal
- Search journals

Private by default.

---

## Future Releases

Planned evolution:

- Personal Archive
- Letters After Midnight
- Time Capsules
- Community Circles
- Audio Poetry

---

# Engineering Priorities

## High

- Production deployment
- Refresh tokens
- Email verification
- Automated testing

## Medium

- Production monitoring
- Performance optimisation
- Moderation tooling

## Low

- Redis-backed rate limiting
- Token blacklist
- Infrastructure scaling

---

# Current Status

```text
Internal Beta

Feature Complete

Documentation Complete

Locally Verified

Deployment Ready

Awaiting Internal User Testing
```

Syaahi has progressed from a functional MVP into a polished internal beta focused on meaningful writing, reading, and emotional preservation.

Every major architectural and product decision continues to support one guiding principle:

> **Help people express, preserve, and revisit their emotions.**