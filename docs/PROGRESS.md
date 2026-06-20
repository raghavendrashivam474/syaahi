# 🪶 Syaahi — Progress Log

This is the engineering diary for Syaahi.
Updated at the end of every meaningful development session.

Format:

```text
## [Date] — [Short Title]
- What was done
- What was decided
- What is next
2026-06 — Foundation (v0.1.0)
Backend
Initialised Node.js + Express.js + TypeScript project
Configured Prisma ORM with Supabase PostgreSQL
Designed initial database schema
Set up environment validation using Zod
Created modular folder structure (config, middleware, modules, utils)
Added health check endpoint
Added helmet, cors, morgan middleware
Created ApiError utility class
Created asyncHandler utility
Decisions Made
Feature-based architecture chosen
Prisma selected as ORM
Zod selected for validation
Supabase selected for PostgreSQL hosting
2026-06 — MVP (v0.2.0)
Backend
Implemented authentication module
Signup with email, username, displayName, password
Login with JWT response
Logout (client-side token discard)
/me endpoint for session recovery
bcrypt password hashing (12 rounds)
JWT signing and verification
Implemented poems module
Create poem (authenticated)
Get poem by ID
Get poem feed
Author data joined on feed and detail
Implemented users module
Get user profile by username
Added rate limiting
Global limiter on all API routes
Stricter limiter on signup and login
Added request validation via Zod schemas on all endpoints
Flutter
Project initialised with Riverpod, Dio, go_router, flutter_secure_storage
Feature-based folder structure implemented
Auth feature implemented
Login screen
Signup screen
Session recovery on app launch
JWT stored in flutter_secure_storage
Poems feature implemented
Feed screen
Poem reader screen
Poem writer screen
Repository pattern implemented across all features
Decisions Made
JWT authentication chosen over session-based auth
Flutter Web chosen as MVP frontend target
express-rate-limit chosen for abuse prevention
Known Gaps at v0.2.0
No refresh token implementation
No email verification on signup
No poem deletion
No profile update endpoint
No pagination on poem feed
No loading states in Flutter feed screen
No empty state UI in Flutter
Token revocation not implemented
These are documented and accepted trade-offs for MVP stage.

Current Focus — v0.3.0 Stability and Deployment
Documentation Sprint
 Backend README updated
 ARCHITECTURE.md created
 ROADMAP.md created
 DECISIONS.md created
 PROGRESS.md created
 VISION.md created
 CONTRIBUTING.md created
 Root README.md updated
 .env.example completed
Deployment Sprint (after documentation)
 Backend deployed to Railway
 Frontend deployed to Vercel
 Environment variables configured on Railway
 CORS updated with Vercel URL
 End-to-end flow verified on staging
 v0.3.0 tagged on GitHub
Upcoming — v0.4.0 Journals
Not started.

Planned scope:

Create journal entry
Edit journal entry
Archive journal entry
Search journal entries
Private by default
Will begin after v0.3.0 deployment is verified.

Engineering Notes
Things to address before production
Issue	Priority	Notes
Refresh token implementation	High	Users must re-login on token expiry
Email verification on signup	High	Any email can be registered currently
CORS wildcard	High	Replace with FRONTEND_URL
Poem feed pagination	Medium	No pagination, returns all poems
Poem deletion	Medium	No way to delete a poem currently
Profile update endpoint	Medium	Users cannot edit their profile
Redis-backed rate limiting	Low	In-memory resets on server restart
Token blacklist for logout	Low	True logout requires Redis
Things that are intentionally deferred
Feature	Reason
Followers and following	Outside current product vision
Like counts	Optimises for validation not depth
Trending feed	Engagement loop, not aligned with vision
AI-generated poetry	Contradicts human expression core value
Monetisation	Premature