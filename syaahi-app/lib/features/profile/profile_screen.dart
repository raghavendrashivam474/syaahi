import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/state/auth_providers.dart';
import 'presentation/author_profile_view.dart';

/// Entry point for `/profile` — the authenticated user's own profile.
///
/// Reads the current user from [authProvider] and delegates
/// rendering to [AuthorProfileView] with [isOwnProfile] = true.
///
/// If the user is not signed in, shows a minimal signed-out state.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: Text('Not signed in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: AuthorProfileView(
        username: user.username,
        isOwnProfile: true,
      ),
    );
  }
}
