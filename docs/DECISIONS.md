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

