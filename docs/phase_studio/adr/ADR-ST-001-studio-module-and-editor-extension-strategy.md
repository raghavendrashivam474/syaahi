# ADR-ST-001: Studio Module & Editor Extension Strategy
**Status:** Accepted  
**Date:** 2025-03-30 (Updated 2026-11-20 in ST-00.3)  
**Context:** phase_studio - Sprints ST-00.1 / ST-00.2 / ST-00.3  
**Deciders:** Syaahi Engineering Lead & Architecture Team  
---
## Context and Problem Statement
Syaahi requires an expanded writing workspace ("Syaahi Studio") supporting offline drafts, draft version history, reusable fragments, theme customization, and linguistic analysis tools (rhymes, synonyms, redundancy detection).
We need to decide whether to extend the existing WriterScreen in lib/features/poems/ or build a dedicated module under lib/features/studio/.

## Decision Drivers
1. **Existing System Stability:** Must not break existing /write route or poem creation logic.
2. **State Management Cleanliness:** Avoid cluttering existing poems_providers.dart with complex draft and analysis state.
3. **Architectural Isolation:** Allow independent iteration on Studio without introducing regression risks to feed or reader features.

## Considered Options
- **Option A:** Extend existing WriterScreen directly.
- **Option B:** Build a dedicated syaahi-app/lib/features/studio/ module while retaining common shared data models (Poem, PoemLanguage, PoemEmotion).
- **Option C:** Extract a shared editor core before building Studio.

## Decision Outcome
**Chosen Option: Option B (Dedicated Studio Module).**

### Rationale:
- A dedicated lib/features/studio/ directory provides clear architectural boundaries.
- Simple quick-writing (WriterScreen) can coexist with advanced Studio composition (StudioScreen).
- Existing poem models and API clients (ApiClient, Poem) will be reused directly, eliminating redundant data transformations.

## Consequences
### Positive:
- High maintainability and zero regression risk to baseline reader/feed features.
- Dedicated Riverpod providers (studioProvider, draftsProvider) isolated to features/studio/state/.
### Negative / Trade-offs:
- Minor initial boilerplate setup for new feature directory structure.
