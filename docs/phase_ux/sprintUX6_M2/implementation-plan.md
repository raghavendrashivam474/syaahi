# Implementation Plan — UX-06.M2

**Date:** 2026-11-08
**Status:** Implemented

## Approach

1. Created a minimal `SyaahiBrandMark` StatelessWidget that renders the
   existing `assets/icon/syaahi.png` at a constrained height (32px default).

2. Replaced `Text('Syaahi')` with `SyaahiBrandMark()` in two AppBar titles:
   - `feed_screen.dart` (primary feed — 6 action buttons)
   - `home_screen.dart` (secondary — 1 action button)

3. No navigation behaviour added — the original `Text('Syaahi')` was not
   interactive, so the logo is also non-interactive per sprint guidelines.

## Why This Approach

- **Smallest change:** 1 new file (~25 lines), 2 modified files (1 line each)
- **No new dependencies:** Uses built-in `Image.asset`
- **No theme changes:** AppBar styling preserved via existing `AppBarTheme`
- **No navigation changes:** Auth guards, routing, and back nav untouched
- **Accessibility:** `Semantics` wrapper with label 'Syaahi'

## Responsive Behaviour

The `BoxFit.contain` constraint ensures the logo scales proportionally.
At 32px height inside a 56px AppBar, the square PNG renders at 32×32px
on all viewports — compact enough to coexist with 6 action buttons on mobile.

## Known Limitations

- The PNG has no alpha channel (RGB only). If the baked-in background
  contrasts poorly with the AppBar's `midnightDark` (#0A0E1A), a
  transparent variant should be provided.
- No SVG version exists for resolution-independent rendering.
- No separate symbol-only or wordmark-only crop exists for adaptive
  desktop/mobile differentiation.

## Files Modified

| File | Change |
|---|---|
| `lib/core/widgets/syaahi_brand_mark.dart` | New — brand mark widget |
| `lib/features/poems/presentation/feed_screen.dart` | Import + title swap |
| `lib/features/home/home_screen.dart` | Import + title swap |
