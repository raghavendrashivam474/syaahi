# ST-00.1: Editor Strategy Evaluation

**Sprint ID:** ST-00.1  
**Phase:** `phase_studio`  
**Status:** Completed  
**Audit Target:** Evaluation of Architectural Options for Syaahi Studio Editor  

---

## 1. Context & Architectural Challenge

Syaahi Studio introduces advanced composition tools (synonyms, rhyming lookup, redundancy/repeat detection, reusable fragments, custom themes, version history, offline drafts, and voice drafts).

We must choose an editor architecture that satisfies these requirements without introducing unnecessary duplication, destabilizing existing poem creation, or violating mandatory Existing-System Protection Rules.

---

## 2. Evaluation of Architectural Options

### Option A: Extend Existing Editor (`lib/features/poems/presentation/writer_screen.dart`)
- **Description:** Modify `WriterScreen` directly by adding all Studio features (panels, toolbars, state management, local drafts) inside the existing `syaahi-app/lib/features/poems/` feature directory.
- **Pros:** Maximum initial code reuse; no new top-level feature folder required.
- **Cons:** High risk of regression for basic poem publishing; `WriterScreen` is currently 365 lines of simple `StatefulWidget` code; stuffing heavy state (fragments, rhyming dictionaries, version history) into it creates a monolithic "god widget"; difficult to maintain.

### Option B: Build a Dedicated Studio Module (`lib/features/studio/`)
- **Description:** Establish a dedicated feature module `lib/features/studio/` containing dedicated screens, controllers, and services, while sharing lower-level models (`Poem`, `PoemLanguage`, `PoemEmotion`) and API clients (`ApiClient`).
- **Pros:** Complete isolation of advanced studio capabilities; zero risk of breaking basic reader/writer workflows; clean separation of concerns; modular state management for draft history, fragments, and offline sync.
- **Cons:** Slight duplication of simple UI inputs (title/content text fields) if not modularized into shared components.

### Option C: Shared Editor Core with Specialized Interfaces
- **Description:** Create a shared core package/module (`lib/core/editor/` or `lib/shared/editor/`) containing text controllers, stanza analyzers, and model abstractions, used by both simple `WriterScreen` and advanced `StudioScreen`.
- **Pros:** Cleanest abstraction; high reuse of analysis algorithms across screens.
- **Cons:** Premature abstraction risk before Studio requirements are fully implemented in code.

---

## 3. Comprehensive Strategy Comparison Matrix

| Evaluation Criteria | Option A: Extend Existing Editor | Option B: Dedicated Studio Module | Option C: Shared Editor Core |
|---|---|---|---|
| **Reusability** | Medium (Reuses existing screen) | High (Reuses data models & network) | High (Reuses core logic & UI) |
| **Complexity** | High (Converts simple screen to god widget) | Low-Medium (Isolated modular scope) | Medium-High (Requires upfront abstraction) |
| **Development Effort** | Low initial, High maintenance | Moderate, predictable | High initial abstraction effort |
| **Performance** | Risk of unnecessary re-renders | High (Tailored studio state management) | High |
| **Maintainability** | Poor (Monolithic widget) | Excellent (Clear feature encapsulation) | Good |
| **Data Compatibility** | High | High (Produces standard `Poem` models) | High |
| **Offline Compatibility**| Low (Requires refactoring `WriterNotifier`)| High (Dedicated `LocalDraftRepository`) | High |
| **Future Extensibility**| Low | Excellent (Easy to add AI/Voice features) | Excellent |

---

## 4. Grounded Recommendation

**Recommendation: Option B (Dedicated Studio Module with Shared Core Models).**

### Rationale:
1. **Existing System Protection:** Creating `lib/features/studio/` ensures that existing quick-post functionality (`/write` -> `WriterScreen`) remains 100% operational and untouched during initial Studio development.
2. **Encapsulation:** Advanced features like rhyming dictionaries, local draft versioning, and redundancy detection require distinct Riverpod state notifiers (`StudioNotifier`, `DraftNotifier`, `VocabularyNotifier`) that would overburden `poems_providers.dart`.
3. **Data Safety:** Studio will output standard `Poem` payloads consumed by the backend `/api/v1/poems` endpoints, ensuring 100% data compatibility with the existing reader and feed modules.

*Documented in ADR-ST-001.*
