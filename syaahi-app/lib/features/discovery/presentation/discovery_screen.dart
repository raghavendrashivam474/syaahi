import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/sizes.dart';
import '../state/discovery_providers.dart';
import 'widgets/author_result_tile.dart';
import 'widgets/author_search_field.dart';
import 'widgets/discovery_empty_state.dart';
import 'widgets/discovery_error_state.dart';
import 'widgets/discovery_initial_state.dart';

/// Dedicated author discovery screen.
///
/// Accessible via /discover. Allows readers to search for writers
/// by username or display name and navigate to their public profiles.
class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoveryProvider);
    final notifier = ref.read(discoveryProvider.notifier);

    return Scaffold(
      backgroundColor: SyaahiColors.midnightDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SyaahiColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Discover Writers',
          style: GoogleFonts.cormorantGaramond(
            color: SyaahiColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Field ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SyaahiSizes.md,
                SyaahiSizes.sm,
                SyaahiSizes.md,
                SyaahiSizes.md,
              ),
              child: AuthorSearchField(
                initialValue: state.query,
                onChanged: notifier.onQueryChanged,
                onClear: notifier.clear,
              ),
            ),

            // ── Subtitle ──
            if (state.status == DiscoveryStatus.initial)
              Padding(
                padding: const EdgeInsets.only(bottom: SyaahiSizes.sm),
                child: Text(
                  'Find writers and explore their work.',
                  style: GoogleFonts.inter(
                    color: SyaahiColors.textFaded,
                    fontSize: 13,
                  ),
                ),
              ),

            // ── Results Area ──
            Expanded(
              child: _buildBody(context, state, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DiscoveryState state,
    DiscoveryNotifier notifier,
  ) {
    switch (state.status) {
      case DiscoveryStatus.initial:
        return const DiscoveryInitialState();

      case DiscoveryStatus.searching:
        return const Center(
          child: CircularProgressIndicator(
            color: SyaahiColors.goldBase,
            strokeWidth: 2,
          ),
        );

      case DiscoveryStatus.results:
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: SyaahiSizes.sm),
          itemCount: state.results.length,
          separatorBuilder: (_, __) => Divider(
            color: SyaahiColors.textFaded.withValues(alpha: 0.1),
            height: 1,
          ),
          itemBuilder: (context, index) {
            final author = state.results[index];
            return AuthorResultTile(
              author: author,
              onTap: () => context.push('/profile/${author.username}'),
            );
          },
        );

      case DiscoveryStatus.empty:
        return DiscoveryEmptyState(query: state.query.trim());

      case DiscoveryStatus.error:
        return DiscoveryErrorState(
          message: state.errorMessage ?? 'Something went wrong',
          onRetry: notifier.retry,
        );
    }
  }
}
