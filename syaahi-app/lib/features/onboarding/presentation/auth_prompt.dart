import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/sizes.dart';

/// A calm, non-intrusive prompt shown when a guest attempts
/// a protected action (heart, respond, write, etc.).
///
/// Explains why authentication is needed and offers clear
/// entry points to sign in or create an account.
///
/// Usage:
/// ```dart
/// AuthPrompt.show(context, action: 'appreciate this poem');
/// ```
class AuthPrompt extends StatelessWidget {
  final String action;

  const AuthPrompt({super.key, required this.action});

  /// Shows the auth prompt as a bottom sheet.
  static Future<void> show(BuildContext context, {required String action}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AuthPrompt(action: action),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SyaahiColors.midnightBase,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        left: SyaahiSizes.xl,
        right: SyaahiSizes.xl,
        top: SyaahiSizes.lg,
        bottom: MediaQuery.paddingOf(context).bottom + SyaahiSizes.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: SyaahiColors.textFaded.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: SyaahiSizes.lg),

          // Message
          Text(
            'To $action, you need an account.',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              color: SyaahiColors.textPrimary,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: SyaahiSizes.sm),
          Text(
            'Your words and appreciation are worth preserving.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: SyaahiColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: SyaahiSizes.xl),

          // Actions
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/auth/signup');
              },
              child: const Text('Create Account'),
            ),
          ),
          const SizedBox(height: SyaahiSizes.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/auth/login');
              },
              child: Text(
                'Sign in instead',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: SyaahiColors.goldLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
