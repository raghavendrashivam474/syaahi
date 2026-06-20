# 🪶 Syaahi Backend

Backend API for **Syaahi** — *Where emotions become words.*

A Node.js + Express + TypeScript service backed by PostgreSQL (Supabase) and Prisma. Powers user accounts, poem publishing, profiles, and emotional discovery.

---

## 📍 Status

**Phase:** 1 — Core Writing Platform
**Version:** v0.1.0
**State:** ✅ Backend complete, verified end-to-end

| Module | Endpoints | Status |
|---|---|---|
| Auth | 4 | ✅ Verified |
| Users | 3 | ✅ Verified |
| Poems | 5 | ✅ Verified |
| Health | 2 | ✅ Verified |

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Runtime | Node.js v20+ |
| Language | TypeScript 5 (strict) |
| Framework | Express 4 |
| ORM | Prisma 6 |
| Database | PostgreSQL (Supabase) |
| Auth | JWT (HS256) + bcrypt |
| Validation | Zod |
| Security | helmet, cors, express-rate-limit |

---

## 🚀 Quick Start

### Prerequisites
- Node.js v20 or higher
- A free [Supabase](https://supabase.com) project

### Setup

```bash
# 1. Install dependencies
npm install

# 2. Copy environment template
cp .env.example .env

# 3. Fill in your Supabase credentials (see below)

# 4. Generate Prisma client
npx prisma generate

# 5. Push schema to your database
npx prisma db push

# 6. Start the dev server
npm run dev
API runs at http://localhost:4000.

🔐 Environment Variables
Create a .env file in the project root:

env

# Server
NODE_ENV=development
PORT=4000

# Database (from Supabase → Settings → Database → ORMs → Prisma)
DATABASE_URL="postgres://postgres.xxxxx:PASSWORD@aws-0-region.pooler.supabase.com:6543/postgres?pgbouncer=true"
DIRECT_URL="postgres://postgres.xxxxx:PASSWORD@aws-0-region.pooler.supabase.com:5432/postgres"

# Supabase (from Project Settings → API)
SUPABASE_URL="https://xxxx.supabase.co"
SUPABASE_ANON_KEY="eyJhbGc..."
SUPABASE_SERVICE_ROLE_KEY="eyJhbGc..."

# JWT — must be 32+ random characters
JWT_SECRET="generate-a-strong-random-secret-min-32-chars"
JWT_EXPIRES_IN="7d"

# CORS
CORS_ORIGIN="http://localhost:3000,http://localhost:5000"
⚠️ Never commit .env — it's in .gitignore. Use .env.example as the template.

Generate a strong JWT_SECRET (PowerShell):

PowerShell

-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 48 | ForEach-Object {[char]$_})
📡 API Endpoints
Base URL: http://localhost:4000/api/v1

Health
Method	Path	Auth
GET	/	—
GET	/health	—
Auth
Method	Path	Auth	Body
POST	/auth/signup	—	{ email, username, displayName, password }
POST	/auth/login	—	{ email, password }
GET	/auth/me	✅	—
POST	/auth/logout	✅	—
Users
Method	Path	Auth	Notes
GET	/users/:username	—	Public profile
GET	/users/:username/poems	—	?cursor&limit
PATCH	/users/me	✅	{ displayName?, bio?, avatarUrl? }
Poems
Method	Path	Auth	Notes
GET	/poems	—	?emotion&language&theme&cursor&limit
GET	/poems/:id	—	—
POST	/poems	✅	{ title?, content, language, emotion?, theme? }
PATCH	/poems/:id	✅ owner	Any field subset
DELETE	/poems/:id	✅ owner	—
Enums
language: ENGLISH | HINDI | URDU
emotion: LOVE | LONGING | HOPE | SOLITUDE | ANGER | GRATITUDE
Response Envelope
JSON

// Success
{ "success": true, "data": { ... } }

// Error
{ "success": false, "message": "...", "errors": { ... } }
Status Codes
Code	Meaning
200 / 201	Success
400	Validation error
401	Authentication required
403	Forbidden (not owner)
404	Not found
409	Conflict (duplicate)
429	Rate limited
500	Server error
🧪 Testing
End-to-end tests are run manually via PowerShell scripts in scripts/.

Full happy-path test
PowerShell

.\scripts\test-phase1.ps1   # signup → login → /me → create poem → list → get
Error case verification
PowerShell

.\scripts\test-errors.ps1   # 13 error scenarios (validation, auth, ownership, 404, 429)
Database inspection
PowerShell

npx prisma studio              # Visual: http://localhost:5555
npx tsx scripts/verify-db.ts   # Scripted: counts, FK integrity, password hash check
Automated tests (Vitest + Supertest) planned post-MVP.

📝 Quick API Examples (PowerShell)
Sign up
PowerShell

$body = @{
  email = "kavya@syaahi.com"
  username = "kavya"
  displayName = "Kavya Sharma"
  password = "MyStrongPass123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:4000/api/v1/auth/signup" `
  -Method Post -Body $body -ContentType "application/json"
Login and store token
PowerShell

$login = Invoke-RestMethod -Uri "http://localhost:4000/api/v1/auth/login" `
  -Method Post `
  -Body (@{ email = "kavya@syaahi.com"; password = "MyStrongPass123" } | ConvertTo-Json) `
  -ContentType "application/json"

$token = $login.data.token
Create a poem
PowerShell

$poem = @{
  title = "Khamoshi"
  content = "Kuch khamoshiyan lafz ban jaati hain..."
  language = "HINDI"
  emotion = "LONGING"
  theme = "Monsoon"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:4000/api/v1/poems" `
  -Method Post -Body $poem -ContentType "application/json" `
  -Headers @{ Authorization = "Bearer $token" }
List poems
PowerShell

Invoke-RestMethod -Uri "http://localhost:4000/api/v1/poems"
🛡️ Rate Limits (per IP)
Endpoint	Limit
POST /auth/signup	5 / hour
POST /auth/login	10 / 15 min
POST /poems	30 / hour
Global (/api/*)	300 / 15 min
Storage: in-memory (single-instance MVP). Will move to Redis when horizontally scaling.

🏗️ Project Structure
syaahi-backend/
├── prisma/
│   └── schema.prisma          # Database schema (source of truth)
├── scripts/
│   ├── verify-db.ts           # DB integrity checker
│   └── test-errors.ps1        # Error case verifier
├── src/
│   ├── config/
│   │   ├── env.ts             # Zod-validated env loader
│   │   └── prisma.ts          # Singleton Prisma client
│   ├── middleware/
│   │   ├── auth.ts            # JWT verification
│   │   ├── errorHandler.ts    # Central error formatter
│   │   └── rateLimiter.ts     # Rate limit policies
│   ├── modules/               # Feature-sliced modules
│   │   ├── auth/
│   │   ├── poems/
│   │   └── users/
│   ├── utils/
│   │   ├── ApiError.ts
│   │   └── asyncHandler.ts
│   ├── app.ts                 # Express app composition
│   └── server.ts              # Process lifecycle
├── .env                       # Local secrets (gitignored)
├── .env.example               # Template (committed)
├── package.json
└── tsconfig.json

Bash

npm run dev               # Start dev server with hot reload
npm run build             # Compile TypeScript to dist/
npm start                 # Run production build

npm run prisma:generate   # Generate Prisma client after schema change
npm run prisma:push       # Push schema to DB (no migration history)
npm run prisma:migrate    # Create + apply a named migration
npm run prisma:studio     # Open visual DB browser
🚧 What's Next
Flutter client (Phase 1 frontend)
Deployment (Railway / Render)
Automated test suite (Vitest + Supertest)
Monitoring (Sentry, Better Stack)
See ../docs/ROADMAP.md (when docs are added) for full plan.

📜 License
MIT