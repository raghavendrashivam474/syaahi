# 🪶 Syaahi — Next Assignment

## Assigned To

Junior Developer

---

## Project Version

**v0.3.0-beta**

---

## Current Project State

Syaahi has completed its internal development milestone.

Completed:

- ✅ Authentication
- ✅ Session Persistence
- ✅ Poetry Feed
- ✅ User Profiles
- ✅ Cursor Pagination
- ✅ Infinite Scroll
- ✅ Pull-to-Refresh
- ✅ Feed Filters
- ✅ Syaahi Flow feed sequencing
- ✅ Meaningful Reactions
- ✅ Commit to Heart
- ✅ Seed Content System
- ✅ Documentation Suite

The application has been fully verified in the local development environment.

The next objective is preparing Syaahi for its **first internal beta release**.

---

# Sprint Objective

Prepare Syaahi for real users.

The goal is **stability**, not additional features.

Every completed task should move the project toward a successful internal beta.

---

# Primary Deliverable

A new user should be able to install the application and complete the entire experience.

```text
Register
      ↓
Login
      ↓
Session Recovery
      ↓
Browse Feed
      ↓
Apply Filters
      ↓
Read Poem
      ↓
Leave Meaningful Reaction
      ↓
Commit To Heart
      ↓
Write Poem
      ↓
Visit Author Profile
      ↓
Logout
```

The complete journey should work without developer intervention.

---

# Deliverable 1 — Production Readiness Audit

Perform a complete audit before deployment.

## Backend

Verify:

```text
✓ Production build succeeds

✓ Environment variables documented

✓ No localhost URLs remain

✓ Prisma schema synchronized

✓ Health endpoint operational

✓ Seed script functional

✓ Feed filters working

✓ Cursor pagination verified

✓ Syaahi Flow verified

✓ Commit to Heart endpoints verified

✓ Meaningful Reactions verified
```

---

## Flutter Application

Verify:

```text
✓ Release APK builds successfully

✓ API URL configurable

✓ Session persistence works

✓ Browser-independent routing

✓ Infinite scroll works

✓ Feed filters work

✓ Heart system works

✓ Meaningful reactions work

✓ User profiles load correctly
```

---

## Output

Create:

```text
docs/DEPLOYMENT_CHECKLIST.md
```

---

# Deliverable 2 — Backend Deployment

Deploy the backend.

Preferred:

```text
Railway
```

Alternatives (if required):

- Render
- Fly.io
- Coolify

Requirements:

```text
✓ Environment variables configured

✓ Database connected

✓ Startup successful

✓ Health endpoint verified

✓ Authentication verified

✓ Feed verified

✓ Filters verified

✓ Pagination verified

✓ Heart endpoints verified

✓ Reaction endpoints verified
```

Expected Output:

```text
https://<backend>.up.railway.app
```

---

# Deliverable 3 — Android Beta Build

Generate an Android APK for internal testing.

Requirements:

```text
✓ Release APK generated

✓ API_BASE_URL configured

✓ Connects to deployed backend

✓ Installs successfully

✓ Launches correctly

✓ Session recovery verified
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

# Deliverable 4 — Production Configuration

Verify production configuration.

Backend:

```text
✓ CORS configured correctly

✓ Environment variables verified

✓ JWT configuration verified

✓ Database connection stable
```

Flutter:

```text
✓ Production API URL

✓ Release configuration

✓ Debug flags removed
```

---

# Deliverable 5 — Complete Beta Verification

Execute the complete user journey.

```text
Install APK
      ↓
Open App
      ↓
Register
      ↓
Login
      ↓
Browse Feed
      ↓
Apply Filters
      ↓
Read Poem
      ↓
React
      ↓
Commit To Heart
      ↓
Write Poem
      ↓
Visit Profile
      ↓
Restart App
      ↓
Verify Session Recovery
      ↓
Logout
      ↓
Login Again
```

Verify:

```text
✓ Authentication

✓ Session Recovery

✓ Feed

✓ Feed Filters

✓ Cursor Pagination

✓ Infinite Scroll

✓ Pull-to-Refresh

✓ Syaahi Flow

✓ Meaningful Reactions

✓ Commit to Heart

✓ User Profiles

✓ Poem Publishing
```

---

# Deliverable 6 — Internal Beta Report

Create:

```text
docs/BETA_VERIFICATION.md
```

Include:

- Backend URL
- APK Version
- Device tested
- Android version
- Verification checklist
- Screenshots
- Performance observations
- Known issues
- Recommendations

---

# Out of Scope

Do **not** begin work on:

```text
Journals

Personal Archive

Letters After Midnight

Time Capsules

Community Circles

Audio Poetry
```

Do not redesign the architecture.

Do not modify the roadmap.

Do not introduce new engagement features.

Focus entirely on deployment readiness and internal beta quality.

---

# Success Criteria

This assignment is complete when:

```text
✓ Backend deployed

✓ Production environment configured

✓ Release APK generated

✓ Complete user journey verified

✓ Documentation updated

✓ No critical issues remain

✓ Ready for internal writers to begin testing
```

---

# Completion Report

Submit:

1. Backend URL
2. APK file
3. Deployment checklist
4. Internal beta verification report
5. Screenshots
6. Known issues
7. Recommendations for the next sprint

---

# Next Sprint

After successful internal beta verification, development will move to:

```text
v0.4.0 — Reliability & Testing
```

Focus areas:

- Automated testing
- Monitoring
- Logging
- Production hardening
- Performance optimization

No major product features will begin until the internal beta is considered stable.

---

# Founder Note

The objective is not simply to release software.

The objective is to place Syaahi into the hands of its first real writers.

Every bug fixed now preserves trust later.

Every thoughtful improvement strengthens the experience.

Prioritize reliability over speed.

Protect simplicity.

Protect meaning.

---

**— Raghavendra Singh**

*Founder, Syaahi*

> **Syaahi — Where emotions become words.**