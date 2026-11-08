import 'package:shared_preferences/shared_preferences.dart';

/// Client-side persistence for onboarding state.
///
/// Uses SharedPreferences (already in pubspec.yaml).
/// No new dependencies required.
///
/// State is divided into two scopes:
/// - **Device-level:** Survives logout. Used for the welcome screen.
/// - **User-level:** Keyed by userId. Cleared on logout to prevent
///   cross-account leakage (Journey D).
class OnboardingStorage {
  // ── Device-level keys ──
  static const _welcomeSeenKey = 'onboarding_device_welcome_seen';

  // ── User-level key prefix ──
  static const _userPrefix = 'onboarding_user';

  // ── Device-level ────────────────────────────────────────

  Future<bool> isWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_welcomeSeenKey) ?? false;
  }

  Future<void> markWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeSeenKey, true);
  }

  // ── User-level helpers ──────────────────────────────────

  String _userKey(String userId, String feature) =>
      '${_userPrefix}_${userId}_$feature';

  Future<bool> isUserFeatureCompleted(
    String userId,
    String feature,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_userKey(userId, feature)) ?? false;
  }

  Future<void> markUserFeatureCompleted(
    String userId,
    String feature,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_userKey(userId, feature), true);
  }

  // ── Walkthrough ─────────────────────────────────────────

  Future<bool> isWalkthroughCompleted(String userId) async {
    return isUserFeatureCompleted(userId, 'walkthrough');
  }

  Future<void> markWalkthroughCompleted(String userId) async {
    await markUserFeatureCompleted(userId, 'walkthrough');
  }

  // ── Contextual guidance ─────────────────────────────────

  Future<bool> isContextualSeen(String userId, String feature) async {
    return isUserFeatureCompleted(userId, 'ctx_$feature');
  }

  Future<void> markContextualSeen(String userId, String feature) async {
    await markUserFeatureCompleted(userId, 'ctx_$feature');
  }

  // ── Cleanup ─────────────────────────────────────────────

  /// Clears all user-specific onboarding state for a given user.
  /// Call during logout to prevent cross-account leakage.
  Future<void> clearUserStates(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = '${_userPrefix}_$userId';
    final keys = prefs.getKeys().where((k) => k.startsWith(prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Clears ALL onboarding state (device + all users).
  /// Use only for testing or full reset.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('onboarding_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
