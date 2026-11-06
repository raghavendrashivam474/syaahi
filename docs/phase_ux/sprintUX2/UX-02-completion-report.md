# UX-02 Completion Report

**Sprint:** UX-02 — Profile & Author Experience
**Initiative:** phase_ux
**Predecessor:** UX-01 — Feed Interaction Improvements
**Baseline commit:** 4d39dc9 (tag: v-UX-01)
**Status:** Complete

---

## 1. What Existed Before UX-02

| Area | State |
|---|---|
| Own profile (`/profile`) | Implemented — single file, read from `authProvider` |
| Other authors' profiles | Not implemented |
| Feed → author navigation | Not implemented |
| Reader → author navigation | Not implemented |
| Author poem pagination (client) | Not implemented (fetched flat 50) |
| Profile loading/error/empty states | Partial (poems only, no header) |
| Profile architecture | Single file, no data/state/presentation |
| Backend author API | Fully available (`GET /users/:username`, `GET /users/:username/poems`) |

## 2. What Was Changed

### New capabilities
- **Public author profiles** at `/profile/:username` — any writer's profile is viewable
- **Author discovery from feed** — tap author name/avatar in any feed card
- **Author discovery from reader** — tap byline or attribution in the poem reader
- **Cursor-paginated author poems** — scroll-triggered load-more (20 per page)
- **Full state handling** — loading, error, 404 (not found), empty poems
- **Profile metadata** — poem count and join date from API
- **Shared presentation** — own profile and author profile use the same `AuthorProfileView`
- **Profile feature architecture** — proper data/state/presentation separation

### Preserved behaviours
- `/profile` still opens the authenticated user's own profile
- Poem deletion popup on own profile tiles (with confirmation dialog)
- All feed functionality (filters, pagination, heart from UX-01)
- All reader functionality (heart, reactions, UX-01 sync)
- All auth, publishing, and notification flows

## 3. Files Modified

| File | Type | Lines Changed |
|---|---|---|
| `syaahi-app/lib/core/router/app_router.dart` | Modified | +1 route (`/profile/:username`) |
| `syaahi-app/lib/features/poems/presentation/feed_screen.dart` | Modified | Author tap in `_PoemCard` |
| `syaahi-app/lib/features/poems/presentation/reader_screen.dart` | Modified | Byline + attribution taps |
| `syaahi-app/lib/features/profile/profile_screen.dart` | Refactored | Delegates to `AuthorProfileView` |

## 4. Files Created

| File | Purpose |
|---|---|
| `syaahi-app/lib/shared/models/author_profile.dart` | Public-only author model (no email) |
| `syaahi-app/lib/features/profile/data/profile_repository.dart` | API client for `/users/*` |
| `syaahi-app/lib/features/profile/state/profile_providers.dart` | `authorProfileProvider`, `authorPoemsProvider` |
| `syaahi-app/lib/features/profile/presentation/author_profile_screen.dart` | `/profile/:username` route target |
| `syaahi-app/lib/features/profile/presentation/author_profile_view.dart` | Shared profile presentation |

**Total: 5 new files, 4 modified files, 0 deleted files.**

## 5. Architecture Decisions

See `docs/architecture/ADR-UX02-author-profile-experience.md`.

Key decisions:
- **Separate `ProfileRepository`** from `PoemsRepository` (different API domains)
- **Dedicated `AuthorProfile` model** (public-only, excludes email/followers)
- **`User` and `PoemAuthor` models unchanged** (backward compatibility)
- **No redirect** from `/profile` to `/profile/:username` (preserves nav stack)
- **`isOwnProfile` flag** controls deletion UI, not data fetching
- **`autoDispose` providers** for memory efficiency

## 6. Tests Performed

| Test | Result |
|---|---|
| `flutter analyze` | PASS — No issues found |
| `flutter test` | PASS — 8/8 tests passed |
| Out-of-scope file check | PASS — No heart/reaction/notification/auth files modified |
| Critical model preservation | PASS — `poem.dart`, `user.dart`, `poems_repository.dart`, `poems_providers.dart`, `auth_providers.dart` unchanged |

### Manual tests required (not automatable)
- [ ] Open own profile from feed app bar
- [ ] Tap author name in feed card → author profile
- [ ] Tap byline in reader → author profile
- [ ] Tap attribution in reader → author profile
- [ ] View author with poems → list renders
- [ ] View author with no poems → empty state
- [ ] View non-existent author → 404 state
- [ ] Scroll to load more poems on prolific author
- [ ] Delete own poem from profile → confirmation → success
- [ ] Heart toggle in feed still works (UX-01)
- [ ] Heart toggle in reader still syncs (UX-01)
- [ ] Back navigation from all paths
- [ ] Responsive: narrow mobile, standard, web

## 7. Known Limitations

- Profile editing UI is deferred (backend supports `PATCH /users/me`)
- `userPoemsProvider` in `poems_providers.dart` is now partially redundant but preserved for backward compatibility
- `AuthorProfile.fromUser()` factory uses placeholder `createdAt` and `poemCount` (API-fetched profile preferred)
- No avatar image upload (backend field exists, no client UI)

## 8. Deferred Improvements

- Profile editing screen (separate sprint)
- Shared poem card component (unify `_PoemCard` and `_AuthorPoemTile`)
- Avatar image upload and display from URL
- Deprecate old `getUserPoems` in `PoemsRepository`

## 9. Commit History

To be created after review and approval.

**Suggested commit message**:

**feat(ux-02)**: add author profile experience and discovery navigation

   - Add /profile/:username route for public author profiles
   - Create AuthorProfile model, ProfileRepository, and providers
   - Build shared AuthorProfileView with cursor pagination
   - Add author tap navigation in feed cards and poem reader
   - Refactor own profile to share AuthorProfileView
   - Add loading, error, 404, and empty states
   - Preserve all existing UX-01, auth, and publishing functionality

**Suggested tag**: `v-UX-02`

---

*UX-02 makes Syaahi's literary world explorable. Readers can now discover the people behind the writing — not through social mechanics, but through the natural act of reading a poem and wanting to know who wrote it.*
