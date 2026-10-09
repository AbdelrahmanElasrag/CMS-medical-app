import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';
import 'concierge_theme.dart';

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
      onPrimaryContainer: AppColors.forest,
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.forest,
      tertiary: tertiary,
      onTertiary: AppColors.forest,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.goldInk,
      surface: AppColors.card,
      onSurface: AppColors.forest,
      onSurfaceVariant: AppColors.inkMuted,
      surfaceContainerHighest: AppColors.ivoryDeep,
      error: AppColors.danger,
      onError: Colors.white,
      outline: AppColors.navMuted,
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
      pageTransitionsTheme: _ivoryPageTransitions,
      scaffoldBackgroundColor: AppColors.ivory,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.ivory,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
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
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
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
        fillColor: AppColors.card,
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
    const primary = Color(0xFFA5B4FC);
    const onPrimary = Color(0xFF15123A);
    final colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: Color(0xFF2A2758),
      onPrimaryContainer: Color(0xFFE4E7FF),
      secondary: Color(0xFFB7C0D6),
      onSecondary: Color(0xFF12182B),
      secondaryContainer: Color(0xFF242B44),
      onSecondaryContainer: Color(0xFFE4E7FF),
      tertiary: Color(0xFFC4B5FD),
      onTertiary: Color(0xFF1C1438),
      tertiaryContainer: Color(0xFF31285A),
      onTertiaryContainer: Color(0xFFEDE9FE),
      surface: Color(0xFF161C30),
      onSurface: Color(0xFFF4F6FC),
      onSurfaceVariant: Color(0xFFB7C0D6),
      surfaceContainerHighest: Color(0xFF242B44),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      outline: Color(0xFF8E98B2),
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
      pageTransitionsTheme: _ivoryPageTransitions,
      scaffoldBackgroundColor: const Color(0xFF0B1020),
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

  /// Member-app theme matching the editorial home.
  static ThemeData editorial() {
    const primary = EditorialPalette.ivory;
    const onPrimary = EditorialPalette.ivoryInk;
    const line = Color(0xFF2E2E30);
    const colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: EditorialPalette.cardInner,
      onPrimaryContainer: EditorialPalette.headline,
      secondary: EditorialPalette.muted,
      onSecondary: EditorialPalette.canvas,
      secondaryContainer: EditorialPalette.card,
      onSecondaryContainer: EditorialPalette.headline,
      tertiary: EditorialPalette.ivory,
      onTertiary: onPrimary,
      tertiaryContainer: EditorialPalette.portrait,
      onTertiaryContainer: EditorialPalette.headline,
      surface: EditorialPalette.card,
      onSurface: EditorialPalette.headline,
      onSurfaceVariant: EditorialPalette.muted,
      surfaceContainerHighest: EditorialPalette.cardInner,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      outline: EditorialPalette.navMuted,
    );

    final baseText = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final textTheme = baseText.apply(
      bodyColor: EditorialPalette.headline,
      displayColor: EditorialPalette.headline,
    ).copyWith(
      headlineLarge: GoogleFonts.cormorantGaramond(
        fontSize: 40,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.6,
        color: EditorialPalette.headline,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.4,
        color: EditorialPalette.headline,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: EditorialPalette.headline,
      ),
    );

    final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(999));
    final buttonText = GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: onPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: EditorialPalette.canvas,
      canvasColor: EditorialPalette.canvas,
      dividerColor: line,
      pageTransitionsTheme: _ivoryPageTransitions,
      textTheme: textTheme,
      iconTheme: const IconThemeData(color: EditorialPalette.headline),
      primaryIconTheme: const IconThemeData(color: onPrimary),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: EditorialPalette.canvas,
        foregroundColor: EditorialPalette.headline,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: EditorialPalette.headline),
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: EditorialPalette.headline,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: EditorialPalette.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: EditorialPalette.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: GoogleFonts.inter(fontSize: 14, height: 1.4, color: EditorialPalette.muted),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: EditorialPalette.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1),
      listTileTheme: const ListTileThemeData(
        iconColor: EditorialPalette.headline,
        textColor: EditorialPalette.headline,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: EditorialPalette.cardInner,
        contentTextStyle: GoogleFonts.inter(color: EditorialPalette.headline),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
          shape: pill,
          textStyle: buttonText,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
          shape: pill,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: EditorialPalette.headline,
          side: const BorderSide(color: Color(0x66F7F4EF)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
          shape: pill,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: EditorialPalette.headline,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EditorialPalette.card,
        hintStyle: GoogleFonts.inter(color: EditorialPalette.navMuted),
        labelStyle: GoogleFonts.inter(color: EditorialPalette.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return onPrimary;
          return EditorialPalette.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return EditorialPalette.cardInner;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(onPrimary),
        side: const BorderSide(color: EditorialPalette.muted),
      ),
    );
  }
}

const _ivoryPageTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: _IvoryFadeSlide(),
    TargetPlatform.iOS: _IvoryFadeSlide(),
    TargetPlatform.macOS: _IvoryFadeSlide(),
    TargetPlatform.windows: _IvoryFadeSlide(),
    TargetPlatform.linux: _IvoryFadeSlide(),
    TargetPlatform.fuchsia: _IvoryFadeSlide(),
  },
);

class _IvoryFadeSlide extends PageTransitionsBuilder {
  const _IvoryFadeSlide();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.06, 0.02), end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  }
}
