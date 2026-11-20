# ADR-ST-002: Local Draft Persistence & Hybrid Offline Synchronization Strategy
**Status:** Accepted  
**Date:** 2025-03-30 (Updated 2026-11-20 in ST-00.3)  
**Context:** phase_studio - Sprints ST-00.1 / ST-00.2 / ST-00.3  
**Deciders:** Syaahi Engineering Lead & Architecture Team  
---
## Context and Problem Statement
Studio users must be able to write freely offline without losing draft progress.
Currently, syaahi-app lacks a local database engine and stores unsaved poem content exclusively in Flutter TextEditingController RAM memory. If the network fails during publication or if the user navigates away, text can be lost.

## Decision Drivers
1. **Zero Content Loss Guarantee:** Drafts must auto-save locally after every keystroke or debounce interval.
2. **Offline First Composition:** Users should be able to create, edit, and list local drafts without active internet connectivity.
3. **Seamless Sync:** When online, local drafts can be published or synchronized with the backend.

## Considered Options
- **Option A:** Use SharedPreferences to store JSON-encoded draft strings.
- **Option B:** Introduce a structured local storage repository (LocalDraftRepository) backed by asynchronous local persistence abstraction (SQLite/Drift or structured file storage).
- **Option C:** Direct Cloud-only HTTP drafts.

## Decision Outcome
**Chosen Option: Option B (Abstracted LocalDraftRepository).**

### Rationale:
- Abstracted persistence interface decouples UI editing from local database engine selection (e.g. SQLite/Drift).
- Enables clean unit testing via repository mocks.
- Prepares Studio for offline draft queueing and background synchronization when network connectivity returns.

## Consequences
### Positive:
- Guarantees local draft safety offline.
- Decouples UI editing from remote HTTP status.
### Negative / Trade-offs:
- Requires entity mapping between local DraftPoem entity and remote backend Poem model.
