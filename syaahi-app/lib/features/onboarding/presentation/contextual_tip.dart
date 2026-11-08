import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/sizes.dart';
import '../state/onboarding_providers.dart';

/// A small, dismissible explanation that appears the first time
/// a user encounters a specific interaction.
///
/// Non-blocking: the user can continue their primary action
/// while the tip is visible.
///
/// Usage:
/// ```dart
/// ContextualTip(
///   feature: 'heart',
///   message: 'Tap the heart to appreciate a poem.',
///   child: HeartButton(...),
/// )
/// ```
class ContextualTip extends ConsumerWidget {
  final String feature;
  final String message;
  final Widget child;
  final bool enabled;

  const ContextualTip({
    super.key,
    required this.feature,
    required this.message,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled) return child;

    final seenAsync = ref.watch(contextualSeenProvider(feature));

    return seenAsync.when(
      loading: () => child,
      error: (_, __) => child,
      data: (seen) {
        if (seen) return child;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            child,
            const SizedBox(height: 6),
            _TipBubble(
              message: message,
              onDismiss: () => markContextualSeen(ref, feature),
            ),
          ],
        );
      },
    );
  }
}

class _TipBubble extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _TipBubble({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SyaahiSizes.md,
          vertical: SyaahiSizes.sm,
        ),
        decoration: BoxDecoration(
          color: SyaahiColors.goldDark.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: SyaahiColors.goldDark.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              size: 14,
              color: SyaahiColors.goldLight,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: SyaahiColors.textMuted,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.close,
              size: 12,
              color: SyaahiColors.textFaded,
            ),
          ],
        ),
      ),
    );
  }
}
