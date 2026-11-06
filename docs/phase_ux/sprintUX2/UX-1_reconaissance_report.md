# UX-02.S1 — Reconnaissance Report

---

## 1. Existing Profile Functionality

| Aspect | Current State |
|---|---|
| **Profile screen** | Single file: `lib/features/profile/profile_screen.dart` (~250 lines). No `data/`, `state/`, or `presentation/` sub-folders unlike every other feature. |
| **Whose profile?** | **Only the logged-in user's own profile.** Reads `authProvider.user` directly. No parameterized route for viewing other authors. |
| **Route** | `/profile` — no path parameters. |
| **Header** | Avatar initial circle → displayName → @username → bio (if set). |
| **Poems section** | "WRITTEN" label → `_ProfilePoemTile` list via `userPoemsProvider(username)`. |
| **Poem actions** | Own poems can be deleted via a popup menu on each tile. |
| **Profile editing** | **Not implemented in the UI.** The backend supports `PATCH /users/me` but the Flutter app has no client for it. |
| **Stats** | `_StatChip` widget exists in the file but is **not used** in the current build tree. |

## 2. Author Data Model & API Contract

**Flutter `User` model** (`shared/models/user.dart`):
`id`, `email`, `username`, `displayName`, `bio?`, `avatarUrl?`

**Flutter `PoemAuthor` model** (embedded in `poem.dart`):
`id`, `username`, `displayName`, `avatarUrl?`, `bio?`

These are essentially the same fields in two separate classes.

**Backend `GET /api/v1/users/:username`** (public, no auth):
Returns `id`, `username`, `displayName`, `bio`, `avatarUrl`, `createdAt`, `_count: { poems, followers, following }`.

**Backend `GET /api/v1/users/:username/poems`** (public, cursor-paginated):
Returns poems with `nextCursor`. Supports `limit` (default 20, max 50).

**Backend `PATCH /api/v1/users/me`** (auth required):
Accepts `displayName`, `bio`, `avatarUrl`.

## 3. State Management Flow

- Profile header: reads synchronously from `authProvider` (Riverpod `StateNotifier`).
- Profile poems: `userPoemsProvider(username)` — a `FutureProvider.autoDispose.family` that calls `repo.getUserPoems(username, limit: 50)`.
- **No dedicated profile state manager.** No loading/error state for the profile itself.

## 4. Published-Poem Retrieval & Pagination

- Client calls `getUserPoems(username, limit: 50)` — **no cursor parameter**, fetches up to 50 poems in one shot.
- Backend supports cursor-based pagination, but the client doesn't use it.
- No "load more" on the profile poems list.

## 5. Navigation Flow

| Journey | Status |
|---|---|
| Feed → Profile | `IconButton` in app bar → `/profile` (own profile only) |
| Feed card → Author profile | **❌ Not implemented.** Author name/avatar in `_PoemCard` is not tappable. |
| Reader → Author profile | **❌ Not implemented.** "by displayName" and "— displayName" are plain text, not tappable. |
| Profile → Poem reader | ✅ `_ProfilePoemTile` → `context.push('/poem/${poem.id}')` |
| Poem reader → back | ✅ Standard `context.pop()` |

## 6. Loading, Error & Empty States

| State | Profile Header | Profile Poems |
|---|---|---|
| Loading | None (sync from auth) | ✅ `CircularProgressIndicator` via `AsyncValue.when` |
| Error | None | ✅ Error text via `AsyncValue.when` |
| Empty (no poems) | N/A | **❌ Missing.** Shows "WRITTEN" header with nothing below. |
| Not signed in | ✅ "Not signed in" text | N/A |
| User not found | **❌ N/A** (no author route) | **❌ N/A** |

## 7. Reusable Components

| Component | Location | Reuse Potential |
|---|---|---|
| `_PoemCard` | `feed_screen.dart` | Feed poem card with heart button. Could be reused on profile but is private. |
| `_ProfilePoemTile` | `profile_screen.dart` | Simpler poem tile (no heart, no avatar). **Duplicates** `_PoemCard` conceptually. |
| `_EmotionBadge` | `feed_screen.dart` | Private to feed. |
| `_MetaBadge` | `reader_screen.dart` | Private to reader. |
| `_StatChip` | `profile_screen.dart` | Unused. |
| `SyaahiColors`, `SyaahiSizes` | `core/constants/` | ✅ Shared across all screens. |
| `GoogleFonts` | Used everywhere | Consistent typography system. |

## 8. Files Proposed for Modification

| File | Change Type | Reason |
|---|---|---|
| `lib/core/router/app_router.dart` | **Add route** | Add `/profile/:username` for viewing any author |
| `lib/features/profile/profile_screen.dart` | **Major refactor** | Split into author profile (parameterized) + own profile redirect |
| `lib/features/poems/data/poems_repository.dart` | **Add methods** | `getUserProfile(username)`, `updateMe(...)`, add cursor to `getUserPoems` |
| `lib/features/poems/state/poems_providers.dart` | **Add providers** | `authorProfileProvider`, `authorPoemsProvider` (paginated), `updateMeProvider` |
| `lib/features/poems/presentation/feed_screen.dart` | **Minor** | Make author name/avatar in `_PoemCard` tappable → navigate to `/profile/:username` |
| `lib/features/poems/presentation/reader_screen.dart` | **Minor** | Make "by displayName" tappable → navigate to `/profile/:username` |
| `lib/shared/models/poem.dart` | **Possible** | Consider unifying `PoemAuthor` with `User` or creating a shared `AuthorProfile` model |

**New files likely needed:**
- `lib/features/profile/data/profile_repository.dart` (or extend `PoemsRepository`)
- `lib/features/profile/state/profile_providers.dart`
- `lib/features/profile/presentation/author_profile_screen.dart` (parameterized)
- `lib/features/profile/presentation/edit_profile_screen.dart` (if editing is in scope)

## 9. Architectural Limitations

1. **No author profile route exists.** The entire "view another writer" journey is missing. The backend fully supports it (`GET /users/:username` is public), but the Flutter app never calls it.

2. **No `getUserProfile` client method.** The backend returns rich profile data including `createdAt` and `_count.poems`, but the Flutter repository has no method to fetch it.

3. **No `updateMe` client method.** The backend supports profile editing, but the Flutter app has no UI or API client for it.

4. **Duplicated poem presentation.** `_ProfilePoemTile` and `_PoemCard` serve similar purposes with different implementations. A shared component would reduce drift.

5. **Profile feature has no architecture.** Every other feature follows `data/` + `state/` + `presentation/`. Profile is a single file.

6. **No cursor pagination for author poems on client.** Backend supports it, client fetches a flat 50.

## 10. Risks & Regression Considerations

| Risk | Mitigation |
|---|---|
| Adding `/profile/:username` may conflict with existing `/profile` | Keep `/profile` as a redirect to `/profile/:currentUserUsername`, or use a separate route like `/author/:username` |
| Making author names tappable in feed/reader could interfere with existing tap targets | Use `GestureDetector` with `HitTestBehavior.opaque` (same pattern as UX-01 heart button) |
| Refactoring `_ProfilePoemTile` into a shared component could break delete functionality | Preserve the delete popup menu as an optional parameter |
| Adding new providers could cause unnecessary rebuilds | Use `autoDispose` and `select` as done in UX-01 |
| Backend returns `followers`/`following` counts | **Do not display them** — explicitly out of scope per sprint brief |

## 11. Proposed Implementation Sequence

| Phase | Work | Files |
|---|---|---|
| **UX-02.S2** | Add `getUserProfile` + `updateMe` to repository. Create `AuthorProfile` model. Add providers. | `poems_repository.dart`, new `profile_providers.dart` |
| **UX-02.S2** | Add `/profile/:username` route. Build `AuthorProfileScreen` with header, bio, and poem list. | `app_router.dart`, new `author_profile_screen.dart` |
| **UX-02.S3** | Add cursor pagination to author poems. Add loading/empty/error states. | `poems_repository.dart`, `author_profile_screen.dart` |
| **UX-02.S4** | Make author names tappable in feed cards and reader. Verify all navigation paths. | `feed_screen.dart`, `reader_screen.dart` |
| **UX-02.S4** | Refactor own `/profile` to redirect to `/profile/:username` or reuse `AuthorProfileScreen`. | `profile_screen.dart`, `app_router.dart` |
| **UX-02.S5** | Regression testing, responsive verification, diff review. | All modified files |

## 12. Testing Plan

- Open own profile from feed app bar → verify header + poems
- Tap author name in feed card → verify navigation to author profile
- Tap author name in reader → verify navigation to author profile
- View author with poems → verify list renders correctly
- View author with no poems → verify empty state
- View non-existent author → verify error state
- Navigate author profile → poem → reader → back → verify stack
- Verify feed pagination still works
- Verify heart interaction (UX-01) still works
- Verify poem reader reactions still work
- Verify authentication flow unchanged

---

## Recommendation

**Proceed after approval: A documented architectural improvement is necessary.**

The backend already fully supports author profiles (`GET /users/:username`), paginated author poems (`GET /users/:username/poems`), and profile editing (`PATCH /users/me`). No backend changes are needed. However, the Flutter app is missing:

1. A parameterized author profile route
2. Client API methods for `getUserProfile` and `updateMe`
3. Navigation paths from feed/reader to author profiles
4. Proper profile feature architecture (data/state/presentation)

These are structural additions (new routes, new providers, new API client methods) that require an ADR before implementation. The changes are **additive** — they don't modify existing backend contracts or break existing functionality.

**Suggested ADR:** `ADR-UX02-author-profile-experience.md`

Shall I proceed to draft the ADR and begin UX-02.S2?