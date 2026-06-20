import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/sizes.dart';
import '../../../shared/models/poem.dart';
import '../state/poems_providers.dart';

class ReaderScreen extends ConsumerWidget {
  final String poemId;
  const ReaderScreen({super.key, required this.poemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poemAsync = ref.watch(poemByIdProvider(poemId));

    return Scaffold(
      backgroundColor: SyaahiColors.midnightDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const SizedBox.shrink(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SyaahiColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: poemAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: SyaahiColors.goldBase),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(SyaahiSizes.xl),
            child: Text(
              'Could not load poem.\n$e',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: SyaahiColors.textMuted),
            ),
          ),
        ),
        data: (poem) => _ReaderView(poem: poem),
      ),
    );
  }
}

class _ReaderView extends StatelessWidget {
  final Poem poem;
  const _ReaderView({required this.poem});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        SyaahiSizes.xl,
        SyaahiSizes.md,
        SyaahiSizes.xl,
        SyaahiSizes.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative top ornament
          Center(
            child: Container(
              width: 40,
              height: 1,
              color: SyaahiColors.goldDark.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: SyaahiSizes.xl),

          if (poem.title != null && poem.title!.isNotEmpty) ...[
            Text(
              poem.title!,
              style: GoogleFonts.cormorantGaramond(
                color: SyaahiColors.goldBase,
                fontSize: 38,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
            const SizedBox(height: SyaahiSizes.lg),
          ],

          // Metadata row (author + emotion + theme)
          Wrap(
            spacing: SyaahiSizes.sm,
            runSpacing: SyaahiSizes.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'by ${poem.author.displayName}',
                style: GoogleFonts.inter(
                  color: SyaahiColors.textMuted,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (poem.emotion != null)
                _MetaBadge(text: '${poem.emotion!.emoji} ${poem.emotion!.label}'),
              if (poem.theme != null && poem.theme!.isNotEmpty)
                _MetaBadge(text: '# ${poem.theme}'),
            ],
          ),

          const SizedBox(height: SyaahiSizes.xxl),

          // The poem itself — beautiful serif
          SelectableText(
            poem.content,
            style: GoogleFonts.cormorantGaramond(
              color: SyaahiColors.textPrimary,
              fontSize: 22,
              height: 1.7,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: SyaahiSizes.xxl),

          // Decorative bottom ornament
          Center(
            child: Container(
              width: 40,
              height: 1,
              color: SyaahiColors.goldDark.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: SyaahiSizes.md),
          Center(
            child: Text(
              '— ${poem.author.displayName}',
              style: GoogleFonts.cormorantGaramond(
                color: SyaahiColors.textMuted,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String text;
  const _MetaBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SyaahiSizes.sm,
        vertical: 4,
      ),
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