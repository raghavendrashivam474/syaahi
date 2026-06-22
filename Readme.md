# 🪶 Syaahi

> Where emotions become words.

Syaahi is a platform for poetry, journals, letters, memory preservation, and personal reflection.

It is not a social media platform.

It is a calm digital space where people can write, revisit memories, preserve emotions, and rediscover their own words over time.

---

# What is Syaahi?

Most digital platforms optimize for attention.

Syaahi optimizes for meaning.

Write a poem today.

Journal tomorrow.

Send a letter when words feel too heavy to speak.

Seal a time capsule for your future self.

Return years later and rediscover who you once were.

The goal is not engagement.

The goal is emotional preservation.

---

# Current Status

**Version:** v0.2.2

**Status:** MVP Complete, Documented, Seeded, Locally Verified

### Available Today

| Feature                | Status |
| ---------------------- | ------ |
| User Registration      | ✅      |
| Login & Authentication | ✅      |
| Session Persistence    | ✅      |
| Poem Publishing        | ✅      |
| Poem Feed              | ✅      |
| Poem Reader            | ✅      |
| User Profiles          | ✅      |
| Cursor Pagination      | ✅      |
| Infinite Scroll        | ✅      |
| Pull To Refresh        | ✅      |
| Seed Content System    | ✅      |
| Documentation Suite    | ✅      |

---

# Roadmap

| Phase                  | Status     |
| ---------------------- | ---------- |
| Foundation             | ✅ Complete |
| MVP                    | ✅ Complete |
| Documentation Sprint   | ✅ Complete |
| Verification Sprint    | ✅ Complete |
| Deployment Sprint      | ⏳ Next     |
| Testing Sprint         | ⏳ Planned  |
| Journals               | ⏳ Planned  |
| Personal Archive       | ⏳ Planned  |
| Letters After Midnight | ⏳ Planned  |
| Time Capsules          | ⏳ Planned  |

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
│   └── FOUNDER_HANDOVER.md
├── README.md
└── LICENSE
```

---

# Technology Stack

## Backend

| Layer          | Technology            |
| -------------- | --------------------- |
| Runtime        | Node.js               |
| Framework      | Express.js            |
| Language       | TypeScript            |
| ORM            | Prisma                |
| Database       | PostgreSQL (Supabase) |
| Authentication | JWT                   |
| Validation     | Zod                   |

---

## Frontend

| Layer            | Technology             |
| ---------------- | ---------------------- |
| Framework        | Flutter Web            |
| Language         | Dart                   |
| State Management | Riverpod               |
| Navigation       | go_router              |
| HTTP Client      | Dio                    |
| Secure Storage   | flutter_secure_storage |

---

# Architecture Overview

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

See:

```text
docs/ARCHITECTURE.md
```

for full system details.

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

## Frontend

```bash
cd syaahi-app

flutter pub get

flutter run -d chrome
```

---

## Seed Development Data

Create the complete development dataset:

```bash
cd syaahi-backend

npx tsx scripts/cleanup-and-reseed.ts
```

Current dataset:

```text
10 Accounts
30 Poems
Multiple Authors
Multiple Emotions
```

---

# Documentation

| File                | Purpose                |
| ------------------- | ---------------------- |
| ARCHITECTURE.md     | System design          |
| API_CONTRACT.md     | API reference          |
| ROADMAP.md          | Product roadmap        |
| DECISIONS.md        | Architecture decisions |
| PROGRESS.md         | Engineering history    |
| VISION.md           | Product philosophy     |
| CONTRIBUTING.md     | Contributor guide      |
| SEED_CONTENT.md     | Development dataset    |
| FOUNDER_HANDOVER.md | Long-term continuity   |

---

# Guiding Principle

Before building any feature, ask:

> Does this help people express, preserve, or revisit emotions?

If the answer is no, it probably does not belong in Syaahi.

---

# License

MIT License

See LICENSE for details.

---

# Founder Note

The most meaningful feature in Syaahi is not something users write today.

It is the moment years later when they return, read their own words, and remember exactly who they were.

---

**Built with midnight thoughts, coffee, and a love for words.**

**— Raghavendra Singh**
