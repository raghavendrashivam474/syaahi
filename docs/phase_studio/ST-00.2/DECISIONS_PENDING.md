# Syaahi Studio — Decisions Pending

## 1. Open Product Questions
- **Draft Retention Policy:** How long should a draft stay in the cloud/local storage before it is flagged for archival or auto-deleted?
- **Fragment Privacy Defaults:** Should fragments be 100% private, or do we allow a "Share as Snippet" feature later?
- **Conversational Poetry Rules:** In two-speaker conversational poems, how do we display speaker names in the live feed? (e.g., "Speaker A" / "Speaker B" vs custom names).

## 2. Technical Research Questions
- **Lexicon & Rhyming Engine:** Which open-source phonetic datasets (e.g., CMU Pronouncing Dictionary for English, transliteration libraries for Hindi/Urdu) provide the best quality-to-size ratio without heavy licensing constraints?
- **Local-First State Persistence:** Evaluate Flutter drift (SQLite) vs hive vs encrypted shared_preferences for robust offline draft autosaving and fragment storage.
- **Two-Speaker Composition Model:** How should the UI handle side-by-side conversational text on narrow Android screens? (Stacked view vs side-by-side scrolling?)

## 3. Architectural Decisions Awaiting Approval
- **ADR-ST-001 (Studio Module & Editor Extension Strategy):** Should the Studio editor be a rich text custom widget, a Markdown-based parser, or a structured block editor?
- **ADR-ST-002 (Draft Persistence & Offline Sync Strategy):** Should drafts be stored as a separate Draft model/table in PostgreSQL, or as Poem records with isPublished=false? (Impact on existing feed and notification triggers).
- **ADR-ST-003 (Frontend Editor State Strategy):** Should we use Riverpod StateNotifier for local draft text manipulation, or manage it inside the text controller with debounced auto-save triggers?

## 4. Proposed Next Steps
1. Review ST-00.2 documentation package (Product Identity, Boundaries, Architecture Assessment).
2. Approve or modify DECISIONS_PENDING.md priorities.
3. Formally accept ADR-ST-001 and ADR-ST-002 to begin implementation of the Studio writing workspace.
