# Syaahi Studio — Editor Architecture Review & Decision
**Sprint:** ST-00.3  
**Document Status:** Technical Evaluation & Architectural Recommendation  
**Related ADRs:** ADR-ST-001, ADR-ST-003  

---

## 1. Executive Context
Syaahi Studio requires a specialized writing environment tailored for poetry composition (lines, stanzas, couplets, ghazals, conversational dialogue, formatting). The standard WriterScreen plain text input field is insufficient for structured editing, offline autosaving, line-by-line rhyming assistance, and revision comparison.

---

## 2. Evaluation of Architectural Options

| Evaluation Criterion | Option A: Extend Existing WriterScreen | Option B: Dedicated Studio Module (eatures/studio/) | Option C: Shared Core Parser / Block Engine |
|---|---|---|---|
| **System Stability Risk** | High (Modifying live /write screen risks breaking simple poem publishing) | **Zero (Isolated directory structure)** | Medium (Premature abstraction overhead) |
| **State Cleanliness** | Poor (Pulls complex draft & AI analysis state into poems_providers.dart) | **High (Isolated studioProvider and draftsProvider)** | Medium |
| **Mobile UX (Android)** | Basic | **Touch-optimized toolbar, stanza-aware IME controls** | Medium |
| **Desktop Expansion** | Difficult | **Adaptive responsive breakpoints (Single pane mobile -> Dual pane desktop)** | High |
| **Maintenance Cost** | Medium | **Low (Modular boundary)** | High |

---

## 3. Editor Technology Strategy Evaluation

### 3.1 Third-Party Rich Text Editors vs Custom Stanza Engine
- **Quill / SuperEditor / FlutterSpinkit RichText:**
  - *Pros:* Pre-built formatting controls.
  - *Cons:* Heavy native bindings, bloated web/desktop dependencies, incompatible with poetic line/stanza metadata (couplets, radif, kaafiya), hard to integrate with local rhyming engines.
- **Custom Custom-Painter / TextSpan Block Editor (Recommended):**
  - Use Flutter's standard TextField wrapped in structured stanza/line models with debounced state controllers.
  - Provides maximum performance on low-end Android devices while preserving exact line-break behavior needed for poetry.

---

## 4. Final Recommendation
1. **Accept ADR-ST-001 (Option B — Dedicated Studio Module):** Build syaahi-app/lib/features/studio/ as an isolated feature directory.
2. **Formulate ADR-ST-003 (Riverpod StateNotifier + 500ms Debounced Autosave):** Manage in-memory text via StudioEditorNotifier with debounced sync to local draft persistence.
