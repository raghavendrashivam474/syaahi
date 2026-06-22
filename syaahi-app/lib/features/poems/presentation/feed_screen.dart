import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/sizes.dart';
import '../../../shared/models/poem.dart';
import '../../auth/state/auth_providers.dart';
import '../state/poems_providers.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    final threshold = position.maxScrollExtent * 0.85;

    if (position.pixels >= threshold) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/write'),
        backgroundColor: SyaahiColors.goldBase,
        foregroundColor: SyaahiColors.midnightDark,
        icon: const Icon(Icons.edit_outlined),
        label: Text(
          'Write',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        color: SyaahiColors.goldBase,
        child: _buildBody(feedState, user?.displayName),
      ),
    );
  }

  Widget _buildBody(FeedState feedState, String? displayName) {
    // Initial loading
    if (feedState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: SyaahiColors.goldBase),
      );
    }

    // Initial error
    if (feedState.error != null && feedState.poems.isEmpty) {
      return _ErrorView(
        message: feedState.error!,
        onRetry: () => ref.read(feedProvider.notifier).load(),
      );
    }

    // Empty
    if (feedState.poems.isEmpty) {
      return _EmptyFeed(onWrite: () => context.push('/write'));
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Header
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            SyaahiSizes.xl,
            SyaahiSizes.lg,
            SyaahiSizes.xl,
            SyaahiSizes.md,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()},',
                  style: GoogleFonts.inter(
                    color: SyaahiColors.textMuted,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayName ?? 'Poet',
                  style: GoogleFonts.cormorantGaramond(
                    color: SyaahiColors.goldBase,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: SyaahiSizes.lg),
                Text(
                  'Recent Poems',
                  style: GoogleFonts.inter(
                    color: SyaahiColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Poem list
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            SyaahiSizes.xl,
            0,
            SyaahiSizes.xl,
            SyaahiSizes.md,
          ),
          sliver: SliverList.separated(
            itemCount: feedState.poems.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: SyaahiSizes.md),
            itemBuilder: (_, i) => _PoemCard(poem: feedState.poems[i]),
          ),
        ),

        // Load more indicator
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: SyaahiSizes.xxxl),
            child: _buildFooter(feedState),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(FeedState feedState) {
    if (feedState.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(SyaahiSizes.lg),
        child: Center(
          child: CircularProgressIndicator(
            color: SyaahiColors.goldBase,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (!feedState.hasMore && feedState.poems.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(SyaahiSizes.lg),
        child: Center(
          child: Text(
            '— you have read everything —',
            style: GoogleFonts.cormorantGaramond(
              color: SyaahiColors.textMuted,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _PoemCard extends StatelessWidget {
  final Poem poem;
  const _PoemCard({required this.poem});

  @override
  Widget build(BuildContext context) {
    final preview = poem.content.length > 140
        ? '${poem.content.substring(0, 140)}…'
        : poem.content;

    return InkWell(
      onTap: () => context.push('/poem/${poem.id}'),
      borderRadius: BorderRadius.circular(SyaahiSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(SyaahiSizes.lg),
        decoration: BoxDecoration(
          color: SyaahiColors.surfaceCard,
          borderRadius: BorderRadius.circular(SyaahiSizes.radiusLg),
          border: Border.all(color: SyaahiColors.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (poem.title != null && poem.title!.isNotEmpty) ...[
              Text(
                poem.title!,
                style: GoogleFonts.cormorantGaramond(
                  color: SyaahiColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: SyaahiSizes.sm),
            ],
            Text(
              preview,
              style: GoogleFonts.cormorantGaramond(
                color: SyaahiColors.textSecondary,
                fontSize: 16,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: SyaahiSizes.md),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: SyaahiColors.midnightLight,
                  child: Text(
                    poem.author.displayName.isNotEmpty
                        ? poem.author.displayName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: SyaahiColors.goldBase,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: SyaahiSizes.sm),
                Expanded(
                  child: Text(
                    'by ${poem.author.displayName}',
                    style: GoogleFonts.inter(
                      color: SyaahiColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (poem.emotion != null)
                  _EmotionBadge(emotion: poem.emotion!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmotionBadge extends StatelessWidget {
  final PoemEmotion emotion;
  const _EmotionBadge({required this.emotion});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SyaahiSizes.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: SyaahiColors.goldDark.withValues(alpha: 0.15),
        border:
            Border.all(color: SyaahiColors.goldDark.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(SyaahiSizes.radiusFull),
      ),
      child: Text(
        '${emotion.emoji} ${emotion.label}',
        style: GoogleFonts.inter(
          color: SyaahiColors.goldLight,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  final VoidCallback onWrite;
  const _EmptyFeed({required this.onWrite});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(SyaahiSizes.xl),
      children: [
        const SizedBox(height: SyaahiSizes.xxxl),
        const Icon(
          Icons.auto_stories_outlined,
          size: 64,
          color: SyaahiColors.goldBase,
        ),
        const SizedBox(height: SyaahiSizes.lg),
        Text(
          'No poems yet.',
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            color: SyaahiColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SyaahiSizes.sm),
        Text(
          'Be the first to write something beautiful.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: SyaahiColors.textMuted,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: SyaahiSizes.xl),
        Center(
          child: ElevatedButton.icon(
            onPressed: onWrite,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Write Your First Poem'),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(SyaahiSizes.xl),
      children: [
        const SizedBox(height: SyaahiSizes.xxxl),
        const Icon(
          Icons.cloud_off_outlined,
          size: 64,
          color: SyaahiColors.textMuted,
        ),
        const SizedBox(height: SyaahiSizes.lg),
        Text(
          'Could not load poems',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: SyaahiSizes.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: SyaahiColors.textMuted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: SyaahiSizes.lg),
        Center(
          child: ElevatedButton(
            onPressed: onRetry,
            child: const Text('Try Again'),
          ),
        ),
      ],
    );
  }
}