# 🪶 Syaahi — Contributing Guide

Welcome to **Syaahi**.

Thank you for taking the time to contribute.

Before writing your first line of code, understand **why Syaahi exists**. Every technical decision in this project is driven by its product philosophy.

Read the following documents first:

```text
docs/VISION.md
docs/ROADMAP.md
docs/ARCHITECTURE.md
docs/DECISIONS.md
```

Only after understanding the vision should implementation begin.

---

# Our Guiding Principle

Every contribution should answer one question:

> **Does this help people express, preserve, or revisit emotions?**

If the answer is no, reconsider whether it belongs in Syaahi.

---

# Development Environment

## Prerequisites

| Tool | Version |
|------|---------|
| Node.js | v20+ |
| npm | v10+ |
| Flutter | Latest Stable |
| Git | Latest Stable |

---

# Repository Structure

```text
syaahi/
├── docs/
├── syaahi-backend/
└── syaahi-app/
```

---

# Backend Setup

```bash
git clone <repository>

cd syaahi/syaahi-backend

npm install

cp .env.example .env

# Configure environment variables

npm run prisma:generate

npm run prisma:push

npm run dev
```

Backend runs at:

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

Generate the complete development dataset:

```bash
npx tsx scripts/cleanup-and-reseed.ts
```

Current dataset:

```text
10 Writers
30 Poems
Multiple Languages
Multiple Themes
Multiple Emotions
```

Purpose:

- UI validation
- Feed testing
- Pagination testing
- Multi-author testing
- Demonstrations

For dataset details see:

```text
docs/SEED_CONTENT.md
```

---

# Branch Strategy

Never commit directly to:

```text
main
```

Create a feature branch first.

Examples:

```bash
git checkout -b feature/journals

git checkout -b feature/time-capsules

git checkout -b feature/hearts

git checkout -b fix/session-recovery

git checkout -b docs/architecture

git checkout -b chore/deployment
```

---

# Branch Naming

| Prefix | Purpose |
|---------|---------|
| feature/ | New functionality |
| fix/ | Bug fixes |
| docs/ | Documentation |
| refactor/ | Internal improvements |
| test/ | Test implementation |
| chore/ | Tooling & configuration |

---

# Commit Messages

Syaahi follows **Conventional Commits**.

Examples:

```bash
feat: add journal creation endpoint

feat: implement syaahi flow feed strategy

fix: resolve session recovery issue

docs: update architecture documentation

refactor: simplify poem repository

test: add authentication integration tests

chore: configure production deployment
```

Guidelines:

- Use present tense
- Keep the subject concise
- Avoid generic messages
- Avoid full stops
- Keep under 72 characters when practical

---

# Backend Standards

## Feature-Based Architecture

Each feature owns its implementation.

Example:

```text
modules/
└── auth/
    ├── auth.routes.ts
    ├── auth.controller.ts
    └── auth.schemas.ts
```

Business logic must remain inside its feature.

Shared concerns belong only in:

```text
config/
middleware/
utils/
```

---

## Request Validation

Never trust client input.

Always validate using Zod.

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

Expected errors should use:

```ts
throw new ApiError(...)
```

Do not return inconsistent error responses.

---

## Async Controllers

Always wrap asynchronous controllers.

```ts
asyncHandler(controller)
```

Never expose unhandled Promise rejections.

---

## Database Changes

Whenever modifying the schema:

- Update `schema.prisma`
- Generate Prisma client
- Create migration (or push during development)
- Update documentation
- Update API contract if required

---

# Flutter Standards

## Architecture

UI must never communicate directly with the backend.

```text
Screen
      ↓
Provider
      ↓
Repository
      ↓
Dio
      ↓
Express API
```

---

## Feature Structure

Every feature follows:

```text
feature/
├── data/
├── state/
└── presentation/
```

Responsibilities:

```text
presentation → UI

state → Riverpod

data → API communication
```

---

## Feed

The feed is managed exclusively through:

```text
FeedNotifier
```

Responsibilities:

- Initial loading
- Cursor pagination
- Infinite scrolling
- Pull-to-refresh
- Filter management
- Error handling

Feed-related logic must not bypass the notifier.

---

## Syaahi Flow

The feed uses the **Syaahi Flow** sequencing engine.

Principles:

- Preserve freshness
- Distribute authors naturally
- Avoid consecutive poems by the same author
- Never rank using engagement
- Keep ordering deterministic

Do not introduce popularity-based ranking.

---

# Product Principles

Syaahi intentionally avoids conventional engagement mechanics.

When adding new functionality:

Prefer:

- Meaningful reactions
- Commit to Heart
- Emotional discovery
- Personal archives

Avoid introducing:

- Like counts
- Trending feeds
- Followers
- Engagement loops
- Attention-maximizing mechanics

When uncertain, revisit:

```text
docs/VISION.md
```

---

# Adding A New Feature

## Backend

1. Create module
2. Add schemas
3. Add controller
4. Add routes
5. Register routes
6. Update API contract
7. Update progress log
8. Update documentation if architecture changes

---

## Frontend

1. Create feature
2. Repository
3. State layer
4. Presentation layer
5. Register routes
6. Verify end-to-end
7. Update documentation

---

# Environment Variables

Whenever introducing a new variable:

1. Add it to the Zod schema
2. Add it to `.env.example`
3. Document it in the README
4. Configure it in production

Never commit:

```text
.env
```

Never hardcode credentials or secrets.

---

# Deployment Checklist

Before deployment ensure:

```text
✓ Production build succeeds

✓ Environment variables configured

✓ No localhost URLs remain

✓ Database connectivity verified

✓ Documentation updated

✓ End-to-end verification completed

✓ Health endpoint verified
```

Code that only works locally is **not complete**.

---

# Definition of Done

A task is complete only when:

```text
✓ Implemented

✓ Input validated

✓ Error cases handled

✓ Manually verified

✓ Documentation updated

✓ Proper commit created

✓ Works on staging (or verified deployment target)
```

---

# Changes Requiring Approval

Discuss before implementing:

- New dependencies
- Database schema redesign
- Architectural changes
- Infrastructure spending
- Features outside the roadmap
- Changes affecting product philosophy

---

# Documentation Checklist

Whenever appropriate, update:

```text
README.md

ARCHITECTURE.md

API_CONTRACT.md

ROADMAP.md

PROGRESS.md

DECISIONS.md

VISION.md
```

Documentation is considered part of the implementation.

---

# Need Help?

When unsure, consult documentation in this order:

```text
VISION.md
      ↓
ROADMAP.md
      ↓
ARCHITECTURE.md
      ↓
DECISIONS.md
      ↓
PROGRESS.md
      ↓
Founder
```

Most questions are already answered there.

---

# Final Principle

Build carefully.

Document thoroughly.

Prefer simplicity over cleverness.

Optimize for emotional value rather than feature count.

Every line of code should help make Syaahi a quieter, more thoughtful place to write, preserve, and rediscover human emotions.

---

> **Syaahi — Where emotions become words.**