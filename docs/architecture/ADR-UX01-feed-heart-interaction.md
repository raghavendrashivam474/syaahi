# ADR-UX01: Feed Card Heart Interaction

**Date:** 2025-07-11
**Sprint:** UX-01
**Status:** Accepted
**Author:** UX-01 Implementation

## Context

Syaahi's poem feed displayed poem cards with no direct interaction controls.
Users had to open the full poem reader to commit a poem to their Heart (save/bookmark).
This introduced unnecessary friction for readers who wanted to express appreciation
while browsing.

The existing "Commit to Heart" feature was fully implemented in the reader screen
using `POST/DELETE /poems/:id/heart` endpoints and the `Heart` database table.

## Decision

Expose the existing Heart toggle directly on feed cards without introducing a new
"like" feature. The Heart action is the canonical save/bookmark interaction in Syaahi.

### State Architecture: Local Heart Cache with Hydration

The feed provider maintains a `Map<String, HeartStatus>` cache of per-poem heart states.

**HeartStatus state machine:**
- `unknown` → initial state, triggers hydration
- `loading` → API call in flight
- `hearted` → user has committed this poem to Heart
- `notHearted` → user has not committed this poem to Heart
- `updating` → toggle request in flight (prevents duplicate taps)
- `failed` → rolled back to previous state

**Hydration strategy:**
- Visible feed cards trigger `hydrateHeart()` via `addPostFrameCallback`
- Only poems with `unknown` status trigger an API call
- Results are cached for the lifetime of the feed provider
- Feed refresh clears the cache (auto-dispose resets state)

**Synchronization:**
- Reader checks feed cache in `initState` to prevent state flash
- Reader calls `invalidateHeart()` after toggling, forcing re-hydration on return
- Backend remains the single source of truth at all times

### Gesture Isolation

The heart button uses `HitTestBehavior.opaque` on a `GestureDetector` to absorb
taps before they reach the parent `InkWell` (card navigation). This prevents
accidental poem navigation when tapping the heart control.

### Like Count: Deferred

The `Poem` model already includes `heartCount` from the backend's `_count.hearts`
field. However, no count is displayed in this sprint to avoid visual clutter.
This can be enabled in a future sprint with a one-line UI addition.

## Alternatives Considered

| Option | Rejected Because |
|---|---|
| N+1 per-card API calls on feed load | Too many requests for 10+ cards |
| Backend enrichment (add `hearted` to feed response) | Requires backend change, out of scope |
| New dedicated "like" feature | Duplicates existing Heart functionality |
| Store heart state in `Poem` model | Model is immutable; state belongs in provider |

## Consequences

- Feed cards now show real-time heart state
- No new API endpoints or database changes required
- No regression to existing reader, My Heart, or reaction functionality
- Minor increase in API calls (one `getHeartStatus` per visible card, cached)
- Heart state stays consistent between feed and reader
