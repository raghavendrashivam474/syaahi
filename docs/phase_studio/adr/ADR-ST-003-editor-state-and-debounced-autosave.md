# ADR-ST-003: Frontend Editor State Management & Debounced Autosave Strategy
**Status:** Proposed  
**Date:** 2026-11-20  
**Context:** phase_studio - Sprint ST-00.3  
**Deciders:** Syaahi Engineering Lead & Architecture Team  
---
## Context and Problem Statement
Studio requires real-time autosaving and responsive writing analysis (syllables, rhyming, line count) as the user types, without causing UI jank or flooding disk/network I/O.

## Decision Drivers
1. **Fluid Typing Performance:** 60fps UI responsive typing on low-end Android devices.
2. **IO Efficiency:** Debounced disk/network write triggers to prevent unnecessary CPU/battery drain.
3. **State Predictability:** Single source of truth for active draft content, autosave status (saving, saved, error), and undo history.

## Decision Outcome
**Chosen Option: Riverpod StateNotifier + 500ms Debounced Stream Controller.**
- In-memory editing updates studioProvider state instantly.
- A 500ms debounce timer triggers LocalDraftRepository.saveDraft().
- Explicit user tap on "Publish" bypasses debounce and completes immediate atomic save + publish request.
