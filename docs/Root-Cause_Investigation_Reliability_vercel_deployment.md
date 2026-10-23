# Technical Incident Post-Mortem & System Audit Report

**To:** Senior Engineering Team  
**From:** Root-Cause Investigation & Reliability  
**System:** Syaahi Backend API (`syaahi-backend`)  
**Status:** **RELOADED & FULLY RESTORED (Production Live)**  
**Canonical Endpoint:** `https://syaahi-backend.vercel.app`  

---

## 1. Executive Summary & Hypothesis Verdict

The backend experienced a critical outage where `GET /api/v1/poems` repeatedly returned `HTTP 500 Internal Server Error`, despite `/health` returning `200 OK`. 

### The Notification Hypothesis: DISPROVED
The primary initial suspicion was that notification development (Phases N1–N4) introduced regressions into shared database models or request pipelines. 
* **Finding:** Notification code (`createPublicationNotifications`, notification routes, schemas, and models) was completely clean, defensive (using `try/catch` and `skipDuplicates`), and well-tested.
* **Actual Trigger:** The failure occurred **after** the notification sprints during post-feature structural re-organization and speculative database connection fixes.

### The Real Root Causes
The outage was caused by a combination of four distinct failure boundaries across infrastructure, database proxying, application middleware, and deployment configuration:

1. **Database Layer:** Supabase transaction-mode PgBouncer pooler crashing on Prisma prepared statements (`PostgresError 42P05`).
2. **Infrastructure Layer:** Deletion of `vercel.json` leading to cached Vercel framework auto-detection (serving Next.js HTML error pages instead of executing Express).
3. **Application Layer:** Flawed CORS handling in `src/app.ts` that threw unhandled JavaScript `Error` exceptions on preflight `OPTIONS` requests when configured with wildcard (`*`) origins.
4. **Platform Security Layer:** Auto-enabled Vercel Standard Authentication blocking native mobile app HTTP requests.

---

## 2. Deep Dive: Root Causes & Technical Breakdown

### Defect 1: Postgres 42P05 (`prepared statement "s0" already exists`)
* **Symptom:** `GET /api/v1/poems` failed with `HTTP 500`, while `prisma.poem.count()` succeeded locally.
* **Root Cause:** Syaahi uses Supabase with PgBouncer connection pooling operating in **Transaction Mode** on port `6543`.
  * Prisma Client, by default, uses server-side prepared statements (`s0`, `s1`, etc.) to optimize query execution.
  * In PgBouncer Transaction Mode, physical database connections are reassigned to different client requests between transactions.
  * When a second query was executed on a reused pooled connection, Postgres threw error `42P05` because a prepared statement named `s0` had already been prepared on that physical connection by a previous transaction.
  * Simple queries (`count()`) masked this issue, but `listPoems` executes a complex query featuring subqueries and `_count` aggregations (reactions and hearts), triggering immediate prepared-statement name collisions.
* **Fix:** Updated the production `DATABASE_URL` string to include explicit PgBouncer parameters:
  ```text
  postgresql://postgres.[ref]:[pass]@aws-1-ap-northeast-1.pooler.supabase.com:6543/postgres?pgbouncer=true&connection_limit=1
  ```
  The `?pgbouncer=true` parameter forces Prisma Engine to bypass server-side prepared statements and send parameterized queries directly, eliminating `42P05` errors.

---

### Defect 2: Deletion of `vercel.json` & Framework Detection Hijack
* **Symptom:** API endpoints began returning `HTTP 200` with `Content-Type: text/html` containing Next.js SPA HTML boilerplate instead of JSON API responses.
* **Root Cause:** Commit `6a43a21` ("Clean project structure") deleted `vercel.json`. 
  * Without `vercel.json`, Vercel attempted auto-detection on the monorepo root.
  * It incorrectly identified the project as a Next.js application, cached the builder pipeline, and routed incoming traffic to a non-existent frontend render tree rather than executing `src/api.ts` through `@vercel/node`.
* **Fix:** 
  1. Re-created `vercel.json` explicitly configuring `@vercel/node` for `src/api.ts`:
     ```json
     {
       "version": 2,
       "builds": [{ "src": "src/api.ts", "use": "@vercel/node" }],
       "routes": [{ "src": "/(.*)", "dest": "src/api.ts" }]
     }
     ```
  2. Because Vercel cached the framework preset at the project level, re-creating the file on the existing project was ignored. We purged the stale project configuration, initialized a clean Vercel deployment target (`syaahi-backend-sable`), and re-aliased the canonical domain `syaahi-backend.vercel.app` to it.

---

### Defect 3: CORS Middleware Preflight Unhandled Exception
* **Symptom:** Mobile app sign-in failed on `POST /api/v1/auth/login` with "Something went wrong". Terminal tests revealed `OPTIONS` preflight requests returned `HTTP 500`.
* **Root Cause:** In `src/app.ts`, the custom CORS origin evaluation logic was implemented as:
  ```typescript
  // OLD BROKEN CODE
  const allowed = env.CORS_ORIGIN.split(',').map((o) => o.trim());
  if (allowed.includes(origin)) {
    return callback(null, true);
  }
  callback(new Error('CORS: origin ' + origin + ' not allowed'));
  ```
  * When `CORS_ORIGIN="*"` was set in environment variables, `allowed` evaluated to `["*"]`.
  * When a mobile native app or local client made a request sending `Origin: http://localhost`, `["*"].includes("http://localhost")` evaluated to `false`.
  * Passing `new Error(...)` into `cors()` callback forced Express to treat origin mismatches as unhandled internal server errors, triggering `errorHandler.ts` and returning `HTTP 500` instead of a standard `HTTP 204` / `HTTP 403` CORS refusal.
* **Fix:** Refactored `src/app.ts` to properly handle wildcard matching and return clean standard CORS callbacks:
  ```typescript
  // FIXED CODE
  cors({
    origin: (origin, callback) => {
      if (!origin) return callback(null, true);
      const allowed = env.CORS_ORIGIN.split(',').map((o) => o.trim());

      if (allowed.includes('*') || allowed.includes(origin)) {
        return callback(null, true);
      }
      if (env.NODE_ENV === 'development' && origin.startsWith('http://localhost')) {
        return callback(null, true);
      }
      callback(null, false); // Clean refusal without throwing an Error
    },
    credentials: true,
  })
  ```

---

### Defect 4: Vercel Standard Deployment Protection
* **Symptom:** Mobile app displayed "Protected by Vercel Authentication" upon submitting sign-in credentials.
* **Root Cause:** When the fresh Vercel project was instantiated, Vercel default security settings applied **Deployment Protection (Standard Vercel Authentication)**. This placed an interactive SSO/cookie wall in front of all HTTP routes, blocking non-browser clients (Flutter/React Native mobile apps).
* **Fix:** Disabled Vercel Authentication in Project Settings → Deployment Protection.

---

## 3. Timeline of Debugging & Failed Fix Attempts

To ensure full transparency, here is the chronological log of what was attempted during the investigation, what failed, and why:

| Attempt | Change Made | Outcome | Reason for Failure |
|---|---|---|---|
| **Attempt 1** | Explicitly passed `datasources.db.url` in `src/config/prisma.ts` | **Failed** | Did not address PgBouncer statement preparation; masked env-var loading. |
| **Attempt 2** | Removed `directUrl` fallback from `schema.prisma` | **Failed** | `directUrl` is required by Supabase for migrations on port `5432`; removing it broke schema sync. |
| **Attempt 3** | Editing `.env` directly via script | **Failed** | PowerShell `Set-Content -Encoding UTF8` inserted a Byte Order Mark (BOM: `0xEF, 0xBB, 0xBF`), rendering `vercel.json` and `.env` unparseable by Vercel's CLI. |
| **Attempt 4** | Pushing `vercel.json` to existing Vercel project | **Failed** | Vercel had locked the framework preset to Next.js in project settings; ignored builder configs in `vercel.json`. |
| **Attempt 5** | Setting `CORS_ORIGIN=*` in Vercel environment variables | **Failed** | Exposed the flaw in `app.ts` array matching (`["*"].includes(origin)`), escalating CORS preflights to `HTTP 500`. |
| **Attempt 6 (Final)** | **1.** Added `?pgbouncer=true` to `DATABASE_URL`.<br>**2.** Patched `src/app.ts` CORS wildcard matching.<br>**3.** Recreated clean Vercel project without BOM.<br>**4.** Disabled Vercel Deployment Protection. | **SUCCESS** | **All API endpoints, CORS preflights, and mobile authentication flows fully functional.** |

---

## 4. Current Architecture & Final State

```
[ Mobile App / Frontend ]
          │
          │ HTTPS (Cross-Origin requests)
          ▼
[ Vercel Edge Serverless Engine ]
          │
          │ Evaluates vercel.json -> src/api.ts
          ▼
[ Express Application (src/app.ts) ]
          │
          ├──> Helmet / Morgan / Global Limiter
          ├──> CORS Middleware (Wildcard '*' safe, clean 204 preflight)
          │
          ▼
[ Modules Router (/api/v1/*) ]
          ├──> /auth  ──> auth.controller.ts (bcrypt + JWT)
          ├──> /poems ──> poems.controller.ts (syaahiFlow sequencing)
          └──> /notifications ──> notifications.controller.ts
          │
          ▼
[ Prisma Client (v6.19.3) ]
          │
          │ pgbouncer=true (Prepared statements disabled)
          ▼
[ Supabase PgBouncer Pooler (Port 6543) ]
          │
          ▼
[ PostgreSQL Primary Database ]
```

---

## 5. Production Verification Evidence

The system was verified live in production following deployment:

1. **System Health Check (`GET /health`):**
   * Response: `HTTP 200 OK`
   * Body: `{"status":"healthy","timestamp":"2026-10-23T19:10:08.571Z"}`

2. **Poem Feed Retrieval (`GET /api/v1/poems?limit=2`):**
   * Response: `HTTP 200 OK`
   * Payload: Successfully fetched and sequenced 2 poems via `syaahiFlow` engine. Includes `_count` aggregations for reactions and hearts without triggering database exceptions.

3. **CORS Options Preflight (`OPTIONS /api/v1/auth/login`):**
   * Request Headers: `Origin: http://localhost`, `Access-Control-Request-Method: POST`
   * Response: `HTTP 204 No Content`
   * Response Headers: `Access-Control-Allow-Origin: http://localhost`

4. **Mobile Authentication (`POST /api/v1/auth/login`):**
   * User: `avyakta@syaaahi.com`
   * Response: `HTTP 200 OK` with valid signed JWT token payload. Mobile app successfully authenticates and enters main feed view.

---

## 6. Action Items & Prevention Plan

### Immediate Action Required
* Ensure all developers pull the latest `main` branch (`commit bc74b15` or later).
* Do **not** manually override `datasources` in `src/config/prisma.ts`.

### Engineering Best Practices Going Forward
1. **Connection Strings for Serverless + Supabase:** Always ensure `DATABASE_URL` targeting PgBouncer (port `6543`) includes `?pgbouncer=true&connection_limit=1`. Use `DIRECT_URL` (port `5432`) exclusively for Prisma CLI migrations.
2. **UTF-8 Encoding Safety on Windows:** Avoid standard PowerShell `Set-Content` for JSON/config files as it injects UTF-8 BOM headers. Use `[System.IO.File]::WriteAllText()` with UTF8 Encoding (`$false` for BOM) or standard Node.js scripts.
3. **CORS Middleware Rules:** Never throw JavaScript `Error` instances inside standard Express route/middleware callbacks unless intending to invoke the 500 error boundary. Return explicit status codes or boolean callbacks.