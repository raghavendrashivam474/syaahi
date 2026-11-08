import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/strings.dart';
import '../onboarding/state/onboarding_providers.dart';

/// Story-led first encounter for Syaahi.
///
/// Introduces the three product pillars — Discover, Express, Connect —
/// through a calm, literary narrative rather than a product advertisement.
///
/// This is not a multi-page carousel. It is a single, scrollable
/// introduction that respects the reader's time and intelligence.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Mark welcome as seen on first display (device-level).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      markWelcomeSeen(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth > 768;
    final contentWidth = isWide ? 520.0 : screenWidth - SyaahiSizes.xl * 2;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              SyaahiColors.midnightDark,
              SyaahiColors.midnightBase,
              SyaahiColors.midnightDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: SyaahiSizes.xl,
                  vertical: SyaahiSizes.lg,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    _buildHero(),
                    const SizedBox(height: 48),
                    _buildPillar(
                      icon: Icons.auto_stories_outlined,
                      title: 'Discover',
                      body:
                          'Wander through poems written by voices you '
                          "haven't met yet. Every poem is a window "
                          "into someone's world.",
                    ),
                    const SizedBox(height: 36),
                    _buildDivider(),
                    const SizedBox(height: 36),
                    _buildPillar(
                      icon: Icons.edit_outlined,
                      title: 'Express',
                      body:
                          'Your thoughts deserve a quiet place. '
                          'Write what you feel, preserve what matters, '
                          "and share when you're ready.",
                    ),
                    const SizedBox(height: 36),
                    _buildDivider(),
                    const SizedBox(height: 36),
                    _buildPillar(
                      icon: Icons.favorite_border_rounded,
                      title: 'Connect',
                      body:
                          'Appreciate a line that moved you. '
                          'Respond with your own words. '
                          'Meaningful connections begin with '
                          'honest reading.',
                    ),
                    const SizedBox(height: 48),
                    _buildActions(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero Section ──────────────────────────────────────────

  Widget _buildHero() {
    return Column(
      children: [
        const Icon(
          Icons.edit_note_rounded,
          size: 56,
          color: SyaahiColors.goldBase,
        ),
        const SizedBox(height: SyaahiSizes.md),
        Text(
          SyaahiStrings.appName,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 48,
            fontWeight: FontWeight.w600,
            color: SyaahiColors.goldBase,
            letterSpacing: 2.0,
            height: 1.0,
          ),
        ),
        const SizedBox(height: SyaahiSizes.md),
        Container(
          width: 40,
          height: 1,
          color: SyaahiColors.goldDark.withValues(alpha: 0.5),
        ),
        const SizedBox(height: SyaahiSizes.lg),
        Text(
          'A sanctuary where words find their home.',
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            color: SyaahiColors.textPrimary,
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ── Pillar Section ────────────────────────────────────────

  Widget _buildPillar({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Column(
      children: [
        Icon(icon, size: 28, color: SyaahiColors.goldLight),
        const SizedBox(height: SyaahiSizes.sm),
        Text(
          title,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: SyaahiColors.textPrimary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: SyaahiSizes.sm),
        Text(
          body,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: SyaahiColors.textMuted,
            height: 1.7,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ── Divider ───────────────────────────────────────────────

  Widget _buildDivider() {
    return Container(
      width: 24,
      height: 1,
      color: SyaahiColors.goldDark.withValues(alpha: 0.3),
    );
  }

  // ── Action Buttons ────────────────────────────────────────

  Widget _buildActions() {
    return Column(
      children: [
        // Explore — for guests who want to browse first
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go('/discover'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: SyaahiColors.goldDark.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Explore Syaahi',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: SyaahiColors.goldLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: SyaahiSizes.md),

        // Join — primary action
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/auth/signup'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Join Syaahi'),
          ),
        ),
        const SizedBox(height: SyaahiSizes.sm),

        // Sign in — secondary
        TextButton(
          onPressed: () => context.go('/auth/login'),
          child: Text(
            'Already have an account? Sign in',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: SyaahiColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
