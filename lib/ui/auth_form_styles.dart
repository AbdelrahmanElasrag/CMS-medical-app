import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Soft filled field matching reference auth cards (light grey pill).
InputDecoration authFilledDecoration({
  String? hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  const fill = Color(0xFFF3F4F6);
  const radius = 12.0;
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
    filled: true,
    fillColor: fill,
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
      borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.55), width: 1.5),
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
            data: IconThemeData(color: Colors.grey.shade600, size: 22),
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
        color: AppColors.primary,
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
        color: Colors.grey.shade800,
      ),
    ),
  );
}
