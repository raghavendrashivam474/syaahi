# STMS-2 — Implementation Plan

**Sprint:** STMS-2 (Deployment, Stabilization & Release Readiness)  
**Target Branch:** `chore/stms-2-deployment-stabilization`  

---

## Stages Overview

### STMS-2.0 — Repository & Deployment Audit (Completed)
- Baseline verified (`v-ST-MS1` ancestor confirmed).
- Backend TypeScript build and 14 Studio tests verified.
- Frontend static analysis, 82 tests, and Web release build verified.
- Production backend 404 on `/api/v1/studio/drafts` documented.

### STMS-2.1 — Backend Deployment & Verification
- Execute Vercel production build & deploy for `syaahi-backend`.
- Ensure Prisma schema migration (`20261120_add_draft_model`) is applied.
- Verify live Draft API endpoints on `https://syaahi-backend.vercel.app/api/v1/studio/drafts`.
- Test authentication, owner isolation, validation, and publish idempotency against live endpoint.

### STMS-2.2 — Frontend Deployment & Connectivity
- Clean up unused import warning in `app_router.dart`.
- Re-verify Flutter Web production URL resolution.
- Verify Web browser persistence and background sync under live production backend.

### STMS-2.3 — Cross-Platform Stabilization & Discrepancy Resolution
- Android local Drift SQLite persistence verification.
- Web Drift Wasm/IndexedDB connection verification.
- Smoke test core features (Authentication, Feed, Studio, Hearts, Reactions).

### STMS-2.4 — Final QA, Documentation & Release Closure
- Generate `DEPLOYMENT_REPORT.md`, `DISCREPANCY_REGISTER.md`, `TEST_REPORT.md`, and `STMS-2_COMPLETION_REPORT.md`.
- Merge feature branch into `main`.
- Tag baseline release as `v-ST-MS2`.
