# Syaahi Studio — Technology Feasibility Review
**Sprint:** ST-00.3  
**Document Status:** Technology Evaluation & Feasibility Assessment  

---

## 1. Core Technology Stack Assessment

| Layer | Technology | Status | Decision & Rationale |
|---|---|---|---|
| **Mobile Frontend** | Flutter / Dart (^3.5.0) | **Retained** | Cross-platform, excellent custom text rendering performance, native Android feel. |
| **Backend API** | Node.js / Express / TypeScript | **Retained** | Fast HTTP execution, non-blocking I/O, lightweight memory footprint. |
| **Database & ORM** | PostgreSQL + Prisma (^6.19.3) | **Retained** | Declarative schema, automated migrations, type-safe query generation. |
| **Frontend State** | Riverpod (^2.6.1) | **Retained** | Clean dependency injection, StateNotifier reactive auto-save triggers. |
| **Local Draft DB** | SQLite / Drift or File JSON | **Evaluated** | Drift (SQLite) recommended for Flutter local draft/fragment caching. |
| **Native Extensions**| Android Kotlin | **Deferred** | Flutter standard framework is sufficient; no native Android plugin required yet. |
| **High-Perf Logic** | Rust (FFI) | **Deferred** | Dart's native performance is sufficient for line/syllable/rhyme tokenization. |
| **NLP / AI Engine** | Python / Cloud AI | **REJECTED** | **Zero budget constraint.** All lexicons must run locally or open-source offline. |

---

## 2. Zero-Budget Offline Writing Intelligence Strategy
To adhere to project budget constraints (zero recurring paid AI API costs):
1. **Rhyme & Phonetic Analysis:** Use local CMU Pronouncing Dictionary JSON assets for English, and rule-based phonetic ending matchers for Hindi/Urdu.
2. **Synonym Search:** Store lightweight open-source WordNet/Thesaurus JSON lookup dictionaries inside Flutter `assets/lexicon/`.
3. **Execution Environment:** All lexical processing runs on the client device in background Dart Isolate threads, keeping memory consumption < 15MB.
