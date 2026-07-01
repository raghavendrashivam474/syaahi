# 🪶 Syaahi App

Flutter frontend for **Syaahi** — *Where emotions become words.*

Syaahi is a platform for poetry, journals, letters, memory preservation, and thoughtful human expression.

Built with **Flutter**, **Riverpod**, **go_router**, and **Dio**, the app is designed around calm interactions rather than engagement-driven mechanics.

---

# Current Status

**Version:** v0.3.0-beta

**Status:** Internal Beta

The Flutter application has completed the MVP and Writer Experience milestones and is ready for internal user testing.

---

# Available Features

## Authentication

| Feature | Status |
|---------|--------|
| Splash Screen | ✅ |
| Welcome Screen | ✅ |
| User Registration | ✅ |
| Login | ✅ |
| Session Persistence | ✅ |
| Logout | ✅ |

---

## Poetry

| Feature | Status |
|---------|--------|
| Browse Feed | ✅ |
| Read Poem | ✅ |
| Publish Poem | ✅ |
| Infinite Scroll | ✅ |
| Cursor Pagination | ✅ |
| Pull to Refresh | ✅ |
| Feed Filters | ✅ |
| Syaahi Flow Support | ✅ |

---

## Meaningful Interactions

| Feature | Status |
|---------|--------|
| Commit to Heart | ✅ |
| My Heart | ✅ |
| Emotional Reactions | ✅ |

Supported reactions:

- I Felt This
- This Stayed With Me
- Beautifully Written
- Made Me Think
- Comforted Me
- Inspired Me

---

## Profiles

| Feature | Status |
|---------|--------|
| Writer Profile | ✅ |
| Languages Used | ✅ |
| Themes Used | ✅ |
| Published Poems | ✅ |

---

# Technology Stack

| Layer | Technology |
|------|------------|
| Framework | Flutter |
| Language | Dart |
| State Management | Riverpod |
| Navigation | go_router |
| Networking | Dio |
| Secure Storage | flutter_secure_storage |
| Typography | google_fonts |

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
    │   ├── poems/
    │   ├── profile/
    │   ├── heart/
    │   └── home/
    │
    ├── shared/
    │   ├── models/
    │   └── widgets/
    │
    └── main.dart
```

Every feature follows the same structure:

```text
feature/
├── data/
├── state/
└── presentation/
```

---

# Getting Started

## Prerequisites

Required:

- Flutter SDK (Latest Stable)
- Dart SDK
- Chrome (Web)
- Android SDK (Android builds)
- Running Syaahi Backend

---

## Install Dependencies

```bash
flutter pub get
```

---

## Run Locally

```bash
flutter run
```

Default backend:

```text
http://localhost:4000
```

---

## Run Against Staging

```bash
flutter run \
--dart-define=API_BASE_URL=https://your-api-url.com
```

---

# Environment Configuration

The backend URL is injected at runtime using:

```text
--dart-define
```

Supported variable:

| Variable | Default |
|---------|----------|
| API_BASE_URL | http://localhost:4000 |

Local development requires no additional configuration.

Always provide an explicit API URL for staging or production builds.

---

# Architecture

The application follows a layered architecture.

```text
Screen
      │
      ▼
Riverpod Provider
      │
      ▼
Repository
      │
      ▼
Dio Client
      │
      ▼
Express Backend
```

Core principle:

> **UI never communicates with the backend directly.**

---

# Feed Architecture

The poem feed is managed by a dedicated state layer.

Responsibilities:

- Initial loading
- Cursor pagination
- Infinite scrolling
- Pull to refresh
- Filter application
- Error handling

Tracked state:

```text
poems
nextCursor
hasMore
isLoading
isLoadingMore
error
```

---

# Syaahi Flow

The frontend consumes poems ordered by the **Syaahi Flow Literary Sequencing Engine**.

Unlike conventional social feeds, the ordering is **not based on popularity or engagement**.

The feed instead emphasizes:

- Reading rhythm
- Writer diversity
- Natural discovery
- Recent writing

without introducing recommendation algorithms.

---

# User Journey

```text
Launch App
      │
      ▼
Splash Screen
      │
      ▼
Restore Session
      │
 ┌────┴────┐
 │         │
 ▼         ▼
Feed    Welcome
 │         │
 │    Login / Signup
 └────┬────┘
      ▼
Browse Feed
      │
      ├─────────────┐
      ▼             ▼
Read Poem      Write Poem
      │
      ├─────────────┐
      ▼             ▼
React        Commit to Heart
      │
      ▼
View Writer Profile
```

---

# Development Dataset

For realistic development and testing, the backend includes a reusable dataset.

Current dataset:

```text
10 Writers
30 Poems
Multiple Languages
Multiple Emotions
Multiple Themes
```

Reset anytime:

```bash
cd syaahi-backend

npx tsx scripts/cleanup-and-reseed.ts
```

Useful for:

- Feed testing
- Pagination
- UI development
- Multi-author validation
- Demonstrations

---

# Useful Commands

## Run Application

```bash
flutter run
```

---

## Build Web

```bash
flutter build web
```

---

## Build Android APK

```bash
flutter build apk --release
```

---

## Build With Custom Backend

```bash
flutter build apk \
--dart-define=API_BASE_URL=https://your-api-url.com
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

## Check Dependencies

```bash
flutter pub outdated
```

---

# Development Principles

The application follows a few core engineering rules.

- UI never calls APIs directly.
- Business logic never lives inside widgets.
- Repository pattern is mandatory.
- State flows through Riverpod.
- Features remain modular.
- Documentation evolves with the codebase.
- Code that only works locally is not considered complete.

---

# Related Documentation

```text
docs/ARCHITECTURE.md
docs/API_CONTRACT.md
docs/ROADMAP.md
docs/DECISIONS.md
docs/PROGRESS.md
docs/VISION.md
```

Backend documentation:

```text
syaahi-backend/README.md
syaahi-backend/API_CONTRACT.md
```

---

# Next Milestone

The next milestone focuses on **internal beta validation**.

Goals:

- Improve stability
- Gather feedback from real writers
- Refine the reading experience
- Resolve usability issues
- Expand automated testing

The Journals module begins after the feedback cycle concludes.

---

# Author

**Raghavendra Singh**

Built with midnight thoughts, coffee, and a love for words.

> **Syaahi — Where emotions become words.**