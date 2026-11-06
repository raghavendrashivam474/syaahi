import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/sizes.dart';
import '../../../shared/models/author_profile.dart';
import '../../../shared/models/poem.dart';
import '../../poems/data/poems_repository.dart' show PoemsException;
import '../../poems/state/poems_providers.dart' show poemsRepositoryProvider;
import '../state/profile_providers.dart';

/// Shared profile presentation used by both [ProfileScreen] (own)
/// and [AuthorProfileScreen] (public).
class AuthorProfileView extends ConsumerStatefulWidget {
  final String username;
  final bool isOwnProfile;

  const AuthorProfileView({
    super.key,
    required this.username,
    required this.isOwnProfile,
  });

  @override
  ConsumerState<AuthorProfileView> createState() => _AuthorProfileViewState();
}

class _AuthorProfileViewState extends ConsumerState<AuthorProfileView> {
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
      ref.read(authorPoemsProvider(widget.username).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(authorProfileProvider(widget.username));
    final poemsState = ref.watch(authorPoemsProvider(widget.username));

    return profileAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: SyaahiColors.goldBase),
      ),
      error: (error, _) {
        final is404 = error is PoemsException && error.statusCode == 404;
        if (is404) return _NotFoundView(username: widget.username);
        return _ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(authorProfileProvider(widget.username)),
        );
      },
      data: (profile) => _buildContent(context, profile, poemsState),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AuthorProfile profile,
    AuthorPoemsState poemsState,
  ) {
    return RefreshIndicator(
      color: SyaahiColors.goldBase,
      backgroundColor: SyaahiColors.midnightBase,
      onRefresh: () async {
        ref.invalidate(authorProfileProvider(widget.username));
        await ref.read(authorPoemsProvider(widget.username).notifier).refresh();
      },
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(SyaahiSizes.xl),
        children: [
          _ProfileHeader(profile: profile),
          const SizedBox(height: SyaahiSizes.xxl),
          Container(height: 0.5, color: SyaahiColors.divider),
          const SizedBox(height: SyaahiSizes.xxl),
          _PoemsSection(
            poemsState: poemsState,
            isOwnProfile: widget.isOwnProfile,
            username: widget.username,
          ),
          const SizedBox(height: SyaahiSizes.xxxl),
        ],
      ),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final AuthorProfile profile;
  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final joinedDate = DateFormat('MMM yyyy').format(profile.createdAt);
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: SyaahiColors.midnightLight,
          backgroundImage: profile.avatarUrl != null
              ? NetworkImage(profile.avatarUrl!)
              : null,
          child: profile.avatarUrl == null
              ? Text(
                  profile.initial,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 38,
                    color: SyaahiColors.goldBase,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
        ),
        const SizedBox(height: SyaahiSizes.md),
        Text(
          profile.displayName,
          style: GoogleFonts.cormorantGaramond(
            color: SyaahiColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SyaahiSizes.xs),
        Text(
          '@${profile.username}',
          style: GoogleFonts.inter(
            color: SyaahiColors.textMuted,
            fontSize: 14,
          ),
        ),
        if (profile.bio != null && profile.bio!.isNotEmpty) ...[
          const SizedBox(height: SyaahiSizes.md),
          Text(
            profile.bio!,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: SyaahiColors.textSecondary,
              fontSize: 14,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: SyaahiSizes.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MetaChip(
              icon: Icons.auto_stories_outlined,
              label: '${profile.poemCount} poem${profile.poemCount == 1 ? '' : 's'}',
            ),
            const SizedBox(width: SyaahiSizes.md),
            _MetaChip(
              icon: Icons.calendar_today_outlined,
              label: 'Joined $joinedDate',
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: SyaahiColors.textFaded),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: SyaahiColors.textFaded,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ── Poems Section (ConsumerWidget — needs ref for provider reads) ─

class _PoemsSection extends ConsumerWidget {
  final AuthorPoemsState poemsState;
  final bool isOwnProfile;
  final String username;

  const _PoemsSection({
    required this.poemsState,
    required this.isOwnProfile,
    required this.username,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PUBLISHED WORKS',
          style: GoogleFonts.inter(
            color: SyaahiColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: SyaahiSizes.md),
        if (poemsState.isLoading && poemsState.poems.isEmpty)
          const Padding(
            padding: EdgeInsets.all(SyaahiSizes.xl),
            child: Center(
              child: CircularProgressIndicator(
                color: SyaahiColors.goldBase,
                strokeWidth: 2,
              ),
            ),
          )
        else if (poemsState.error != null && poemsState.poems.isEmpty)
          _ErrorView(
            message: poemsState.error!,
            onRetry: () =>
                ref.read(authorPoemsProvider(username).notifier).refresh(),
          )
        else if (poemsState.poems.isEmpty)
          _EmptyPoemsView(isOwnProfile: isOwnProfile)
        else
          ...poemsState.poems.map(
            (poem) => Padding(
              padding: const EdgeInsets.only(bottom: SyaahiSizes.md),
              child: _AuthorPoemTile(
                poem: poem,
                isOwnProfile: isOwnProfile,
                username: username,
              ),
            ),
          ),
        if (poemsState.isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(SyaahiSizes.md),
            child: Center(
              child: CircularProgressIndicator(
                color: SyaahiColors.goldBase,
                strokeWidth: 2,
              ),
            ),
          ),
        if (poemsState.error != null && poemsState.poems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SyaahiSizes.sm),
            child: Center(
              child: Text(
                poemsState.error!,
                style: GoogleFonts.inter(
                  color: SyaahiColors.error,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Poem Tile (ConsumerWidget — needs ref for delete) ─────────────

class _AuthorPoemTile extends ConsumerWidget {
  final Poem poem;
  final bool isOwnProfile;
  final String username;

  const _AuthorPoemTile({
    required this.poem,
    required this.isOwnProfile,
    required this.username,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tile = InkWell(
      onTap: () => context.push('/poem/${poem.id}'),
      borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(SyaahiSizes.md),
        decoration: BoxDecoration(
          color: SyaahiColors.surfaceCard,
          borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
          border: Border.all(color: SyaahiColors.divider, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (poem.title != null && poem.title!.isNotEmpty)
                    Text(
                      poem.title!,
                      style: GoogleFonts.cormorantGaramond(
                        color: SyaahiColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Text(
                      poem.content.length > 60
                          ? '${poem.content.substring(0, 60)}...'
                          : poem.content,
                      style: GoogleFonts.cormorantGaramond(
                        color: SyaahiColors.textSecondary,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const SizedBox(height: SyaahiSizes.xs),
                  Row(
                    children: [
                      Text(
                        poem.language.label,
                        style: GoogleFonts.inter(
                          color: SyaahiColors.textFaded,
                          fontSize: 11,
                        ),
                      ),
                      if (poem.emotion != null) ...[
                        Text(
                          ' \u00b7 ',
                          style: GoogleFonts.inter(
                            color: SyaahiColors.textFaded,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          poem.emotion!.label,
                          style: GoogleFonts.inter(
                            color: SyaahiColors.textFaded,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: SyaahiColors.textFaded,
              size: 18,
            ),
          ],
        ),
      ),
    );

    if (!isOwnProfile) return tile;

    return Stack(
      children: [
        tile,
        Positioned(
          top: 0,
          right: 0,
          child: PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: SyaahiColors.textFaded,
              size: 18,
            ),
            color: SyaahiColors.midnightSoft,
            onSelected: (value) async {
              if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: SyaahiColors.midnightSoft,
                    title: Text(
                      'Delete Poem',
                      style: GoogleFonts.cormorantGaramond(
                        color: SyaahiColors.textPrimary,
                        fontSize: 22,
                      ),
                    ),
                    content: Text(
                      'This cannot be undone.',
                      style: GoogleFonts.inter(
                        color: SyaahiColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            color: SyaahiColors.textMuted,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
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
                    await ref
                        .read(poemsRepositoryProvider)
                        .deletePoem(poem.id);
                    ref
                        .read(authorPoemsProvider(username).notifier)
                        .refresh();
                    ref.invalidate(authorProfileProvider(username));
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
          ),
        ),
      ],
    );
  }
}

// ── State Views ───────────────────────────────────────────────────

class _EmptyPoemsView extends StatelessWidget {
  final bool isOwnProfile;
  const _EmptyPoemsView({required this.isOwnProfile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SyaahiSizes.xl),
      child: Column(
        children: [
          const Icon(Icons.edit_note_outlined, size: 48, color: SyaahiColors.textFaded),
          const SizedBox(height: SyaahiSizes.md),
          Text(
            isOwnProfile
                ? 'You haven\'t published any poems yet.'
                : 'No published poems yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: SyaahiColors.textMuted,
              fontSize: 14,
            ),
          ),
          if (isOwnProfile) ...[
            const SizedBox(height: SyaahiSizes.md),
            TextButton.icon(
              onPressed: () => context.push('/write'),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Write your first poem'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SyaahiSizes.xl),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48, color: SyaahiColors.textMuted),
          const SizedBox(height: SyaahiSizes.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: SyaahiColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: SyaahiSizes.md),
          TextButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  final String username;
  const _NotFoundView({required this.username});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SyaahiSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_outlined, size: 64, color: SyaahiColors.textFaded),
            const SizedBox(height: SyaahiSizes.lg),
            Text(
              '@$username',
              style: GoogleFonts.cormorantGaramond(
                color: SyaahiColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SyaahiSizes.sm),
            Text(
              'This writer could not be found.',
              style: GoogleFonts.inter(color: SyaahiColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
