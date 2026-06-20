# 🪶 Syaahi

> Where emotions become words.

Syaahi is a platform for poetry, letters, journals, and memory preservation.

It is not a social media platform.
It is a calm digital space where people can write, reflect, revisit memories,
and connect through meaningful words.

---

## What is Syaahi?

Most digital platforms reward performance over expression.

Syaahi is different.

- Write a poem today
- Journal tomorrow
- Send an anonymous letter at midnight
- Seal a time capsule for your future self
- Come back years later and rediscover your own words

The most meaningful feature of Syaahi is not what you write today.
It is the moment, years from now, when you read what you wrote
and remember exactly who you were.

---

## Current Status

**v0.2.0 — MVP Complete**

| Feature              | Status        |
|----------------------|---------------|
| User Registration    | ✅ Complete   |
| Login / Session      | ✅ Complete   |
| Poem Feed            | ✅ Complete   |
| Poem Reader          | ✅ Complete   |
| Poem Writer          | ✅ Complete   |
| Journals             | 🔜 Sprint 3   |
| Personal Archive     | 🔜 Planned    |
| Letters After Midnight | 🔜 Planned  |
| Time Capsules        | 🔜 Planned    |
| Community Circles    | 🔜 Planned    |

---

## Repository Structure

```text
syaahi/
├── syaahi-backend/          # Express.js API
├── syaahi-app/              # Flutter application
├── docs/                    # Project documentation
│   ├── ARCHITECTURE.md      # System design
│   ├── ROADMAP.md           # Feature roadmap
│   ├── DECISIONS.md         # Architecture decision records
│   ├── PROGRESS.md          # Engineering diary
│   ├── VISION.md            # Product vision
│   └── CONTRIBUTING.md      # Contribution guide
├── README.md                # This file
└── LICENSE
Tech Stack
Backend

Layer	Technology
Runtime	Node.js v20+
Framework	Express.js v5
Language	TypeScript
ORM	Prisma
Database	PostgreSQL (Supabase)
Authentication	JWT
Validation	Zod
Frontend

Layer	Technology
Framework	Flutter
Language	Dart
State Management	Riverpod
Navigation	go_router
HTTP Client	Dio
Secure Storage	flutter_secure_storage
Getting Started
Backend
Bash

cd syaahi-backend
npm install
cp .env.example .env
# Fill in .env values
npm run prisma:generate
npm run dev
Runs at http://localhost:4000

Full setup guide: syaahi-backend/README.md

Flutter App
Bash

cd syaahi-app
flutter pub get
flutter run -d chrome
Full setup guide: syaahi-app/README.md

Documentation
Document	Description
docs/ARCHITECTURE.md	System design and data flow
docs/ROADMAP.md	Planned features by phase
docs/DECISIONS.md	Why things were built this way
docs/PROGRESS.md	Engineering diary
docs/VISION.md	Product vision and principles
docs/CONTRIBUTING.md	How to contribute
syaahi-backend/API_CONTRACT.md	API endpoint reference
Guiding Principle
Before any feature is built, ask:

"Does this help people express, preserve, or revisit emotions?"

If the answer is no, it does not belong in Syaahi.

License
MIT — see LICENSE

Built with coffee, midnight thoughts, and a love for words.
— Raghavendra Singh