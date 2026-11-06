# UX-04 Implementation Plan
## Sprint: Author Discovery & Search
## Date: 2026-11-06
## Baseline: v-UX-03 @ 88077ee

---

## Implementation Sequence

### Step 1: Backend — Search Endpoint (UX-04.S2)

**1a. Add Zod validation schema** (`users.schemas.ts`)
```typescript
export const searchUsersQuerySchema = z.object({
  q: z.string().min(2).max(50),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});

```

**1b. Add controller handler** (`users.controller.ts`)

```typescript
export const searchUsers = async (req: Request, res: Response) => {
  const { q, limit } = searchUsersQuerySchema.parse(req.query);
  const users = await prisma.user.findMany({
    where: {
      OR: [
        { username: { contains: q, mode: 'insensitive' } },
        { displayName: { contains: q, mode: 'insensitive' } },
      ],
    },
    select: {
      username: true,
      displayName: true,
      bio: true,
      avatarUrl: true,
    },
    take: limit,
    orderBy: { username: 'asc' },
  });
  res.json({ success: true, data: { users } });
};

```

**1c. Register route** (`users.routes.ts`)

```typescript
router.get('/search', asyncHandler(searchUsers)); // BEFORE /:username

```

**1d. Update API contract** (`docs/API_CONTRACT.md`)

---

### Step 2: Frontend — Data Layer (UX-04.S2 continued)

**2a. Extend ProfileRepository** (`profile_repository.dart`)

* Add `searchAuthors(String query, {int limit = 20})` method.
* Calls `GET /users/search?q=...&limit=...`.
* Returns `List<AuthorProfile>` (reusing existing model).
* Maps response: `data['users']` list → `AuthorProfile.fromJson()` per item.
* *Note:* Search response won't include `_count` or `createdAt`, so use a lighter factory or provide defaults.

---

### Step 3: Frontend — State Management (UX-04.S3)

**3a. Create discovery providers** (`discovery_providers.dart`)

* `DiscoveryState`: query, results list, status (`initial` / `searching` / `results` / `empty` / `error`).
* `DiscoveryNotifier` (`StateNotifier`):
* `search(String query)` with debounce (500ms Timer).
* Request version counter to discard stale responses.
* `clear()` resets to initial state.
* `retry()` re-executes last query.
* Cancel/ignore responses where the query has changed since the request started.



---

### Step 4: Frontend — Discovery Screen (UX-04.S4)

**4a. Create DiscoveryScreen** (`discovery_screen.dart`)

* `AppBar` with "Discover Writers" title.
* Search `TextField` with clear button.
* Body switches on state: `initial` → `searching` → `results` → `empty` → `error`.
* Each result tile: avatar/initial, displayName, `@username`, bio.
* Tap result → `context.push('/profile/<username>')`.

**4b. Create widgets:**

* `AuthorSearchField`: `TextField` with debounce callback, clear icon.
* `AuthorResultTile`: `ListTile`-style widget for one search result.
* `DiscoveryEmptyState`: "No writers found" message.
* `DiscoveryInitialState`: "Find writers and explore their work" prompt.
* `DiscoveryErrorState`: Error message with retry button.

---

### Step 5: Navigation Integration (UX-04.S4)

**5a. Add route** (`app_router.dart`)

```dart
GoRoute(
  path: '/discover',
  builder: (context, state) => const DiscoveryScreen(),
),

```

* Add to protected routes in `_redirect()`.

**5b. Add entry point** (`feed_screen.dart`)

* Add search/discover icon in `FeedScreen` `AppBar`:
```dart
IconButton(
  icon: const Icon(Icons.search), 
  onPressed: () => context.push('/discover'),
)

```



---

### Step 6: Testing & Verification (UX-04.S5)

* Test search by `username` and `displayName`.
* Test partial matching and case insensitivity.
* Test empty query, no results, network error, retry.
* Test rapid typing (stale response protection).
* Test navigation to author profile and back.
* **Regression:** verify Feed, Reader, Profile, Heart, Inbox, Auth flows.
* Run `flutter analyze`, `flutter test`.
* Run backend build and tests.

---

## Files Summary

### Backend (modify 3 files)

* `syaahi-backend/src/modules/users/users.schemas.ts`
* `syaahi-backend/src/modules/users/users.controller.ts`
* `syaahi-backend/src/modules/users/users.routes.ts`

### Frontend (create 7, modify 3)

**Create:**

* `lib/features/discovery/presentation/discovery_screen.dart`
* `lib/features/discovery/presentation/widgets/author_search_field.dart`
* `lib/features/discovery/presentation/widgets/author_result_tile.dart`
* `lib/features/discovery/presentation/widgets/discovery_empty_state.dart`
* `lib/features/discovery/presentation/widgets/discovery_initial_state.dart`
* `lib/features/discovery/presentation/widgets/discovery_error_state.dart`
* `lib/features/discovery/state/discovery_providers.dart`

**Modify:**

* `lib/features/profile/data/profile_repository.dart`
* `lib/core/router/app_router.dart`
* `lib/features/poems/presentation/feed_screen.dart`

### Documentation (create 1, modify 1)

* `docs/API_CONTRACT.md` (add search endpoint)
* `docs/phase_ux/sprintUX4/UX-04-completion-report.md` (at end)

---

## Out of Scope (Confirmed)

* No follow/unfollow, DM, trending, recommendations, social graph.
* No new database indexes at this time.
* No new third-party dependencies.
* No architectural refactoring beyond additive changes.

```