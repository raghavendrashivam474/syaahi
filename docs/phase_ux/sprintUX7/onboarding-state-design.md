# UX-07 Onboarding State Design

## Current Persistence Landscape

| Mechanism | Library | Used For | Location |
|---|---|---|---|
| FlutterSecureStorage | `flutter_secure_storage` | Auth token | `lib/core/storage/token_storage.dart` |
| SharedPreferences | `shared_preferences` | **Not yet used** (but in pubspec) | — |

## Proposed Persistence Strategy

Since `shared_preferences` is already in `pubspec.yaml` but not yet used, we will use it for onboarding state. No new dependencies needed.

## State Inventory

| State Key | Type | Scope | Storage | Lifecycle | Reset Condition |
|---|---|---|---|---|---|
| `onboarding_welcome_seen` | bool | Device/install | SharedPreferences | Permanent until reinstall | App reinstall |
| `onboarding_walkthrough_completed` | bool | User/account | SharedPreferences (keyed by userId) | Until logout | Logout clears user-keyed states |
| `onboarding_contextual_heart` | bool | User/account | SharedPreferences (keyed by userId) | Until logout | Logout |
| `onboarding_contextual_respond` | bool | User/account | SharedPreferences (keyed by userId) | Until logout | Logout |
| `onboarding_contextual_resonance` | bool | User/account | SharedPreferences (keyed by userId) | Until logout | Logout |
| `onboarding_contextual_write` | bool | User/account | SharedPreferences (keyed by userId) | Until logout | Logout |

## Scope Definitions

### Device/install-level
- Survives logout and account switching.
- Used for the welcome screen (Journey C: returning users don't see it again).
- Key prefix: `onboarding_device_`

### User/account-level
- Tied to a specific authenticated user.
- Key format: `onboarding_user_{userId}_{feature}`
- Cleared on logout to prevent cross-account leakage (Journey D).
- If userId is not available, these states default to "not completed."

### Session-level
- Not persisted. Lives only in memory during the current app session.
- Used for temporary walkthrough step tracking.
- No storage needed — managed by Riverpod state.

## Implementation Approach

1. **Create `OnboardingStorageService`** in `lib/core/storage/` alongside `token_storage.dart`.
2. Uses `SharedPreferences` (already in pubspec).
3. Exposes typed getters/setters for each state key.
4. Provides a `clearUserStates(String userId)` method called during logout.
5. Provides a `clearAllUserStates()` method for safety.

## Riverpod Integration

- Create `onboarding_providers.dart` in `lib/features/onboarding/state/`.
- Each contextual guidance gets a provider that reads from `OnboardingStorageService`.
- Walkthrough state is a simple `StateNotifier<bool>` (session-level).

## Logout Integration Point

In `AuthNotifier.logout()` (`lib/features/auth/state/auth_providers.dart`):
- After clearing the auth token, call `OnboardingStorageService.clearUserStates(userId)`.
- This ensures Journey D (account switching) works correctly.

## Files to Create

| File | Purpose |
|---|---|
| `lib/core/storage/onboarding_storage.dart` | SharedPreferences wrapper for onboarding state |
| `lib/features/onboarding/state/onboarding_providers.dart` | Riverpod providers for onboarding state |

## Files to Modify

| File | Change | Risk |
|---|---|---|
| `lib/features/auth/state/auth_providers.dart` | Add onboarding state cleanup on logout | Low — additive only |
| `lib/core/router/app_router.dart` | Add welcome-first-encounter redirect logic | Medium — must preserve existing redirects |

## ⚠️ Architecture Decision

**No new storage library.** We use `shared_preferences` which is already a dependency. This avoids the "do not introduce another storage library simply for convenience" constraint from the spec.

**No database schema changes.** All onboarding state is client-side only.
