import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

/// Unified light/dark themes for Creative Mobadra.
abstract final class AppTheme {
  static ThemeData light() {
    const primary = AppColors.primary;
    const secondary = AppColors.secondary;
    const tertiary = AppColors.tertiary;

    final colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: Color(0xFF001D36),
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: Color(0xFF002022),
      tertiary: tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: Color(0xFF221A00),
      surface: Colors.white,
      onSurface: Color(0xFF1A1C1E),
      surfaceContainerHighest: AppColors.neutralSurface,
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      outline: Color(0xFF73777F),
    );

    final baseText = GoogleFonts.interTextTheme();
    final textTheme = baseText.copyWith(
      displayLarge: GoogleFonts.manropeTextTheme(baseText).displayLarge,
      displayMedium: GoogleFonts.manropeTextTheme(baseText).displayMedium,
      displaySmall: GoogleFonts.manropeTextTheme(baseText).displaySmall,
      headlineLarge: GoogleFonts.manropeTextTheme(baseText).headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
      headlineMedium: GoogleFonts.manropeTextTheme(baseText).headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
      headlineSmall: GoogleFonts.manropeTextTheme(baseText).headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
      titleLarge: GoogleFonts.manropeTextTheme(baseText).titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.neutralSurface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.neutralSurface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
    );
  }

  static ThemeData dark() {
    const primary = Color(0xFF9ECAFF);
    const onPrimary = Color(0xFF003258);
    final colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: Color(0xFF004882),
      onPrimaryContainer: Color(0xFFD1E4FF),
      secondary: Color(0xFF4FD8E8),
      onSecondary: Color(0xFF00363A),
      tertiary: Color(0xFFE2C46D),
      onTertiary: Color(0xFF3B2F08),
      surface: Color(0xFF1A1C1E),
      onSurface: Color(0xFFE2E2E6),
      surfaceContainerHighest: Color(0xFF333537),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      outline: Color(0xFF8C9199),
    );

    final baseText = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final textTheme = baseText.copyWith(
      headlineLarge: GoogleFonts.manropeTextTheme(baseText).headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
      headlineMedium: GoogleFonts.manropeTextTheme(baseText).headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
      ),
    );
  }
}
