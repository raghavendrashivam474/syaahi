import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syaahi_app/core/constants/colors.dart';
import 'package:syaahi_app/core/constants/sizes.dart';
import 'package:syaahi_app/shared/models/poem.dart';
import 'package:syaahi_app/features/poems/state/poems_providers.dart';

class HeartScreen extends ConsumerStatefulWidget {
  const HeartScreen({super.key});

  @override
  ConsumerState<HeartScreen> createState() => _HeartScreenState();
}

class _HeartScreenState extends ConsumerState<HeartScreen> {
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(heartProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(heartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Heart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(HeartState state) {
    if (state.isLoading && state.poems.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: SyaahiColors.goldBase),
      );
    }

    if (state.error != null && state.poems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(SyaahiSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: SyaahiColors.textMuted,
              ),
              const SizedBox(height: SyaahiSizes.md),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: SyaahiColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: SyaahiSizes.lg),
              ElevatedButton(
                onPressed: () => ref.read(heartProvider.notifier).refresh(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.poems.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(SyaahiSizes.xl),
        children: [
          const SizedBox(height: SyaahiSizes.xxxl),
          const Icon(
            Icons.favorite_outline,
            size: 64,
            color: SyaahiColors.goldBase,
          ),
          const SizedBox(height: SyaahiSizes.lg),
          Text(
            'Your heart is empty.',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              color: SyaahiColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SyaahiSizes.sm),
          Text(
            'Poems you commit to heart\nwill live here, privately.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: SyaahiColors.textMuted,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: SyaahiSizes.xl),
          Center(
            child: ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Explore Poems'),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      color: SyaahiColors.goldBase,
      backgroundColor: SyaahiColors.midnightBase,
      onRefresh: () => ref.read(heartProvider.notifier).refresh(),
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
          return _HeartPoemCard(poem: state.poems[index]);
        },
      ),
    );
  }
}

class _HeartPoemCard extends StatelessWidget {
  final Poem poem;
  const _HeartPoemCard({required this.poem});

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
          border: Border.all(
            color: SyaahiColors.goldDark.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.favorite,
                  size: 12,
                  color: SyaahiColors.goldBase,
                ),
                const SizedBox(width: 4),
                Text(
                  'In your heart',
                  style: GoogleFonts.inter(
                    color: SyaahiColors.goldBase,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SyaahiSizes.sm),
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
                Text(
                  'by ${poem.author.displayName}',
                  style: GoogleFonts.inter(
                    color: SyaahiColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}