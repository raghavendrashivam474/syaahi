# 🪶 Syaahi — Contributing Guide

Welcome to Syaahi.

Before contributing, read:

```text
docs/VISION.md
```

to understand what this project is and what it is not.

Every contribution should support the core question:

> Does this help people express, preserve, or revisit emotions?

---

# Before You Start

Read these documents first:

1. VISION.md
2. ROADMAP.md
3. ARCHITECTURE.md
4. DECISIONS.md

Only after understanding the product vision should implementation begin.

---

# Development Environment

## Prerequisites

| Tool    | Version        |
| ------- | -------------- |
| Node.js | v20+           |
| npm     | v10+           |
| Flutter | Latest Stable  |
| Git     | Recent Version |

---

# Backend Setup

```bash
git clone <repository>

cd syaahi/syaahi-backend

npm install

cp .env.example .env

# configure environment variables

npm run prisma:generate

npm run dev
```

Runs at:

```text
http://localhost:4000
```

---

# Frontend Setup

```bash
cd syaahi/syaahi-app

flutter pub get

flutter run -d chrome
```

---

# Development Dataset

Generate development content:

```bash
npx tsx scripts/cleanup-and-reseed.ts
```

Current dataset:

```text
10 Accounts
30 Poems
Multiple Authors
Multiple Emotions
```

Purpose:

* UI validation
* Feed testing
* Pagination testing
* Demonstrations

See:

```text
docs/SEED_CONTENT.md
```

for details.

---

# Branch Strategy

Never commit directly to:

```text
main
```

Create a branch first.

Examples:

```bash
git checkout -b feature/journals
git checkout -b feature/archive
git checkout -b fix/auth-session
git checkout -b docs/roadmap
git checkout -b chore/deployment
```

---

# Branch Prefixes

| Prefix    | Purpose                 |
| --------- | ----------------------- |
| feature/  | New functionality       |
| fix/      | Bug fixes               |
| docs/     | Documentation           |
| chore/    | Tooling & configuration |
| refactor/ | Internal improvements   |
| test/     | Test implementation     |

---

# Commit Messages

Syaahi uses Conventional Commits.

Examples:

```bash
feat: add journal creation endpoint

fix: resolve session recovery bug

docs: update roadmap

chore: configure railway deployment

test: add auth endpoint tests
```

Rules:

* Present tense
* No full stop
* Under 72 characters when possible
* Specific and descriptive

---

# Backend Standards

## Module Structure

Each feature owns its own folder.

Example:

```text
auth/
├── auth.routes.ts
├── auth.controller.ts
└── auth.schemas.ts
```

---

## Validation

Never trust user input.

Always validate through Zod.

Correct:

```ts
const data = schema.parse(req.body);
```

Incorrect:

```ts
const { email } = req.body;
```

---

## Error Handling

Expected failures should use:

```ts
throw new ApiError(...)
```

Never return inconsistent error shapes.

---

## Async Routes

Use:

```ts
asyncHandler(...)
```

for all async controllers.

---

# Flutter Standards

## Layering

UI never calls APIs directly.

Architecture:

```text
Screen
 ↓
Provider
 ↓
Repository
 ↓
Dio
 ↓
API
```

---

## Feature Structure

```text
feature/
├── data/
├── state/
└── presentation/
```

---

## Feed Architecture

Poem feed uses:

```text
FeedNotifier
```

Responsibilities:

* Initial loading
* Pagination
* Refresh
* Error handling
* Infinite scroll state

Do not bypass FeedNotifier for feed-related functionality.

---

# Pagination Standards

Feed endpoints use:

```text
Cursor Pagination
```

Preferred format:

```text
GET /resource?cursor=&limit=
```

Avoid offset pagination for feed-style content.

Reason:

* Better scalability
* Better infinite scroll support

---

# Adding A New Feature

## Backend

1. Create module folder
2. Add schemas
3. Add controller
4. Add routes
5. Register routes
6. Update API contract
7. Update progress log

---

## Frontend

1. Create feature folder
2. Add repository
3. Add state layer
4. Add UI layer
5. Register routes
6. Update progress log

---

# Environment Variables

Whenever a new variable is introduced:

1. Add to Zod schema
2. Add to `.env.example`
3. Document in README
4. Configure in Railway before deployment

Never commit:

```text
.env
```

Never hardcode secrets.

---

# Deployment Rules

Before deployment:

```text
✓ Production build passes
✓ Environment variables configured
✓ No localhost URLs remain
✓ Documentation updated
✓ End-to-end flow verified
```

Code that only works locally is not complete.

---

# Definition Of Done

A task is complete only when:

```text
✓ Implemented
✓ Validated
✓ Error handled
✓ Manually verified
✓ Documented
✓ Committed properly
✓ Works on staging
```

---

# Changes Requiring Approval

Approval required before:

* Adding dependencies
* Database schema changes
* New roadmap features
* Infrastructure spending
* Architectural changes

---

# Where To Look First

If something is unclear:

```text
ARCHITECTURE.md
↓
DECISIONS.md
↓
ROADMAP.md
↓
VISION.md
↓
Founder
```

---

# Final Principle

Build carefully.

Document thoroughly.

Protect simplicity.

Optimize for emotional value, not feature count.
