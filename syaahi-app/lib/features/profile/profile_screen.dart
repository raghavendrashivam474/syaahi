import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syaahi_app/core/constants/colors.dart';
import 'package:syaahi_app/core/constants/sizes.dart';
import 'package:syaahi_app/features/auth/state/auth_providers.dart';
import 'package:syaahi_app/shared/models/poem.dart';
import 'package:syaahi_app/features/poems/state/poems_providers.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SyaahiSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar and identity
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: SyaahiColors.midnightLight,
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 36,
                        color: SyaahiColors.goldBase,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: SyaahiSizes.md),
                  Text(
                    user.displayName,
                    style: GoogleFonts.cormorantGaramond(
                      color: SyaahiColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SyaahiSizes.xs),
                  Text(
                    '@${user.username}',
                    style: GoogleFonts.inter(
                      color: SyaahiColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: SyaahiSizes.md),
                    Text(
                      user.bio!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: SyaahiColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: SyaahiSizes.xxl),
            Container(height: 0.5, color: SyaahiColors.divider),
            const SizedBox(height: SyaahiSizes.xxl),

            // Writing section
            _ProfileUserPoems(username: user.username),

            const SizedBox(height: SyaahiSizes.xxl),
          ],
        ),
      ),
    );
  }
}

class _ProfileUserPoems extends ConsumerWidget {
  final String username;
  const _ProfileUserPoems({required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poemsAsync = ref.watch(userPoemsProvider(username));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WRITTEN',
          style: GoogleFonts.inter(
            color: SyaahiColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: SyaahiSizes.md),
        poemsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: SyaahiColors.goldBase,
              strokeWidth: 2,
            ),
          ),
          error: (e, _) => Text(
            'Could not load poems.',
            style: GoogleFonts.inter(
              color: SyaahiColors.textMuted,
              fontSize: 13,
            ),
          ),
          data: (poems) {
            if (poems.isEmpty) {
              return Text(
                'No poems yet.',
                style: GoogleFonts.inter(
                  color: SyaahiColors.textMuted,
                  fontSize: 14,
                ),
              );
            }

            // Collect languages used
            final languages = poems
                .map((p) => p.language.label)
                .toSet()
                .toList();

            // Collect emotions used
            final emotions = poems
                .where((p) => p.emotion != null)
                .map((p) => p.emotion!.label)
                .toSet()
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                Row(
                  children: [
                    _StatChip(
                      label: '${poems.length}',
                      sublabel: poems.length == 1 ? 'poem' : 'poems',
                    ),
                    const SizedBox(width: SyaahiSizes.sm),
                    ...languages.map(
                      (l) => Padding(
                        padding: const EdgeInsets.only(right: SyaahiSizes.sm),
                        child: _StatChip(label: l, sublabel: 'language'),
                      ),
                    ),
                  ],
                ),

                if (emotions.isNotEmpty) ...[
                  const SizedBox(height: SyaahiSizes.md),
                  Text(
                    'EMOTIONS EXPLORED',
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
                    children: emotions.map((e) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SyaahiSizes.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: SyaahiColors.midnightSoft,
                          border: Border.all(color: SyaahiColors.divider),
                          borderRadius:
                              BorderRadius.circular(SyaahiSizes.radiusFull),
                        ),
                        child: Text(
                          e,
                          style: GoogleFonts.inter(
                            color: SyaahiColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: SyaahiSizes.xl),

                Text(
                  'POEMS',
                  style: GoogleFonts.inter(
                    color: SyaahiColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: SyaahiSizes.md),

                ...poems.map(
                  (poem) => Padding(
                    padding: const EdgeInsets.only(bottom: SyaahiSizes.md),
                    child: _ProfilePoemTile(poem: poem),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String sublabel;
  const _StatChip({required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SyaahiSizes.md,
        vertical: SyaahiSizes.sm,
      ),
      decoration: BoxDecoration(
        color: SyaahiColors.surfaceCard,
        borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
        border: Border.all(color: SyaahiColors.divider),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.cormorantGaramond(
              color: SyaahiColors.goldBase,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            sublabel,
            style: GoogleFonts.inter(
              color: SyaahiColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePoemTile extends StatelessWidget {
  final Poem poem;
  const _ProfilePoemTile({required this.poem});

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                          ' · ',
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
  }
}