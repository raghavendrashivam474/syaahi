import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/sizes.dart';
import '../auth/state/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Syaahi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/welcome');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(SyaahiSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_stories_outlined,
                size: 64,
                color: SyaahiColors.goldBase,
              ),
              const SizedBox(height: SyaahiSizes.lg),
              Text(
                user != null ? 'Welcome, ${user.displayName}.' : 'Welcome, Poet.',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SyaahiSizes.sm),
              if (user != null)
                Text(
                  '@${user.username}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: SyaahiSizes.lg),
              Text(
                'Feed coming next. For now — you are signed in.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}