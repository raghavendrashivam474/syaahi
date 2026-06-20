
# 🪶 Syaahi — Contributing Guide

Welcome to Syaahi.

Before contributing, read `VISION.md` to understand what this
project is and what it is not.

Every contribution should serve the core question:

> "Does this help people express, preserve, or revisit emotions?"

---

## Getting Started

### Prerequisites

| Tool        | Version     |
|-------------|-------------|
| Node.js     | v20 or higher |
| npm         | v10 or higher |
| Flutter     | Latest stable |
| Git         | Any recent version |

---

### Backend Setup

```bash
# Clone the repository
git clone https://github.com/your-org/syaahi.git
cd syaahi/syaahi-backend

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Open .env and fill in all values

# Generate Prisma client
npm run prisma:generate

# Start development server
npm run dev
Server runs at http://localhost:4000

Flutter Setup
Bash

cd syaahi/syaahi-app

# Install dependencies
flutter pub get

# Run the app
flutter run -d chrome
Branch Strategy
Never commit directly to main.

All work happens on feature branches.

Bash

# Creating a branch
git checkout -b feature/journals
git checkout -b feature/deployment
git checkout -b fix/auth-session
git checkout -b docs/architecture
git checkout -b chore/env-cleanup
Branch naming:

Prefix	When to use
feature/	New feature work
fix/	Bug fixes
docs/	Documentation only
chore/	Config, tooling, cleanup
refactor/	Code changes with no behaviour change
Commit Messages
Syaahi uses Conventional Commits.

Bash

# Format
type: short description in present tense

# Examples
feat: add journal creation endpoint
fix: resolve token expiry handling in Flutter
docs: update architecture diagram
chore: add .env.example for backend
refactor: extract poem validation into schema file
test: add auth endpoint regression tests
Type	When to use
feat	New feature
fix	Bug fix
docs	Documentation changes
chore	Tooling, config, dependencies
refactor	Code restructure, no behaviour change
test	Adding or updating tests
style	Formatting only, no logic change
Rules:

Use present tense: add not added
Keep the first line under 72 characters
No full stop at the end
Be specific: fix: resolve JWT expiry on Flutter session recovery
not fix: bug fix
Code Standards
Backend
One file, one purpose.

text

auth.routes.ts      → Route definitions only
auth.controller.ts  → Business logic only
auth.schemas.ts     → Zod validation schemas only
Never trust client input.

Every request body must be parsed through a Zod schema
before any value is accessed.

TypeScript

// Correct
const data = signupSchema.parse(req.body);

// Never do this
const { email } = req.body;
Use asyncHandler for all async routes.

TypeScript

// Correct
router.post('/signup', asyncHandler(signup));

// Never do this
router.post('/signup', async (req, res) => { ... });
Throw ApiError for all expected error cases.

TypeScript

// Correct
throw new ApiError(404, 'User not found');

// Never do this
res.status(404).json({ message: 'User not found' });
Flutter
UI never calls the API directly.

text

Screen → Provider → Repository → Dio → API
One file, one purpose.

text

login_screen.dart     → UI only
auth_provider.dart    → State only
auth_repository.dart  → API calls only
All API calls live in the repository layer.

Adding a New Feature
Backend
Create a new folder under src/modules/feature-name/
Create feature.schemas.ts with Zod validation
Create feature.controller.ts with business logic
Create feature.routes.ts with route definitions
Register routes in src/app.ts
Update API_CONTRACT.md with new endpoints
Update docs/PROGRESS.md
Flutter
Create a new folder under lib/features/feature-name/
Create data/ with repository
Create state/ with Riverpod providers
Create presentation/ with screens
Register routes in go_router config
Update docs/PROGRESS.md
Environment Variables
When adding a new environment variable:

Add it to the Zod schema in src/config/env.ts
Add it to .env.example with a description
Add it to the Environment Variables table in README.md
Set it in Railway dashboard before deploying
Never commit a filled .env file.
Never hardcode a secret in source code even temporarily.

Definition of Done
A feature is complete only when:

text

✓ Implemented
✓ Input validated (Zod on backend, form validation on Flutter)
✓ Error cases handled
✓ Tested (at minimum, manually verified end-to-end)
✓ Documented (PROGRESS.md updated, API_CONTRACT.md updated if needed)
✓ Committed with proper commit message
✓ Works on staging, not just locally
Code that only works locally is not done.

What Requires Approval
You do not need approval for:

Observations and findings
Documentation updates
Bug fixes
Refactoring within existing modules
You do need approval before:

Adding a new dependency
Changing the database schema
Adding a new feature not in the roadmap
Any infrastructure spending
Any architectural change
When in doubt, open a discussion before writing code.

Questions
If something is unclear, check in this order:

docs/ARCHITECTURE.md — how the system is structured
docs/DECISIONS.md — why things were built this way
docs/ROADMAP.md — what is planned and what is not
docs/VISION.md — what Syaahi is and is not
Ask the founder
Build carefully. Document thoroughly. Protect simplicity.