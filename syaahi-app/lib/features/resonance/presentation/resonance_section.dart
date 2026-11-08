import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../../../shared/models/poem.dart';
import '../../auth/state/auth_providers.dart';
import '../state/resonance_providers.dart';
import 'response_composer.dart';
import 'response_item.dart';
import '../../onboarding/presentation/auth_prompt.dart';

class ResonanceSection extends ConsumerWidget {
  final Poem poem;

  const ResonanceSection({super.key, required this.poem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resonanceProvider(poem.id));
    final currentUser = ref.watch(authProvider).user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Description
        Text(
          'RESONANCE',
          style: GoogleFonts.inter(
            color: SyaahiColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: SyaahiSizes.xs),
        Text(
          'Share what this poem made you feel or connect with.',
          style: GoogleFonts.inter(
            color: SyaahiColors.textFaded,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: SyaahiSizes.md),

        // Response Composer (if logged in)
        if (currentUser != null)
          ResponseComposer(poemId: poem.id)
        else
          _GuestResonancePrompt(poemTitle: poem.title ?? 'this poem'),

        const SizedBox(height: SyaahiSizes.lg),

        // Response List / States
        if (state.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(SyaahiSizes.lg),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: SyaahiColors.goldBase,
              ),
            ),
          )
        else if (state.error != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(SyaahiSizes.md),
              child: Text(
                'Could not load responses.',
                style: GoogleFonts.inter(
                  color: SyaahiColors.textFaded,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else if (state.responses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SyaahiSizes.md),
            child: Center(
              child: Text(
                'No responses yet. Every conversation starts with a single word.',
                style: GoogleFonts.cormorantGaramond(
                  color: SyaahiColors.textFaded,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.responses.length,
            itemBuilder: (context, index) {
              final response = state.responses[index];
              return ResponseItem(
                poemId: poem.id,
                authorId: poem.author.id,
                response: response,
              );
            },
          ),
      ],
    );
  }
}

// ── UX-07: Guest Resonance Prompt ──────────────────────────────
class _GuestResonancePrompt extends StatelessWidget {
  final String poemTitle;
  const _GuestResonancePrompt({required this.poemTitle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AuthPrompt.show(context, action: 'respond to this poem'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: SyaahiSizes.lg,
          vertical: SyaahiSizes.md,
        ),
        decoration: BoxDecoration(
          color: SyaahiColors.goldDark.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: SyaahiColors.goldDark.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.edit_outlined,
              size: 18,
              color: SyaahiColors.goldLight.withValues(alpha: 0.6),
            ),
            const SizedBox(width: SyaahiSizes.sm),
            Expanded(
              child: Text(
                'Sign in to share your response',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: SyaahiColors.textMuted,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: SyaahiColors.textFaded,
            ),
          ],
        ),
      ),
    );
  }
}

