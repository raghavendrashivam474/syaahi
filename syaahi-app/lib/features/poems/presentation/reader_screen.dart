import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syaahi_app/core/constants/colors.dart';
import 'package:syaahi_app/core/constants/sizes.dart';
import 'package:syaahi_app/shared/models/poem.dart';
import 'package:syaahi_app/features/auth/state/auth_providers.dart';
import 'package:syaahi_app/features/poems/data/poems_repository.dart' show PoemsException;
import 'package:syaahi_app/features/poems/state/poems_providers.dart';

class ReaderScreen extends ConsumerWidget {
  final String poemId;
  const ReaderScreen({super.key, required this.poemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poemAsync = ref.watch(poemByIdProvider(poemId));
    final currentUser = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: SyaahiColors.midnightDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SyaahiColors.textPrimary),
          onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
        ),
        actions: [
          poemAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (poem) {
              final isOwner = currentUser?.id == poem.author.id;
              if (!isOwner) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: SyaahiColors.textMuted,
                ),
                color: SyaahiColors.surfaceCard,
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: SyaahiColors.midnightBase,
                        title: Text(
                          'Delete this poem?',
                          style: GoogleFonts.cormorantGaramond(
                            color: SyaahiColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: Text(
                          'This action permanently removes the poem from Syaahi.\n\nThis cannot be undone.',
                          style: GoogleFonts.inter(
                            color: SyaahiColors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                color: SyaahiColors.textMuted,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text(
                              'Delete',
                              style: GoogleFonts.inter(
                                color: SyaahiColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      try {
                        final repo = ref.read(poemsRepositoryProvider);
                        await repo.deletePoem(poem.id);
                        if (context.mounted) {
                          ref.read(feedProvider.notifier).refresh();
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Poem deleted successfully.',
                                style: GoogleFonts.inter(fontSize: 14),
                              ),
                              backgroundColor: SyaahiColors.midnightSoft,
                            ),
                          );
                        }
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not delete poem. Try again.'),
                            ),
                          );
                        }
                      }
                    }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          color: SyaahiColors.error,
                          size: 18,
                        ),
                        const SizedBox(width: SyaahiSizes.sm),
                        Text(
                          'Delete Poem',
                          style: GoogleFonts.inter(
                            color: SyaahiColors.error,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: poemAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: SyaahiColors.goldBase),
        ),
        error: (e, _) => _ReaderErrorView(
          error: e,
          onRetry: () => ref.invalidate(poemByIdProvider(poemId)),
        ),
        data: (poem) => _ReaderView(poem: poem),
      ),
    );
  }
}

// ── Reader Error View (UX-03) ────────────────────────────────────
class _ReaderErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ReaderErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final is404 = error is PoemsException &&
        (error as PoemsException).statusCode == 404;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SyaahiSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              is404 ? Icons.auto_stories_outlined : Icons.cloud_off_outlined,
              size: 64,
              color: SyaahiColors.textFaded,
            ),
            const SizedBox(height: SyaahiSizes.lg),
            Text(
              is404 ? 'Poem not found.' : 'Could not load this poem.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                color: SyaahiColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SyaahiSizes.sm),
            Text(
              is404
                  ? 'This poem may have been removed or never existed.'
                  : 'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: SyaahiColors.textMuted,
                fontSize: 14,
              ),
            ),
            if (!is404) ...[
              const SizedBox(height: SyaahiSizes.xl),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReaderView extends ConsumerStatefulWidget {
  final Poem poem;
  const _ReaderView({required this.poem});

  @override
  ConsumerState<_ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends ConsumerState<_ReaderView> {
  bool _hearted = false;
  bool _heartLoading = false;
  List<ReactionSummary> _reactions = [];
  bool _reactionsLoading = true;

  @override
  void initState() {
    super.initState();
    // UX-01: Use feed cache as initial value to prevent flash
    final cached = ref.read(feedProvider).heartStates[widget.poem.id];
    if (cached == HeartStatus.hearted) _hearted = true;
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final repo = ref.read(poemsRepositoryProvider);
    try {
      final results = await Future.wait([
        repo.getHeartStatus(widget.poem.id),
        repo.getReactions(widget.poem.id),
      ]);
      if (mounted) {
        setState(() {
          _hearted = results[0] as bool;
          _reactions = results[1] as List<ReactionSummary>;
          _reactionsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _reactionsLoading = false);
    }
  }

  Future<void> _toggleHeart() async {
    if (_heartLoading) return;
    setState(() => _heartLoading = true);
    final repo = ref.read(poemsRepositoryProvider);
    try {
      if (_hearted) {
        await repo.removeFromHeart(widget.poem.id);
      } else {
        await repo.commitToHeart(widget.poem.id);
      }
      if (mounted) setState(() => _hearted = !_hearted);
      // UX-01: Invalidate feed cache so it re-hydrates on return
      ref.read(feedProvider.notifier).invalidateHeart(widget.poem.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _heartLoading = false);
    }
  }

  Future<void> _toggleReaction(ReactionType type) async {
    final repo = ref.read(poemsRepositoryProvider);
    final existing = _reactions.firstWhere((r) => r.type == type);
    setState(() {
      _reactions = _reactions.map((r) {
        if (r.type != type) return r;
        return ReactionSummary(
          type: r.type,
          label: r.label,
          count: existing.reacted ? r.count - 1 : r.count + 1,
          reacted: !existing.reacted,
        );
      }).toList();
    });
    try {
      if (existing.reacted) {
        await repo.removeReaction(widget.poem.id, type);
      } else {
        await repo.addReaction(widget.poem.id, type);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _reactions = _reactions.map((r) {
            if (r.type != type) return r;
            return ReactionSummary(
              type: r.type,
              label: r.label,
              count: existing.count,
              reacted: existing.reacted,
            );
          }).toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        SyaahiSizes.xl, SyaahiSizes.md, SyaahiSizes.xl, SyaahiSizes.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 1,
              color: SyaahiColors.goldDark.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: SyaahiSizes.xl),
          if (widget.poem.title != null && widget.poem.title!.isNotEmpty) ...[
            Text(
              widget.poem.title!,
              style: GoogleFonts.cormorantGaramond(
                color: SyaahiColors.goldBase,
                fontSize: 38,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
            const SizedBox(height: SyaahiSizes.lg),
          ],
          Wrap(
            spacing: SyaahiSizes.sm,
            runSpacing: SyaahiSizes.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // UX-02: Tappable byline -> author profile
              GestureDetector(
                onTap: () => context.push('/profile/${widget.poem.author.username}'),
                child: Text(
                  'by ${widget.poem.author.displayName}',
                  style: GoogleFonts.inter(
                    color: SyaahiColors.textMuted,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.underline,
                    decorationColor: SyaahiColors.textFaded,
                  ),
                ),
              ),
              if (widget.poem.emotion != null)
                _MetaBadge(
                  text: '${widget.poem.emotion!.emoji} ${widget.poem.emotion!.label}',
                ),
              if (widget.poem.theme != null && widget.poem.theme!.isNotEmpty)
                _MetaBadge(text: '# ${widget.poem.theme}'),
            ],
          ),
          const SizedBox(height: SyaahiSizes.xxl),
          SelectableText(
            widget.poem.content,
            style: GoogleFonts.cormorantGaramond(
              color: SyaahiColors.textPrimary,
              fontSize: 22,
              height: 1.7,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: SyaahiSizes.xxl),
          Center(
            child: Container(
              width: 40, height: 1,
              color: SyaahiColors.goldDark.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: SyaahiSizes.md),
          // UX-02: Tappable attribution -> author profile
          Center(
            child: GestureDetector(
              onTap: () => context.push('/profile/${widget.poem.author.username}'),
              child: Text(
                '— ${widget.poem.author.displayName}',
                style: GoogleFonts.cormorantGaramond(
                  color: SyaahiColors.textMuted,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline,
                  decorationColor: SyaahiColors.textFaded,
                ),
              ),
            ),
          ),
          const SizedBox(height: SyaahiSizes.xxl),
          _HeartSection(
            hearted: _hearted,
            loading: _heartLoading,
            onToggle: _toggleHeart,
          ),
          const SizedBox(height: SyaahiSizes.xl),
          if (_reactionsLoading)
            const Center(
              child: CircularProgressIndicator(
                color: SyaahiColors.goldBase, strokeWidth: 2,
              ),
            )
          else if (_reactions.isNotEmpty)
            _ReactionsSection(reactions: _reactions, onToggle: _toggleReaction),
        ],
      ),
    );
  }
}

class _HeartSection extends StatelessWidget {
  final bool hearted;
  final bool loading;
  final VoidCallback onToggle;
  const _HeartSection({
    required this.hearted,
    required this.loading,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onToggle,
      child: Container(
        padding: const EdgeInsets.all(SyaahiSizes.md),
        decoration: BoxDecoration(
          color: hearted
              ? SyaahiColors.goldBase.withValues(alpha: 0.08)
              : SyaahiColors.surfaceCard,
          borderRadius: BorderRadius.circular(SyaahiSizes.radiusLg),
          border: Border.all(
            color: hearted
                ? SyaahiColors.goldBase.withValues(alpha: 0.4)
                : SyaahiColors.divider,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(
                height: 18, width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: SyaahiColors.goldBase,
                ),
              )
            else
              Icon(
                hearted ? Icons.favorite : Icons.favorite_outline,
                color: hearted ? SyaahiColors.goldBase : SyaahiColors.textMuted,
                size: 20,
              ),
            const SizedBox(width: SyaahiSizes.sm),
            Text(
              hearted ? 'Committed to Heart' : 'Commit to Heart',
              style: GoogleFonts.inter(
                color: hearted ? SyaahiColors.goldBase : SyaahiColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionsSection extends StatelessWidget {
  final List<ReactionSummary> reactions;
  final ValueChanged<ReactionType> onToggle;
  const _ReactionsSection({required this.reactions, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THIS POEM',
          style: GoogleFonts.inter(
            color: SyaahiColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: SyaahiSizes.sm),
        Wrap(
          spacing: SyaahiSizes.sm,
          runSpacing: SyaahiSizes.sm,
          children: reactions.map((r) {
            return GestureDetector(
              onTap: () => onToggle(r.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: SyaahiSizes.md,
                  vertical: SyaahiSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: r.reacted
                      ? SyaahiColors.goldBase.withValues(alpha: 0.12)
                      : SyaahiColors.surfaceCard,
                  borderRadius: BorderRadius.circular(SyaahiSizes.radiusFull),
                  border: Border.all(
                    color: r.reacted
                        ? SyaahiColors.goldBase.withValues(alpha: 0.5)
                        : SyaahiColors.divider,
                  ),
                ),
                child: Text(
                  r.label,
                  style: GoogleFonts.inter(
                    color: r.reacted
                        ? SyaahiColors.goldLight
                        : SyaahiColors.textSecondary,
                    fontSize: 13,
                    fontWeight: r.reacted ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String text;
  const _MetaBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SyaahiSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: SyaahiColors.midnightSoft,
        border: Border.all(color: SyaahiColors.divider),
        borderRadius: BorderRadius.circular(SyaahiSizes.radiusFull),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: SyaahiColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
