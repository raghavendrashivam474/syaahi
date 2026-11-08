import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/sizes.dart';
import '../state/onboarding_providers.dart';

/// A short, skippable walkthrough that introduces Syaahi's
/// interaction model. Not a compulsory tutorial — the user
/// can exit at any time.
///
/// Triggered from the feed screen via a help icon or menu.
class OnboardingWalkthrough extends ConsumerStatefulWidget {
  const OnboardingWalkthrough({super.key});

  /// Shows the walkthrough as a full-screen dialog.
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => const OnboardingWalkthrough(),
    );
  }

  @override
  ConsumerState<OnboardingWalkthrough> createState() =>
      _OnboardingWalkthroughState();
}

class _OnboardingWalkthroughState
    extends ConsumerState<OnboardingWalkthrough> {
  int _step = 0;

  static const _steps = <_WalkStep>[
    _WalkStep(
      icon: Icons.auto_stories_outlined,
      title: 'Discover',
      body:
          'Browse poems from writers around the world. '
          'Each poem is a window into someone else\'s experience.',
    ),
    _WalkStep(
      icon: Icons.favorite_border_rounded,
      title: 'Appreciate',
      body:
          'When a poem moves you, tap the heart. '
          'It is a quiet way of saying "this mattered to me."',
    ),
    _WalkStep(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Respond',
      body:
          'Share your own words in response to a poem. '
          'A thoughtful reply can mean more than a hundred likes.',
    ),
    _WalkStep(
      icon: Icons.waves_outlined,
      title: 'Resonance',
      body:
          'Resonance is the space where readers and writers '
          'meet through honest conversation.',
    ),
    _WalkStep(
      icon: Icons.edit_outlined,
      title: 'Express',
      body:
          'When you are ready, write your own poem. '
          'There is no rush. Your words will wait for you.',
    ),
  ];

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _finish() {
    markWalkthroughCompleted(ref);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    final isLast = _step == _steps.length - 1;

    return Dialog(
      backgroundColor: SyaahiColors.midnightBase,
      insetPadding: const EdgeInsets.all(SyaahiSizes.xl),
      child: Container(
        padding: const EdgeInsets.all(SyaahiSizes.xl),
        decoration: BoxDecoration(
          color: SyaahiColors.midnightBase,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: SyaahiColors.goldBase.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _step ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: i == _step
                        ? SyaahiColors.goldBase
                        : SyaahiColors.textFaded.withValues(alpha: 0.3),
                  ),
                );
              }),
            ),
            const SizedBox(height: SyaahiSizes.xl),

            // Icon
            Icon(step.icon, size: 40, color: SyaahiColors.goldLight),
            const SizedBox(height: SyaahiSizes.md),

            // Title
            Text(
              step.title,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: SyaahiColors.textPrimary,
              ),
            ),
            const SizedBox(height: SyaahiSizes.sm),

            // Body
            Text(
              step.body,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: SyaahiColors.textMuted,
                height: 1.6,
              ),
            ),
            const SizedBox(height: SyaahiSizes.xl),

            // Actions
            Row(
              children: [
                // Skip / Back
                TextButton(
                  onPressed: _finish,
                  child: Text(
                    isLast ? 'Done' : 'Skip',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: SyaahiColors.textFaded,
                    ),
                  ),
                ),
                const Spacer(),
                // Next
                ElevatedButton(
                  onPressed: _next,
                  child: Text(isLast ? 'Get Started' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkStep {
  final IconData icon;
  final String title;
  final String body;
  const _WalkStep({
    required this.icon,
    required this.title,
    required this.body,
  });
}
