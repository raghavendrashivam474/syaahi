# Syaahi Studio — User Journeys

## Journey 1: Android — Quick Capture to Published Poem
1. **Entry:** User opens Syaahi and taps the central "Write" action.
2. **Editor view:** Studio opens in focused writing mode.
3. **Capture:** User types or pastes an initial line or thought. Autosave silently commits the draft to local state.
4. **Explore:** User selects a word, taps "Synonyms" or "Rhymes" in the contextual toolbar, and selects an alternative.
5. **Format:** User selects the "Couplet" format helper, applying double-space stanza breaks.
6. **Preview:** User taps "Preview", testing Cormorant Garamond vs Google Sans in Light/Dark manuscript modes.
7. **Publish:** User chooses Emotion (`Longing`), Language (`Hindi`), Title (`साया`), and taps "Publish".
8. **Outcome:** Draft transfers to live database via `POST /poems`, clears local draft, and appears in Syaahi Flow.

## Journey 2: Desktop — Spacious Two-Pane Composition
1. **Entry:** User accesses Syaahi Studio via web browser or desktop wrapper.
2. **Workspace:** Wide canvas opens with left editor pane and right context sidebar.
3. **Write & Explore:** User types on the left pane while viewing saved fragments and rhyming suggestions on the right pane simultaneously.
4. **Conversational Poetry:** User selects "Conversational Format". The editor splits into side-by-side author-speaker blocks (Speaker A / Speaker B).
5. **Revision:** User compares current draft against Revision #3 from 2 hours ago in a side-by-side diff view.
6. **Export:** User exports the final poem as a beautifully formatted PNG card or publishes directly.

## Journey 3: Draft Lifecycle
[New Input] ──► Local Offline Draft ──► Auto-Sync Draft (Private) ──► Publish ──► Live Poem
│ │
└──► Discard └──► Delete Draft

text

- **Draft Creation:** Instantly generated upon first keystroke.
- **Persistence:** Local-first storage ensures zero loss on network failure or screen exit.
- **Conversion:** Publishing converts the private draft into a public/published `Poem`.

## Journey 4: Fragment Lifecycle
[Fleeting Line] ──► Save as Fragment ──► Private Collection ──► Insert into Draft

text

- **Capture:** Highlight a phrase or type a standalone line -> tap "Save Fragment".
- **Storage:** Fragment stored in local storage / private table tagged with emotion or keywords.
- **Reuse:** While writing a new poem, user opens "Fragments Drawer" and taps "Insert at Cursor".

## Journey 5: Preview & Publication
1. User completes draft editing.
2. Taps **Preview** -> views card rendering with emotion emoji, typography styling, and author signature.
3. Selects distribution options (Publish to Feed, Add to Room, or Export as Image).
4. Taps **Confirm Publish** -> calls backend `POST /poems`.
