import 'package:flutter/material.dart';

/// White elevated card for sign-in / sign-up (reference UI).
class MobadraAuthSheet extends StatelessWidget {
  const MobadraAuthSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 32, 24, 28),
    this.maxWidth = 440,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surfaceContainerHigh
        : Colors.white;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          color: surface,
          elevation: 14,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
