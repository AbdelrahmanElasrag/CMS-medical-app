import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'app_tokens.dart';
import 'concierge_theme.dart';

/// Shadcn UI theme aligned with Creative Mobadra tokens (used by ShadApp + Shad widgets).
abstract final class MobadraShadThemes {
  static ShadThemeData light() {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadColorScheme(
        background: AppColors.ivory,
        foreground: AppColors.forest,
        card: AppColors.card,
        cardForeground: AppColors.forest,
        popover: AppColors.card,
        popoverForeground: AppColors.forest,
        primary: AppColors.primary,
        primaryForeground: Colors.white,
        secondary: AppColors.secondary,
        secondaryForeground: Colors.white,
        muted: AppColors.ivoryDeep,
        mutedForeground: AppColors.inkMuted,
        accent: AppColors.emeraldWash,
        accentForeground: AppColors.forest,
        destructive: AppColors.danger,
        destructiveForeground: Colors.white,
        border: AppColors.line,
        input: AppColors.line,
        ring: AppColors.primary,
        selection: AppColors.primaryContainer,
      ),
      radius: BorderRadius.circular(AppRadii.md),
      textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.inter),
    );
  }

  static ShadThemeData dark() {
    return ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: const ShadColorScheme(
        background: Color(0xFF0B1020),
        foreground: Color(0xFFF4F6FC),
        card: Color(0xFF161C30),
        cardForeground: Color(0xFFF4F6FC),
        popover: Color(0xFF161C30),
        popoverForeground: Color(0xFFF4F6FC),
        primary: Color(0xFFA5B4FC),
        primaryForeground: Color(0xFF15123A),
        secondary: Color(0xFFC4B5FD),
        secondaryForeground: Color(0xFF1C1438),
        muted: Color(0xFF242B44),
        mutedForeground: Color(0xFFB7C0D6),
        accent: Color(0xFF222848),
        accentForeground: Color(0xFFF4F6FC),
        destructive: Color(0xFFFFB4AB),
        destructiveForeground: Color(0xFF690005),
        border: Color(0xFF2C3550),
        input: Color(0xFF2C3550),
        ring: Color(0xFFA5B4FC),
        selection: Color(0xFF2A2758),
      ),
      radius: BorderRadius.circular(AppRadii.md),
      textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.inter),
    );
  }

  /// Dialogs and shad controls for the editorial member app.
  static ShadThemeData editorial() {
    return ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: const ShadColorScheme(
        background: EditorialPalette.canvas,
        foreground: EditorialPalette.headline,
        card: EditorialPalette.card,
        cardForeground: EditorialPalette.headline,
        popover: EditorialPalette.card,
        popoverForeground: EditorialPalette.headline,
        primary: EditorialPalette.ivory,
        primaryForeground: EditorialPalette.ivoryInk,
        secondary: EditorialPalette.cardInner,
        secondaryForeground: EditorialPalette.headline,
        muted: EditorialPalette.cardInner,
        mutedForeground: EditorialPalette.muted,
        accent: EditorialPalette.cardInner,
        accentForeground: EditorialPalette.headline,
        destructive: Color(0xFFFFB4AB),
        destructiveForeground: Color(0xFF690005),
        border: Color(0xFF2E2E30),
        input: Color(0xFF2E2E30),
        ring: EditorialPalette.ivory,
        selection: EditorialPalette.portrait,
      ),
      radius: BorderRadius.circular(22),
      textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.inter),
    );
  }
}
