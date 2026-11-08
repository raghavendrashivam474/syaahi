import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

/// Responsive Syaahi brand mark widget.
///
/// Responsive behaviour:
/// - Mobile (< 600px): Compact logo mark ONLY (fits alongside 6 action buttons)
/// - Tablet/Desktop (>= 600px): Logo mark + Gold 'Syaahi' wordmark
class SyaahiBrandMark extends StatelessWidget {
  /// Height/width of the logo icon container.
  final double iconSize;

  /// Override for wordmark visibility.
  /// If null, automatically shows wordmark ONLY on tablet/desktop (width >= 600).
  final bool? showWordmark;

  /// Optional callback on tap. Defaults to navigating to '/home'.
  final VoidCallback? onTap;

  const SyaahiBrandMark({
    super.key,
    this.iconSize = 28,
    this.showWordmark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        // Strict 600px breakpoint: Mobile phone viewports ONLY get compact icon mark
        final displayWordmark = showWordmark ?? (screenWidth >= 600);

        return Semantics(
          label: 'Syaahi Home',
          button: true,
          child: InkWell(
            onTap: onTap ?? () => context.go('/home'),
            borderRadius: BorderRadius.circular(SyaahiSizes.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stylized compact logo container
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SyaahiSizes.radiusSm),
                      border: Border.all(
                        color: SyaahiColors.goldBase.withValues(alpha: 0.4),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: SyaahiColors.goldBase.withValues(alpha: 0.12),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(SyaahiSizes.radiusSm - 1),
                      child: Image.asset(
                        'assets/icon/syaahi.png',
                        fit: BoxFit.cover,
                        isAntiAlias: true,
                      ),
                    ),
                  ),

                  // Wordmark — Tablet & Desktop ONLY
                  if (displayWordmark) ...[
                    const SizedBox(width: SyaahiSizes.sm),
                    Flexible(
                      child: Text(
                        'Syaahi',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cormorantGaramond(
                          color: SyaahiColors.goldBase,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
