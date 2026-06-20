# Contributing to Syaahi

## Prerequisites

- Node.js v20+
- Git
- A Supabase account (free)
- (For Flutter) Flutter SDK 3.x

## Backend Setup

```bash
cd syaahi-backend
npm install
cp .env.example .env
# Fill DATABASE_URL, DIRECT_URL, SUPABASE_*, JWT_SECRET
npx prisma generate
npx prisma db push
npm run dev
API at http://localhost:4000.

Branch Naming
feat/<name> — new feature
fix/<name> — bug fix
docs/<name> — documentation
chore/<name> — tooling, deps
refactor/<name> — non-functional change
Commit Messages (Conventional Commits)
text

feat(poems): add update endpoint
fix(auth): correct token expiry
docs: update API contract
chore(deps): bump prisma to 6.19.3
refactor(users): extract profile selector
Scope is optional but encouraged.

PR Checklist
 Code compiles (npm run dev boots cleanly)
 All affected endpoints manually tested
 PROGRESS.md updated
 API_CONTRACT.md updated if API changed
 New ADR added if decision was non-trivial
Testing
Currently manual via PowerShell Invoke-RestMethod. Test scripts live in scripts/ (TODO).

Vitest + Supertest planned post-MVP.

Code Style
TypeScript strict mode
Prefer async/await over .then()
No business logic in routes — keep controllers thin
Validate every input with Zod
Throw ApiError, never raw Error