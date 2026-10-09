import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cms/content/mobadra_perks.dart';
import 'package:cms/screens/health_assistant_screen.dart';
import 'package:cms/screens/offers_screen.dart';
import 'package:cms/screens/service_screen.dart';
import 'package:cms/screens/wellness_screen.dart';
import 'package:cms/services/auth_service.dart';
import 'package:cms/services/wellness_service.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/theme/concierge_theme.dart';
import 'package:cms/ui/booking_auth_prompt.dart';
import 'package:cms/ui/concierge/concierge.dart';
import 'package:cms/ui/mobadra_ui.dart';

/// Concierge tab: personal assistance, rewards, and included care.
class ConciergeScreen extends StatelessWidget {
  const ConciergeScreen({
    super.key,
    required this.username,
    required this.points,
    required this.onOpenProfile,
  });

  final String username;
  final int points;
  final VoidCallback onOpenProfile;

  void _requireSignIn(BuildContext context, VoidCallback action) {
    final auth = Provider.of<AuthService>(context, listen: false);
    if (!auth.isLoggedIn) {
      showBookingAuthPrompt(context);
      return;
    }
    action();
  }

  void _showPerkDetails(BuildContext context, MobadraPerk perk) {
    final ink = ConciergePalette.ink(context);
    final muted = ConciergePalette.muted(context);
    showDialog(
      context: context,
      builder: (dialogContext) => ShadDialog(
        title: Text(perk.title, style: ConciergeType.title(ink)),
        description: Text(PerkTile.summaryFor(perk), style: ConciergeType.caption(muted)),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          ShadButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (!context.mounted) return;
              _requireSignIn(context, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceScreen(
                      service: 'Quick Booking',
                      username: username,
                    ),
                  ),
                );
              });
            },
            child: const Text('Book a visit'),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IncludedBadge(),
            const SizedBox(height: 14),
            Text(perk.description, style: ConciergeType.body(ink)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ink = ConciergePalette.ink(context);
    final muted = ConciergePalette.muted(context);
    final signedIn = context.watch<AuthService>().isLoggedIn;
    final reduce = MediaQuery.disableAnimationsOf(context);
    Widget enter(Widget child, int index) => reduce ? child : child.mobadraCardIn(delayMs: 50 * index);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, 18, AppSpacing.page, AppSpacing.xl),
          children: [
            enter(Text('Concierge', style: ConciergeType.greetingName(ink).copyWith(fontSize: 34)), 0),
            const SizedBox(height: 6),
            enter(Text('Personal assistant, anytime.', style: ConciergeType.caption(muted)), 1),
            const SizedBox(height: 22),
            enter(
              HomeLinkCard(
              icon: Icons.health_and_safety_outlined,
              title: 'Health assistant',
              subtitle: signedIn ? 'Symptom check and common questions' : 'Sign in to use',
              tone: HomeLinkTone.editorial,
              onTap: () => _requireSignIn(
                context,
                () => Navigator.push(
                  context,
                  HealthAssistantScreen.createRoute(bookingUsername: username),
                ),
              ),
            ),
              2,
            ),
            const SizedBox(height: 22),
            enter(Text('Your rewards', style: ConciergeType.title(ink).copyWith(fontSize: 16)), 3),
            const SizedBox(height: 10),
            enter(RewardsCard(points: points, onOpenQr: onOpenProfile), 4),
            const SizedBox(height: 22),
            enter(Text('Included with your membership', style: ConciergeType.title(ink).copyWith(fontSize: 16)), 5),
            const SizedBox(height: 10),
            for (var i = 0; i < kMobadraPerks.length; i++) ...[
              enter(
                HomeLinkCard(
                  icon: PerkTile.iconFor(kMobadraPerks[i].title),
                  title: kMobadraPerks[i].title,
                  subtitle: PerkTile.summaryFor(kMobadraPerks[i]),
                  tone: HomeLinkTone.editorial,
                  onTap: () => _showPerkDetails(context, kMobadraPerks[i]),
                ),
                6 + i,
              ),
              if (i != kMobadraPerks.length - 1) const SizedBox(height: 10),
            ],
            const SizedBox(height: 22),
            enter(Text('Partner offers', style: ConciergeType.title(ink).copyWith(fontSize: 16)), 12),
            const SizedBox(height: 10),
            enter(
              HomeLinkCard(
                icon: Icons.local_offer_outlined,
                title: 'Partner benefits',
                subtitle: signedIn ? 'Discounts and hospital privileges.' : 'Reserved for members.',
                tone: HomeLinkTone.editorial,
                onTap: () => _requireSignIn(
                  context,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const OffersScreen()),
                  ),
                ),
              ),
              13,
            ),
            const SizedBox(height: 22),
            enter(Text('Between visits', style: ConciergeType.title(ink).copyWith(fontSize: 16)), 14),
            const SizedBox(height: 10),
            enter(const _BetweenVisitsCard(), 15),
          ],
        ),
      ),
    );
  }
}

class _BetweenVisitsCard extends StatefulWidget {
  const _BetweenVisitsCard();

  @override
  State<_BetweenVisitsCard> createState() => _BetweenVisitsCardState();
}

class _BetweenVisitsCardState extends State<_BetweenVisitsCard> {
  int _water = 0;
  int _waterGoal = 8;
  int _workout = 0;
  int _workoutGoal = 30;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final w = await WellnessService.instance.todayWaterGlasses();
      final wg = await WellnessService.instance.getWaterGoal();
      final wo = await WellnessService.instance.todayWorkoutMinutes();
      final wog = await WellnessService.instance.getWorkoutGoal();
      if (!mounted) return;
      setState(() {
        _water = w;
        _waterGoal = wg;
        _workout = wo;
        _workoutGoal = wog;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _openWellness() {
    final auth = Provider.of<AuthService>(context, listen: false);
    if (!auth.isLoggedIn) {
      showBookingAuthPrompt(context);
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => const WellnessScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = context.watch<AuthService>().isLoggedIn;
    return QuietCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          _CareRow(
            icon: Icons.water_drop_outlined,
            title: 'Hydration',
            detail: !signedIn
                ? 'Sign in to track'
                : _loading
                    ? null
                    : '$_water of $_waterGoal glasses',
            onTap: _openWellness,
          ),
          Divider(height: 1, color: ConciergePalette.line(context)),
          _CareRow(
            icon: Icons.directions_walk_outlined,
            title: 'Activity',
            detail: !signedIn
                ? 'Sign in to track'
                : _loading
                    ? null
                    : '$_workout of $_workoutGoal min',
            onTap: _openWellness,
          ),
        ],
      ),
    );
  }
}

class _CareRow extends StatelessWidget {
  const _CareRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = ConciergePalette.ink(context);
    final muted = ConciergePalette.muted(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: ink.withValues(alpha: 0.86)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ConciergeType.title(ink).copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  if (detail == null)
                    const SkeletonBox(height: 12, width: 96, radius: 4)
                  else
                    Text(detail!, style: ConciergeType.caption(muted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: muted),
          ],
        ),
      ),
    );
  }
}
