import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:cms/services/auth_service.dart';
import 'package:cms/ui/booking_auth_prompt.dart';
import 'package:cms/screens/home_screen.dart';
import 'package:cms/screens/offers_screen.dart';
import 'package:cms/screens/profile_screen.dart';
import 'package:cms/screens/service_screen.dart';
import 'package:cms/screens/visits_screen.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/ui/mobadra_ui.dart';

class MainShell extends StatefulWidget {
  final String username;
  final int points;
  final String? profileImageUrl;

  const MainShell({
    super.key,
    required this.username,
    required this.points,
    this.profileImageUrl,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => ShadDialog.alert(
            title: const Text('Exit app?'),
            description: const Text('Are you sure you want to exit?'),
            actions: [
              ShadButton.outline(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ShadButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
    if (shouldExit && context.mounted) {
      SystemNavigator.pop();
    }
  }

  void _openBooking(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    if (!auth.isLoggedIn) {
      showBookingAuthPrompt(context);
      return;
    }
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ServiceScreen(
          service: 'Book visit',
          username: widget.username,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ShadTheme.of(context).colorScheme;
    final materialCs = Theme.of(context).colorScheme;
    final headerBorder = materialCs.outline.withValues(alpha: 0.18);
    final barBg = Theme.of(context).brightness == Brightness.dark
        ? materialCs.surfaceContainerHigh
        : AppColors.primaryContainer;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _confirmExit(context);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            MobadraHomeTab(
              username: widget.username,
              points: widget.points,
              profileImageUrl: widget.profileImageUrl,
              onOpenProfile: () => setState(() => _index = 3),
              onViewAllOffers: () => setState(() => _index = 1),
            ),
            const OffersScreen(),
            const VisitsScreen(),
            ProfileScreen(
              username: widget.username,
              points: widget.points,
            ),
          ],
        ),
        floatingActionButton: SizedBox(
          width: 72,
          height: 72,
          child: FloatingActionButton(
            onPressed: () => _openBooking(context),
            backgroundColor: Colors.white,
            foregroundColor: scheme.primary,
            elevation: 4,
            shape: CircleBorder(
              side: BorderSide(
                color: scheme.primary.withValues(alpha: 0.22),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: SizedBox(
                width: 60,
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    'assets/booknow.gif',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: barBg,
              border: Border(top: BorderSide(color: headerBorder, width: 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomAppBar(
              padding: EdgeInsets.zero,
              height: 50,
              elevation: 0,
              notchMargin: 10,
              color: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: const CircularNotchedRectangle(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _CompactNavItem(
                            icon: Icons.home_rounded,
                            label: 'Home',
                            selected: _index == 0,
                            primary: scheme.primary,
                            muted: scheme.mutedForeground,
                            onTap: () => setState(() => _index = 0),
                          ),
                          _CompactNavItem(
                            icon: Icons.local_offer_outlined,
                            label: 'Offers',
                            selected: _index == 1,
                            primary: scheme.primary,
                            muted: scheme.mutedForeground,
                            onTap: () => setState(() => _index = 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 108),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _CompactNavItem(
                            icon: Icons.calendar_month_outlined,
                            label: 'Visits',
                            selected: _index == 2,
                            primary: scheme.primary,
                            muted: scheme.mutedForeground,
                            onTap: () => setState(() => _index = 2),
                          ),
                          _CompactNavItem(
                            icon: Icons.person_outline,
                            label: 'Profile',
                            selected: _index == 3,
                            primary: scheme.primary,
                            muted: scheme.mutedForeground,
                            onTap: () => setState(() => _index = 3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color primary;
  final Color muted;
  final VoidCallback onTap;

  const _CompactNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.primary,
    required this.muted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 21, color: selected ? primary : muted),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? primary : muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
