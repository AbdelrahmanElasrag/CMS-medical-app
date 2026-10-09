import 'package:flutter/material.dart';

import 'package:cms/theme/app_tokens.dart';
import 'package:cms/theme/concierge_theme.dart';
import 'package:cms/ui/concierge/concierge_button.dart';
import 'package:cms/ui/concierge/next_visit_strip.dart';
import 'package:cms/ui/concierge/quiet_card.dart';

class BookVisitPanel extends StatelessWidget {
  const BookVisitPanel({
    super.key,
    required this.signedIn,
    required this.onBook,
    required this.onOpenVisits,
  });

  final bool signedIn;
  final VoidCallback onBook;
  final VoidCallback onOpenVisits;

  @override
  Widget build(BuildContext context) {
    final ink = ConciergePalette.ink(context);
    final muted = ConciergePalette.muted(context);
    return QuietCard(
      accent: QuietAccent.gold,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Book a visit', style: ConciergeType.display(ink)),
          const SizedBox(height: 6),
          Text('Your care, thoughtfully arranged.', style: ConciergeType.body(muted)),
          if (signedIn) ...[
            const SizedBox(height: 14),
            NextVisitStrip(onOpenVisits: onOpenVisits),
          ],
          const SizedBox(height: AppSpacing.md),
          ConciergeButton(
            label: 'Book a visit',
            icon: Icons.calendar_month_outlined,
            onPressed: onBook,
          ),
        ],
      ),
    );
  }
}
