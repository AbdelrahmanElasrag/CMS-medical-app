import 'package:flutter/material.dart';

import 'package:cms/theme/app_tokens.dart';
import 'package:cms/theme/concierge_theme.dart';
import 'package:cms/ui/concierge/quiet_card.dart';

enum HomeLinkTone { quiet, editorial }

/// Quiet row used on the Ivory Concierge home: icon, title, subtitle, chevron.
class HomeLinkCard extends StatelessWidget {
  const HomeLinkCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.tone = HomeLinkTone.quiet,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final HomeLinkTone tone;

  @override
  Widget build(BuildContext context) {
    if (tone == HomeLinkTone.editorial) return _editorial();
    final ink = ConciergePalette.ink(context);
    final muted = ConciergePalette.muted(context);
    return QuietCard(
      onTap: onTap,
      radius: AppRadii.xl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ConciergePalette.emeraldWash(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: ConciergePalette.emerald(context)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ConciergeType.title(ink).copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ConciergeType.caption(muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, size: 20, color: muted),
        ],
      ),
    );
  }

  Widget _editorial() {
    const radius = BorderRadius.all(Radius.circular(22));
    return Material(
      color: EditorialPalette.card,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 22, color: EditorialPalette.headline),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: EditorialType.cardTitle()),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: EditorialType.cardMeta(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, size: 22, color: EditorialPalette.navMuted),
            ],
          ),
        ),
      ),
    );
  }
}
