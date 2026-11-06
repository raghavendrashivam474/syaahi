# UX-05 Implementation Plan

**Sprint:** UX-05 — Reader Experience & Reading Continuity
**Baseline:** v-UX-04 (0525744)
**Branch:** ux-05/reader-experience

## Changes Summary

All changes are confined to two files:

### 1. `syaahi-app/lib/features/poems/presentation/reader_screen.dart`

| Area | Change | UX Problem |
|------|--------|------------|
| Layout | `ConstrainedBox(maxWidth: 680)` centered | P1: No reading width |
| Layout | `LayoutBuilder` with responsive padding (48px on >720px) | P1: Wide screen |
| Typography | Line height 1.7 → 1.8, body 22px → 21px | P6: Hierarchy |
| Typography | Title 34px mobile / 42px wide | P8: Title scaling |
| Typography | Byline 13px → 14px | P6: Hierarchy |
| Stanzas | Split content by `\n\n`, render with 24px gaps | P2: No stanza separation |
| Loading | Branded loading: icon + spinner + "Opening poem..." | P3: Abrupt loading |
| Author | `CircleAvatar` with `avatarUrl` or initial | P4: Minimal author |
| Continuity | "More from [Author]" card at bottom | P5: No continuity CTA |
| Empty | Graceful fallback for empty content | P7: Empty content |
| Code | Extracted `_OwnerMenu`, `_AuthorByline`, `_PoemBody`, `_AuthorContinuity` | Maintainability |

### 2. `syaahi-app/test/features/poems/presentation/reader_screen_test.dart` (new)

24 tests covering model parsing, content formatting, filters, heart status, and all reader widget states.

## Preserved (no changes)

- Back navigation (canPop/pop with /home fallback)
- 404 error handling
- Retry behaviour
- Heart toggle with feed cache invalidation
- Reaction toggle with optimistic update
- Delete poem flow
- All metadata badges
- Router, model, repository, providers
- No new dependencies
