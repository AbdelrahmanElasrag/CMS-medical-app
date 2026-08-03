import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cms/content/mobadra_perks.dart';
import 'package:cms/services/auth_service.dart';
import 'package:cms/ui/booking_auth_prompt.dart';
import 'package:cms/screens/health_assistant_screen.dart';
import 'package:cms/screens/service_screen.dart';
import 'package:cms/screens/wellness_screen.dart';
import 'package:cms/services/wellness_service.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/ui/mobadra_ui.dart';
import 'package:cms/ui/mobadra_app_bar.dart';
import 'package:cms/widgets/partner_ads_carousel.dart';

/// Home tab content (used inside [MainShell]).
class MobadraHomeTab extends StatelessWidget {
  final String username;
  final int points;
  final String? profileImageUrl;
  final VoidCallback onOpenProfile;
  final VoidCallback onViewAllOffers;

  const MobadraHomeTab({
    super.key,
    required this.username,
    required this.points,
    this.profileImageUrl,
    required this.onOpenProfile,
    required this.onViewAllOffers,
  });

  void _showPerkDetails(BuildContext context, MobadraPerk perk) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: Text(perk.title, style: TextStyle(color: cs.primary)),
        description: Text(perk.subtitle, style: TextStyle(color: Colors.grey[600])),
        actions: [
          ShadButton(
            onPressed: () {
              final auth = Provider.of<AuthService>(context, listen: false);
              Navigator.pop(context);
              if (!auth.isLoggedIn) {
                showBookingAuthPrompt(context);
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceScreen(
                    service: 'Quick Booking',
                    username: username,
                  ),
                ),
              );
            },
            child: const Text('Book with Mobadra'),
          ),
        ],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: cs.surfaceContainerHighest,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Image.asset(
                    perk.imageUrl,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Free for members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(perk.description, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Creative Mobadra'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
        child: SingleChildScrollView(
          child: Text.rich(
            TextSpan(
              style: TextStyle(color: cs.onSurface, fontSize: 14, height: 1.4),
              children: [
                const TextSpan(
                  text: 'Creative Mobadra is a member program that connects you to partner hospitals in the UAE with '
                      'exclusive support and benefits—at no extra cost for included services.\n\n',
                ),
                TextSpan(text: 'Member benefits include:\n', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
                ...kMobadraPerks.expand((p) => [
                      TextSpan(text: '• ${p.title}\n', style: TextStyle(color: cs.tertiary, fontWeight: FontWeight.w500)),
                    ]),
                const TextSpan(text: '\nEarn points when your QR is scanned at visits; redeem gifts when you reach milestones.'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (points / kGiftPointsThreshold).clamp(0.0, 1.0);
    final sectionTitleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: MobadraAppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: onOpenProfile,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
              child: profileImageUrl == null
                  ? Icon(Icons.person, size: 20, color: AppColors.primary)
                  : null,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hello, $username', maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(
              'Your Creative Mobadra hub',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.smart_toy_outlined, color: Colors.white.withValues(alpha: 0.95)),
            tooltip: 'Symptom check & health FAQ',
            onPressed: () {
              Navigator.push(context, HealthAssistantScreen.createRoute(bookingUsername: username));
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: Colors.white.withValues(alpha: 0.95)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 20, AppSpacing.md, AppSpacing.lg + 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    // ── Partners & savings ──────────────────────────────────
                    Text(
                      'Partners & savings',
                      style: sectionTitleStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Featured discounts and hospital promos',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    PartnerAdsCarousel(
                      onViewAllOffers: onViewAllOffers,
                      onShowAbout: () => _showAbout(context),
                    ).mobadraFadeSlide(delayMs: 40),
                    const SizedBox(height: 28),

                    // ── Points & rewards ────────────────────────────────────
                    Text(
                      'Points & rewards',
                      style: sectionTitleStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Earn points at every partner visit',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.06),
                            AppColors.secondary.withValues(alpha: 0.08),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 5,
                                      backgroundColor: AppColors.secondary.withValues(alpha: 0.22),
                                      color: AppColors.primary,
                                      strokeCap: StrokeCap.round,
                                    ),
                                  ),
                                  Text(
                                    '$points',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your QR scans at partner visits add points automatically.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.25,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                    backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 1),
                                      child: Icon(
                                        points >= kGiftPointsThreshold
                                            ? Icons.celebration_rounded
                                            : Icons.redeem_rounded,
                                        size: 22,
                                        color: points >= kGiftPointsThreshold
                                            ? AppColors.tertiary
                                            : AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              style: TextStyle(
                                                fontSize: 13,
                                                height: 1.25,
                                                color: Colors.grey.shade800,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: '$points',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                const TextSpan(text: ' out of '),
                                                TextSpan(
                                                  text: '$kGiftPointsThreshold',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                const TextSpan(text: ' points'),
                                              ],
                                            ),
                                          ),
                                          if (points < kGiftPointsThreshold) ...[
                                            const SizedBox(height: 3),
                                            Text(
                                              'Keep showing your QR after visits to earn more.',
                                              style: TextStyle(
                                                fontSize: 11,
                                                height: 1.3,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ] else ...[
                                            const SizedBox(height: 3),
                                            Text(
                                              "You've reached the gift milestone — ask Mobadra about your reward.",
                                              style: TextStyle(
                                                fontSize: 11,
                                                height: 1.3,
                                                color: AppColors.secondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).mobadraFadeSlide(),
                    const SizedBox(height: 28),

                    // ── Free member perks ───────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Free member perks',
                                style: sectionTitleStyle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Swipe to explore what is included with your membership',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Fixed aspect ratio makes cells very tall on wide layouts (e.g. web):
                        // height = cellWidth / ratio, while card content height stays ~constant.
                        const crossAxisCount = 2;
                        const crossSpacing = 14.0;
                        const mainSpacing = 14.0;
                        const targetCardHeight = 226.0;
                        final w = constraints.maxWidth;
                        final cellWidth = w.isFinite && w > 0
                            ? (w - crossSpacing * (crossAxisCount - 1)) / crossAxisCount
                            : 160.0;
                        // Narrow columns (phones): content stacks tighter; shorter row drops excess bottom gap.
                        final rowHeight =
                            cellWidth < 190 ? 210.0 : targetCardHeight;
                        final aspectRatio = cellWidth / rowHeight;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 8),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: crossSpacing,
                            mainAxisSpacing: mainSpacing,
                            childAspectRatio: aspectRatio,
                          ),
                          itemCount: kMobadraPerks.length,
                          itemBuilder: (context, index) {
                            final perk = kMobadraPerks[index];
                            return mobadraStagger(
                              index,
                              _PerkHeroCard(
                                perk: perk,
                                onTap: () => _showPerkDetails(context, perk),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    // ── Wellness ────────────────────────────────────────────
                    Text(
                      'Wellness',
                      style: sectionTitleStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your daily hydration and activity',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    const _HomeWellnessSection(),
                    const SizedBox(height: 28),

                    // ── Health assistant ──────────────────────────────────
                    Text(
                      'Health assistant',
                      style: sectionTitleStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Symptom check with care guidance and common questions',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    _AiAssistantCard(username: username),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Wellness section (stateful — loads live data) ──────────────────────────

class _HomeWellnessSection extends StatefulWidget {
  const _HomeWellnessSection();

  @override
  State<_HomeWellnessSection> createState() => _HomeWellnessSectionState();
}

class _HomeWellnessSectionState extends State<_HomeWellnessSection> {
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
    final w = await WellnessService.instance.todayWaterGlasses();
    final wg = await WellnessService.instance.getWaterGoal();
    final wo = await WellnessService.instance.todayWorkoutMinutes();
    final wog = await WellnessService.instance.getWorkoutGoal();
    if (mounted) {
      setState(() {
        _water = w;
        _waterGoal = wg;
        _workout = wo;
        _workoutGoal = wog;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final isLoggedIn = auth.isLoggedIn;

    return Column(
      children: [
        _WellnessCircleCard(
          gifPath: 'assets/water.gif',
          label: 'Hydration',
          subtitle: 'Daily water intake',
          unit: 'glasses',
          value: _loading ? null : _water,
          goal: _waterGoal,
          isLoggedIn: isLoggedIn,
        ).mobadraFadeSlide(delayMs: 0),
        const SizedBox(height: 12),
        _WellnessCircleCard(
          gifPath: 'assets/running (1).gif',
          label: 'Activity',
          subtitle: 'Workout minutes today',
          unit: 'min',
          value: _loading ? null : _workout,
          goal: _workoutGoal,
          isLoggedIn: isLoggedIn,
        ).mobadraFadeSlide(delayMs: 60),
      ],
    );
  }
}

class _WellnessCircleCard extends StatelessWidget {
  final String gifPath;
  final String label;
  final String subtitle;
  final String unit;
  final int? value;
  final int goal;
  final bool isLoggedIn;

  const _WellnessCircleCard({
    required this.gifPath,
    required this.label,
    required this.subtitle,
    required this.unit,
    required this.value,
    required this.goal,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = isLoggedIn && value != null
        ? (value! / goal).clamp(0.0, 1.0)
        : 0.0;

    return ShadCard(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      radius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: () {
          if (!isLoggedIn) {
            showBookingAuthPrompt(context);
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WellnessScreen()),
          );
        },
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // GIF in circle with progress ring
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      backgroundColor: cs.primary.withValues(alpha: 0.12),
                      color: cs.primary,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surfaceContainerHighest,
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.10),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        gifPath,
                        width: 66,
                        height: 66,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Text + progress info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isLoggedIn) ...[
                      if (value == null)
                        SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                        )
                      else ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: cs.primary.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$value / $goal $unit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ] else ...[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.22),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_outline_rounded, size: 13, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                'Log in to track',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cs.outline),
            ],
          ),
        ),
      ),
    );
  }
}

// ── AI Health Assistant card ────────────────────────────────────────────────

class _AiAssistantCard extends StatelessWidget {
  const _AiAssistantCard({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = Provider.of<AuthService>(context);
    final isLoggedIn = auth.isLoggedIn;

    return ShadCard(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      radius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: () {
          if (!isLoggedIn) {
            showBookingAuthPrompt(context);
            return;
          }
          Navigator.push(context, HealthAssistantScreen.createRoute(bookingUsername: username));
        },
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/ai-assistant.gif',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health assistant',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Symptom check with triage guidance and a built-in FAQ.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: isLoggedIn
                            ? AppColors.primary.withValues(alpha: 0.10)
                            : Colors.grey.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isLoggedIn
                              ? AppColors.primary.withValues(alpha: 0.22)
                              : Colors.grey.withValues(alpha: 0.22),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLoggedIn
                                  ? Icons.healing_outlined
                                  : Icons.lock_outline_rounded,
                              size: 14,
                              color: isLoggedIn ? AppColors.primary : Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isLoggedIn ? 'Open' : 'Log in to use',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isLoggedIn ? AppColors.primary : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: cs.outline,
              ),
            ],
          ),
        ),
      ),
    ).mobadraFadeSlide(delayMs: 80);
  }
}

class _PerkHeroCard extends StatelessWidget {
  final MobadraPerk perk;
  final VoidCallback onTap;

  const _PerkHeroCard({required this.perk, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: ShadCard(
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        radius: BorderRadius.circular(AppRadii.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 78,
                  child: Center(
                    child: Image.asset(
                      perk.imageUrl,
                      height: 72,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  perk.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    height: 1.12,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 7),
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(Icons.verified_outlined, size: 14, color: cs.primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Included for members',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: cs.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        perk.subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: cs.outline,
                        ),
                      ),
                    ),
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
