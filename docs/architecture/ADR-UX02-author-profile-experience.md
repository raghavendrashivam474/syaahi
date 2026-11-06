# ADR-UX02: Author Profile Experience

**Sprint:** UX-02 — Profile & Author Experience
**Status:** Proposed (awaiting approval)
**Date:** 2025-07-11
**Author:** UX-02 Developer
**Reviewer:** Senior Developer

---

## Context

Syaahi currently supports viewing only the logged-in user's own profile at /profile.
The backend already exposes public author endpoints (GET /users/:username,
GET /users/:username/poems) but the Flutter client never calls them.

Readers cannot navigate from a feed card or poem reader to an author's profile.
The profile feature is a single file with no data/state/presentation separation.

UX-02 aims to make the relationship between a writer, their identity, and their
literary work more meaningful — without introducing social-network features.

## Decision

### 1. Route Architecture

| Route | Screen | Behaviour |
|---|---|---|
| `/profile` | ProfileScreen (existing, refactored) | Reads `authProvider.user`. If authenticated, renders `AuthorProfileView(username: user.username, isOwnProfile: true)`. If not, shows "Not signed in". **No redirect.** |
| `/profile/:username` | AuthorProfileScreen (new) | Fetches public profile via `GET /users/:username`. Compares `username` against `authProvider.user?.username` to determine `isOwnProfile`. Renders the same `AuthorProfileView`. |

**Rationale for no redirect:** A redirect from `/profile` to `/profile/:username` would change the navigation stack and could break back-navigation from the feed app bar. Rendering the shared view directly at `/profile` preserves the existing stack and all current behaviours.

**Own-profile detection:** `AuthorProfileScreen` checks `ref.read(authProvider).user?.username == username` at build time. This is a read-only comparison — no new auth logic is introduced.

### 2. AuthorProfile Model (New, Public-Only)

A dedicated public model containing only fields safe for public display.

```dart
class AuthorProfile {
  final String id;
  final String username;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final DateTime createdAt;
  final int poemCount;
}

```

Explicitly excluded: email, followers, following.

Field mapping from existing models:

| AuthorProfile field | From User | From PoemAuthor | From GET /users/:username |
| --- | --- | --- | --- |
| `id` | ✅ | ✅ | ✅ |
| `username` | ✅ | ✅ | ✅ |
| `displayName` | ✅ | ✅ | ✅ |
| `bio` | ✅ | ✅ | ✅ |
| `avatarUrl` | ✅ | ✅ | ✅ |
| `createdAt` | ❌ (not in User) | ❌ | ✅ |
| `poemCount` | ❌ | ❌ | ✅ (`_count.poems`) |

Compatibility preservation:

* **`User` model remains unchanged.** It is the auth/session model and contains private fields (email) that must not leak into public representations.
* **`PoemAuthor` model remains unchanged.** It is an embedded sub-object inside `Poem` and has a different serialization context.
* **`AuthorProfile` is constructed from the dedicated `GET /users/:username` response.** No migration of `User` or `PoemAuthor` is performed.
* A convenience factory `AuthorProfile.fromUser(User)` may be added for the own-profile case where we already have a `User` object, but it will set `createdAt` and `poemCount` to defaults since `User` lacks those fields.

### 3. Repository / API Methods

All new methods go in a new `ProfileRepository` class (not `PoemsRepository`) to establish a clean separation of concerns.

```dart
class ProfileRepository {
  // NEW: Fetch public author profile
  Future<AuthorProfile> getUserProfile(String username);
  // Maps to: GET /api/v1/users/:username

  // NEW: Fetch author's poems with cursor pagination
  Future<PoemFeedResult> getAuthorPoems(
    String username, {
    String? cursor,
    int limit = 20,
  });
  // Maps to: GET /api/v1/users/:username/poems?cursor=...&limit=...
  // Reuses existing PoemFeedResult type.
}

```

**Note:** The existing `PoemsRepository.getUserPoems(username, {limit})` method returns `List<Poem>` with no cursor. It will be preserved for backward compatibility but the new `ProfileRepository.getAuthorPoems` will be the primary method for the profile screen. The old method may be deprecated in a future sprint.

### 4. Provider Architecture

```dart
// Public author profile — fetched once per username
final authorProfileProvider =
    FutureProvider.autoDispose.family<AuthorProfile, String>(...);

// Author poems — cursor-paginated, similar to FeedNotifier
final authorPoemsProvider =
    StateNotifierProvider.autoDispose.family<AuthorPoemsNotifier, AuthorPoemsState, String>(...);

```

State shape for `AuthorPoemsState`:

```dart
class AuthorPoemsState {
  final List<Poem> poems;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final String? error;
}

```

This mirrors `FeedState` but without filters or heart-state caching, since those are feed-specific concerns.

### 5. Shared Presentation

A single `AuthorProfileView` widget will be rendered by both `ProfileScreen` and `AuthorProfileScreen`.

```dart
class AuthorProfileView extends ConsumerWidget {
  final String username;
  final bool isOwnProfile;
  // ...
}

```

`isOwnProfile` controls:

* Poem deletion popup menu on each tile (existing behaviour, preserved)
* Future edit-profile button (deferred, placeholder only)

`isOwnProfile` does NOT control:

* Profile data fetching (both paths use `authorProfileProvider`)
* Poem display (identical for own and other profiles)
* Navigation to poem reader (identical)

### 6. Navigation Changes

| From | To | Trigger | Implementation |
| --- | --- | --- | --- |
| Feed app bar | `/profile` | Existing icon button | No change |
| Feed `_PoemCard` author name | `/profile/:username` | Tap on author name/avatar | New `GestureDetector` with `HitTestBehavior.opaque` wrapping the author row segment |
| Reader `_ReaderView` byline | `/profile/:username` | Tap on "by displayName" | New `GestureDetector` wrapping the byline `Text` |
| Reader attribution | `/profile/:username` | Tap on "— displayName" | New `GestureDetector` wrapping the attribution `Text` |
| Profile poem tile | `/poem/:id` | Existing tap | No change |

**Tap isolation:** Following the UX-01 pattern, author-name taps will use `GestureDetector` with `behavior: HitTestBehavior.opaque` to prevent interference with parent `InkWell` tap targets (the card itself navigates to the reader).

### 7. What Is NOT Changing

* `User` model — unchanged
* `PoemAuthor` model — unchanged
* `Poem` model — unchanged
* `PoemsRepository` — unchanged (new methods go in `ProfileRepository`)
* `FeedNotifier` / `feedProvider` — unchanged
* `HeartNotifier` / `heartProvider` — unchanged
* `WriterNotifier` / `writerProvider` — unchanged
* Heart interaction (UX-01) — unchanged
* Reactions — unchanged
* Notifications — unchanged
* Auth flow — unchanged
* Backend — no changes required

### Consequences

#### Positive

* Readers can discover and explore any author's literary work
* Feed and reader become navigation entry points to author profiles
* Profile feature gains proper architecture (data/state/presentation)
* Cursor pagination for author poems improves performance for prolific writers
* Own-profile and author-profile share a single presentation, reducing drift

#### Negative

* Two repository classes (`PoemsRepository`, `ProfileRepository`) may feel redundant initially. This is intentional: `PoemsRepository` owns poem CRUD and interactions; `ProfileRepository` owns user/author data.
* The `userPoemsProvider` in `poems_providers.dart` becomes partially redundant. It will be preserved for now to avoid breaking changes.

#### Risks

* Author-name tap targets in feed cards are close to the heart button and card-level tap. Careful hit-testing is required.
* The `isOwnProfile` flag depends on `authProvider` being populated. If the user logs out while viewing their own profile via `/profile/:username`, the view should gracefully degrade (no crash, deletion menu disappears).

### Testing Strategy

See UX-02.S1 reconnaissance report, section 12.

### Approval

* [ ] Senior Developer review
* [ ] Model compatibility verified
* [ ] Route plan verified against GoRouter behaviour
* [ ] Regression plan confirmed

*This ADR will be updated to "Accepted" before implementation begins.*

```