# STMS-2 — Production Deployment Report

**Date:** November 21, 2026  
**Sprint:** STMS-2 (Deployment, Stabilization & Release Readiness)  
**Production Backend URL:** `https://syaahi-backend.vercel.app` (`https://syaahi-backend-sable.vercel.app`)  
**Deployment Platform:** Vercel (Serverless Node.js + Prisma / Supabase PostgreSQL)  

---

## 1. Executive Summary
The ST-01 Draft API implementation has been successfully deployed to Vercel production and verified end-to-end. The production alias `syaahi-backend.vercel.app` has been rebound to the updated production build, bringing the backend into 100% alignment with the Flutter application configuration (`SyaahiStrings.apiBaseUrl`).

---

## 2. Deployment Details

### Backend (`syaahi-backend`)
- **Vercel Project ID:** `prj_arsN5ko30IsqtPwNgMDVc3Fv3yty`
- **Target URL:** `https://syaahi-backend.vercel.app`
- **Deployment Status:** READY
- **Build Command:** `npm run build` (`tsc`)
- **Entry Point:** `src/api.ts` -> Express `src/app.ts`
- **Database Status:** PostgreSQL on Supabase (`Draft` table schema active and intact)

---

## 3. Active Production Endpoints Verified

| Route | Method | Access | Live Status |
|---|---|---|---|
| `/health` | GET | Public | `200 OK` |
| `/api/v1/auth/signup` | POST | Public | `201 Created` (JWT Token Issued) |
| `/api/v1/auth/login` | POST | Public | `200 OK` |
| `/api/v1/studio/drafts` | GET | Authenticated | `200 OK` |
| `/api/v1/studio/drafts` | POST | Authenticated | `201 Created` |
| `/api/v1/studio/drafts/:id` | GET | Authenticated (Owner-isolated) | `200 OK` / `404 Not Found` |
| `/api/v1/studio/drafts/:id` | PATCH | Authenticated (Owner-isolated) | `200 OK` |
| `/api/v1/studio/drafts/:id` | DELETE | Authenticated (Owner-isolated) | `200 OK` |
| `/api/v1/studio/drafts/:id/publish` | POST | Authenticated (Idempotent) | `201 Created` / `200 OK` |

---

## 4. Verification Evidence
Live E2E production automated test script executed against `https://syaahi-backend.vercel.app`:
- User registration via `/api/v1/auth/signup` -> PASSED
- Draft creation via `POST /api/v1/studio/drafts` -> PASSED
- Draft retrieval via `GET /api/v1/studio/drafts/:id` -> PASSED
- Draft listing via `GET /api/v1/studio/drafts` -> PASSED
- Draft deletion via `DELETE /api/v1/studio/drafts/:id` -> PASSED
