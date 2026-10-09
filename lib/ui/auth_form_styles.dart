import 'package:flutter/material.dart';

import 'package:cms/theme/concierge_theme.dart';

/// Soft filled field matching reference auth cards (light grey pill).
InputDecoration authFilledDecoration({
  String? hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  const radius = 16.0;
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: EditorialPalette.navMuted, fontSize: 15),
    filled: true,
    fillColor: EditorialPalette.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: EditorialPalette.ivory, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
    ),
    prefixIcon: prefixIcon == null
        ? null
        : IconTheme(
            data: const IconThemeData(color: EditorialPalette.muted, size: 22),
            child: prefixIcon,
          ),
    suffixIcon: suffixIcon,
  );
}

/// Sign-up style: small caps label in primary blue above the field.
Widget authCapsLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
        color: EditorialPalette.headline,
      ),
    ),
  );
}

/// Sign-in style: sentence-case label, dark grey.
Widget authFieldLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: EditorialPalette.headline,
      ),
    ),
  );
}
