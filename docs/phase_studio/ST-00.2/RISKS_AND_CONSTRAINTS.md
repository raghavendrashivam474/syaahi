# Syaahi Studio — Risks & Constraints

## 1. Economical & Engineering Constraints
- **Student Budget:** The project has zero budget for recurring paid APIs (e.g., OpenAI, Anthropic, Google Cloud Translation, or hosted GPU instances).
- **Rule-Based & Open-Source First:** All dictionary, thesaurus, rhyming, and structural features must use local rule engines, open-source dictionaries, or offline assets.
- **No Keystroke Streaming:** Keystrokes must never trigger real-time HTTP calls. Word suggestions and analysis must run locally or on-demand on explicit user request.

## 2. Device & Performance Constraints
- **Android Primary Target:** Must run smoothly on mid-range and lower-tier Android devices without consuming excessive RAM or battery.
- **Touch-First Mechanics:** Toolbar controls, selection handles, and formatting tools must be touch-friendly and accommodate virtual keyboards.
- **Local Persistence Overhead:** Local draft and fragment storage must remain lightweight (using SQLite/Drift or encrypted local storage) to avoid startup lag.

## 3. Data Integrity & Sync Risks
- **Draft Conflict Resolution:** When a user writes offline on Android and later opens the Studio desktop interface, draft conflict resolution strategy must be deterministic (e.g., last-write-wins with explicit conflict copy).
- **Database Schema Migration:** The current Prisma schema has isPublished Boolean @default(true) without a separate Draft model. Introducing drafts must be backward-compatible with existing feeds and notification systems.
- **Accidental Discard Risk:** Auto-saving must be robust. Unexpected app terminations or system low-memory kills must not cause loss of user writing.

## 4. Privacy & Data Ownership
- **Unpublished Content Security:** Drafts and fragments are strictly confidential. API endpoints for drafts must enforce explicit user-level authentication filters.
- **No Cloud AI Training:** User drafts must never be transmitted to third-party services for AI training or analysis without explicit opt-in consent.

## 5. Architectural Compatibility Risks
- **Notification Side-Effects:** The current backend fires createPublicationNotifications whenever a poem is created. Draft creation must NOT hit POST /poems without isPublished=false, otherwise spurious notifications will be sent to followers.
- **Syaahi Flow Feed Pollution:** Drafts must be strictly excluded from the syaahiFlow feed query (where: { isPublished: true }).
