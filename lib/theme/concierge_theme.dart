import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Context-aware Lumen colors and type.
abstract final class ConciergePalette {
  static bool dark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color canvas(BuildContext context) => EditorialPalette.canvas;

  static Color surface(BuildContext context) => EditorialPalette.card;

  /// Flat card fill used by quiet surfaces.
  static Color glass(BuildContext context) => EditorialPalette.card;

  static Color ink(BuildContext context) => EditorialPalette.headline;

  static Color muted(BuildContext context) => EditorialPalette.muted;

  static Color line(BuildContext context) => const Color(0xFF2E2E30);

  static Color emerald(BuildContext context) => EditorialPalette.headline;

  static Color emeraldWash(BuildContext context) => EditorialPalette.cardInner;

  static Color gold(BuildContext context) => EditorialPalette.ivory;

  static Color goldInk(BuildContext context) => EditorialPalette.ivory;

  static Color navMuted(BuildContext context) => EditorialPalette.navMuted;

  static List<BoxShadow> quiet(BuildContext context) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}

abstract final class ConciergeType {
  static TextStyle wordmark(Color color) => GoogleFonts.cormorantGaramond(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1,
        color: color,
      );

  static TextStyle greeting(Color color) => GoogleFonts.cormorantGaramond(
        fontSize: 30,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
        height: 1.05,
        color: color,
      );

  static TextStyle greetingName(Color color) => GoogleFonts.cormorantGaramond(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        height: 1.02,
        color: color,
      );

  static TextStyle display(Color color) => GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.45,
        height: 1.15,
        color: color,
      );

  static TextStyle section(Color color) => GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.2,
        color: color,
      );

  static TextStyle title(Color color) => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.25,
        color: color,
      );

  static TextStyle points(Color color) => GoogleFonts.manrope(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        height: 1,
        color: color,
      );

  static TextStyle body(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color,
      );

  static TextStyle caption(Color color) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  static TextStyle label(Color color) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        height: 1.2,
        color: color,
      );

  static TextStyle button(Color color) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: color,
      );
}

/// Near-black editorial home from the luxury reference.
abstract final class EditorialPalette {
  static const Color canvas = Color(0xFF0C0C0C);
  static const Color card = Color(0xFF1C1C1E);
  static const Color cardInner = Color(0xFF2A2A2C);
  static const Color ivory = Color(0xFFF4EFE7);
  static const Color ivoryInk = Color(0xFF1A1A1A);
  static const Color headline = Color(0xFFF7F4EF);
  static const Color muted = Color(0xFFA3A3A3);
  static const Color navMuted = Color(0xFF8E8E93);
  static const Color portrait = Color(0xFF3F3832);
}

abstract final class EditorialType {
  static TextStyle headline() => GoogleFonts.cormorantGaramond(
        fontSize: 38,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.7,
        height: 1.02,
        color: EditorialPalette.headline,
      );

  static TextStyle subhead() => GoogleFonts.inter(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: const Color(0xD9F7F4EF),
      );

  static TextStyle section() => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.2,
        color: EditorialPalette.headline,
      );

  static TextStyle cardTitle() => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.25,
        color: EditorialPalette.headline,
      );

  static TextStyle cardMeta() => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: EditorialPalette.muted,
      );

  static TextStyle button() => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: EditorialPalette.ivoryInk,
      );

  static TextStyle monogram() => GoogleFonts.cormorantGaramond(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1,
        color: EditorialPalette.headline,
      );

  static TextStyle nav(Color color, {required bool selected}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        letterSpacing: 0,
        height: 1.1,
        color: color,
      );
}
