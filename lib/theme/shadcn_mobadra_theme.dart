import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'app_tokens.dart';

/// Shadcn UI theme aligned with Creative Mobadra tokens (used by ShadApp + Shad widgets).
abstract final class MobadraShadThemes {
  static ShadThemeData light() {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadColorScheme(
        background: AppColors.neutralSurface,
        foreground: Color(0xFF0F172A),
        card: Colors.white,
        cardForeground: Color(0xFF0F172A),
        popover: Colors.white,
        popoverForeground: Color(0xFF0F172A),
        primary: AppColors.primary,
        primaryForeground: Colors.white,
        secondary: AppColors.secondary,
        secondaryForeground: Colors.white,
        muted: Color(0xFFF1F5F9),
        mutedForeground: Color(0xFF64748B),
        accent: AppColors.secondaryContainer,
        accentForeground: Color(0xFF0F172A),
        destructive: Color(0xFFDC2626),
        destructiveForeground: Colors.white,
        border: Color(0xFFE2E8F0),
        input: Color(0xFFE2E8F0),
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
        background: Color(0xFF0F1419),
        foreground: Color(0xFFE2E2E6),
        card: Color(0xFF1A1F26),
        cardForeground: Color(0xFFE2E2E6),
        popover: Color(0xFF1A1F26),
        popoverForeground: Color(0xFFE2E2E6),
        primary: Color(0xFF9ECAFF),
        primaryForeground: Color(0xFF003258),
        secondary: Color(0xFF4FD8E8),
        secondaryForeground: Color(0xFF002022),
        muted: Color(0xFF272E38),
        mutedForeground: Color(0xFF94A3B8),
        accent: Color(0xFF37445A),
        accentForeground: Color(0xFFE2E2E6),
        destructive: Color(0xFFFFB4AB),
        destructiveForeground: Color(0xFF690005),
        border: Color(0xFF334155),
        input: Color(0xFF334155),
        ring: Color(0xFF9ECAFF),
        selection: Color(0xFF004882),
      ),
      radius: BorderRadius.circular(AppRadii.md),
      textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.inter),
    );
  }
}
