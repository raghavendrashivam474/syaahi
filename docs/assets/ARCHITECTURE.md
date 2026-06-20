# Syaahi — Architecture

## High-Level
[Flutter Client] → [Express API] → [PostgreSQL (Supabase)]
↓
[JWT auth]

text


## Backend Architecture Principles

1. **Feature-sliced modules** — each domain owns its routes, controller, schemas
2. **Validation at the edge** — Zod schemas on every endpoint
3. **Errors are values** — `ApiError` class + central handler, no try/catch in controllers
4. **Singleton Prisma client** — survives hot reload
5. **Fail-fast env** — Zod-validated at boot; bad config = no boot

## Folder Layout
syaahi-backend/
├── prisma/
│ └── schema.prisma
├── src/
│ ├── config/ # env, prisma singleton
│ ├── middleware/ # auth, errorHandler, rateLimiter
│ ├── modules/
│ │ ├── auth/ # signup, login, me, logout
│ │ ├── poems/ # CRUD
│ │ └── users/ # profile
│ ├── utils/ # ApiError, asyncHandler
│ ├── app.ts
│ └── server.ts
└── .env

text


## Data Model (Current)

- **User** — id, email, username, passwordHash, displayName, bio, avatarUrl
- **Poem** — id, authorId, title, content, language, emotion, theme, isPublished
- **Reaction** *(schema only, not used yet)* — userId, poemId, type
- **Follow** *(schema only)* — followerId, followingId
- **Room / RoomMember / PoemRoom** *(schema only)*

### Enums
- `Language`: ENGLISH, HINDI, URDU
- `Emotion`: LOVE, LONGING, HOPE, SOLITUDE, ANGER, GRATITUDE
- `ReactionType`: FELT_THIS, STAYED_WITH_ME, BEAUTIFUL_IMAGERY, MADE_ME_THINK

## Security

| Concern | Status |
|---|---|
| Password hashing | bcrypt cost 12 ✅ |
| JWT signing | HS256, 48-char secret ✅ |
| Input validation | Zod on every endpoint ✅ |
| SQL injection | Prisma parameterized ✅ |
| Rate limiting | express-rate-limit ✅ |
| CORS allowlist | ✅ |
| Helmet headers | ✅ |
| Refresh tokens | ❌ deferred |
| Email verification | ❌ deferred |
| 2FA | ❌ deferred |

## Frontend (Planned)

- **Framework:** Flutter (web first, mobile later)
- **State:** Riverpod
- **Routing:** go_router
- **HTTP:** Dio (auth interceptor)
- **Storage:** flutter_secure_storage (JWT)
- **Theme:** Dark Midnight Blue + Gold
- **Fonts:** Cormorant Garamond (poetry), Inter (UI)

## Deployment (Planned)

- **Backend:** Railway or Render
- **DB:** Supabase (already hosted)
- **Frontend:** Vercel (web) / TestFlight + Play Internal (mobile)
- **Monitoring:** Sentry (post-MVP)
