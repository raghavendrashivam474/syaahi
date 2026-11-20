# Syaahi Studio — Feature Inventory & Classification

| Classification | Meaning |
|---|---|
| **Existing** | Already available in Syaahi |
| **Extend** | Existing capability needs improvement |
| **New** | Proposed Studio capability (not built) |
| **Future** | Not included in initial scope |
| **Research** | Requires feasibility investigation |

---

## A. Writing Workspace
| Feature | Class | Notes |
|---|---|---|
| Basic plain-text poem creation | **Existing** | `writer_screen.dart` supports title/content entry. |
| Emotion & language selection | **Existing** | Chips exist in the editor UI. |
| Focused editor UI | **Extend** | Needs distraction-free mode, margin adjustments, and adaptive keyboard layout. |
| Automatic saving | **New** | Currently requires manual publish; no auto-draft mechanism. |
| Line and stanza formatting | **New** | Plain text field does not support intentional stanza breaks or indentation. |
| Preview before publishing | **New** | Currently goes straight from editing to live feed. |

## B. Writing Intelligence
| Feature | Class | Notes |
|---|---|---|
| Redundancy / repeated phrase detection | **New** | Rule-based local engine. |
| Synonym suggestions | **New** | Open-source lexical integration. |
| Rhyming / near-rhyming words | **New** | Open-source phonetic dictionary. |
| Optional line-improvement suggestions | **New** | Contextual, non-destructive. |
| Silent auto-correction | **Out of Scope** | Never overwrite user intent. |

## C. Poetry Formats
| Feature | Class | Notes |
|---|---|---|
| Free verse | **Existing** | Default plain text mode. |
| Couplets / Ghazal / Sonnet / Haiku | **New** | Requires structured metadata or stanza logic. |
| Conversational (two-speaker) | **New** | Dual-canvas or alternating speaker model. |
| Forced structure validation | **Out of Scope** | User must remain free to break rules. |

## D. Language Exploration
| Feature | Class | Notes |
|---|---|---|
| English / Hindi / Urdu support | **Existing** | Hardcoded in Dart model and Zod schema. |
| Translation & pronunciation | **New** | Needs verified open-source lexicons. |
| Persian & Sanskrit support | **Research** | License and data quality verification required. |

## E. My Fragments
| Feature | Class | Notes |
|---|---|---|
| Save individual lines/couplets | **New** | Separate from published Poems. |
| Organize, search, insert fragments | **New** | Local-first persistence (SQLite/Drift). |
| Fragment-to-Poem conversion | **New** | Explicit user action. |

## F. Writing Memory
| Feature | Class | Notes |
|---|---|---|
| Draft history / version tracking | **New** | Currently `isPublished` is a bare boolean; no revision table. |
| Compare revisions | **New** | UI for side-by-side diff view. |
| Recover earlier drafts | **New** | Undo destructive edits. |

## G. Reading & Export
| Feature | Class | Notes |
|---|---|---|
| Reading themes / typography | **New** | Preview modes. |
| Image/card / PDF export | **New** | Shareable assets. |
| `audioUrl` field | **Existing** | Present in Prisma schema but unused in current editor flow. |

## H. Voice Drafts
| Feature | Class | Notes |
|---|---|---|
| Capture spoken thoughts | **Future** | Deferred. |
| Speech-to-text transcription | **Future** | Deferred; requires offline STT engine evaluation. |
