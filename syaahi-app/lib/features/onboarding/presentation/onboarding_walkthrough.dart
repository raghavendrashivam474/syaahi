import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/sizes.dart';
import '../state/onboarding_providers.dart';

class OnboardingWalkthrough {
  OnboardingWalkthrough._();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _WalkthroughSheet(),
    );
  }
}

class _WalkthroughSheet extends ConsumerStatefulWidget {
  const _WalkthroughSheet();

  @override
  ConsumerState<_WalkthroughSheet> createState() => _WalkthroughSheetState();
}

class _WalkthroughSheetState extends ConsumerState<_WalkthroughSheet> {
  int _step = 0;

  static const _steps = [
    {'icon': Icons.auto_stories_outlined, 'title': 'Discover',
     'body': 'Browse poems from writers around the world. Each poem is a window into someone else\'s experience.'},
    {'icon': Icons.favorite_border_rounded, 'title': 'Appreciate',
     'body': 'When a poem moves you, tap the heart. It is a quiet way of saying "this mattered to me."'},
    {'icon': Icons.chat_bubble_outline_rounded, 'title': 'Respond',
     'body': 'Share your own words in response to a poem. A thoughtful reply can mean more than a hundred likes.'},
    {'icon': Icons.waves_outlined, 'title': 'Resonance',
     'body': 'Resonance is the space where readers and writers meet through honest conversation.'},
    {'icon': Icons.edit_outlined, 'title': 'Express',
     'body': 'When you are ready, write your own poem. There is no rush. Your words will wait for you.'},
  ];

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    final isLast = _step == _steps.length - 1;

    return Container(
      decoration: const BoxDecoration(
        color: SyaahiColors.midnightBase,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: SyaahiSizes.xl,
        right: SyaahiSizes.xl,
        top: SyaahiSizes.md,
        bottom: SyaahiSizes.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SyaahiColors.textFaded.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: SyaahiSizes.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_steps.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
          Icon(
            step['icon'] as IconData,
            size: 40,
            color: SyaahiColors.goldLight,
          ),
          const SizedBox(height: SyaahiSizes.md),
          Text(
            step['title'] as String,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: SyaahiColors.textPrimary,
            ),
          ),
          const SizedBox(height: SyaahiSizes.sm),
          Text(
            step['body'] as String,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: SyaahiColors.textMuted,
              height: 1.6,
            ),
          ),
          const SizedBox(height: SyaahiSizes.xl),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  markWalkthroughCompleted(ref);
                  Navigator.pop(context);
                },
                child: Text(
                  isLast ? 'Done' : 'Skip',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: SyaahiColors.textFaded,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                ),
                onPressed: () {
                  if (_step < _steps.length - 1) {
                    setState(() => _step++);
                  } else {
                    markWalkthroughCompleted(ref);
                    Navigator.pop(context);
                  }
                },
                child: Text(isLast ? 'Get Started' : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}