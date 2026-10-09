import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cms/theme/app_tokens.dart';
import 'package:cms/theme/concierge_theme.dart';
import 'package:cms/ui/mobadra_motion.dart';

/// Ivory Concierge chrome: CMS wordmark, notices, and profile.
class ConciergeHeader extends StatelessWidget {
  const ConciergeHeader({
    super.key,
    required this.onOpenProfile,
    this.profileImageUrl,
    this.onPhoto = false,
  });

  final VoidCallback onOpenProfile;
  final String? profileImageUrl;

  /// White wordmark and icons, for the editorial photograph.
  final bool onPhoto;

  void _showNotices(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ConciergePalette.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, 12, AppSpacing.page, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: ConciergePalette.line(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),
              Icon(Icons.notifications_none_rounded, color: ConciergePalette.ink(context), size: 28),
              const SizedBox(height: 12),
              Text('You are all caught up', style: ConciergeType.title(ConciergePalette.ink(context))),
              const SizedBox(height: 6),
              Text(
                'Visit reminders and member notices will appear here.',
                textAlign: TextAlign.center,
                style: ConciergeType.caption(ConciergePalette.muted(context)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ink = onPhoto ? Colors.white : ConciergePalette.ink(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: onPhoto || ConciergePalette.dark(context) ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.page, 6, 12, 2),
            child: Row(
              children: [
                Text('CMS', style: ConciergeType.wordmark(ink)).mobadraFadeSlide(),
                const Spacer(),
                IconButton(
                  tooltip: 'Notices',
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(foregroundColor: ink),
                  onPressed: () => _showNotices(context),
                  icon: Icon(Icons.notifications_none_rounded, color: ink, size: 22),
                ).mobadraFadeSlide(delayMs: 60),
                const SizedBox(width: 2),
                Semantics(
                  button: true,
                  label: 'Open profile',
                  child: InkWell(
                    onTap: onOpenProfile,
                    customBorder: const CircleBorder(),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: onPhoto
                            ? Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.2)
                            : null,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(onPhoto ? 1.5 : 0),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: onPhoto ? EditorialPalette.portrait : AppColors.ivoryDeep,
                          backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
                          child: profileImageUrl == null
                              ? Icon(
                                  Icons.person_outline_rounded,
                                  size: 18,
                                  color: onPhoto ? Colors.white : ink.withValues(alpha: 0.8),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ).mobadraPop(delayMs: 90),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
