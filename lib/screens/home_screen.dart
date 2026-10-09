import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:cms/services/auth_service.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/theme/concierge_theme.dart';
import 'package:cms/ui/concierge/concierge.dart';
import 'package:cms/ui/mobadra_ui.dart';

/// Home tab content (used inside [MainShell]).
class MobadraHomeTab extends StatelessWidget {
  final String username;
  final String? profileImageUrl;
  final VoidCallback onOpenProfile;
  final VoidCallback onBook;
  final VoidCallback onOpenVisits;
  final VoidCallback onOpenConcierge;
  final bool heroPlaying;

  const MobadraHomeTab({
    super.key,
    required this.username,
    this.profileImageUrl,
    required this.onOpenProfile,
    required this.onBook,
    required this.onOpenVisits,
    required this.onOpenConcierge,
    this.heroPlaying = true,
  });

  String get _displayName {
    final raw = username.trim();
    if (raw.isEmpty) return 'Guest';
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = context.watch<AuthService>().isLoggedIn;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final heroHeight = (MediaQuery.sizeOf(context).height * 0.5).clamp(380.0, 520.0);
    Widget enter(Widget child, {int delayMs = 0, bool pop = false}) {
      if (reduce) return child;
      return pop ? child.mobadraPop(delayMs: delayMs) : child.mobadraCardIn(delayMs: delayMs);
    }

    return Semantics(
      container: true,
      label: 'Home for $_displayName',
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: EditorialPalette.canvas,
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: heroHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    EditorialHero(playing: heroPlaying),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ConciergeHeader(
                          profileImageUrl: profileImageUrl,
                          onOpenProfile: onOpenProfile,
                          onPhoto: true,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 28, 0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Align(
                                  alignment: Alignment.bottomLeft,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.bottomLeft,
                                    child: SizedBox(
                                      width: constraints.maxWidth,
                                      child: enter(const _EditorialLockup()),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                          child: enter(
                            EditorialBookButton(
                              label: 'Book a visit',
                              onPressed: onBook,
                            ),
                            delayMs: 160,
                            pop: true,
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.page, 6, AppSpacing.page, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    enter(
                      Text('Upcoming appointment', style: EditorialType.section()),
                      delayMs: 220,
                    ),
                    const SizedBox(height: 10),
                    enter(
                      UpcomingAppointmentCard(
                        signedIn: signedIn,
                        onOpen: onOpenVisits,
                      ),
                      delayMs: 280,
                    ),
                    const SizedBox(height: 12),
                    enter(
                      HomeLinkCard(
                        icon: Icons.person_outline_rounded,
                        title: 'Concierge',
                        subtitle: 'Your personal healthcare assistant',
                        tone: HomeLinkTone.editorial,
                        onTap: onOpenConcierge,
                      ),
                      delayMs: 340,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorialLockup extends StatelessWidget {
  const _EditorialLockup();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exceptional care, beautifully simple.',
            style: EditorialType.headline(),
          ),
          const SizedBox(height: 12),
          Text(
            'Concierge healthcare for a healthier tomorrow.',
            style: EditorialType.subhead(),
          ),
        ],
      ),
    );
  }
}
