# 🪶 Syaahi Backend

Backend API for **Syaahi** — *Where emotions become words.*

Node.js + Express + TypeScript backend powering authentication, poems, user profiles, emotional expression, and future memory-preservation features.

---

# Current Status

**Version:** v0.2.2

**Status:** MVP Complete • Locally Verified • Deployment Pending

### Verified User Journey

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

---

# Available Modules

| Module              | Status |
| ------------------- | ------ |
| Health              | ✅      |
| Authentication      | ✅      |
| Users               | ✅      |
| Poems               | ✅      |
| Cursor Pagination   | ✅      |
| Seed Content System | ✅      |

---

# Tech Stack

| Layer          | Technology                  |
| -------------- | --------------------------- |
| Runtime        | Node.js v20+                |
| Language       | TypeScript                  |
| Framework      | Express 5                   |
| ORM            | Prisma                      |
| Database       | PostgreSQL (Supabase)       |
| Authentication | JWT + bcrypt                |
| Validation     | Zod                         |
| Security       | Helmet, CORS, Rate Limiting |

---

# Architecture

```text
Client
 ↓
Express API
 ↓
Controllers
 ↓
Prisma
 ↓
PostgreSQL
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
│   │   └── users/
│   ├── utils/
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

* Node.js v20+
* PostgreSQL database
* Supabase project

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

Fill all required values.

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

Server:

```text
http://localhost:4000
```

---

# Environment Variables

Required:

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

All variables are validated at startup using Zod.

The server will refuse to start if configuration is invalid.

---

# API Overview

Base URL:

```text
/api/v1
```

---

# Health

| Method | Endpoint |
| ------ | -------- |
| GET    | /        |
| GET    | /health  |

---

# Authentication

| Method | Endpoint     |
| ------ | ------------ |
| POST   | /auth/signup |
| POST   | /auth/login  |
| GET    | /auth/me     |
| POST   | /auth/logout |

---

# Users

| Method | Endpoint         |
| ------ | ---------------- |
| GET    | /users/:username |

### Planned

```text
PATCH /users/me
GET /users/:username/poems
```

---

# Poems

| Method | Endpoint   |
| ------ | ---------- |
| GET    | /poems     |
| GET    | /poems/:id |
| POST   | /poems     |

### Feed Pagination

Supported:

```text
GET /poems?cursor=&limit=
```

Current page size:

```text
10
```

---

### Planned

```text
PATCH /poems/:id
DELETE /poems/:id
```

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

The repository includes a reusable development dataset.

Current dataset:

```text
10 Accounts
30 Poems
Multiple Authors
Multiple Emotions
Multiple Themes
```

Reset anytime:

```bash
npx tsx scripts/cleanup-and-reseed.ts
```

Purpose:

* Feed testing
* Pagination testing
* UI validation
* Demonstrations

---

# Security

Implemented:

* JWT Authentication
* Password Hashing (bcrypt)
* Helmet
* Request Validation (Zod)
* Rate Limiting
* Centralized Error Handling

---

# Known Limitations

Current MVP limitations:

* No refresh tokens
* No email verification
* No poem editing
* No poem deletion
* No profile editing
* No automated tests
* No token blacklist
* In-memory rate limiting

These are documented and accepted trade-offs.

---

# Useful Commands

## Development

```bash
npm run dev
```

---

## Build

```bash
npm run build
```

---

## Production

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

## Seed Content

```bash
npx tsx scripts/cleanup-and-reseed.ts
```

---

# Next Milestone

## v0.3.0 — Deployment Sprint

Goals:

* Deploy backend to Railway
* Configure production environment variables
* Verify health endpoint
* Verify database connectivity
* Verify authentication
* Verify feed pagination on staging

---

# Related Documentation

```text
API_CONTRACT.md
docs/ARCHITECTURE.md
docs/ROADMAP.md
docs/DECISIONS.md
docs/PROGRESS.md
```

---

# License

MIT License

---

# Author

**Raghavendra Singh**

Built with coffee, midnight thoughts, and a love for words.

> Syaahi — Where emotions become words.
