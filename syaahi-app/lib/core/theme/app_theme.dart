import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

class SyaahiTheme {
  SyaahiTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    final textTheme = _buildTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: SyaahiColors.midnightDark,
      brightness: Brightness.dark,
      primaryColor: SyaahiColors.goldBase,

      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: SyaahiColors.goldBase,
        onPrimary: SyaahiColors.midnightDark,
        secondary: SyaahiColors.goldLight,
        onSecondary: SyaahiColors.midnightDark,
        surface: SyaahiColors.midnightBase,
        onSurface: SyaahiColors.textPrimary,
        error: SyaahiColors.error,
        onError: SyaahiColors.textPrimary,
      ),

      textTheme: textTheme,
      primaryTextTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: SyaahiColors.midnightDark,
        foregroundColor: SyaahiColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          color: SyaahiColors.goldBase,
          fontSize: 26,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SyaahiColors.goldBase,
          foregroundColor: SyaahiColors.midnightDark,
          minimumSize: const Size.fromHeight(SyaahiSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SyaahiColors.goldLight,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SyaahiColors.surfaceCard,
        hintStyle: GoogleFonts.inter(color: SyaahiColors.textMuted),
        labelStyle: GoogleFonts.inter(color: SyaahiColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SyaahiSizes.md,
          vertical: SyaahiSizes.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
          borderSide: const BorderSide(color: SyaahiColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
          borderSide: const BorderSide(color: SyaahiColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
          borderSide: const BorderSide(color: SyaahiColors.goldBase, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
          borderSide: const BorderSide(color: SyaahiColors.error),
        ),
      ),

      cardTheme: CardThemeData(
        color: SyaahiColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SyaahiSizes.radiusLg),
          side: const BorderSide(color: SyaahiColors.divider, width: 0.5),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: SyaahiColors.divider,
        thickness: 0.5,
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    // Cormorant Garamond → poetry, headings (feels literary)
    // Inter → UI text (readable, modern)
    final serif = GoogleFonts.cormorantGaramondTextTheme(base);
    final sans = GoogleFonts.interTextTheme(base);

    return TextTheme(
      // Display & headlines — literary serif
      displayLarge: serif.displayLarge?.copyWith(color: SyaahiColors.textPrimary, fontWeight: FontWeight.w600),
      displayMedium: serif.displayMedium?.copyWith(color: SyaahiColors.textPrimary, fontWeight: FontWeight.w600),
      displaySmall: serif.displaySmall?.copyWith(color: SyaahiColors.textPrimary, fontWeight: FontWeight.w600),
      headlineLarge: serif.headlineLarge?.copyWith(color: SyaahiColors.textPrimary),
      headlineMedium: serif.headlineMedium?.copyWith(color: SyaahiColors.textPrimary),
      headlineSmall: serif.headlineSmall?.copyWith(color: SyaahiColors.textPrimary),
      titleLarge: serif.titleLarge?.copyWith(color: SyaahiColors.textPrimary, fontWeight: FontWeight.w600),

      // UI text — clean sans-serif
      titleMedium: sans.titleMedium?.copyWith(color: SyaahiColors.textPrimary),
      titleSmall: sans.titleSmall?.copyWith(color: SyaahiColors.textSecondary),
      bodyLarge: sans.bodyLarge?.copyWith(color: SyaahiColors.textPrimary),
      bodyMedium: sans.bodyMedium?.copyWith(color: SyaahiColors.textSecondary),
      bodySmall: sans.bodySmall?.copyWith(color: SyaahiColors.textMuted),
      labelLarge: sans.labelLarge?.copyWith(color: SyaahiColors.textPrimary, fontWeight: FontWeight.w500),
      labelMedium: sans.labelMedium?.copyWith(color: SyaahiColors.textSecondary),
      labelSmall: sans.labelSmall?.copyWith(color: SyaahiColors.textMuted),
    );
  }
}