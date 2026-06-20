    # 🪶 Syaahi

> Where emotions become words.

A digital sanctuary for poetry, journals, letters, and emotional expression — built for writers, dreamers, and storytellers.

---

## 📍 Status

**Current Phase:** Phase 1 — Core Writing Platform
**Backend:** ✅ Complete (12 endpoints live)
**Frontend:** ⚪ Not started
**Version:** v0.1.0

See [PROGRESS.md](./PROGRESS.md) for the latest changelog.

---

## 📚 Documentation Map

| Document | Purpose |
|---|---|
| [VISION.md](./VISION.md) | Product vision and principles |
| [ROADMAP.md](./ROADMAP.md) | Phased delivery plan |
| [PROGRESS.md](./PROGRESS.md) | Living changelog (updated every session) |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | System design and tech stack |
| [API_CONTRACT.md](./API_CONTRACT.md) | REST API reference |
| [DECISIONS.md](./DECISIONS.md) | Architecture Decision Records (ADRs) |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Dev setup and conventions |

---

## 🚀 Quick Start (Backend)

```bash
cd syaahi-backend
npm install
cp .env.example .env   # then fill in your Supabase credentials
npx prisma generate
npx prisma db push
npm run dev
API runs at http://localhost:4000.

🧩 Repo Layout
text

syaahi/
├── syaahi-backend/   # Node.js + Express + Prisma + PostgreSQL
├── syaahi-app/       # Flutter (web + mobile) — coming soon
└── docs/             # All documentation
🛠 Tech Stack
Layer	Choice
Backend	Node.js, Express, TypeScript
Database	PostgreSQL (Supabase)
ORM	Prisma
Auth	JWT + bcrypt
Frontend	Flutter (planned)
📜 License
MIT