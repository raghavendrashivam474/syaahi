import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../../../shared/models/author_profile.dart';

/// A single author search result.
///
/// Visually distinct from poem cards — focuses on author identity.
class AuthorResultTile extends StatelessWidget {
  final AuthorProfile author;
  final VoidCallback onTap;

  const AuthorResultTile({
    super.key,
    required this.author,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SyaahiSizes.md,
          vertical: SyaahiSizes.sm,
        ),
        child: Row(
          children: [
            // Avatar or initial fallback
            CircleAvatar(
              radius: 22,
              backgroundColor: SyaahiColors.goldBase.withValues(alpha: 0.15),
              backgroundImage: author.avatarUrl != null
                  ? NetworkImage(author.avatarUrl!)
                  : null,
              child: author.avatarUrl == null
                  ? Text(
                      author.initial,
                      style: GoogleFonts.cormorantGaramond(
                        color: SyaahiColors.goldBase,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: SyaahiSizes.md),
            // Name and username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    author.displayName,
                    style: GoogleFonts.cormorantGaramond(
                      color: SyaahiColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '@',
                    style: GoogleFonts.inter(
                      color: SyaahiColors.textMuted,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (author.bio != null && author.bio!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      author.bio!,
                      style: GoogleFonts.inter(
                        color: SyaahiColors.textFaded,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: SyaahiColors.textFaded,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
