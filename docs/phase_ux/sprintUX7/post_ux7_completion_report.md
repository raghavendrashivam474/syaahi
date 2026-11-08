---

# Post-Implementation Report: UX-07 — A World of Expression

**To:** Senior Development  
**From:** Implementation Team  
**Date:** 2025-07-11  
**Branch:** `feature/ux-07-first-experience`  
**Baseline:** 47 tests passing, 0 analyze issues (commit `63d8326` on `main`)  
**Final State:** 56 tests passing, 0 analyze issues  
**Spec Reference:** UX-07 Implementation Handoff (15-section product spec)

---

## 1. Executive Summary

UX-07 implements the complete first-time user experience for Syaahi across six workstreams: story-led welcome, guest discovery, contextual interaction education, first writing journey, informative empty states, and onboarding state persistence. All acceptance criteria from the spec are met — no compulsory tutorials, no intrusive popups, no gamification, no new dependencies, no backend or schema changes. The product teaches through experience, not instruction.

**Net change:** 6 files created, 9 files modified, 9 tests added. All changes are additive or surgical replacements of existing placeholder logic. No regressions against the 47-test baseline.

---

## 2. Workstream Breakdown

### UX-07.1 — Story-Led First Encounter

**What was built:** Complete rewrite of `welcome_screen.dart` (was a 134-line stub with only signup/login buttons). The new screen is a scrollable single-page layout with:
- A hero section with the tagline "A World of Expression"
- Three pillars: Discover, Express, Connect — each with a literary description
- Three CTAs: "Explore as Guest" → `/discover`, "Join Syaahi" → `/auth/signup`, "Sign In" → `/auth/login`
- Responsive constraint (520px max width on wide screens)
- Marks `welcome_seen` via `addPostFrameCallback` so it only shows once per device

**Routing change:** `splash_screen.dart` was rewritten to check `OnboardingStorage.isWelcomeSeen()`. First-timers route to `/welcome`; returning guests route to `/discover` (not `/home`, since they may not be authenticated).

**Design rationale:** The spec explicitly rejected modals and overlays for first encounter. A full-screen welcome respects the user's attention and sets the literary tone before any content loads.

### UX-07.2 — First-Time Discovery Experience

**What was built:** `/discover` was reclassified as a public route in `app_router.dart`. Previously, the auth guard (`_redirect`) would bounce unauthenticated users to `/welcome`. Now the `isPublic` check includes `isDiscover`, allowing guests to browse the feed without an account.

**Guest limitations are enforced at the interaction layer, not the route layer:**
- Heart toggle in `feed_screen.dart` → shows `AuthPrompt` bottom sheet instead of SnackBar
- Heart toggle in `reader_screen.dart` → same `AuthPrompt` gate
- Respond action in `reader_screen.dart` → navigates to reader with `focus=resonance`, where `ResonanceSection` shows a guest prompt
- Write FAB in `feed_screen.dart` → navigates to `/write` (which is still protected by the route guard, so unauthenticated users get redirected)

**Why this approach:** The spec demanded "limited exploration, not a walled garden." Route-level gating would have blocked discovery entirely. Interaction-level gating lets guests read freely and only interrupts when they try to act — which is the natural moment to invite account creation.

### UX-07.3 — Interaction Education

**What was built:** Two complementary systems:

1. **Contextual Tips** (`contextual_tip.dart`): A dismissible bubble widget that wraps any child. Reads from `contextualSeenProvider(feature)` to ensure each tip shows only once per user. Used in three places:
   - `reader_screen.dart` → Heart section: "Tap to appreciate a poem"
   - `reader_screen.dart` → Resonance section: "Share your thoughts with the author"
   - `writer_screen.dart` → Above title field: "Write freely. There are no rules here."

2. **Optional Walkthrough** (`onboarding_walkthrough.dart`): A 5-step dialog covering Discover, Appreciate, Respond, Resonance, and Express. Triggered only by a help `IconButton` (question mark) in the feed AppBar. Skippable at any step. Marks `walkthrough_completed` on finish or skip. Never auto-triggers.

**Why no auto-trigger:** The spec's core philosophy is "teach through experience, not instruction." Auto-showing a walkthrough on first login would violate the "no compulsory tutorials" constraint. The help button makes it available without being intrusive.

### UX-07.4 — First Writing Journey

**What was built:** Two touchpoints:
- **Write FAB** on `feed_screen.dart`: A floating action button with an edit icon that navigates to `/write`. This solves the spec's concern that "the writing entry point is buried in the navigation bar."
- **Contextual tip** on `writer_screen.dart`: A single non-repeating tip above the title field. No step-by-step wizard, no template suggestions — just a gentle nudge that disappears after dismissal.

**What was deliberately not built:** No writing templates, no guided prompts, no "your first poem" flow. The spec was explicit: "Syaahi is not a writing app that teaches you how to write. It is a space where writing happens."

### UX-07.5 — First-Time Empty States

**What was built:** Three empty state improvements:
- `resonance_section.dart`: Changed from a bare container to "No responses yet. Every conversation starts with a single word."
- `discovery_empty_state.dart`: Changed "No writers found" to "No writers found yet" (the word "yet" implies temporariness)
- `heart_screen.dart` and `inbox_screen.dart`: Already had literary empty states ("All quiet.") — left untouched per the spec's instruction to only fix states that feel "unfinished"

**Guest resonance prompt:** When an unauthenticated user views a poem's resonance section, they now see a tappable prompt ("Your words belong here. Sign in to respond.") instead of a blank container. This is both an empty state fix and an auth gate.

### UX-07.6 — Onboarding State Persistence

**What was built:** `onboarding_storage.dart` — a SharedPreferences wrapper with three persistence tiers:

| Tier | Key Pattern | Scope | Cleared On |
|---|---|---|---|
| Device-level | `onboarding_device_welcome_seen` | All users on this device | Never (factory reset only) |
| User-level | `onboarding_user_{userId}_{feature}` | Per authenticated user | Logout |
| Session-level | In-memory StateNotifier | Current app session | App restart |

**Critical behavior:** `auth_providers.dart` logout now captures `userId` before clearing auth state, then calls `OnboardingStorage().clearUserStates(userId)`. This prevents cross-account leakage — if User A completes the walkthrough and logs out, User B on the same device will see contextual tips fresh.

**Why SharedPreferences over FlutterSecureStorage:** The onboarding flags are not sensitive data. Using SecureStorage would add unnecessary async complexity and platform-specific keychain behavior for boolean flags. SharedPreferences is already in the dependency tree.

---

## 3. Files Changed — Complete Manifest

### New Files (6)

| File | Lines | Purpose |
|---|---|---|
| `lib/core/storage/onboarding_storage.dart` | ~80 | SharedPreferences wrapper with device/user/session tier methods |
| `lib/features/onboarding/state/onboarding_providers.dart` | ~45 | Riverpod providers for all onboarding state |
| `lib/features/onboarding/presentation/auth_prompt.dart` | ~70 | Reusable bottom sheet for guest-to-auth conversion |
| `lib/features/onboarding/presentation/contextual_tip.dart` | ~90 | Dismissible tip bubble, reads contextualSeenProvider |
| `lib/features/onboarding/presentation/onboarding_walkthrough.dart` | ~180 | 5-step optional dialog with skip/next/finish |
| `test/features/onboarding/onboarding_test.dart` | ~120 | 7 storage unit tests + 2 WelcomeScreen widget tests |

### Modified Files (9)

| File | Nature of Change | Risk Level |
|---|---|---|
| `welcome_screen.dart` | Complete rewrite | Low (isolated screen, no shared logic) |
| `splash_screen.dart` | Complete rewrite of routing logic | **Medium** (entry point for all users) |
| `app_router.dart` | Single line added to `isPublic` check | Low |
| `reader_screen.dart` | Auth guard on heart, two ContextualTip wrappers | **Medium** (895-line file, surgical edits) |
| `feed_screen.dart` | AuthPrompt replaces SnackBar, Write FAB added, help button added | **Medium** (679-line file, multiple edit points) |
| `writer_screen.dart` | ContextualTip wrapper above title field | Low |
| `resonance_section.dart` | Guest prompt widget, empty state text change | Low |
| `discovery_empty_state.dart` | Single word change ("yet") | Minimal |
| `auth_providers.dart` | Import added, logout extended with user state cleanup | **Medium** (auth flow) |

---

## 4. Problems Faced & Mitigations

This section is unvarnished. The implementation was done via PowerShell scripting against the codebase, and several rounds of file surgery caused breakages that required iterative repair.

### 4.1 Splash Screen Brace Collapse

**Problem:** The initial approach used PowerShell's `.Replace()` with a multi-line here-string to swap the `else` branch in `_decideNextRoute`. The replacement string didn't match the actual file content due to CRLF vs LF differences and subtle whitespace variations. The result was a malformed `else` block that lost its closing brace, producing `Expected to find '}'` on compilation.

**Mitigation:** Abandoned incremental replacement entirely. Rewrote `splash_screen.dart` from scratch as a complete file, preserving the original structure but replacing the routing logic. This was the first lesson that led to the "complete rewrite over line surgery" approach for all subsequent high-risk files.

### 4.2 Duplicate `_HeartSection` in Reader Screen

**Problem:** A line-index-based `Insert()` operation intended to wrap `_HeartSection` with `ContextualTip` instead created a duplicate — the original `_HeartSection(` remained on line 498 while the wrapper's `child: _HeartSection(` was inserted on line 497. This produced 7 compile errors (duplicate widget, mismatched parentheses, orphaned closers).

**Mitigation:** String `.Replace()` kept failing to match the broken block due to invisible whitespace differences between what PowerShell read and what was actually in the file. The fix required finding the comment line above the block, scanning forward for the two `),` closers, deleting the entire broken range by line index, and inserting a clean 10-line replacement block. This took three attempts.

### 4.3 Duplicate Imports in Resonance Section

**Problem:** Inline import injection appended `../../../core/constants/colors.dart` (3-level relative path) alongside the file's existing `../../../../core/constants/colors.dart` (4-level relative path). Both resolved to the same file but Dart treated them as distinct imports, causing `duplicate_import` warnings.

**Mitigation:** Scanned for the `../../../core/constants/` pattern (the newly injected, incorrect depth) and removed those lines, preserving the original 4-level imports.

### 4.4 `poem.title` Nullability Mismatch

**Problem:** `_GuestResonancePrompt(poemTitle: poem.title)` failed because `poem.title` is `String?` in the model but the widget constructor expects `String`. This was a type error caught at compile time.

**Mitigation:** Changed to `poem.title ?? 'this poem'`, which also reads better in the UI ("Your words belong here for this poem" vs a null crash).

### 4.5 PowerShell String Interpolation Collisions

**Problem:** Two separate PowerShell parsing errors:
1. `${indent}),` — the `${}` interpolation syntax followed by `)` confused the parser (`Missing expression after ','`)
2. `` `.\nTry `` — the backtick is PowerShell's escape character, so it consumed the following character instead of rendering literally

**Mitigation:** Switched to single-quoted strings with no interpolation for all code-generation blocks. Used explicit variable concatenation where dynamic values were needed.

### 4.6 Missing OnboardingStorage Import in Auth Providers

**Problem:** The `.Replace()` call intended to add `import 'package:syaahi_app/core/storage/onboarding_storage.dart';` to `auth_providers.dart` didn't match the actual file content (likely a trailing space or CRLF mismatch). The import was silently not added, and the `OnboardingStorage()` call in `logout()` produced an undefined class error.

**Mitigation:** Switched to line-index `Insert(3, ...)` after programmatically confirming the import was absent. This is more fragile than content matching but was the only approach that worked given the whitespace inconsistencies.

### 4.7 Feed SnackBar → AuthPrompt Replacement Failure

**Problem:** Multi-line regex `.Replace()` to swap the `ScaffoldMessenger.of(context).showSnackBar(...)` block with `AuthPrompt.show(...)` failed because the actual indentation in the file didn't match the regex pattern. The SnackBar remained in place.

**Mitigation:** Line-index search for `ScaffoldMessenger.*showSnackBar` and `Sign in to commit`, identified the exact range, deleted it, and inserted the `AuthPrompt.show()` call with correct indentation.

### 4.8 Broader Lesson: PowerShell File Surgery Is Fragile

The recurring theme across all seven issues above is that **line-by-line and string-replacement file editing via PowerShell is inherently fragile** for Dart/Flutter codebases. Whitespace, CRLF, indentation depth, and brace matching create a combinatorial explosion of edge cases. The implementation would have been significantly faster and less error-prone with:
- A proper AST-aware code modification tool (e.g., `dart fix` custom rules, or `codemod`)
- Direct file editing in an IDE with compile-time feedback
- Git-based diff review after each change rather than batch scripting

This is noted for future sprint planning.

---

## 5. Testing

### What's Covered (9 new tests)

**OnboardingStorage unit tests (7):**
- `isWelcomeSeen` returns false by default
- `markWelcomeSeen` persists correctly
- `isUserFeatureCompleted` returns false for unknown user
- `markUserFeatureCompleted` persists per-user
- `clearUserStates` removes only the target user's keys
- `clearAll` removes all onboarding keys
- Device-level keys survive `clearUserStates`

**WelcomeScreen widget tests (2):**
- Renders hero tagline and three pillar headings
- "Explore as Guest" button navigates to `/discover`

### What's Not Covered (Known Gaps)

- **ContextualTip dismissal behavior** — no test verifies that dismissing a tip sets the `contextualSeen` flag
- **AuthPrompt bottom sheet** — no widget test for the guest-to-auth flow
- **OnboardingWalkthrough step navigation** — no test for next/skip/finish
- **Splash screen routing logic** — no test for the welcome_seen → /welcome vs /discover branching
- **Feed Write FAB** — no test for navigation to `/write`
- **Guest resonance prompt** — no test for the tappable prompt in ResonanceSection
- **Logout user-state cleanup** — no integration test verifying `clearUserStates` is called on logout

These gaps are acceptable for the current sprint given the spec's testing requirements focused on storage correctness and welcome screen rendering. They should be addressed in a follow-up testing sprint before production release.

---

## 6. Git State & Merge Readiness

**Current branch:** `feature/ux-07-first-experience` (uncommitted changes, awaiting commit)

**Blocking dependency:** UX-06.M2 (`feature/ux-06-m2-brand-mark`, tag `v-UX-06.M2` at `971c886`) is **not yet merged into `main`**. The spec requires UX-06.M2 to be on `main` before UX-07 is finalized. The merge sequence must be:

1. Merge `feature/ux-06-m2-brand-mark` → `main`
2. Rebase `feature/ux-07-first-experience` onto updated `main`
3. Resolve any conflicts (likely in `welcome_screen.dart` and `splash_screen.dart` if UX-06.M2 touched them)
4. Merge `feature/ux-07-first-experience` → `main`
5. Tag `v-UX-07`

**No conflicts expected** with UX-06.M2 based on the file manifests, but the rebase step is mandatory per the spec's git protocol.

---

## 7. Spec Compliance Checklist

| Constraint | Status | Notes |
|---|---|---|
| No compulsory tutorials | ✅ | Walkthrough is help-button-triggered only |
| No intrusive popups | ✅ | AuthPrompt is a bottom sheet, not a dialog; tips are dismissible |
| No repeated explanations | ✅ | All tips and prompts are one-shot per user/device |
| No gamification | ✅ | No badges, streaks, progress bars, or achievement systems |
| No new dependencies | ✅ | Uses existing `shared_preferences` |
| No backend/schema changes | ✅ | All state is client-side |
| No cross-account leakage | ✅ | User-level keys include userId, cleared on logout |
| Literary tone preserved | ✅ | All copy follows Syaahi's voice ("Every conversation starts with a single word") |
| Responsive layout | ✅ | Welcome screen constrained to 520px on wide viewports |
| Guest can discover | ✅ | `/discover` is public; interaction gates are at the action level |

---

## 8. Recommendations for Review

1. **Manual QA on web** — The welcome screen, splash routing, and guest discovery flow should be tested in a browser. SharedPreferences behavior on web (localStorage-backed) should be verified for persistence across tab closes.

2. **Logout → re-login flow** — Verify that contextual tips reappear for a new user after the previous user logs out. This is the cross-account leakage scenario.

3. **Wide viewport** — Check the welcome screen at 1440px+ to confirm the 520px constraint renders correctly and doesn't look lost.

4. **Walkthrough accessibility** — The 5-step dialog uses `showDialog` with a `StatefulBuilder`. Verify keyboard navigation and screen reader behavior if accessibility is a current priority.

5. **Consider codemod for future sprints** — The PowerShell file surgery approach cost significant time in debugging. For UX-08 and beyond, I recommend either direct IDE editing or a Dart-aware code transformation tool.

---

**End of report.**