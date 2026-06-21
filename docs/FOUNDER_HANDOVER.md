# Syaahi

## Founder Handover & Continuity Document

### Version: v0.2.1

### Prepared By: Raghavendra Singh

### Purpose: Long-Term Project Continuity

---

# 1. Executive Summary

Syaahi is a platform for emotional expression, memory preservation, poetry, journals, letters, and personal reflection.

The project exists because modern social platforms optimize for attention.

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

* Social media rewards visibility.
* Most platforms optimize for reactions.
* Few platforms help users preserve emotional experiences.

People write:

* Poems
* Letters
* Journals
* Reflections

But those writings become scattered across notebooks, chats, notes apps, and social feeds.

Syaahi exists to become:

> A personal archive of human expression.

---

# 3. Product Philosophy

Every feature should satisfy at least one of:

1. Helps users express emotions.
2. Helps users preserve memories.
3. Helps users revisit past experiences.

If a feature does not satisfy any of these criteria, it should be questioned.

---

# 4. What Syaahi Is Not

Syaahi is NOT:

* Instagram
* Twitter/X
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

Version:

v0.2.1

Status:

Locally verified MVP.

Users can:

* Register
* Login
* Persist session
* Publish poem
* Browse poems
* Read poems

The first complete user journey has been validated.

---

# 6. Technical Architecture

Frontend

Flutter Web

Architecture:

UI
↓
Riverpod
↓
Repository
↓
Dio

Backend

Node.js
↓
Express
↓
Prisma

Database

Supabase PostgreSQL

Data Flow:

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

---

# 7. Architectural Decisions

## ADR-001

Feature-Based Architecture

Reason:

Scalability and maintainability.

---

## ADR-002

Repository Pattern

Reason:

UI should never directly call APIs.

---

## ADR-003

JWT Authentication

Reason:

Mobile-friendly and stateless.

---

## ADR-004

Flutter

Reason:

Single codebase for Web and Mobile.

---

## ADR-005

Supabase + Prisma

Reason:

Rapid development while maintaining SQL ownership.

---

# 8. Current Folder Structure

Backend

src/

config/

middleware/

modules/

auth/

poems/

users/

utils/

Frontend

lib/

core/

features/

auth/

poems/

shared/

Future features should follow the same structure.

---

# 9. Known Technical Debt

Current accepted limitations:

* No refresh tokens
* No email verification
* No pagination
* No profile editing
* No automated tests
* Staging CORS relaxation
* No token blacklist

These are known and acceptable at current stage.

---

# 10. Future Roadmap

## Phase 1

Deployment

Goal:

Public staging environment.

---

## Phase 2

Testing

Goal:

Reliability.

---

## Phase 3

Journals

Goal:

Daily user retention.

Features:

* Create
* Edit
* Archive
* Search

Private by default.

---

## Phase 4

Personal Archive

Goal:

Memory preservation.

Features:

* Timeline
* Memory view
* Writing history

---

## Phase 5

Letters After Midnight

Goal:

Anonymous emotional communication.

Important:

Requires moderation strategy before implementation.

---

## Phase 6

Time Capsules

Goal:

Long-term emotional retention.

Users can write messages to their future selves.

---

## Phase 7

Community Circles

Goal:

Belonging through shared themes.

Examples:

* Midnight Thoughts
* Healing
* Monsoon Poetry
* First Love

No follower mechanics.

---

## Phase 8

Audio Poetry

Goal:

Alternative content format.

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

These can fundamentally alter product direction.

---

# 12. Deployment Information

Backend:

Railway

Frontend:

Vercel

Database:

Supabase

Required Environment Variables:

Backend:

DATABASE_URL
DIRECT_URL
JWT_SECRET
JWT_EXPIRES_IN
CORS_ORIGIN
SUPABASE_URL
SUPABASE_ANON_KEY
SUPABASE_SERVICE_ROLE_KEY

Frontend:

API_BASE_URL

---

# 13. Definition of Done

A feature is complete only if:

✓ Implemented

✓ Validated

✓ Error handling added

✓ Documented

✓ Reviewed

✓ Works on staging

Local-only functionality is not considered complete.

---

# 14. Development Rules

1. Keep architecture simple.

2. Prefer maintainability over cleverness.

3. Avoid premature optimization.

4. Document decisions.

5. Commit frequently.

6. Preserve product philosophy.

7. Do not build features because competitors have them.

8. Build features only if they strengthen the mission.

---

# 15. Success Metrics

Short Term

* Public staging deployment
* 10 active users
* 100 poems

Medium Term

* 100 users
* 1,000 poems
* Journal adoption

Long Term

* Meaningful personal archives
* Returning users revisiting old writing
* Time Capsule engagement

---

# 16. Final Founder Note

The value of Syaahi is not the technology.

Any competent engineer can rebuild the codebase.

The difficult part is preserving the intent.

The project should always feel like a quiet library, a journal, or a box of old letters.

If a future version begins to feel like a social network, something important has been lost.

Protect the experience.

Protect the simplicity.

Protect the reason it exists.

— Raghavendra Singh
Founder, Syaahi

"Where emotions become words."
