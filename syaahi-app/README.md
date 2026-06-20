# 🪶 Syaahi — App

Flutter frontend for **Syaahi**, a platform for poetry, letters, journals, and human expression.

> Where emotions become words.

---

## Current Status

**v0.2.0 — MVP Complete**

| Feature          | Status       |
|------------------|--------------|
| Splash Screen    | ✅ Complete  |
| Welcome Screen   | ✅ Complete  |
| Authentication   | ✅ Complete  |
| Poem Feed        | ✅ Complete  |
| Poem Reader      | ✅ Complete  |
| Poem Writer      | ✅ Complete  |
| User Profiles    | 🔜 Planned   |
| Journals         | 🔜 Sprint 3  |

---

## Tech Stack

| Layer            | Technology              |
|------------------|-------------------------|
| Framework        | Flutter                 |
| Language         | Dart                    |
| State Management | Riverpod                |
| Navigation       | go_router               |
| HTTP Client      | Dio                     |
| Secure Storage   | flutter_secure_storage  |
| Fonts            | google_fonts            |

---

## Project Structure

```text
syaahi-app/
└── lib/
    ├── core/
    │   ├── constants/       # App-wide constants
    │   ├── network/         # Dio API client setup
    │   ├── router/          # go_router configuration
    │   ├── storage/         # Secure storage helpers
    │   └── theme/           # Colors, typography, theme
    │
    ├── features/
    │   ├── splash/          # Splash screen
    │   ├── welcome/         # Welcome / onboarding screen
    │   ├── auth/
    │   │   ├── data/        # AuthRepository
    │   │   ├── state/       # Auth providers (Riverpod)
    │   │   └── presentation/ # Login, Signup screens
    │   ├── poems/
    │   │   ├── data/        # PoemRepository
    │   │   ├── state/       # Poem providers (Riverpod)
    │   │   └── presentation/ # Feed, Reader, Writer screens
    │   └── home/            # Home screen
    │
    ├── shared/
    │   ├── models/          # User, Poem data models
    │   └── widgets/         # Shared UI components
    │
    └── main.dart            # App entry point
Getting Started
Prerequisites
Flutter SDK (stable channel)
Dart SDK ^3.5.0
Chrome (for web development)
Syaahi backend running locally or on staging
1. Install Dependencies
Bash

flutter pub get
2. Run the App
Against local backend:

Bash

flutter run -d chrome
Against staging backend:

Bash

flutter run -d chrome --dart-define=API_BASE_URL=https://your-railway-url.up.railway.app
Environment Configuration
The API base URL is injected at runtime via --dart-define.

Variable	Default	Description
API_BASE_URL	http://localhost:4000	Backend API base URL
For local development the default works out of the box.

For staging or production, always pass the correct URL via --dart-define.

Architecture
Key Principle
UI never calls the API directly.

text

Screen
  ↓
Riverpod Provider
  ↓
Repository
  ↓
Dio (API Client)
  ↓
Express Backend
Feature Structure
Every feature follows the same pattern:

text

feature/
├── data/
│   └── feature_repository.dart   # All API calls
├── state/
│   └── feature_provider.dart     # Riverpod state
└── presentation/
    └── feature_screen.dart       # UI only
Screens only read from providers.
Providers call repositories.
Repositories talk to the API.

Available Commands
Bash

# Run on Chrome
flutter run -d chrome

# Build for web
flutter build web

# Build for web with staging URL
flutter build web --dart-define=API_BASE_URL=https://your-url.up.railway.app

# Run tests
flutter test

# Check for outdated packages
flutter pub outdated

# Analyze code
flutter analyze
User Journey
text

App Launch
    ↓
Splash Screen (check stored token)
    ↓
Token exists → Home Screen (Feed)
    ↓
No token → Welcome Screen
    ↓
Login / Signup
    ↓
Home Screen (Feed)
    ↓
Read Poem → Poem Reader
    ↓
Write Poem → Poem Writer
Backend
This app connects to the Syaahi backend API.

See syaahi-backend/README.md for backend setup.
See syaahi-backend/API_CONTRACT.md for endpoint reference.

Author
Raghavendra Singh
Built with coffee, midnight thoughts, and a love for words.