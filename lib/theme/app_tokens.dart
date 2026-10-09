import 'package:flutter/material.dart';

/// Lumen tokens for Creative Mobadra.
///
/// Navy carries text. Indigo is the interactive brand color.
/// Violet is reserved for points, rewards, and fine highlights.
abstract final class AppColors {
  static const Color ivory = Color(0xFFF3F5FC);
  static const Color ivoryDeep = Color(0xFFE4E9F6);
  static const Color card = Color(0xFFFFFFFF);
  static const Color forest = Color(0xFF14182B);
  static const Color forestSoft = Color(0xFF3A4462);
  static const Color inkMuted = Color(0xFF5C6786);
  static const Color navMuted = Color(0xFF7A849E);
  static const Color line = Color(0xFFD7DEEE);

  static const Color emerald = Color(0xFF4F46E5);
  static const Color emeraldDeep = Color(0xFF3730A3);
  static const Color emeraldWash = Color(0xFFEEF0FF);

  static const Color violet = Color(0xFF7C5CFF);
  static const Color cyan = Color(0xFF22D3EE);

  static const Color gold = Color(0xFF7C5CFF);
  static const Color goldInk = Color(0xFF5B45D6);
  static const Color goldWash = Color(0xFFF1EEFF);

  /// Primary action fill. Indigo, paired with [violet] in gradients.
  static const Color bronze = Color(0xFF4F46E5);

  static const Color danger = Color(0xFFD14343);

  /// Interactive brand color. Deep emerald, readable as text on ivory and as a fill with white type.
  static const Color primary = emerald;
  static const Color secondary = Color(0xFF3E6B60);
  static const Color tertiary = gold;
  static const Color chatAssistantText = forest;
  static const Color neutralSurface = ivory;
  static const Color primaryContainer = emeraldWash;
  static const Color secondaryContainer = Color(0xFFDCE8E3);
  static const Color tertiaryContainer = goldWash;
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
  static const double page = 20;
  static const double lg = 24;
  static const double xl = 32;
}
