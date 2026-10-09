import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cms/theme/concierge_theme.dart';

enum ConciergeButtonTone { emerald, bronze }

/// Ivory capsule shared by booking and concierge actions.
class ConciergeButton extends StatefulWidget {
  const ConciergeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.tone = ConciergeButtonTone.emerald,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final ConciergeButtonTone tone;

  @override
  State<ConciergeButton> createState() => _ConciergeButtonState();
}

class _ConciergeButtonState extends State<ConciergeButton> {
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
              child: widget.expand
                  ? Row(
                      children: [
                        Icon(widget.icon ?? Icons.calendar_month_outlined, size: 18, color: EditorialPalette.ivoryInk),
                        Expanded(
                          child: Text(widget.label, textAlign: TextAlign.center, style: EditorialType.button()),
                        ),
                        const Icon(Icons.arrow_forward_rounded, size: 18, color: EditorialPalette.ivoryInk),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 18, color: EditorialPalette.ivoryInk),
                          const SizedBox(width: 8),
                        ],
                        Text(widget.label, style: EditorialType.button()),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConciergeTextAction extends StatelessWidget {
  const ConciergeTextAction({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: EditorialPalette.headline,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        minimumSize: const Size(44, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: EditorialType.cardMeta().copyWith(fontWeight: FontWeight.w600, color: EditorialPalette.headline)),
    );
  }
}
