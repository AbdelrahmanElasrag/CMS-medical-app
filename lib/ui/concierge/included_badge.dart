import 'package:flutter/material.dart';

import 'package:cms/theme/concierge_theme.dart';

/// Status chip that pairs a check icon with a word, so meaning is not color-only.
class IncludedBadge extends StatelessWidget {
  const IncludedBadge({super.key, this.label = 'Included'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = ConciergePalette.emerald(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ConciergePalette.emeraldWash(context),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, size: 13, color: color),
            const SizedBox(width: 3),
            Text(label, style: ConciergeType.label(color).copyWith(letterSpacing: 0.2)),
          ],
        ),
      ),
    );
  }
}
