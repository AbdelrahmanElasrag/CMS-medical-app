import 'package:flutter/material.dart';

import 'package:cms/content/mobadra_perks.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/theme/concierge_theme.dart';
import 'package:cms/ui/concierge/quiet_card.dart';

class RewardsCard extends StatelessWidget {
  const RewardsCard({
    super.key,
    required this.points,
    required this.onOpenQr,
  });

  final int points;
  final VoidCallback onOpenQr;

  @override
  Widget build(BuildContext context) {
    final ink = ConciergePalette.ink(context);
    final muted = ConciergePalette.muted(context);
    final gold = ConciergePalette.goldInk(context);
    final progress = (points / kGiftPointsThreshold).clamp(0.0, 1.0);
    final ready = points >= kGiftPointsThreshold;

    return QuietCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: '$points of $kGiftPointsThreshold points',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$points', style: ConciergeType.points(gold)),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('points', style: ConciergeType.caption(muted)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ready
                ? 'Reward ready. Ask Mobadra about your gift.'
                : '$points of $kGiftPointsThreshold toward your next reward',
            style: ConciergeType.caption(ink),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: ConciergePalette.line(context),
              color: EditorialPalette.ivory,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onOpenQr,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.qr_code_2_rounded, size: 18, color: ConciergePalette.emerald(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Scan your QR code at partner visits to earn points.',
                      style: ConciergeType.caption(muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
