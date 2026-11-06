# UX-04 Reconnaissance Report
## Sprint: Author Discovery & Search
## Date: 2026-11-06
## Baseline: v-UX-03 @ 88077ee

---

## 1. Frontend Architecture

### Navigation
- **Router:** lib/core/router/app_router.dart using GoRouter.
- **Structure:** Flat route definitions. No bottom navigation shell or nested ShellRoute.
- **Routes:** / (splash), /welcome, /auth/*, /home (FeedScreen), /write, /poem/:id, /heart, /profile, /profile/:username, /notifications.
- **Auth guard:** _redirect() classifies routes as public vs protected. Public: splash, welcome, auth, poem, public profile. Protected: everything else.
- **Discovery integration:** New /discover route will be added as a protected route. Navigation entry point to be added within FeedScreen (app bar action or icon button) since no bottom nav exists.

### Author Model
- **File:** lib/shared/models/author_profile.dart
- **Fields:** id, username, displayName, io, vatarUrl, createdAt, poemCount.
- **Serialization:** AuthorProfile.fromJson() expects { id, username, displayName, bio, avatarUrl, createdAt, _count: { poems } }.
- **Reusable for search?** Yes. The model contains exactly the fields needed for search result display. Search results can use the same model with poemCount defaulting to 0 if not included in the search response.

### Profile Repository
- **File:** lib/features/profile/data/profile_repository.dart
- **HTTP client:** Dio via ApiClient().dio.
- **Methods:** getUserProfile(username), getAuthorPoems(username, cursor, limit).
- **Error handling:** Catches DioException, maps to PoemsException with status codes.
- **Extension plan:** Add searchAuthors(String query, {int limit}) method. Alternatively, create a dedicated DiscoveryRepository to keep concerns separated. Decision: extend ProfileRepository since it already owns the /users/* domain.

### State Management (Riverpod)
- **File:** lib/features/profile/state/profile_providers.dart
- **Patterns observed:**
  - Provider<ProfileRepository> for repository instantiation.
  - FutureProvider.autoDispose.family<AuthorProfile, String> for single profile fetch.
  - StateNotifierProvider.autoDispose.family<AuthorPoemsNotifier, AuthorPoemsState, String> for paginated lists.
- **Discovery state plan:** Create a StateNotifier-based provider for search state (query, results, loading, error). Must handle debouncing and stale response protection.

### API Client
- **File:** lib/core/network/api_client.dart
- **Base URL:** From SyaahiStrings.apiBaseUrl.
- **Auth:** Interceptor adds Authorization: Bearer <token> from TokenStorage.
- **Timeouts:** 10s connect, 15s receive.
- **Reuse:** Discovery will use the same Dio instance via ProfileRepository.

### UI Conventions
- **Theme:** SyaahiColors (midnightDark, goldBase, textPrimary, textMuted, textFaded), SyaahiSizes.
- **Typography:** GoogleFonts.cormorantGaramond for headings, GoogleFonts.inter for body.
- **States:** Existing screens implement loading/error/empty states inline.

---

## 2. Backend Architecture

### Existing User Endpoints
| Method | Endpoint | Auth | Purpose |
|--------|----------|------|---------|
| GET | /api/v1/users/:username | Public | Single user profile |
| GET | /api/v1/users/:username/poems | Public | User's published poems |
| PATCH | /api/v1/users/me | Protected | Update own profile |

### Search Endpoint Status
- **Does a search endpoint exist?** No.
- **Action required:** Create GET /api/v1/users/search.

### Searchable Fields
| Field | Stored | Indexed | Searchable |
|-------|--------|---------|------------|
| username | Yes | Yes (@@index + @unique) | Yes — contains + insensitive |
| displayName | Yes | No | Yes — contains + insensitive |
| bio | Yes | No | Not needed for search |
| email | Yes | Yes (@unique) | Must NOT be exposed |

### Authentication for Search
- Search should be **public** (no auth required), consistent with GET /:username being public.
- The uthenticate middleware is imported but not applied to public routes.

### Response Conventions
- Envelope: { success: true, data: { ... } }
- Errors: { success: false, message: "..." }
- Validation: Zod schemas in users.schemas.ts.

### Route Ordering Constraint
- Express matches routes in definition order.
- /search **must** be defined **before** /:username to prevent "search" from being captured as a username parameter.

### Database
- **ORM:** Prisma with PostgreSQL (Supabase).
- **User indexes:** @@index([username]). No index on displayName.
- **Index decision:** No new index needed at current scale. ILIKE on displayName will perform adequately. Add a trigram GIN index only if query performance degrades with user growth.
- **Soft delete:** Not implemented. No status or deletedAt field on User. No filtering needed.

---

## 3. Architecture Assessment

### Existing Implementation
- Complete author profile system (model, repository, providers, screens).
- Public profile route /profile/:username fully functional.
- Cursor-paginated author poems.
- Consistent error handling and state management.

### Identified Gaps
1. No backend search endpoint.
2. No frontend search UI or state management.
3. No navigation entry point for discovery.

### Proposed Changes

#### Backend (syaahi-backend)
| File | Change | Type |
|------|--------|------|
| src/modules/users/users.schemas.ts | Add searchUsersQuerySchema (Zod) | Modify |
| src/modules/users/users.controller.ts | Add searchUsers handler | Modify |
| src/modules/users/users.routes.ts | Add GET /search before /:username | Modify |

#### Frontend (syaahi-app)
| File | Change | Type |
|------|--------|------|
| lib/features/profile/data/profile_repository.dart | Add searchAuthors() | Modify |
| lib/features/discovery/presentation/discovery_screen.dart | New discovery screen | Create |
| lib/features/discovery/presentation/widgets/* | Search field, result tile, states | Create |
| lib/features/discovery/state/discovery_providers.dart | Search state + debounce | Create |
| lib/core/router/app_router.dart | Add /discover route | Modify |
| lib/features/poems/presentation/feed_screen.dart | Add discovery nav entry | Modify |

### Architectural Decisions Needed
- **None at this time.** All changes are additive extensions of existing patterns. No ADR required.

---

## 4. Risk Assessment
| Risk | Mitigation |
|------|------------|
| /search route captured as username | Place before /:username in route definition |
| Stale search responses overwriting newer | Request sequencing with cancellation token or version counter |
| Exposing private user data | Select only public fields in Prisma query |
| Breaking existing profile navigation | Regression test existing /profile/:username flow |
| Empty search results looking broken | Intentional initial + empty states |
