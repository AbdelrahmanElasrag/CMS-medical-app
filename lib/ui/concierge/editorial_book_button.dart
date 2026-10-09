import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cms/theme/concierge_theme.dart';

/// Ivory capsule used on the editorial home.
class EditorialBookButton extends StatefulWidget {
  const EditorialBookButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  State<EditorialBookButton> createState() => _EditorialBookButtonState();
}

class _EditorialBookButtonState extends State<EditorialBookButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final reduce = MediaQuery.disableAnimationsOf(context);
    const radius = BorderRadius.all(Radius.circular(999));
    return AnimatedScale(
      scale: _pressed && !reduce ? 0.98 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: enabled ? 0.28 : 0),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: enabled ? EditorialPalette.ivory : EditorialPalette.ivory.withValues(alpha: 0.55),
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled
                ? () {
                    HapticFeedback.lightImpact();
                    widget.onPressed!();
                  }
                : null,
            onHighlightChanged: (down) => setState(() => _pressed = down),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 20, color: EditorialPalette.ivoryInk),
                  Expanded(
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: EditorialType.button(),
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, size: 20, color: EditorialPalette.ivoryInk),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
