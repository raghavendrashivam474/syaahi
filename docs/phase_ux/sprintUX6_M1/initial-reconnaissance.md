# UX-06.M1 — Initial Reconnaissance Report

**Date:** 2026-11-07
**Branch:** `hotfix/ux-06-reader-response-flow`
**Baseline:** `main` at `v-UX-06` (commit `cc8693a`)
**Flutter SDK:** 3.44.2 (Dart 3.12.2)

## Repository State

- Working branch checked out from `v-UX-06` tag.
- 6 files already modified in working tree (prior partial hotfix attempt).
- No uncommitted stashes or conflicts.
- `docs/phase_ux/sprintUX6/` contains prior UX-06 sprint reports.

## Modified Files (Pre-existing)

| File | Change Summary |
|---|---|
| `lib/core/network/api_client.dart` | Token retrieval wrapped in try/catch with 3s timeout |
| `lib/core/router/app_router.dart` | Added `?focus` query parameter parsing |
| `lib/features/poems/presentation/feed_screen.dart` | Respond wrapped in GestureDetector |
| `lib/features/poems/presentation/reader_screen.dart` | ResonanceSection integrated, focus/scroll support added |
| `lib/features/resonance/presentation/response_composer.dart` | `width: double.infinity` fix |
| `test/features/poems/presentation/reader_screen_test.dart` | FakeResonanceRepository added |

## Reproduction

### Reader Loading Stall (RC-1)
1. Open app in Flutter Web.
2. Tap any poem card in the feed.
3. Reader shows "Opening poem..." indefinitely.
4. Root cause: `TokenStorage.getToken()` hangs on Flutter Web due to FlutterSecureStorage/localStorage race.

### Respond Not Interactive (RC-3)
1. Tap "Respond" label on a poem card.
2. Reader opens normally (no Resonance focus).
3. Root cause: Respond was a static Row with no gesture handler.

## Key Findings

- `TokenStorage` located at `lib/core/storage/token_storage.dart` (uses `FlutterSecureStorage`).
- `ResonanceSection` constructor: `const ResonanceSection({super.key, required this.poem})`.
- GoRouter config at `lib/core/router/app_router.dart`, poem route: `/poem/:id`.
- `flutter analyze`: No issues found.
- Existing test baseline: 36 tests, all passing.