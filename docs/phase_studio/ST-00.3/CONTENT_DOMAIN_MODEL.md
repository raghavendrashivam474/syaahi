# Syaahi Studio — Content & Domain Model Review
**Sprint:** ST-00.3  
**Document Status:** Domain Model Specification  

---

## 1. Domain Entities & Core Concepts

```text
┌─────────────────┐ 1:N  ┌─────────────────────┐
│ User            │─────>│ Draft               │
└─────────────────┘      └─────────────────────┘
        │                           │
        │ 1:N                       │ 1:1 (on publish)
        v                           v
┌─────────────────┐ 1:N  ┌─────────────────────┐
│ Poem            │─────>│ PoemRevision        │
└─────────────────┘      └─────────────────────┘
        │
        │ 1:N
        v
┌─────────────────┐      ┌─────────────────────┐
│ Fragment        │      │ Stanza / Content    │
└─────────────────┘      │ (Structured JSON)   │
                         └─────────────────────┘

```

---

## 2. Proposed Data Model Specifications

### 2.1 Extended Stanza Content Structure

To move beyond a single raw text field without introducing database complexity, `content` will store structured JSON or plain multi-line string with standard delimiter conventions (`\n\n` for stanzas, `\n` for lines).

```typescript
// Client/Server JSON representation for structured composition
interface StructuredPoemContent {
  version: 1;
  stanzas: Array<{
    id: string;
    type: 'STANDARD' | 'COUPLET' | 'SPEAKER_A' | 'SPEAKER_B';
    lines: Array<{
      id: string;
      text: string;
      indentation?: number;
    }>;
  }>;
}

```

### 2.2 Proposed Database Schema Extensions (Prisma)

```prisma
// Draft Model — Dedicated entity for unpublished work
model Draft {
  id                String   @id @default(uuid())
  authorId          String
  title             String?
  content           String   @db.Text
  language          Language @default(ENGLISH)
  emotion           Emotion?
  theme             String?
  audioUrl          String?
  structuredContent Json? // Optional structured stanza representation
  author            User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  createdAt         DateTime @default(now())
  updatedAt         DateTime @updatedAt

  @@index([authorId, updatedAt])
}

// PoemRevision Model — Version history snapshot
model PoemRevision {
  id         String   @id @default(uuid())
  poemId     String
  revisionNo Int
  title      String?
  content    String   @db.Text
  createdAt  DateTime @default(now())
  poem       Poem     @relation(fields: [poemId], references: [id], onDelete: Cascade)

  @@unique([poemId, revisionNo])
}

// Fragment Model — Reusable lines and ideas
model Fragment {
  id        String   @id @default(uuid())
  authorId  String
  text      String   @db.VarChar(500)
  tags      String[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  author    User     @relation(fields: [authorId], references: [id], onDelete: Cascade)

  @@index([authorId])
}

```

---

## 3. Language Enum Extensibility

Currently `Language` is defined as `enum Language { ENGLISH, HINDI, URDU }`.

* **Backward Compatibility:** Keep existing enum values intact.
* **Future Expansion:** Introduce `code` string field (e.g., `'fa'` for Persian, `'sa'` for Sanskrit) when multilingual research phase matures, preserving backwards-compatible fallback to `ENGLISH`.

```