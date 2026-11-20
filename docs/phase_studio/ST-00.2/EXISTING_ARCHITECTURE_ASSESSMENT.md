# Syaahi Studio — Existing Architecture Assessment

## 1. Frontend Baseline (syaahi-app)
- Framework: Flutter (SDK ^3.5.0)
- State Management: flutter_riverpod (^2.6.1)
- Routing: go_router (^14.6.2)
- Networking: dio (^5.7.0) with custom ApiClient
- Storage: flutter_secure_storage (^9.2.2), shared_preferences (^2.3.3)
- Typography: google_fonts (^6.2.1)

### Existing Editor Assessment
- Location: lib/features/poems/presentation/writer_screen.dart
- Component: Standard Material TextField widgets for Title, Content, and Theme.
- State Handler: writerProvider (lib/features/poems/state/poems_providers.dart).
- Gaps Identified:
  1. Plain multi-line text input without rich structure or line/stanza metadata.
  2. No local persistence — exiting screen triggers a discard confirmation modal (PopScope).
  3. No auto-save or draft drawer.
  4. Immediate publish-only path via PoemsRepository.createPoem().

## 2. Backend Baseline (syaahi-backend)
- Runtime: Node.js / TypeScript / Express
- Database / ORM: PostgreSQL / Prisma (prisma/schema.prisma)
- Validation: Zod (src/modules/poems/poems.schemas.ts)
- Authentication: Custom JWT middleware (src/middleware/auth.ts)

### Existing Database Schema (Poem Model)
model Poem {
  id          String   @id @default(uuid())
  authorId    String
  title       String?
  content     String   @db.Text
  language    Language @default(ENGLISH)
  emotion     Emotion?
  theme       String?
  audioUrl    String?
  isPublished Boolean  @default(true)
}

### Identified Architectural Gaps
1. Draft State Machine Missing: While isPublished boolean exists on Poem, createPoem controller hardcodes creation as published work and immediately triggers createPublicationNotifications.
2. Revision History Missing: No revision history table exists in Prisma schema (PoemRevision). updatedAt is updated in-place on edit.
3. Fragment Storage Missing: No Fragment model exists in the backend or frontend database.
4. Structure Metadata Missing: content is a single raw Text field without support for formatted stanzas, speaker roles, or poetic templates.
