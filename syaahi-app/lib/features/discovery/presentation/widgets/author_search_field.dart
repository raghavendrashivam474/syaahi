import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';

/// Debounced search input for author discovery.
class AuthorSearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String initialValue;

  const AuthorSearchField({
    super.key,
    required this.onChanged,
    required this.onClear,
    this.initialValue = '',
  });

  @override
  State<AuthorSearchField> createState() => _AuthorSearchFieldState();
}

class _AuthorSearchFieldState extends State<AuthorSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: GoogleFonts.inter(
        color: SyaahiColors.textPrimary,
        fontSize: 15,
      ),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search by name or username',
        hintStyle: GoogleFonts.inter(
          color: SyaahiColors.textFaded,
          fontSize: 15,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: SyaahiColors.textMuted,
          size: 22,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.close,
                  color: SyaahiColors.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onClear();
                },
              )
            : null,
        filled: true,
        fillColor: SyaahiColors.midnightDark.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SyaahiSizes.md,
          vertical: SyaahiSizes.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: SyaahiColors.goldBase,
            width: 1,
          ),
        ),
      ),
    );
  }
}
