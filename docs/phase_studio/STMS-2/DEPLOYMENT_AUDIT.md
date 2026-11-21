# STMS-2 — Deployment & Repository Audit Report

**Date:** November 21, 2026  
**Sprint:** STMS-2 (Deployment, Stabilization & Release Readiness)  
**Target Branch:** `chore/stms-2-deployment-stabilization`  
**Baseline Release Tag:** `v-ST-MS1` (Commit: `159fba7`)  
**Previous Milestone:** `v-ST-ST1` (Commits: `9e96089`, `41c5440`)  

---

## 1. Executive Summary
The STMS-2.0 deployment and repository audit has been completed. The local workspace is fully intact with all ST-01 (Backend Draft API) and STMS-1 (Web Compatibility) implementations present and verified via local build and unit test suites. 

Empirical network inspection of the production backend (`syaahi-backend-sable.vercel.app`) confirmed that production is currently running deployment `dpl_FMQn6G7eYhTNrqMrbjwXkfFZq2o1` from **November 7, 2026**, which predates the ST-01 delivery (November 20, 2026). Consequently, requests to `/api/v1/studio/drafts` return `404 Not Found`.

The audit confirms that deploying the current backend codebase to Vercel will safely publish the ST-01 Draft API and Prisma `Draft` schema to production without breaking existing poem/user endpoints.

---

## 2. Component Baseline Verification

### 2.1 Backend (`syaahi-backend`)
- **Vercel Project ID:** `prj_arsN5ko30IsqtPwNgMDVc3Fv3yty`
- **Vercel Project Name:** `syaahi-backend`
- **Production URL:** `https://syaahi-backend-sable.vercel.app` (`syaahi-backend.vercel.app`)
- **Entry Point:** `src/api.ts` (configured correctly in `vercel.json`)
- **Prisma Schema:** `Draft` model present with fields `id`, `ownerId`, `title`, `content`, `language`, `emotion`, `theme`, `isPublished`, `version`, `createdAt`, `updatedAt`.
- **Migrations:** `20261120_add_draft_model` present locally.
- **TypeScript Build:** `npm run build` completed with Exit Code 0.
- **Studio Unit Tests:** `npm run test:studio` executed **14/14 tests PASSED**.
- **Live Endpoint Test:**
  - `GET /health` -> `200 OK`
  - `GET /api/v1/studio/drafts` -> `404 Not Found` (Proves ST-01 is missing in production).

### 2.2 Frontend (`syaahi-app`)
- **Target Platforms:** Android & Web (`build/web`)
- **API Base URL Configuration:** `SyaahiStrings.apiBaseUrl` = `https://syaahi-backend.vercel.app/api/v1`
- **Flutter Version Requirement:** SDK `^3.5.0`
- **Analyzer Status:** Passed (1 unused import in `app_router.dart` identified for cleanup).
- **Test Suite Status:** Executed **82/82 tests PASSED**.
- **Web Build:** `flutter build web --release` completed with Exit Code 0 (`build/web/index.html` generated, size 3.1MB JS bundle).

---

## 3. Discrepancies & Action Plan

| ID | Category | Discrepancy | Severity | Planned Fix Stage |
|---|---|---|---|---|
| DISC-01 | Backend | Production Vercel deployment predates ST-01; `/api/v1/studio/drafts` returns 404. | Critical | STMS-2.1 |
| DISC-02 | Frontend | Unused import warning in `lib/core/router/app_router.dart`. | Low | STMS-2.3 |

---

## 4. Execution Sequence
1. **STMS-2.1**: Deploy `syaahi-backend` to Vercel production -> Apply Prisma migrations -> Perform production Draft API integration verification.
2. **STMS-2.2**: Verify Flutter Web production API connectivity and browser persistence.
3. **STMS-2.3**: Address minor discrepancies, perform Android & Web cross-platform smoke tests.
4. **STMS-2.4**: Final QA, handover documentation, and `v-ST-MS2` release tagging.
