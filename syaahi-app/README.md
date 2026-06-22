# 🪶 Syaahi — App

Flutter frontend for **Syaahi**, a platform for poetry, journals, letters, memory preservation, and human expression.

> Where emotions become words.

---

# Current Status

**Version:** v0.2.2

**Status:** MVP Complete • Documentation Complete • Locally Verified

---

## Available Features

| Feature             | Status     |
| ------------------- | ---------- |
| Splash Screen       | ✅          |
| Welcome Screen      | ✅          |
| Authentication      | ✅          |
| Session Persistence | ✅          |
| Poem Feed           | ✅          |
| Poem Reader         | ✅          |
| Poem Writer         | ✅          |
| Cursor Pagination   | ✅          |
| Infinite Scroll     | ✅          |
| Pull To Refresh     | ✅          |
| User Profiles       | ✅ Basic    |
| Journals            | 🔜 Planned |

---

# Tech Stack

| Layer            | Technology             |
| ---------------- | ---------------------- |
| Framework        | Flutter Web            |
| Language         | Dart                   |
| State Management | Riverpod               |
| Navigation       | go_router              |
| HTTP Client      | Dio                    |
| Secure Storage   | flutter_secure_storage |
| Typography       | google_fonts           |

---

# Project Structure

```text
syaahi-app/
└── lib/
    ├── core/
    │   ├── constants/
    │   ├── network/
    │   ├── router/
    │   ├── storage/
    │   └── theme/
    │
    ├── features/
    │   ├── splash/
    │   ├── welcome/
    │   ├── auth/
    │   │   ├── data/
    │   │   ├── state/
    │   │   └── presentation/
    │   │
    │   ├── poems/
    │   │   ├── data/
    │   │   ├── state/
    │   │   └── presentation/
    │   │
    │   └── home/
    │
    ├── shared/
    │   ├── models/
    │   └── widgets/
    │
    └── main.dart
```

---

# Getting Started

## Prerequisites

Required:

* Flutter SDK (Stable Channel)
* Dart SDK ^3.5.0
* Chrome
* Running Syaahi Backend

---

## Install Dependencies

```bash
flutter pub get
```

---

## Run Locally

```bash
flutter run -d chrome
```

Default backend:

```text
http://localhost:4000
```

---

## Run Against Staging

```bash
flutter run -d chrome \
--dart-define=API_BASE_URL=https://your-railway-url.up.railway.app
```

---

# Environment Configuration

API URL is injected through:

```text
--dart-define
```

| Variable     | Default               |
| ------------ | --------------------- |
| API_BASE_URL | http://localhost:4000 |

Local development works without additional configuration.

Staging and production deployments should always provide an explicit API URL.

---

# Architecture

## Core Principle

UI never talks directly to the backend.

Architecture:

```text
Screen
 ↓
Provider
 ↓
Repository
 ↓
Dio
 ↓
Express API
```

---

# Feature Architecture

Every feature follows:

```text
feature/
├── data/
├── state/
└── presentation/
```

Responsibilities:

```text
presentation → UI
state        → Riverpod
data         → API communication
```

---

# Feed Architecture

The feed is powered by:

```text
FeedNotifier
```

Responsibilities:

* Initial load
* Cursor pagination
* Infinite scroll
* Pull to refresh
* Error handling

State tracked:

```text
poems
isLoading
isLoadingMore
hasMore
nextCursor
error
```

---

# Pagination

Feed uses cursor pagination.

API:

```text
GET /api/v1/poems?cursor=&limit=
```

Default page size:

```text
10 poems
```

Behavior:

```text
Load first page
      ↓
Receive nextCursor
      ↓
User scrolls
      ↓
Load next page
      ↓
Repeat until nextCursor = null
```

---

# User Journey

```text
App Launch
    ↓
Splash Screen
    ↓
Check Stored JWT
    ↓
Token Exists
    ↓
Feed Screen

OR

No Token
    ↓
Welcome Screen
    ↓
Login / Signup
    ↓
Feed Screen
    ↓
Read Poem
    ↓
Write Poem
```

---

# Development Dataset

For realistic testing, the backend includes:

```text
10 Seed Accounts
30 Seed Poems
```

Used for:

* Feed validation
* Pagination testing
* UI demonstrations
* Multi-author testing

Reset via:

```bash
npx tsx scripts/cleanup-and-reseed.ts
```

from the backend project.

---

# Useful Commands

## Run Application

```bash
flutter run -d chrome
```

---

## Build Web

```bash
flutter build web
```

---

## Build For Staging

```bash
flutter build web \
--dart-define=API_BASE_URL=https://your-url.up.railway.app
```

---

## Run Tests

```bash
flutter test
```

---

## Analyze Code

```bash
flutter analyze
```

---

## Check Dependency Updates

```bash
flutter pub outdated
```

---

# Related Documentation

See:

```text
docs/ARCHITECTURE.md
docs/API_CONTRACT.md
docs/ROADMAP.md
docs/DECISIONS.md
docs/PROGRESS.md
```

Backend:

```text
syaahi-backend/README.md
syaahi-backend/API_CONTRACT.md
```

---

# Development Principles

* UI never calls APIs directly
* Business logic does not live in widgets
* Repository pattern is mandatory
* State flows through Riverpod
* Documentation is updated alongside code
* Code that only works locally is not complete

---

# Author

**Raghavendra Singh**

Built with coffee, midnight thoughts, and a love for words.

> Syaahi — Where emotions become words.
