# UX-05 Reconnaissance Report

**Sprint:** UX-05 — Reader Experience & Reading Continuity
**Baseline:** v-UX-04 (commit 0525744)
**Branch:** ux-05/reader-experience
**Date:** 2026-11-06

---

## 1. Existing Reader Architecture

### Entry Point
- **File:** `lib/features/poems/presentation/reader_screen.dart` (579 lines)
- **Route:** `/poem/:id` via GoRouter (`lib/core/router/app_router.dart`)
- **Widget:** `ReaderScreen` (ConsumerWidget) — receives `poemId`
- **Data:** `poemByIdProvider(poemId)` → `FutureProvider.autoDispose.family<Poem, String>`
- **State management:** Riverpod (ConsumerWidget + ConsumerStatefulWidget)

### Widget Hierarchy

```text
ReaderScreen (ConsumerWidget)
├── Scaffold
│ ├── AppBar (transparent, back nav, owner-delete menu)
│ └── body: poemAsync.when()
│ ├── loading → CircularProgressIndicator
│ ├── error → _ReaderErrorView (404-aware, retry)
│ └── data → _ReaderView (ConsumerStatefulWidget)
│ └── SingleChildScrollView
│ └── Column
│ ├── Gold divider
│ ├── Title (CormorantGaramond 38px gold)
│ ├── Byline row (author, emotion, theme badges)
│ ├── Poem body (SelectableText, CormorantGaramond 22px)
│ ├── Gold divider
│ ├── Attribution ("— Author", tappable)
│ ├── _HeartSection
│ └── _ReactionsSection
```

### State in _ReaderViewState
- `_hearted` (bool) — initialized from feed cache, then hydrated from API
- `_heartLoading` (bool)
- `_reactions` (List<ReactionSummary>) — loaded from API
- `_reactionsLoading` (bool)

## 2. Existing Reader UI and States

| State | Current Implementation | Assessment |
|-------|----------------------|------------|
| Loading | Centered CircularProgressIndicator (gold) | Functional but abrupt |
| Success | _ReaderView with full poem | Core works, needs polish |
| 404 Error | _ReaderErrorView with specific message | Good — preserve |
| API Error | _ReaderErrorView with retry button | Good — preserve |
| Empty title | Conditional rendering (if title != null) | Good |
| Empty content | No explicit handling | Gap |
| Long poem | SingleChildScrollView, no constraints | Stretches on wide screens |
| Long title | Wraps naturally at 38px | Could dominate small screens |

## 3. Existing Poem Data Flow

### Model (`lib/shared/models/poem.dart`)
- **Poem:** id, title?, content, language, emotion?, theme?, author, reactionCount, heartCount, createdAt
- **PoemAuthor:** id, username, displayName, avatarUrl?, bio?
- **PoemLanguage:** english, hindi, urdu
- **PoemEmotion:** love, longing, hope, solitude, anger, gratitude (with emoji)
- **ReactionType:** 6 types with labels
- **ReactionSummary:** type, label, count, reacted

### Repository (`lib/features/poems/data/poems_repository.dart`)
- `getPoem(id)` → Poem
- `getHeartStatus(poemId)` → bool
- `commitToHeart(poemId)` / `removeFromHeart(poemId)`
- `getReactions(poemId)` → List<ReactionSummary>
- `addReaction(poemId, type)` / `removeReaction(poemId, type)`
- `deletePoem(id)`

### Providers (`lib/features/poems/state/poems_providers.dart`)
- `poemsRepositoryProvider` — singleton
- `poemByIdProvider` — FutureProvider.family, autoDispose
- `feedProvider` — StateNotifier with heart cache
- `heartProvider` — StateNotifier for saved poems
- `userPoemsProvider` — FutureProvider.family for author poems

## 4. Existing Author Navigation

- **Byline:** `GestureDetector` → `context.push('/profile/${widget.poem.author.username}')`
- **Attribution:** Same pattern at bottom of poem
- **Route:** `/profile/:username` → `AuthorProfileScreen` (public, no auth required)
- **Profile screen:** Delegates to `AuthorProfileView` widget
- **Avatar:** `PoemAuthor.avatarUrl` exists but is NOT displayed in reader

## 5. Existing Save/Unsave Interaction

- **_HeartSection:** GestureDetector with Container
- **Toggle:** `_toggleHeart()` calls repo, invalidates feed cache
- **Visual:** Gold border + fill when hearted, muted when not
- **Loading:** Small CircularProgressIndicator replaces icon
- **Feed sync:** `ref.read(feedProvider.notifier).invalidateHeart(poem.id)`

## 6. Existing Entry Points to Reader

| Origin | Navigation | Stack Behavior |
|--------|-----------|----------------|
| Feed (`_PoemCard`) | `context.push('/poem/${poem.id}')` | Push — back returns to feed |
| Heart Screen | `context.push('/poem/...')` (assumed) | Push — back returns to heart |
| Author Profile | Via poem list (assumed push) | Push — back returns to profile |
| Discovery | Via search results (assumed push) | Push — back returns to discovery |
| Notifications | Via notification tap | Push — back returns to inbox |

## 7. Existing Responsive Behavior

- **No max-width constraint** — content stretches to full screen width
- **Padding:** `EdgeInsets.fromLTRB(32, 16, 32, 64)`
- **SingleChildScrollView** handles vertical overflow
- **No LayoutBuilder or MediaQuery-based adjustments**
- **Text sizes are fixed** (title 38px, body 22px, byline 13px)

## 8. Reusable Components

| Component | Location | Reuse Potential |
|-----------|----------|----------------|
| `SyaahiColors` | `lib/core/constants/colors.dart` | All color references |
| `SyaahiSizes` | `lib/core/constants/sizes.dart` | All spacing/sizing |
| `_MetaBadge` | reader_screen.dart | Could extract if needed elsewhere |
| `_HeartSection` | reader_screen.dart | Reader-specific |
| `_ReactionsSection` | reader_screen.dart | Reader-specific |
| `_ReaderErrorView` | reader_screen.dart | Reader-specific |
| GoogleFonts.cormorantGaramond | Throughout | Poetry typography |
| GoogleFonts.inter | Throughout | UI typography |

## 9. Identified UX Problems

### P1 — No Reading Width Constraint (High)
On tablets and desktop, poem text stretches edge-to-edge. Long lines are hard to read. Need a max-width (~680px) centered layout.

### P2 — No Stanza Separation (High)
`SelectableText` renders `poem.content` as a single block. Double newlines (`\n\n`) in the content create visual gaps, but there is no deliberate stanza spacing. Stanzas should have clear visual separation.

### P3 — Loading State is Abrupt (Medium)
A bare centered spinner with no context. A calmer, branded loading presentation would improve the experience.

### P4 — Author Identity is Minimal (Medium)
Byline is 13px italic text. The author's `avatarUrl` field exists but is unused in the reader. A small avatar would strengthen attribution.

### P5 — No Reading Continuity CTA (Medium)
After finishing a poem, there is no prompt to explore the author's other work. The bottom attribution links to the profile, but a more explicit "More from [Author]" would improve continuity.

### P6 — Typography Hierarchy Could Be Stronger (Low)
Title (38px gold) and body (22px white) have good contrast, but the byline (13px muted) and metadata badges (11px) are very small. Slight adjustments would improve scannability.

### P7 — No Empty Content Handling (Low)
If `poem.content` is empty, the reader shows a blank area. Should handle gracefully.

### P8 — No Large-Screen Title Scaling (Low)
38px title on a small phone is dominant. Could scale down slightly on narrow viewports.

## 10. Proposed Implementation Boundaries

### In Scope (UX-05)
- Reading surface layout improvements (max-width, padding, spacing)
- Stanza-aware poem body rendering
- Typography refinements (line height, hierarchy)
- Author avatar in byline
- "More from author" continuity link
- Calmer loading state
- Empty content handling
- Responsive title sizing
- All changes within `reader_screen.dart` and possibly new widget files in the same directory

### Out of Scope
- No model changes (Poem, PoemAuthor remain as-is)
- No repository changes
- No router changes
- No new backend features
- No new dependencies
- No changes to feed, heart, discovery, or profile screens
- No new reaction types or social features

## 11. Architectural Limitations

- `SelectableText` does not support rich text formatting per-stanza. If stanza-aware rendering is needed, we may need to split content and render multiple `SelectableText` widgets or use `Text.rich` with `TextSpan`.
- `poemByIdProvider` is `autoDispose` — the poem data is re-fetched on every visit. This is fine for now but means no offline caching.
- The reader manages heart/reaction state locally (`ConsumerStatefulWidget`) rather than through Riverpod. This works but means state is lost on rebuild. Preserving this pattern for UX-05.

## 12. Relevant Tests

- No reader-specific tests found in the repository.
- Sprint will add widget tests for reader states.

---

*Reconnaissance complete. Proceeding to implementation plan and UX-05.S2.*
