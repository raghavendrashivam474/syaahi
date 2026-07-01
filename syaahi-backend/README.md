# 🪶 Syaahi Backend

Backend API for **Syaahi** — *Where emotions become words.*

Syaahi Backend powers authentication, poetry publishing, emotional interactions, writer profiles, and the platform's literary sequencing engine.

Built with **Node.js**, **Express**, **TypeScript**, **Prisma**, and **PostgreSQL (Supabase)**.

---

# Current Status

**Version:** v0.3.0-beta

**Status:** Internal Beta

The backend has completed the MVP and Writer Experience milestones and is ready for internal user testing.

---

# Verified User Journey

```text
Register
    ↓
Login
    ↓
Session Recovery
    ↓
Browse Feed
    ↓
Filter Poems
    ↓
Read Poem
    ↓
React Emotionally
    ↓
Commit to Heart
    ↓
View Writer Profile
    ↓
Logout
```

---

# Available Modules

| Module | Status |
|---------|--------|
| Health | ✅ |
| Authentication | ✅ |
| Users | ✅ |
| Poems | ✅ |
| Heart | ✅ |
| Reactions | ✅ |
| Cursor Pagination | ✅ |
| Feed Filters | ✅ |
| Syaahi Flow | ✅ |
| Seed Content System | ✅ |

---

# Technology Stack

| Layer | Technology |
|------|------------|
| Runtime | Node.js v20+ |
| Language | TypeScript |
| Framework | Express.js |
| ORM | Prisma |
| Database | PostgreSQL (Supabase) |
| Authentication | JWT + bcrypt |
| Validation | Zod |
| Security | Helmet, CORS, Rate Limiting |

---

# Architecture

```text
Flutter / Android
        │
        ▼
Express API
        │
Controllers
        │
Business Services
        │
Prisma ORM
        │
PostgreSQL (Supabase)
```

---

# Project Structure

```text
syaahi-backend/
├── prisma/
│   └── schema.prisma
│
├── scripts/
│   ├── cleanup-and-reseed.ts
│   └── verify-db.ts
│
├── src/
│   ├── config/
│   ├── middleware/
│   ├── modules/
│   │   ├── auth/
│   │   ├── poems/
│   │   ├── users/
│   │   ├── heart/
│   │   └── reactions/
│   │
│   ├── utils/
│   │   └── feed/
│   │       └── syaahiFlow.ts
│   │
│   ├── app.ts
│   └── server.ts
│
├── .env.example
├── package.json
└── tsconfig.json
```

---

# Quick Start

## Prerequisites

- Node.js v20+
- PostgreSQL database
- Supabase project

---

## Install Dependencies

```bash
npm install
```

---

## Configure Environment

```bash
cp .env.example .env
```

Fill all required environment variables.

---

## Generate Prisma Client

```bash
npm run prisma:generate
```

---

## Synchronize Database

```bash
npm run prisma:push
```

---

## Start Development Server

```bash
npm run dev
```

Backend runs at:

```text
http://localhost:4000
```

---

# Environment Variables

Required configuration:

```env
NODE_ENV=development
PORT=4000

DATABASE_URL=
DIRECT_URL=

SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

JWT_SECRET=
JWT_EXPIRES_IN=7d

CORS_ORIGIN=
```

All variables are validated at startup using **Zod**.

The server refuses to start if any required configuration is missing or invalid.

---

# API Overview

Base URL

```text
/api/v1
```

---

## Health

| Method | Endpoint |
|---------|----------|
| GET | / |
| GET | /health |

---

## Authentication

| Method | Endpoint |
|---------|----------|
| POST | /auth/signup |
| POST | /auth/login |
| GET | /auth/me |
| POST | /auth/logout |

---

## Users

| Method | Endpoint |
|---------|----------|
| GET | /users/:username |
| PATCH | /users/me |
| GET | /users/:username/poems |

---

## Poems

| Method | Endpoint |
|---------|----------|
| GET | /poems |
| GET | /poems/:id |
| POST | /poems |
| PATCH | /poems/:id |
| DELETE | /poems/:id |

Supports:

- Cursor pagination
- Feed filters
- Syaahi Flow sequencing

Example:

```text
GET /poems?cursor=&limit=&emotion=&language=&theme=
```

---

## Heart

Meaningful saving without public metrics.

| Method | Endpoint |
|---------|----------|
| POST | /poems/:id/heart |
| DELETE | /poems/:id/heart |
| GET | /users/me/heart |

Characteristics:

- Private
- No notifications
- No public counts

---

## Reactions

Meaningful acknowledgements instead of likes.

| Method | Endpoint |
|---------|----------|
| POST | /poems/:id/reactions |
| DELETE | /poems/:id/reactions/:type |
| GET | /poems/:id/reactions |

Supported reactions:

- FELT_THIS
- STAYED_WITH_ME
- BEAUTIFULLY_WRITTEN
- MADE_ME_THINK
- COMFORTED_ME
- INSPIRED_ME

---

# Syaahi Flow

The feed is powered by **Syaahi Flow**, a literary sequencing engine.

Unlike recommendation algorithms, Syaahi Flow never ranks poems using:

- Likes
- Hearts
- Reactions
- Followers
- Engagement

Instead it:

- Preserves overall recency
- Avoids consecutive poems by the same writer whenever possible
- Maintains a natural reading rhythm
- Produces deterministic ordering

The objective is a better reading experience, not higher engagement.

---

# Response Format

## Success

```json
{
  "success": true,
  "data": {}
}
```

## Error

```json
{
  "success": false,
  "message": "Error message"
}
```

---

# Seed Content

A reusable development dataset is included.

Current dataset:

```text
10 Writers
30 Poems
Multiple Languages
Multiple Themes
Multiple Emotions
```

Reset anytime:

```bash
npx tsx scripts/cleanup-and-reseed.ts
```

Useful for:

- UI development
- Feed testing
- Pagination verification
- Demonstrations

---

# Security

Implemented:

- JWT Authentication
- bcrypt Password Hashing
- Zod Request Validation
- Helmet
- CORS
- Global Rate Limiting
- Authentication Rate Limiting
- Centralized Error Handling

---

# Known Limitations

Current Internal Beta limitations:

- No refresh tokens
- No email verification
- No automated test suite
- No token blacklist
- In-memory rate limiting
- No Redis cache
- Single-instance deployment assumptions

These are documented and accepted trade-offs for the current stage.

---

# Useful Commands

## Development

```bash
npm run dev
```

---

## Production Build

```bash
npm run build
```

---

## Production Server

```bash
npm start
```

---

## Prisma

```bash
npm run prisma:generate
npm run prisma:push
npm run prisma:migrate
npm run prisma:studio
```

---

## Seed Development Data

```bash
npx tsx scripts/cleanup-and-reseed.ts
```

---

# Next Milestone

The next milestone focuses on **internal beta validation**, not feature expansion.

Objectives:

- Stability improvements
- Internal user testing
- Bug fixing
- Feedback collection
- Automated test coverage
- Production deployment

Major feature development (Journals) begins after the feedback cycle is complete.

---

# Related Documentation

```text
API_CONTRACT.md
docs/ARCHITECTURE.md
docs/ROADMAP.md
docs/DECISIONS.md
docs/PROGRESS.md
docs/VISION.md
```

---

# License

MIT License

See `LICENSE` for details.

---

# Author

**Raghavendra Singh**

Built with midnight thoughts, coffee, and a love for words.

> **Syaahi — Where emotions become words.**