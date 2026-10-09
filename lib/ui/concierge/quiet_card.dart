import 'package:flutter/material.dart';

import 'package:cms/theme/app_tokens.dart';
import 'package:cms/theme/concierge_theme.dart';

enum QuietAccent { none, gold }

/// A calm surface: thin border, soft shadow, optional champagne rule.
class QuietCard extends StatefulWidget {
  const QuietCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.accent = QuietAccent.none,
    this.radius = AppRadii.lg,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final QuietAccent accent;
  final double radius;

  @override
  State<QuietCard> createState() => _QuietCardState();
}

class _QuietCardState extends State<QuietCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final shape = BorderRadius.circular(widget.radius);
    return AnimatedScale(
      scale: _pressed && !reduce ? 0.97 : 1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: shape,
          boxShadow: ConciergePalette.quiet(context),
        ),
        child: Material(
          color: ConciergePalette.glass(context),
          borderRadius: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: widget.onTap == null ? null : (down) => setState(() => _pressed = down),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: shape,
                border: Border.all(color: ConciergePalette.line(context)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.accent == QuietAccent.gold) Container(height: 2, color: ConciergePalette.gold(context)),
                  Padding(padding: widget.padding, child: widget.child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
