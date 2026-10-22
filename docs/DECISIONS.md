# 🪶 Syaahi — Architecture Decision Records

This document records significant technical and product decisions made during Syaahi's development.

Each decision includes context, the decision itself, the reasoning, and current status.

---

## How to Add a Decision

When a significant decision is made, add a new entry following this format:

```text
## ADR-XXX: Title
Date: YYYY-MM-DD
Status: Active | Superseded | Deprecated

### Context
What situation required a decision?

### Decision
What was decided?

### Reasoning
Why was this the right choice?

### Consequences
What does this mean going forward?
ADR-001: Feature-Based Architecture
Date: 2026-06
Status: Active

Context
Needed a folder structure that would scale as features grew without creating
a tangled shared codebase.

Decision
Every feature owns its own routes, controller, schema, and data layer.
Shared concerns live only in middleware and utils.

text

modules/
├── auth/
│   ├── auth.routes.ts
│   ├── auth.controller.ts
│   └── auth.schemas.ts
├── poems/
└── users/
Reasoning
Feature-based structure means a developer working on journals
does not need to understand the poems module.
Each feature is independently readable and testable.

Consequences
New features require creating a new folder under modules.
No business logic should leak into middleware or utils.

ADR-002: Zod for Environment Validation
Date: 2026-06
Status: Active

Context
Missing environment variables in production cause silent failures
that are difficult to debug.

Decision
All environment variables are validated at startup using a Zod schema.
The server refuses to start if any required variable is missing or invalid.

Reasoning
Fail fast and loudly.
A clear startup error is infinitely better than a runtime crash
twenty minutes after deployment.

Consequences
Every new environment variable must be added to the Zod schema in
src/config/env.ts and to .env.example.

ADR-003: JWT Authentication
Date: 2026-06
Status: Active

Context
Needed a stateless authentication system compatible with both
Flutter Web and future mobile apps.

Decision
JWT tokens signed with HS256.
Tokens stored in flutter_secure_storage on the client.
Sent as Authorization: Bearer <token> on every request.

Reasoning
Stateless: no server-side session storage needed
Mobile compatible: works identically on web and native
Simple: no Redis or session database required at this stage
Consequences
Token revocation is not possible without a blacklist
Logout is currently client-side only (token is discarded)
If a token is stolen before expiry, it cannot be invalidated
Refresh tokens are not yet implemented
Re-login required when token expires
These are acceptable trade-offs for MVP stage.
A token blacklist using Redis should be considered before production launch.

ADR-004: Prisma as ORM
Date: 2026-06
Status: Active

Context
Needed a database access layer that is type-safe, maintainable,
and works well with TypeScript.

Decision
Prisma ORM with PostgreSQL via Supabase.
Schema defined in prisma/schema.prisma.
All database changes go through Prisma migrations.

Reasoning
Type-safe queries reduce runtime errors
Schema as source of truth
Migration history is version controlled
Prisma Studio provides a visual database browser for development
Consequences
Every schema change requires a migration file.
No raw SQL changes directly to the database.
Schema changes must be documented in this file.

ADR-005: Zod for Request Validation
Date: 2026-06
Status: Active

Context
User input cannot be trusted.
Needed consistent validation across all API endpoints.

Decision
Every route that accepts a request body has a corresponding Zod schema.
Validation happens at the controller level using schema.parse(req.body).
Zod throws automatically on invalid input and the error handler catches it.

Reasoning
Consistent validation across all modules
Type inference from schema means no duplicate type definitions
Error messages are structured and predictable
Consequences
Every new endpoint needs a schema file.
Never access req.body without parsing it through Zod first.

ADR-006: Express Rate Limiting
Date: 2026-06
Status: Active

Context
Auth endpoints without rate limiting are vulnerable to brute force attacks.

Decision
express-rate-limit applied at two levels:

Global limiter on all /api/ routes
Stricter limiters on /auth/signup and /auth/login
Reasoning
Simple and effective protection with no external dependencies.
Does not require Redis at this stage.

Consequences
In-memory rate limiting resets on server restart.
For production with multiple instances, a Redis-backed store
should be used instead.

ADR-007: Flutter Web as MVP Frontend Target
Date: 2026-06
Status: Active

Context
Needed a frontend that could validate the product quickly
while keeping the option open for native mobile later.

Decision
Flutter Web for MVP.
Same Flutter codebase will extend to Android and iOS post-MVP.

Reasoning
Single codebase for web and mobile
No need to build a separate web frontend
Faster time to validation
Consequences
Flutter Web has performance limitations compared to native web frameworks.
This is acceptable for MVP user numbers.
If Syaahi grows significantly, a dedicated web frontend may be needed.

ADR-008: Supabase for PostgreSQL Hosting
Date: 2026-06
Status: Active

Context
Needed a managed PostgreSQL database with minimal setup overhead.

Decision
Supabase as the PostgreSQL host.
Prisma connects via pooled DATABASE_URL and direct DIRECT_URL.

Reasoning
Managed database with no infrastructure overhead
Generous free tier for early development
Direct PostgreSQL access means no vendor lock-in
Can migrate to any PostgreSQL host in the future
Consequences
Two connection strings required: pooled and direct.
Direct URL is needed for Prisma migrations.
Pooled URL is used for application queries.

ADR-009: CORS Wildcard for Staging
Date: 2026-06
Status: Active — Staging Only

Context
During initial deployment, the frontend URL is not known before
the backend is deployed.

Decision
Use wildcard CORS origin (*) for the staging environment only.

Reasoning
Speed. Staging is not public-facing and exists only for MVP validation.

Consequences
This must be replaced before any production deployment.
When FRONTEND_URL is known, update app.ts to use it explicitly.

## ADR-010: Development CORS Strategy

Date: 2026-06
Status: Active

### Context
Flutter Web runs on a dynamic localhost port during development.
The port changes every time the app is launched.
Hardcoding specific ports in CORS_ORIGIN was not practical.

### Decision
In development mode, all localhost origins are permitted automatically.
In production, only origins listed in the CORS_ORIGIN environment variable are allowed.

### Reasoning
- Eliminates the need to update .env every time Flutter picks a new port
- No security risk in development
- Production remains strictly controlled via environment variable

### Consequences
CORS_ORIGIN must be set correctly on Railway before any production deployment.
The Vercel frontend URL must be the only allowed origin in production.

## ADR-011: Cursor-Based Feed Pagination

Date: 2026-06

Status: Active

### Context

The poem feed initially returned all poems in a single request.

As the dataset grew from a handful of poems to dozens of poems, loading the entire feed became inefficient and prevented infinite scrolling.

A scalable feed strategy was required before deployment.

### Decision

Implement cursor-based pagination for the poem feed.

API contract:

```text
GET /api/v1/poems?cursor=<cursor>&limit=<limit>
```

Response returns:

```text
poems
nextCursor
```

Frontend uses nextCursor to request additional pages.

### Reasoning

* Better scalability than offset pagination
* Consistent performance as data grows
* Supports infinite scroll naturally
* Avoids duplicate or skipped records during feed updates

### Consequences

All feed consumers must understand cursor pagination.

Feed responses now include:

```text
poems
nextCursor
```

Future feed-related endpoints should prefer cursor pagination over offset pagination.

---

## ADR-012: Infinite Scroll Feed Experience

Date: 2026-06

Status: Active

### Context

The original feed required manual pagination and exposed only the first portion of available poems.

A more natural reading experience was needed.

### Decision

Implement automatic infinite scrolling.

Frontend loads the next page when the user reaches approximately 85% of the current scroll position.

End of feed displays:

```text
— you have read everything —
```

### Reasoning

* More natural reading experience
* Reduced user friction
* Aligns with modern content consumption patterns
* Works well with cursor pagination

### Consequences

Feed state became more complex.

A simple FutureProvider was no longer sufficient.

Dedicated feed state management was introduced.

---

## ADR-013: Feed StateNotifier Architecture

Date: 2026-06

Status: Active

### Context

Cursor pagination introduced multiple state variables:

* loading
* loading more
* next cursor
* accumulated poems
* has more
* error state

FutureProvider could no longer manage feed state cleanly.

### Decision

Replace the feed FutureProvider with a dedicated StateNotifier.

FeedNotifier owns:

```text
poems
isLoading
isLoadingMore
hasMore
nextCursor
error
```

### Reasoning

* Better separation of concerns
* Predictable pagination state
* Easier future enhancements
* Cleaner UI layer

### Consequences

All feed interactions must go through FeedNotifier.

Future feed features should extend FeedNotifier rather than introducing parallel state systems.

---

## ADR-014: Development Seed Content System

Date: 2026-06

Status: Active

### Context

An empty platform creates a poor testing and demonstration experience.

Manual creation of accounts and poems before every test session was repetitive and error-prone.

### Decision

Introduce a reusable seed content system.

Seed dataset currently contains:

```text
10 Users
30 Poems
```

Reset command:

```bash
npx tsx scripts/cleanup-and-reseed.ts
```

### Reasoning

* Consistent testing environment
* Better demo experience
* Faster onboarding for new developers
* Enables pagination verification

### Consequences

Seed data is now considered part of the development environment.

Changes to seed accounts, poems, or credentials should be documented in:

```text
docs/SEED_CONTENT.md
```

---

## ADR-015: Writer Persona-Based Seed Data

Date: 2026-06

Status: Active

### Context

Randomly generated seed content made the platform feel artificial.

The goal was to create a believable reading experience.

### Decision

Each seed account represents a specific writing style.

Examples:

```text
aarav_thinks     → Philosophical
meera_writes     → Romantic
kabir_outdoors   → Nature
ananya_heals     → Healing
rizwan_recalls   → Nostalgic
```

### Reasoning

* More realistic feed
* Better emotional variety
* Improved product demonstrations
* Easier visual validation during development

### Consequences

Future seed content should preserve author identity and writing style.

Seed accounts are development assets and should remain consistent across resets.

---

## ADR-020: Feature-Based Modular Expansion

**Date:** 2026-07

**Status:** Active

### Context

As Syaahi expanded beyond the MVP, new capabilities such as Hearts, Reactions, Profiles, and future Journals increased architectural complexity.

A consistent strategy for future expansion was required.

### Decision

Every new capability will continue to be implemented as an independent feature module.

Each module owns its:

- Routes
- Validation
- Business logic
- State management
- Documentation

Shared concerns remain isolated within common middleware, utilities, and configuration.

### Reasoning

Independent modules improve maintainability, onboarding, testing, and long-term scalability.

### Consequences

Future features such as Journals, Time Capsules, Community Circles, Letters After Midnight, and Audio Poetry will follow the same architectural pattern.
---

## ADR-021: Application-Level Notification Isolation

**Date:** 2026-10
**Status:** Active

### Context

The notification system requires strict user isolation: User A must never access User B's notifications. The existing Syaahi architecture enforces all access control at the application layer (Express controllers), with no database-level Row-Level Security (RLS) policies.

### Decision

Notification isolation is enforced exclusively at the application layer. Every Prisma query in the notification controller includes `recipientId: req.user.userId` in the WHERE clause. No RLS policies are added for notification tables.

### Reasoning

- Consistent with the existing architecture (poem ownership, hearts, reactions all use application-level checks).
- No RLS infrastructure exists in the repository (no SQL files, no `supabase/` directory).
- Adding RLS for notifications alone would create an inconsistent security model.
- Application-level isolation is sufficient when the backend is the sole database client.

### Consequences

- If a future bug omits the `recipientId` filter, data leaks are possible. Mitigated by code review and integration tests.
- RLS should be considered as a defense-in-depth measure before production launch, applied to all user-scoped tables simultaneously.

---

## ADR-022: Synchronous In-Request Event Processing

**Date:** 2026-10
**Status:** Active

### Context

When a poem is published, notification records must be created for all opted-in recipients. The backend deploys on Vercel serverless with no background workers, message queues, or cron infrastructure.

### Decision

Notification creation is performed synchronously within the poem publication request, after the poem is successfully persisted. Push delivery (N5) is fire-and-forget within the same request.

### Reasoning

- Vercel serverless does not support long-running background processes.
- Adding a worker (Railway, BullMQ, Vercel Cron) is disproportionate for v0.1 user counts.
- For typical opted-in counts (<1000), bulk insert completes well within Vercel's 10s timeout.
- The poem is the user's creative output and must not be rolled back due to notification failures.

### Consequences

- Notification creation is not transactional with poem creation. A crash between the two creates a gap.
- If user count grows significantly, migrate to an outbox + worker pattern.
- Push delivery failures are logged but not retried in v0.1.

---

## ADR-023: Strict Opt-In Notification Model

**Date:** 2026-10
**Status:** Active

### Context

The notification system needs a recipient eligibility model. Options include opt-out (all users receive by default), opt-in (users must explicitly enable), and followers-only.

### Decision

Strict opt-in. All users default to `newPoemAlerts: false`. No user receives notifications until they explicitly enable the preference. Existing users are not assumed to have consented.

### Reasoning

- Privacy-first approach aligns with Syaahi's emotional-first philosophy (ARCHITECTURE.md principle 10).
- Avoids consent and regulatory issues.
- No follow system exists in the application UI; building one solely for notifications is out of scope.
- Users who want notifications will opt in; those who don't will not be disturbed.

### Consequences

- Initial notification volume will be low until users discover and enable the setting.
- A prominent settings entry point is needed in the Flutter app to drive opt-in.
- The preference default may be revisited after user feedback.

---

## ADR-024: Cascade Delete for Notification Records

**Date:** 2026-10
**Status:** Active

### Context

When a user or poem is deleted, the system must handle related notification records.

### Decision

Both the `recipientId` and `poemId` foreign keys on the `Notification` model use `onDelete: Cascade`. Deleting a user removes all their notifications. Deleting a poem removes all notifications referencing it.

### Reasoning

- Consistent with all existing relations in the Prisma schema (every FK uses Cascade).
- Prevents orphan records and broken references.
- Simplifies cleanup logic — no application-level cascade needed.

### Consequences

- If an author deletes a poem, recipients lose the notification. This is acceptable because the poem is no longer accessible.
- If cascade behavior needs to change in the future (e.g., soft-delete poems), the notification model must be updated simultaneously.

---

## ADR-025: Author Self-Notification Policy

**Date:** 2026-10
**Status:** Pending Owner Approval

### Context

When a user publishes a poem, should they receive a notification about their own publication?

### Decision (Proposed)

No self-notification. The author is excluded from the recipient list during notification creation.

### Reasoning

- The author already sees a success snackbar ("Published. Your words are out there.") and the feed refreshes immediately.
- A self-notification adds no informational value.
- Reduces notification noise.

### Consequences

- If the product owner wants self-notifications (e.g., for cross-device awareness), the recipient query filter is trivially adjusted.
- This decision must be explicitly approved before N3 implementation.

---

## ADR-026: Firebase Cloud Messaging as Push Provider

**Date:** 2026-10
**Status:** Active

### Context

The notification system requires a push delivery channel for Android.

### Decision

Firebase Cloud Messaging (FCM) via the HTTP v1 API. The Flutter app uses `firebase_messaging`. The backend sends push via HTTPS using a service account.

### Reasoning

- Android is the only target platform; FCM is the native Android push service.
- Unlimited free push messages.
- Simple HTTP API compatible with Vercel serverless.
- Full control over payload content (privacy-safe).
- Standard Flutter integration via `firebase_messaging`.

### Consequences

- Requires a Firebase project and service account key.
- The `google-services.json` file must be added to the Flutter Android project.
- FCM credentials must be stored as Vercel environment variables.

---

## ADR-027: Non-Transactional Poem and Notification Creation

**Date:** 2026-10
**Status:** Active

### Context

Poem creation and notification creation could be wrapped in a single database transaction for atomicity.

### Decision

Poem creation and notification creation are separate operations. The poem is persisted first. Notification creation follows as a best-effort step. A notification failure does not roll back the poem.

### Reasoning

- The poem is the user's creative output. Losing it due to a notification error is unacceptable.
- The recipient query and bulk insert could involve many rows, holding a transaction open unnecessarily.
- Notifications are derived data and can be regenerated from the poem.

### Consequences

- A crash between poem insert and notification insert creates a notification gap.
- Gaps can be backfilled via a manual script or future cron job.
- This is an acceptable trade-off for v0.1.
