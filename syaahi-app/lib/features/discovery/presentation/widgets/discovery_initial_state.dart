import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';

/// Shown before the user starts searching.
class DiscoveryInitialState extends StatelessWidget {
  const DiscoveryInitialState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SyaahiSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_stories_outlined,
              size: 56,
              color: SyaahiColors.textFaded,
            ),
            const SizedBox(height: SyaahiSizes.lg),
            Text(
              'Discover Writers',
              style: GoogleFonts.cormorantGaramond(
                color: SyaahiColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SyaahiSizes.sm),
            Text(
              'Search for writers by name or username\nand explore their published work.',
              style: GoogleFonts.inter(
                color: SyaahiColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
