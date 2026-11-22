# ST-03 — Writing Intelligence Design Document

## 1. Architectural Overview

The **Writing Intelligence Engine** is a local-first, advisory module designed specifically for creative writers, poets, and authors working within **Syaahi Studio**.

```text
+---------------------------------------------------------------------------------+
|                               StudioEditorScreen                                |
|  +---------------------------+     +-----------------------------------------+  |
|  |   TextEditingController   | <-> |      studioProvider (Draft State)        |  |
|  +---------------------------+     +-----------------------------------------+  |
|               |                                         |                       |
|               v (Snapshot text)                         v (500ms Debounce)      |
|  +---------------------------------------------------------------------------+  |
|  |                        WritingIntelligenceEngine                          |  |
|  |  +---------------------+  +---------------------+  +-------------------+  |  |
|  |  | RepetitionAnalyzer  |  | RedundancyAnalyzer  |  | WordSuggestion    |  |  |
|  |  +---------------------+  +---------------------+  +-------------------+  |  |
|  +---------------------------------------------------------------------------+  |
|                                       |                                         |
|                                       v (Immutable Result)                      |
|  +---------------------------------------------------------------------------+  |
|  |                      writingIntelligenceProvider                          |  |
|  +---------------------------------------------------------------------------+  |
|                                       |                                         |
|                                       v                                         |
|  +---------------------------------------------------------------------------+  |
|  |                       WritingIntelligenceSheet (UI)                       |  |
|  +---------------------------------------------------------------------------+  |
+---------------------------------------------------------------------------------+

```

### Core Design Principles

* **Advisory Non-Intrusiveness:** The system never mutates document text, formatting, or draft state on its own. Every replacement or dismissal requires explicit user interaction.
* **100% Offline & Zero Latency:** No external AI APIs, cloud endpoints, or LLM services are called. All calculations run locally on Dart string algorithms and local maps in `< 5ms` for standard poems.
* **Decoupled State Boundaries:** The intelligence engine operates on text snapshots. Its state (`WritingIntelligenceState`) is managed by a distinct Riverpod provider (`writingIntelligenceProvider`) isolated from draft persistence (`studioProvider` / `DriftDatabase`).

---

## 2. Component Specifications

### 2.1 Repetition Analyzer (`RepetitionAnalyzer`)

Identifies overused words, consecutive repeated words, and repeated phrases.

* **Word Repetition:** Counts frequency of non-stop-words. Triggers suggestion if `frequency >= 3` (default threshold).
* **Consecutive Duplicate Detection:** Regex pattern match `\b(\w+)\s+\1\b` targeting unintentional double typing (e.g., `"the the"`, `"dark dark"`, `"boond boond"`).
* **N-Gram Phrase Repetition:** Extracts phrase n-grams of size `2`, `3`, and `4` words across all lines. Ignores phrase combinations composed solely of stop-words.
* **Stop Words:** Combined dictionary covering high-frequency English (articles, prepositions, pronouns) and Hindi transliterated stop words (`hai`, `ki`, `ka`, `se`, `me`, `par`, etc.).

### 2.2 Redundancy Analyzer (`RedundancyAnalyzer`)

Detects tautologies, verbal redundancies, and duplicate/near-duplicate lines.

* **Rule-Based Dictionary:** Map of multi-word redundancies to concise alternatives:
* `"returned back"` $\rightarrow$ `"returned"`
* `"reason is because"` $\rightarrow$ `"reason is"`
* `"close proximity"` $\rightarrow$ `"proximity"` / `"close by"`
* `"past history"` $\rightarrow$ `"history"`
* `"future plans"` $\rightarrow$ `"plans"`
* `"end result"` $\rightarrow$ `"result"`


* **Line Similarity (Jaccard Overlap):** Tokenizes consecutive lines into word sets and computes Jaccard Index:

$$J = \frac{|A \cap B|}{|A \cup B|}$$



Lines with similarity $\ge 0.65$ are flagged as near-duplicate line redundancies.

### 2.3 Word Suggestion Service (`WordSuggestionService`)

Provides poetic synonyms and evocative word choices.

* **Offline Poetic Dictionary:** Pre-built mapping covering both English and Hindi transliterated poetry vocabulary:
* **English:** `"beautiful"` $\rightarrow$ `["elegant", "radiant", "graceful", "exquisite"]`
* **Transliterated Hindi:** `"pyaar"` $\rightarrow$ `["mohabbat", "ishq", "ulfat", "chaahat"]`


* **Lookup Modes:**
* **Selection Mode:** Accepts highlighted word selection from `TextSelection` and returns immediate suggestions.
* **Document Discovery Mode:** Scans document text against dictionary keys and returns suggestions for all matching terms.



### 2.4 Interface & State Management (`WritingIntelligenceSheet` & `WritingIntelligenceNotifier`)

* **Modal Bottom Sheet:** Displays summary metrics (*Total Words*, *Unique Words*, *Richness %*, *Total Alerts*).
* **Category Tabs:** *All*, *Repeated Words*, *Repeated Phrases*, *Redundancies*, *Word Suggestions*.
* **Interactive Cards:** Supports **Dismiss** (removes item from active sheet without affecting document) and **Replace** (executes replacement callback).
* **Safe Replacement Integration:** Safe text substitution helper `applyReplacement(currentContent, target, replacement)` updates `TextEditingController` text and selection, triggering `studioProvider.notifier.updateContent()` to run existing 500ms debounced autosave seamlessly.

---

## 3. Data Models & Data Flow

### `WritingSuggestion`

* `id` (`String`): Unique identifier for suggestion.
* `type` (`WritingSuggestionType`): `repeatedWord`, `repeatedPhrase`, `consecutiveWord`, `redundantPhrase`, `lineRedundancy`, `wordChoice`.
* `targetText` (`String`): Text pattern in document causing the suggestion.
* `message` (`String`): Descriptive advisory message for the writer.
* `suggestedReplacements` (`List<String>`): Array of proposed alternative terms.
* `range` (`TextRange?`): Character offset location within document string.

### `WritingAnalysisResult`

* `suggestions` (`List<WritingSuggestion>`): Filtered list of active suggestions.
* `totalWords` (`int`): Count of tokenized words in document.
* `uniqueWords` (`int`): Count of distinct words.
* `vocabularyRichness` (`double`): Ratio of unique to total words ($0.0 - 1.0$).
* `repetitionCount` (`int`), `redundancyCount` (`int`), `wordSuggestionCount` (`int`).

```