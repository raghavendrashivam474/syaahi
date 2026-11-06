---

# Post-Sprint Report: UX-02 — Profile & Author Experience

**To:** Senior Developer
**From:** UX-02 Developer
**Date:** 11 July 2025
**Sprint:** UX-02 (phase_ux)
**Predecessor:** UX-01 — Feed Interaction Improvements
**Baseline:** Commit `4d39dc9` (tag: `v-UX-01`)

---

## Executive Summary

UX-02 set out to improve the Profile & Author Experience in Syaahi so that readers can discover writers and explore their published works. Prior to this sprint, the application supported viewing only the logged-in user's own profile. The journey from reading a poem to discovering its author did not exist, despite the backend fully supporting public author endpoints.

This sprint delivered a complete author profile experience — public profiles, discovery navigation from feed and reader, cursor-paginated poem listings, and comprehensive state handling — while preserving all existing functionality from UX-01 and earlier sprints.

**Outcome:** 5 new files, 4 modified files, 0 deleted files. Static analysis clean. All 8 existing tests passing. No regressions in out-of-scope modules.

---

## 1. Reconnaissance Findings (UX-02.S1)

Before any implementation, a full reconnaissance of the existing codebase was conducted across eight priority targets. The key findings were:

| Area | Finding |
|---|---|
| **Profile screen** | Single file (`profile_screen.dart`, ~250 lines). No data/state/presentation separation, unlike every other feature in the codebase. |
| **Whose profile?** | Only the authenticated user's own. Read directly from `authProvider.user`. No parameterized route for other authors. |
| **Backend API** | Fully available and public: `GET /users/:username` (profile), `GET /users/:username/poems` (cursor-paginated), `PATCH /users/me` (editing). The Flutter client never called any of these. |
| **Navigation gaps** | No tap target on author names in feed cards or the poem reader. The only way to reach a profile was the app bar icon, which always opened the user's own profile. |
| **Data models** | Two overlapping models (`User` for auth, `PoemAuthor` embedded in `Poem`) with no dedicated public author representation. |
| **Pagination** | Backend supports cursor-based pagination. Client fetched a flat 50 poems in one request. |
| **Profile editing** | Backend supports `PATCH /users/me`. No Flutter client or UI existed. |
| **States** | Loading and error handled for poem list only. No empty state, no 404 handling, no header loading state. |

These findings were documented in the reconnaissance report and formed the basis for the architectural decisions that followed.

---

## 2. Architecture Decisions

An Architecture Decision Record (`ADR-UX02-author-profile-experience.md`) was drafted and reviewed before implementation. The key decisions were:

### 2.1 Route Architecture
- `/profile` remains the authenticated user's own profile entry point. No redirect.
- `/profile/:username` opens any author's public profile.
- Both routes render the same shared `AuthorProfileView` widget, differentiated by an `isOwnProfile` boolean.
- Own-profile detection is a simple read-only comparison: `authProvider.user?.username == username`.

### 2.2 AuthorProfile Model
A new public-only model was created, deliberately excluding private fields:

| Field | Included | Rationale |
|---|---|---|
| `id`, `username`, `displayName` | Yes | Core identity |
| `bio`, `avatarUrl` | Yes | Public literary presence |
| `createdAt` | Yes | "Joined" metadata |
| `poemCount` | Yes | Literary output indicator |
| `email` | **No** | Private account data |
| `followers`, `following` | **No** | Out of scope per sprint brief |

The existing `User` and `PoemAuthor` models were left untouched to preserve backward compatibility.

### 2.3 Repository Separation
A new `ProfileRepository` was created for `/users/*` API operations, separate from the existing `PoemsRepository` which owns `/poems/*`. This avoids a single repository growing to cover unrelated API domains. The existing `getUserPoems` method in `PoemsRepository` was preserved for backward compatibility.

### 2.4 Provider Architecture
- `authorProfileProvider` — `FutureProvider.autoDispose.family` for single profile fetch.
- `authorPoemsProvider` — `StateNotifierProvider.autoDispose.family` with full cursor pagination, load-more guards, list preservation on error, and refresh capability.

---

## 3. What Was Implemented

### 3.1 Foundation Layer (S2)

**`shared/models/author_profile.dart`** (81 lines)
Public author model with `fromJson` factory mapping directly to the backend's `GET /users/:username` response shape, including `_count.poems`. Includes a convenience `fromUser` factory for the own-profile fast path and a computed `initial` getter for avatar fallback.

**`features/profile/data/profile_repository.dart`** (87 lines)
Two methods: `getUserProfile(username)` and `getAuthorPoems(username, {cursor, limit})`. Both return typed results. Error handling distinguishes 404 (author not found) from network failures and server errors by preserving the HTTP status code on the exception object.

**`features/profile/state/profile_providers.dart`** (111 lines)
Repository provider, profile future provider, and a full `AuthorPoemsNotifier` state machine with `load()`, `loadMore()`, and `refresh()` methods. Safeguards include duplicate-request prevention via `isLoading`/`isLoadingMore` guards, list preservation on pagination errors, and `autoDispose` lifecycle management.

### 3.2 Presentation Layer (S2–S3)

**`features/profile/presentation/author_profile_view.dart`** (589 lines)
The core shared widget. Implemented as a `ConsumerStatefulWidget` to support a `ScrollController` for scroll-triggered pagination. Contains:

- **Profile header:** Avatar (with network image support and initial fallback), display name, username, bio, poem count, and join date.
- **Published works section:** Full poem tile list with language and emotion metadata.
- **Own-profile deletion:** `PopupMenuButton` with confirmation dialog, gated by `isOwnProfile`. Calls `poemsRepositoryProvider.deletePoem` and refreshes both profile and poem providers.
- **State views:** Loading spinner, error with retry, 404 "writer not found" with person-off icon, and empty poems with contextual messaging (own vs. other).
- **Pull-to-refresh:** `RefreshIndicator` that invalidates both profile and poem providers.
- **Scroll pagination:** Triggers `loadMore()` when within 300px of the bottom.

**`features/profile/presentation/author_profile_screen.dart`** (35 lines)
Thin route target for `/profile/:username`. Determines `isOwnProfile` by comparing the path parameter against the authenticated user's username, then delegates to `AuthorProfileView`.

**`features/profile/profile_screen.dart`** (43 lines, refactored from ~250)
Reduced from a monolithic screen to a thin wrapper that reads `authProvider.user` and delegates to `AuthorProfileView` with `isOwnProfile: true`. The "not signed in" guard is preserved.

### 3.3 Navigation Integration (S4)

**`core/router/app_router.dart`** (+1 route)
Added `GoRoute(path: '/profile/:username')` pointing to `AuthorProfileScreen`. Placed after `/profile` to avoid route conflicts.

**`features/poems/presentation/feed_screen.dart`** (modified)
The author avatar and "by displayName" text in `_PoemCard` are now wrapped in a `GestureDetector` with `HitTestBehavior.opaque`. This follows the exact pattern established in UX-01 for the heart button — opaque hit testing prevents the tap from reaching the parent `InkWell` (which navigates to the poem reader). The author row uses `Flexible` instead of `Expanded` to accommodate the gesture wrapper within the existing `Row` layout.

**`features/poems/presentation/reader_screen.dart`** (modified)
Two navigation entry points added:
- **Byline** ("by displayName" at the top of the poem) — wrapped in `GestureDetector` with subtle underline decoration.
- **Attribution** ("— displayName" at the bottom) — wrapped in `GestureDetector` inside the existing `Center` widget, also with underline.

Both navigate to `/profile/:username` using the poem's embedded `PoemAuthor.username`.

---

## 4. Problems Encountered and Mitigations

This sprint surfaced several implementation challenges, primarily related to the monorepo structure and the fragility of automated string replacement on Dart source files.

### 4.1 Working Directory Drift (Repeated)

**Problem:** The monorepo structure (`syaahi/` → `syaahi-app/` → `lib/`) caused the PowerShell working directory to shift unpredictably between the monorepo root and the app directory across blocks. This resulted in:
- A phantom `syaahi-app/syaahi-app/` nested directory being created.
- `profile_providers.dart` being written to a non-existent path and silently lost.
- A stray `lib/` directory appearing at the monorepo root.
- File-not-found errors when subsequent blocks tried to read files from doubled paths.

**Mitigation:** Identified the root cause as `$App = ".\syaahi-app\lib"` being evaluated when the shell was already inside `syaahi-app/`. Corrected all subsequent paths to use `.\lib` directly. Cleaned up phantom directories with `Remove-Item`. Added explicit directory verification steps before file operations.

**Lesson:** In monorepo environments, always verify `Get-Location` before constructing relative paths. A future improvement would be to anchor all paths to an absolute `$PSScriptRoot` variable.

### 4.2 Non-Existent Material Icon

**Problem:** The empty-state view used `Icons.feather_outlined`, which does not exist in Flutter's Material Icons set. This was caught by `flutter analyze`.

**Mitigation:** Replaced with `Icons.edit_note_outlined`, which conveys a similar writing/authoring metaphor and is available in the current Flutter SDK.

### 4.3 Greedy Regex Corrupted Widget Hierarchy

**Problem:** When converting `AuthorProfileView` from `ConsumerWidget` to `ConsumerStatefulWidget` (to add `ScrollController`), a series of regex replacements were applied to the file. The replacements were too broad:
- They changed `build(BuildContext context, WidgetRef ref)` to `build(BuildContext context)` in **all** widget classes, including child `ConsumerWidget` subclasses (`_PoemsSection`, `_AuthorPoemTile`) that legitimately need the `WidgetRef` parameter.
- They replaced all bare `username` references with `widget.username`, including in child widgets that receive `username` as a direct constructor field, not through a `widget` accessor.

This produced 12 compile errors including `invalid_override`, `undefined_identifier`, and `undefined_class`.

**Mitigation:** Abandoned the regex approach entirely. Rewrote `author_profile_view.dart` from scratch with the correct widget type hierarchy:
- `AuthorProfileView` → `ConsumerStatefulWidget` (needs `ScrollController` lifecycle)
- `_PoemsSection` → `ConsumerWidget` (needs `ref` for provider reads, uses direct fields)
- `_AuthorPoemTile` → `ConsumerWidget` (needs `ref` for delete operations, uses direct fields)
- All stateless widgets (`_ProfileHeader`, `_MetaChip`, `_EmptyPoemsView`, `_ErrorView`, `_NotFoundView`) → `StatelessWidget`

This resolved all 12 errors and produced a clean `flutter analyze`.

**Lesson:** Automated string replacement on structured source code is inherently fragile. When widget type hierarchies are involved, a full rewrite is safer than surgical regex.

### 4.4 Reader Screen String Replacement Silent Failure

**Problem:** The initial attempt to add tap handlers to the reader screen used `.Replace()` with a multi-line string literal. The replacement for the attribution text failed silently because the actual source had the `Text` widget nested inside `Center(child: Text(...))`, while the search string assumed a flat `Text(...)` at the indentation level of the `Center`'s sibling. The `.Replace()` call returned the original string unchanged, and no error was raised.

**Mitigation:** Restored the file from git (`git checkout --`). Inspected the exact line content using `Select-String` with context. Switched to a line-number-based replacement strategy using `ArrayList.RemoveRange()` and `InsertRange()`.

### 4.5 Line-Index Shifting During Sequential Replacement

**Problem:** When applying two line-number replacements to the reader file (byline at line 303, attribution at line 342), replacing the byline first shifted all subsequent line indices. The attribution replacement then targeted the wrong lines, corrupting the file with 37 syntax errors.

**Mitigation:** Restored from git again. Applied replacements in **reverse order** — attribution first (higher line numbers), then byline (lower line numbers). This ensures the first replacement does not affect the indices of the second target. This is a standard technique in source code manipulation that was overlooked in the first attempt.

**Lesson:** When performing multiple positional edits on a file, always work from the bottom up.

### 4.6 Unused Imports

**Problem:** `flutter analyze` flagged unused `colors.dart` imports in `author_profile_screen.dart` and `profile_screen.dart` after refactoring removed the code that referenced `SyaahiColors`.

**Mitigation:** Removed the unused import lines via filtered `Set-Content`. This was straightforward and caught by the analyze step before it could accumulate.

---

## 5. Verification Results

| Check | Result |
|---|---|
| `flutter analyze` | **PASS** — No issues found |
| `flutter test` | **PASS** — 8/8 tests passed |
| Out-of-scope file integrity | **PASS** — No heart, reaction, notification, auth, or publishing files modified |
| Critical model preservation | **PASS** — `poem.dart`, `user.dart`, `poems_repository.dart`, `poems_providers.dart`, `auth_providers.dart` all unchanged |
| Modified file count | **4** (router, feed, reader, profile) |
| New file count | **5** (model, repository, providers, screen, view) |
| Deleted file count | **0** |

Manual verification on device/emulator is still required for the full navigation journey, responsive layouts, and edge cases (404, empty, network failure).

---

## 6. Known Limitations and Deferred Work

| Item | Status | Rationale |
|---|---|---|
| Profile editing UI | Deferred | Backend supports `PATCH /users/me`. Requires a separate sprint with form validation, avatar upload, and optimistic updates. |
| Shared poem card component | Deferred | `_PoemCard` (feed) and `_AuthorPoemTile` (profile) serve similar purposes with different implementations. Unification would reduce drift but is not urgent. |
| `userPoemsProvider` redundancy | Accepted | The old provider in `poems_providers.dart` is partially superseded by `authorPoemsProvider` but preserved to avoid breaking changes. |
| Avatar image upload | Deferred | Backend field exists. No client UI or image picker integration. |
| `AuthorProfile.fromUser` placeholders | Accepted | `createdAt` and `poemCount` default to `DateTime.now()` and `0` when constructed from the local `User` object. The API-fetched profile is preferred whenever possible. |

---

## 7. Recommendations

1. **Profile editing** should be the next sprint after UX-02. The backend contract is ready; only the Flutter UI and `updateMe` client method are needed.
2. **Manual testing** should be performed on a real device or emulator before merging, particularly the tap-target isolation in feed cards (author tap vs. card tap vs. heart tap).
3. **Consider deprecating** `PoemsRepository.getUserPoems` in a future cleanup sprint once all consumers have migrated to `ProfileRepository.getAuthorPoems`.

---

## 8. Conclusion

UX-02 successfully transformed Syaahi's profile from a single-user account page into a navigable literary space. Readers can now tap an author's name in any feed card or poem reader and explore that writer's published works, with proper pagination, loading states, and error handling. The implementation is additive and non-destructive — all existing functionality from UX-01 and earlier sprints remains intact.

The sprint also surfaced important lessons about working in a monorepo with PowerShell and about the fragility of automated source code manipulation. These lessons have been documented here to inform future sprint execution.

**Recommendation:** Proceed to manual verification, then commit and tag as `v-UX-02`.

---

*End of report.*