# Syaahi Studio — Decision Register & Open Questions
**Sprint:** ST-00.3  
**Document Status:** Decision Register  

---

## 1. Architectural Decision Records (ADRs) Summary Index

| ADR ID | Title | Status | Recommendation | Approval Owner |
|---|---|---|---|---|
| **ADR-ST-001** | Studio Module & Editor Extension Strategy | **Accepted** | Build `syaahi-app/lib/features/studio/` as a dedicated module. | Project Owner |
| **ADR-ST-002** | Local Draft Persistence Strategy | **Accepted** | Implement abstracted `LocalDraftRepository` (SQLite/Drift). | Project Owner |
| **ADR-ST-003** | Editor State Management & Debounced Autosave | **Proposed** | Use Riverpod `StateNotifier` with 500ms debounced auto-save. | Project Owner / Eng Lead |

---

## 2. Outstanding Product & Technical Questions

### 2.1 Product Decisions Requiring Sign-Off
1. **Draft Cloud Backup Default:** Should local drafts automatically sync to `POST /api/v1/studio/drafts` when online, or remain local-only until explicitly enabled? *(Recommendation: Auto-sync in background when authenticated).*
2. **Draft Retention & Discard Policy:** How long should unpublished local/cloud drafts be retained? *(Recommendation: Infinite retention until user explicitly deletes or publishes).*
3. **Conversational Stanza Display:** How should alternating speaker dialogue (two-speaker poems) be displayed on narrow mobile screens? *(Recommendation: Stacked vertical blocks with speaker indicator tags).*

### 2.2 Technical Research Dependencies
1. **Offline Rhyming Dataset Selection:** Verify CMU Pronouncing Dictionary license and file size compression for Android asset packaging (< 2MB asset target).
2. **Multilingual Transliteration Engine:** Research open-source offline Hindi/Urdu transliteration libraries for future language exploration.
