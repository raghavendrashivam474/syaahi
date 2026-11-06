import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';

/// Shown when a search returns no results.
class DiscoveryEmptyState extends StatelessWidget {
  final String query;

  const DiscoveryEmptyState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SyaahiSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: SyaahiColors.textFaded,
            ),
            const SizedBox(height: SyaahiSizes.md),
            Text(
              'No writers found',
              style: GoogleFonts.cormorantGaramond(
                color: SyaahiColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SyaahiSizes.sm),
            Text(
              'No results for "$query".\nTry a different name or spelling.',
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
