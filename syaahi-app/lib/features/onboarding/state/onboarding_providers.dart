import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/onboarding_storage.dart';
import '../../auth/state/auth_providers.dart';

/// Singleton storage service for onboarding state.
final onboardingStorageProvider = Provider<OnboardingStorage>((ref) {
  return OnboardingStorage();
});

// ── Device-level ──────────────────────────────────────────

/// Whether the welcome screen has been seen on this device.
final welcomeSeenProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(onboardingStorageProvider);
  return storage.isWelcomeSeen();
});

/// Marks the welcome as seen (device-level, survives logout).
Future<void> markWelcomeSeen(WidgetRef ref) async {
  final storage = ref.read(onboardingStorageProvider);
  await storage.markWelcomeSeen();
  ref.invalidate(welcomeSeenProvider);
}

// ── User-level: contextual guidance ───────────────────────

/// Whether a specific contextual tip has been shown to the current user.
final contextualSeenProvider =
    FutureProvider.family<bool, String>((ref, feature) async {
  final storage = ref.watch(onboardingStorageProvider);
  final user = ref.watch(authProvider).user;
  if (user == null) return false;
  return storage.isContextualSeen(user.id, feature);
});

/// Marks a contextual tip as seen for the current user.
Future<void> markContextualSeen(WidgetRef ref, String feature) async {
  final storage = ref.read(onboardingStorageProvider);
  final user = ref.read(authProvider).user;
  if (user == null) return;
  await storage.markContextualSeen(user.id, feature);
  ref.invalidate(contextualSeenProvider(feature));
}

// ── User-level: walkthrough ───────────────────────────────

/// Whether the walkthrough has been completed by the current user.
final walkthroughCompletedProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(onboardingStorageProvider);
  final user = ref.watch(authProvider).user;
  if (user == null) return false;
  return storage.isWalkthroughCompleted(user.id);
});

/// Marks the walkthrough as completed for the current user.
Future<void> markWalkthroughCompleted(WidgetRef ref) async {
  final storage = ref.read(onboardingStorageProvider);
  final user = ref.read(authProvider).user;
  if (user == null) return;
  await storage.markWalkthroughCompleted(user.id);
  ref.invalidate(walkthroughCompletedProvider);
}
