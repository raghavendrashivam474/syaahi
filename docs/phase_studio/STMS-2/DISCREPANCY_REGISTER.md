# STMS-2 — Discrepancy Register

**Sprint:** STMS-2  
**Date:** November 21, 2026  

---

| ID | Module | Issue Discovered | Severity | Resolution Status | Action Taken |
|---|---|---|---|---|---|
| DISC-01 | Backend | Production Vercel deployment predated ST-01 delivery (deployed Nov 7 vs ST-01 delivered Nov 20). Endpoint `/api/v1/studio/drafts` returned 404. | Critical | Resolved | Deployed updated backend to Vercel via `vercel --prod` and re-assigned `syaahi-backend.vercel.app` alias. |
| DISC-02 | Backend Build | `npm run build` failed due to TypeScript test files (`src/__tests__/*.ts`) being included in `tsc` compilation. | High | Resolved | Added `"src/__tests__/**/*"` and `"**/*.test.ts"` to `exclude` array in `syaahi-backend/tsconfig.json`. |
| DISC-03 | Backend Auth | Auth routes (`/signup`, `/login`, `/me`) were defined in `src/modules/auth/auth.routes.ts` but not mounted in Express `src/app.ts`. | High | Resolved | Added `app.use('/api/v1/auth', authRoutes);` in `src/app.ts`. |
| DISC-04 | Frontend Analysis | Unused import warnings in `lib/core/router/app_router.dart` for `studio_home_screen.dart` and `studio_editor_screen.dart`. | Low | Resolved | Removed unused import statements from `app_router.dart`. Static analyzer warnings resolved. |
