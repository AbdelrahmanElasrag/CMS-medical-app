import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Subtle screen and list motion (shadcn-adjacent, non-bouncy).
extension MobadraMotion on Widget {
  Widget mobadraFadeSlide({int delayMs = 0}) {
    return animate(delay: delayMs.ms)
        .fadeIn(duration: 280.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.04,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

Widget mobadraStagger(int index, Widget child) =>
    child.mobadraFadeSlide(delayMs: 32 * index);
