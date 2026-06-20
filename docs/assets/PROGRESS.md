# Syaahi — Progress Log

A living changelog. Newest entries at the top. Update after every meaningful session.

**Format:**
[YYYY-MM-DD] — Session Title
Phase: X | Duration: Nh | Commit: abc123

Done
...
Decisions
...
Next
...
text


---

## [2026-06-20] — Phase 1 Backend Complete

**Phase:** 1 | **Commit:** _(fill in after commit)_

### Done
- ✅ Logout endpoint (`POST /api/v1/auth/logout`)
- ✅ Rate limiting (signup, login, writes, global)
- ✅ Poem update & delete with ownership checks
- ✅ User profile endpoints (lookup, update, user's poems)
- ✅ Verified all 12 endpoints end-to-end via PowerShell

### Decisions
- Symbolic logout for MVP (no Redis blacklist yet)
- Kept full schema (Reactions/Follows/Rooms) even though deferred — minimal cost
- Rate limiter uses in-memory store (Redis upgrade post-MVP)

### Next
- Set up Flutter project (`syaahi-app/`)
- Configure dark theme (Midnight Blue + Gold)
- Build Splash → Welcome → Auth screens

---

## [2026-06-19] — Backend Foundation Verified

**Phase:** 1 | **Commit:** _(fill in)_

### Done
- ✅ Express + TypeScript + Prisma + Supabase wired
- ✅ Auth module (signup, login, /me)
- ✅ Poems module (create, list, get)
- ✅ All 7 base endpoints E2E tested

### Decisions
- PostgreSQL via Supabase (managed, free tier sufficient for beta)
- Custom JWT instead of Supabase Auth (portability)
- Prisma 6 (pinned; v7 ecosystem too new)

### Next
- Add profile + update/delete + rate limit + logout

---

## [2026-06-18] — Project Kickoff

**Phase:** 0 | **Commit:** initial

### Done
- ✅ Repo initialized (MIT license, README, .gitignore)
- ✅ Supabase project created (region: ap-northeast-1)
- ✅ Backend folder scaffolded
- ✅ Tech stack chosen

### Decisions
- Backend-first; Flutter to follow
- Schema designed beyond MVP (acceptable; iterate later)
- Web (Chrome) as Flutter initial target