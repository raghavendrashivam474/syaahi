# ADR-ST-002: Local Draft Persistence & Hybrid Offline Synchronization Strategy

**Status:** Proposed  
**Date:** 2025-03-30  
**Context:** `phase_studio` - Sprint ST-00.1  
**Deciders:** Syaahi Engineering Lead & Architecture Team  

---

## Context and Problem Statement

Studio users must be able to write freely offline without losing draft progress.

Currently, `syaahi-app` lacks a local database engine and stores unsaved poem content exclusively in Flutter `TextEditingController` RAM memory. If the network fails during publication or if the user navigates away, text can be lost.

---

## Decision Drivers

1. **Zero Content Loss Guarantee:** Drafts must auto-save locally after every keystroke or debounce interval.
2. **Offline First Composition:** Users should be able to create, edit, and list local drafts without active internet connectivity.
3. **Seamless Sync:** When online, local drafts can be published or synchronized with the backend (`POST /api/v1/poems` or `PATCH /api/v1/poems/:id`).

---

## Considered Options

- **Option A:** Use `SharedPreferences` to store JSON-encoded draft strings.
- **Option B:** Introduce a structured local storage repository (`LocalDraftRepository`) backed by asynchronous local JSON key-value persistence / file storage abstraction.
- **Option C:** Introduce heavy ORM database (`sqflite` / `drift`).

---

## Decision Outcome

**Chosen Option: Option B (Abstracted LocalDraftRepository).**

### Rationale:
- Avoids complex native SQLite database bindings while providing structured, asynchronous local CRUD operations for poem drafts (`DraftPoem` model).
- Enables clean unit testing via repository mocks.
- Prepares Studio for offline draft queueing and background synchronization when network connectivity returns.

---

## Consequences

### Positive:
- Guarantees local draft safety offline.
- Decouples UI editing from remote HTTP status.

### Negative / Trade-offs:
- Requires mapping between local `DraftPoem` entity and remote backend `Poem` model.
