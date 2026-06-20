import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/strings.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SyaahiSizes.xl),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Brand mark
                Icon(
                  Icons.edit_note_rounded,
                  size: 64,
                  color: SyaahiColors.goldBase,
                ),
                const SizedBox(height: SyaahiSizes.md),
                Text(
                  SyaahiStrings.appName,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 56,
                    fontWeight: FontWeight.w600,
                    color: SyaahiColors.goldBase,
                    letterSpacing: 2.0,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: SyaahiSizes.sm),
                Container(
                  width: 50,
                  height: 1,
                  color: SyaahiColors.goldDark.withValues(alpha: 0.5),
                ),

                const Spacer(flex: 1),

                // Promise
                Text(
                  'A sanctuary for poetry,',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    color: SyaahiColors.textPrimary,
                    fontStyle: FontStyle.italic,
                    height: 1.3,
                  ),
                ),
                Text(
                  'journals, and emotions.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    color: SyaahiColors.textPrimary,
                    fontStyle: FontStyle.italic,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: SyaahiSizes.lg),

                Text(
                  'Where emotions become words.\nWhere words become memories.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: SyaahiColors.textMuted,
                    height: 1.6,
                    letterSpacing: 0.3,
                  ),
                ),

                const Spacer(flex: 2),

                // Actions
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/auth/signup'),
                    child: const Text('Begin Your Journey'),
                  ),
                ),
                const SizedBox(height: SyaahiSizes.md),
                TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: SyaahiColors.textMuted,
                      ),
                      children: const [
                        TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign in',
                          style: TextStyle(
                            color: SyaahiColors.goldLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: SyaahiSizes.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}