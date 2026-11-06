import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/state/auth_providers.dart';
import 'author_profile_view.dart';

/// Route target for `/profile/:username`.
///
/// Determines whether the viewed profile belongs to the
/// authenticated user and delegates rendering to [AuthorProfileView].
class AuthorProfileScreen extends ConsumerWidget {
  final String username;

  const AuthorProfileScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).user;
    final isOwnProfile = currentUser?.username == username;

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? 'Profile' : '@$username'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
        ),
      ),
      body: AuthorProfileView(
        username: username,
        isOwnProfile: isOwnProfile,
      ),
    );
  }
}
