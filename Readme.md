# 🪶 Syaahi

> **Where emotions become words.**

Syaahi is a platform for poetry, journals, letters, memory preservation, and personal reflection.

It is **not** a social media platform.

Instead of optimizing for attention, Syaahi is designed to help people express emotions, preserve memories, and rediscover their own words over time.

---

# What is Syaahi?

Most digital platforms reward visibility.

Syaahi rewards authenticity.

Write a poem today.

Journal tomorrow.

Send a letter when words feel too heavy to speak.

Commit a poem to your heart.

Seal a time capsule for your future self.

Return years later and rediscover the person you once were.

The goal is not engagement.

The goal is emotional preservation.

---

# Current Status

**Version:** v0.3.0-beta

**Status:** Internal Beta

The platform has completed its MVP and Writer Experience milestones.

Core infrastructure, documentation, and user experience foundations are in place.

---

# Features

## Authentication

| Feature | Status |
|---------|--------|
| User Registration | ✅ |
| Login | ✅ |
| Session Persistence | ✅ |
| Logout | ✅ |
| JWT Authentication | ✅ |

---

## Poetry

| Feature | Status |
|---------|--------|
| Publish Poem | ✅ |
| Read Poem | ✅ |
| Infinite Feed | ✅ |
| Cursor Pagination | ✅ |
| Pull to Refresh | ✅ |
| Feed Filters | ✅ |
| Syaahi Flow Literary Sequencing | ✅ |

---

## Meaningful Interactions

| Feature | Status |
|---------|--------|
| Commit to Heart | ✅ |
| My Heart Collection | ✅ |
| Emotional Reactions | ✅ |
| Private Heart System | ✅ |

Supported emotional acknowledgements:

- I Felt This
- This Stayed With Me
- Beautifully Written
- Made Me Think
- Comforted Me
- Inspired Me

---

## Profiles

| Feature | Status |
|---------|--------|
| Writer Profile | ✅ |
| Languages Used | ✅ |
| Themes Used | ✅ |
| Public Poem Listing | ✅ |

No followers.

No following.

No popularity metrics.

---

## Platform

| Feature | Status |
|---------|--------|
| Seed Content System | ✅ |
| Documentation Suite | ✅ |
| Backend Deployment Ready | ✅ |
| Android APK (Internal Beta) | ✅ |

---

# Product Philosophy

Every feature should answer one question:

> **Does this help people express, preserve, or revisit emotions?**

If the answer is no, it probably does not belong in Syaahi.

---

# Roadmap

| Phase | Status |
|--------|--------|
| Foundation | ✅ Complete |
| MVP | ✅ Complete |
| Documentation Sprint | ✅ Complete |
| Verification Sprint | ✅ Complete |
| Writer Experience Sprint | ✅ Complete |
| Internal Beta | ✅ Complete |
| Testing & Feedback | ⏳ Next |
| Journals | ⏳ Planned |
| Personal Archive | ⏳ Planned |
| Letters After Midnight | ⏳ Planned |
| Time Capsules | ⏳ Planned |
| Community Circles | ⏳ Planned |
| Audio Poetry | ⏳ Planned |

---

# Repository Structure

```text
syaahi/
├── syaahi-backend/
├── syaahi-app/
├── docs/
│   ├── ARCHITECTURE.md
│   ├── API_CONTRACT.md
│   ├── ROADMAP.md
│   ├── DECISIONS.md
│   ├── PROGRESS.md
│   ├── VISION.md
│   ├── CONTRIBUTING.md
│   ├── SEED_CONTENT.md
│   ├── CHANGELOG.md
│   └── FOUNDER_HANDOVER.md
├── README.md
└── LICENSE
```

---

# Technology Stack

## Backend

| Layer | Technology |
|------|------------|
| Runtime | Node.js |
| Framework | Express.js |
| Language | TypeScript |
| ORM | Prisma |
| Database | PostgreSQL (Supabase) |
| Authentication | JWT |
| Validation | Zod |

---

## Frontend

| Layer | Technology |
|------|------------|
| Framework | Flutter |
| Language | Dart |
| State Management | Riverpod |
| Navigation | go_router |
| HTTP Client | Dio |
| Secure Storage | flutter_secure_storage |

---

# Architecture Overview

```text
Flutter
    │
    ▼
Riverpod
    │
    ▼
Repositories
    │
    ▼
Dio
    │
    ▼
Express API
    │
    ▼
Prisma ORM
    │
    ▼
PostgreSQL (Supabase)
```

Detailed documentation:

```text
docs/ARCHITECTURE.md
```

---

# Syaahi Flow

One of Syaahi's defining engineering components is the **Syaahi Flow Literary Sequencing Engine**.

Unlike traditional recommendation systems, Syaahi Flow does **not** rank poems using popularity, engagement, or reactions.

Instead, it focuses on creating a pleasant reading experience by:

- Preserving overall recency
- Avoiding consecutive poems from the same author whenever possible
- Maintaining the platform's natural distribution of writers and emotions
- Remaining deterministic and engagement-independent

Syaahi Flow is intentionally a **literary sequencing engine**, not a recommendation engine.

---

# Getting Started

## Backend

```bash
cd syaahi-backend

npm install

cp .env.example .env

# Configure environment variables

npm run prisma:generate

npm run dev
```

Runs at:

```text
http://localhost:4000
```

---

## Flutter App

```bash
cd syaahi-app

flutter pub get

flutter run
```

To build an Android release APK:

```bash
flutter build apk --release
```

---

# Seed Development Data

Populate the local database with realistic development content.

```bash
cd syaahi-backend

npx tsx scripts/cleanup-and-reseed.ts
```

Current development dataset:

```text
10 Writers
30 Poems
Multiple Languages
Multiple Emotions
Multiple Themes
```

---

# Documentation

| Document | Purpose |
|----------|---------|
| ARCHITECTURE.md | System architecture |
| API_CONTRACT.md | Backend API reference |
| ROADMAP.md | Product roadmap |
| DECISIONS.md | Architecture Decision Records |
| PROGRESS.md | Engineering history |
| VISION.md | Product philosophy |
| CONTRIBUTING.md | Contributor guide |
| SEED_CONTENT.md | Development dataset |
| CHANGELOG.md | Version history |
| FOUNDER_HANDOVER.md | Long-term project continuity |

---

# Current Development Focus

The next milestone focuses on **real-world validation** rather than additional features.

Objectives:

- Internal beta testing with writers
- UX refinement
- Stability improvements
- Bug fixing
- Feedback collection
- Test coverage

Feature development for Journals will begin after the internal beta feedback cycle is complete.

---

# Guiding Principle

Before writing code, ask:

> **Does this help people express, preserve, or revisit emotions?**

If the answer is no, rethink the feature.

---

# License

MIT License.

See `LICENSE` for details.

---

# Founder Note

Syaahi is not trying to become another social platform.

It is trying to become a place people return to years later.

The most meaningful feature is not what someone writes today.

It is the moment they reopen Syaahi years later, read their own words, and remember exactly who they were.

Build every feature with that future moment in mind.

---

**Built with midnight thoughts, coffee, and a love for words.**

**— Raghavendra Singh**

*"Where emotions become words."*