# Brand Asset Inventory — UX-06.M2

**Date:** 2026-11-08
**Sprint:** UX-06.M2 — Brand Mark Integration
**Status:** S0 Discovery Complete — Pending Visual Confirmation

---

## 1. Discovered Assets

| Field | Value |
|---|---|
| **Asset name** | syaahi.png |
| **Location** | `syaahi-app/assets/icon/syaahi.png` |
| **Format** | PNG (8-bit, ColorType 2 = RGB) |
| **Dimensions** | 1254 × 1254 px |
| **File size** | 2.01 MB |
| **Transparency** | **No** (RGB only, no alpha channel) |
| **Composition** | *Pending visual confirmation* (likely combined symbol + wordmark based on square aspect) |
| **Variants** | **None** — no SVG, no dark/light variants, no symbol-only, no wordmark-only |
| **Existing usage** | Launcher icon only (`flutter_launcher_icons` in `pubspec.yaml:50`) |
| **In-app rendering** | **None** — the PNG is not referenced by any `Image.asset` or `AssetImage` call |
| **Suitability** | *Pending visual confirmation* — no-alpha RGB square may have baked-in background |
| **Recommendation** | *Pending visual confirmation* |

## 2. Current Brand Presentation (In-App)

The application does **not** currently render the PNG logo anywhere in its UI.

Instead, branding is achieved through:

| Screen | Symbol | Text | Style |
|---|---|---|---|
| Splash (`splash_screen.dart:84-98`) | `Icons.edit_note_rounded` (80px) | `SyaahiStrings.appName` | Cormorant Garamond 64px, goldBase |
| Welcome (`welcome_screen.dart:34-48`) | `Icons.edit_note_rounded` (64px) | `SyaahiStrings.appName` | Cormorant Garamond 56px, goldBase |
| Feed header (`feed_screen.dart:49`) | None | `Text('Syaahi')` | Default AppBar title |
| Home header (`home_screen.dart:17`) | None | `Text('Syaahi')` | Default AppBar title |
| 404 screen (`app_router.dart:135`) | None | `Text('Not Found')` | Default AppBar title |

## 3. Header Modification Targets

| File | Line | Current Title | Action Buttons | Priority |
|---|---|---|---|---|
| `feed_screen.dart` | 49 | `Text('Syaahi')` | 6 (search, filter, bell, heart, profile, logout) | **Primary** |
| `home_screen.dart` | 17 | `Text('Syaahi')` | 1 (logout) | Secondary |

## 4. Key Constraints

- The PNG has **no transparency** — a solid background is baked in
- The PNG is **1254×1254** (square) — likely designed as a launcher icon, not a header wordmark
- No SVG or vector version exists
- No symbol-only or wordmark-only crop exists
- The app's de facto brand symbol is `Icons.edit_note_rounded` in gold

## 5. Pending Decisions

- [ ] Visual confirmation of PNG content (symbol? wordmark? combined? background color?)
- [ ] Whether the PNG can be used directly in the dark AppBar
- [ ] Whether to use the existing PNG, the Material icon pattern, or request a new asset

---

*No code changes made. S0 discovery only.*
