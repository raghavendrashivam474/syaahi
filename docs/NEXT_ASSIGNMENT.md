# 🪶 Syaahi — Next Assignment

## Assigned To

Junior Developer

## Project Version

v0.2.2

## Current Status

Syaahi MVP is complete.

Documentation sprint is complete.

Local verification is complete.

Seed content system is complete.

Cursor pagination and infinite scrolling are complete.

The project is now entering the Deployment Sprint.

---

# Objective

Deploy Syaahi to a publicly accessible staging environment.

Target outcome:

A new user should be able to visit a public URL and complete the entire journey without local setup.

```text
Register
↓
Login
↓
Browse Feed
↓
Create Poem
↓
Read Poem
↓
Logout
```

---

# Deliverable 1 — Deployment Readiness Audit

Before deployment, verify:

## Backend

```text
✓ Production build succeeds
✓ No hardcoded localhost URLs
✓ Environment variables documented
✓ Prisma schema synchronized
✓ Health endpoint operational
✓ Seed script still functional
```

## Frontend

```text
✓ Flutter web build succeeds
✓ API URL configurable via --dart-define
✓ Session persistence verified
✓ Browser refresh does not break routing
✓ Infinite scroll still functions
```

Output:

```text
docs/DEPLOYMENT_CHECKLIST.md
```

---

# Deliverable 2 — Railway Deployment

Deploy backend.

Requirements:

```text
✓ Create Railway project
✓ Configure environment variables
✓ Connect Supabase database
✓ Verify startup logs
✓ Verify health endpoint
✓ Verify authentication endpoints
✓ Verify poems endpoints
```

Expected Result:

```text
https://<backend>.up.railway.app
```

---

# Deliverable 3 — Vercel Deployment

Deploy Flutter Web application.

Requirements:

```text
✓ Production Flutter build
✓ Configure API_BASE_URL
✓ Deploy to Vercel
✓ Verify routing
✓ Verify login flow
✓ Verify poem creation
```

Expected Result:

```text
https://<frontend>.vercel.app
```

---

# Deliverable 4 — Production CORS Configuration

Current development mode allows localhost origins.

Before staging verification:

```text
✓ Remove wildcard-style staging configuration
✓ Set CORS_ORIGIN to Vercel URL
✓ Redeploy backend
✓ Verify frontend connectivity
```

Result:

Only the staging frontend may access the backend.

---

# Deliverable 5 — End-to-End Staging Verification

Execute and document:

```text
Open App
↓
Register New User
↓
Login
↓
Create Poem
↓
Refresh Browser
↓
Verify Session Recovery
↓
Read Poem
↓
Logout
↓
Login Again
```

Verify:

```text
✓ Authentication
✓ Feed
✓ Pagination
✓ Infinite Scroll
✓ Pull To Refresh
✓ Poem Creation
✓ Session Persistence
```

---

# Deliverable 6 — Staging Report

Create:

```text
docs/STAGING_VERIFICATION.md
```

Include:

* Frontend URL
* Backend URL
* Screenshots
* Test results
* Known issues
* Recommendations

---

# Out Of Scope

Do NOT begin:

```text
Journals
Personal Archive
Letters After Midnight
Time Capsules
Community Circles
Audio Poetry
```

Do not introduce new product features.

Do not modify the roadmap.

Focus exclusively on deployment and verification.

---

# Success Criteria

Assignment is complete when:

```text
✓ Backend deployed
✓ Frontend deployed
✓ Public URLs available
✓ Full user journey verified
✓ Documentation updated
✓ No critical blockers remain
```

---

# Completion Report Required

Submit:

1. Frontend URL
2. Backend URL
3. Deployment checklist
4. Staging verification report
5. Screenshots
6. Known issues

Only after successful staging verification will v0.4.0 (Testing Sprint) begin.

---

# Founder Note

The objective is not merely to deploy software.

The objective is to make Syaahi accessible to real users for the first time.

Prioritize stability over speed.

A working deployment is more valuable than three unfinished features.

---

**— Raghavendra Singh**

*Syaahi — Where emotions become words.*
