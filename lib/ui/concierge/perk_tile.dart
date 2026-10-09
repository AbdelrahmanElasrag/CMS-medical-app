import 'package:flutter/material.dart';

import 'package:cms/content/mobadra_perks.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/theme/concierge_theme.dart';
import 'package:cms/ui/concierge/included_badge.dart';

class PerkTile extends StatelessWidget {
  const PerkTile({
    super.key,
    required this.perk,
    required this.onTap,
  });

  final MobadraPerk perk;
  final VoidCallback onTap;

  static IconData iconFor(String title) {
    switch (title) {
      case 'Transportation':
        return Icons.directions_car_outlined;
      case 'On-site coordinators':
        return Icons.support_agent_outlined;
      case 'Fast check-in':
        return Icons.qr_code_2_outlined;
      case 'Follow-up appointments':
        return Icons.event_available_outlined;
      case 'Patient support':
        return Icons.forum_outlined;
      case 'Post-treatment visits':
        return Icons.favorite_border_rounded;
      default:
        return Icons.spa_outlined;
    }
  }

  static String summaryFor(MobadraPerk perk) {
    switch (perk.title) {
      case 'Transportation':
        return 'Door-to-hospital travel, arranged for you.';
      case 'On-site coordinators':
        return 'A person beside you at every visit.';
      case 'Fast check-in':
        return 'A calmer arrival, with less waiting.';
      case 'Follow-up appointments':
        return 'Next steps scheduled with care.';
      case 'Patient support':
        return 'Clear answers when you need them.';
      case 'Post-treatment visits':
        return 'Recovery visits, quietly coordinated.';
      default:
        return perk.subtitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ink = ConciergePalette.ink(context);
    final muted = ConciergePalette.muted(context);
    final emerald = ConciergePalette.emerald(context);
    return Material(
      color: ConciergePalette.surface(context),
      borderRadius: BorderRadius.circular(AppRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: ConciergePalette.line(context)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ConciergePalette.emeraldWash(context),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(iconFor(perk.title), size: 18, color: emerald),
                ),
                const SizedBox(height: 12),
                Text(
                  perk.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ConciergeType.title(ink).copyWith(fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  summaryFor(perk),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: ConciergeType.caption(muted),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const IncludedBadge(),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, size: 18, color: muted),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
