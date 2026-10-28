import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/sizes.dart';
import '../../../shared/models/poem.dart';
import '../../../features/auth/state/auth_providers.dart';
import '../data/poems_repository.dart';
import '../state/poems_providers.dart';
import '../../notifications/state/notifications_providers.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    ref.read(unreadCountProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Syaahi'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: state.filters.isEmpty
                  ? SyaahiColors.textMuted
                  : SyaahiColors.goldBase,
            ),
            tooltip: 'Filters',
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          _BellButton(),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            tooltip: 'My Heart',
            onPressed: () => context.push('/heart'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/write'),
        backgroundColor: SyaahiColors.goldBase,
        foregroundColor: SyaahiColors.midnightDark,
        child: const Icon(Icons.edit_outlined),
      ),
      body: Column(
        children: [
          if (_showFilters) _FilterBar(
            filters: state.filters,
            onChanged: (filters) {
              ref.read(feedProvider.notifier).setFilters(filters);
            },
            onClear: () {
              ref.read(feedProvider.notifier).clearFilters();
            },
          ),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(FeedState state) {
    if (state.isLoading && state.poems.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: SyaahiColors.goldBase),
      );
    }

    if (state.error != null && state.poems.isEmpty) {
      return _ErrorView(
        message: state.error!,
        onRetry: () => ref.read(feedProvider.notifier).refresh(),
      );
    }

    if (state.poems.isEmpty) {
      return _EmptyFeed(onWrite: () => context.push('/write'));
    }

    return RefreshIndicator(
      color: SyaahiColors.goldBase,
      backgroundColor: SyaahiColors.midnightBase,
      onRefresh: () => ref.read(feedProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          SyaahiSizes.md, SyaahiSizes.md, SyaahiSizes.md, SyaahiSizes.xxxl,
        ),
        itemCount: state.poems.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: SyaahiSizes.md),
        itemBuilder: (context, index) {
          if (index == state.poems.length) {
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
          return _PoemCard(poem: state.poems[index]);
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final FeedFilters filters;
  final ValueChanged<FeedFilters> onChanged;
  final VoidCallback onClear;

  const _FilterBar({
    required this.filters,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        SyaahiSizes.md, SyaahiSizes.sm, SyaahiSizes.md, SyaahiSizes.md,
      ),
      decoration: const BoxDecoration(
        color: SyaahiColors.midnightBase,
        border: Border(
          bottom: BorderSide(color: SyaahiColors.divider, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'EMOTION',
                style: GoogleFonts.inter(
                  color: SyaahiColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              if (!filters.isEmpty)
                GestureDetector(
                  onTap: onClear,
                  child: Text(
                    'Clear all',
                    style: GoogleFonts.inter(
                      color: SyaahiColors.goldLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: SyaahiSizes.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: PoemEmotion.values.map((e) {
                final selected = filters.emotion == e;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text('${e.emoji} ${e.label}'),
                    selected: selected,
                    onSelected: (sel) {
                      onChanged(sel
                          ? filters.copyWith(emotion: e)
                          : filters.copyWith(clearEmotion: true));
                    },
                    backgroundColor: SyaahiColors.surfaceCard,
                    selectedColor: SyaahiColors.goldBase,
                    labelStyle: TextStyle(
                    color: selected
                        ? SyaahiColors.midnightDark
                        : SyaahiColors.textSecondary,
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                    side: BorderSide(
                      color: selected
                          ? SyaahiColors.goldBase
                          : SyaahiColors.divider,
                    ),
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: SyaahiSizes.sm),
          Text(
            'LANGUAGE',
            style: GoogleFonts.inter(
              color: SyaahiColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: SyaahiSizes.xs),
          Row(
            children: PoemLanguage.values.map((l) {
              final selected = filters.language == l;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(l.label),
                  selected: selected,
                  onSelected: (sel) {
                    onChanged(sel
                        ? filters.copyWith(language: l)
                        : filters.copyWith(clearLanguage: true));
                  },
                  backgroundColor: SyaahiColors.surfaceCard,
                  selectedColor: SyaahiColors.goldBase,
                  labelStyle: TextStyle(
                    color: selected
                        ? SyaahiColors.midnightDark
                        : SyaahiColors.textSecondary,
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  side: BorderSide(
                    color: selected
                        ? SyaahiColors.goldBase
                        : SyaahiColors.divider,
                  ),
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PoemCard extends StatelessWidget {
  final Poem poem;
  const _PoemCard({required this.poem});

  @override
  Widget build(BuildContext context) {
    final preview = poem.content.length > 140
        ? '${poem.content.substring(0, 140)}...'
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
        border: Border.all(
            color: SyaahiColors.goldDark.withValues(alpha: 0.4)),
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


// ── Notification Bell (N4) ──────────────────────────────────────────

class _BellButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);

    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => context.push('/notifications'),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none),
          if (unread != null && unread > 0)
            Positioned(
              right: -4,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 1,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: SyaahiColors.goldBase,
                  borderRadius: BorderRadius.circular(SyaahiSizes.radiusFull),
                ),
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: SyaahiColors.midnightDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
