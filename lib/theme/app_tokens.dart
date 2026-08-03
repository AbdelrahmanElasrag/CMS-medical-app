import 'package:flutter/material.dart';

/// Creative Mobadra design tokens (medical kit).
abstract final class AppColors {
  static const Color primary = Color(0xFF005EB8);
  /// Questionnaire prompts (distinct from [primary] used on tappable choice chips).
  static const Color chatAssistantText = Color(0xFF1E2D36);
  static const Color secondary = Color(0xFF00A3AD);
  static const Color tertiary = Color(0xFFC5A059);
  static const Color neutralSurface = Color(0xFFF8F9FA);
  static const Color primaryContainer = Color(0xFFE3EEF6);
  static const Color secondaryContainer = Color(0xFFD6F0F2);
  static const Color tertiaryContainer = Color(0xFFF5ECD8);
}

abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}
