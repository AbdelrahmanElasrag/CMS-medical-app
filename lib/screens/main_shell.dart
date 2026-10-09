import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:cms/services/auth_service.dart';
import 'package:cms/ui/booking_auth_prompt.dart';
import 'package:cms/screens/concierge_screen.dart';
import 'package:cms/screens/home_screen.dart';
import 'package:cms/screens/profile_screen.dart';
import 'package:cms/screens/service_screen.dart';
import 'package:cms/screens/visits_screen.dart';
import 'package:cms/theme/concierge_theme.dart';
import 'package:cms/ui/concierge/concierge_nav_bar.dart';
import 'package:cms/ui/lumen_field.dart';
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _confirmExit(context);
      },
      child: Scaffold(
        backgroundColor: EditorialPalette.canvas,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const LumenField(),
            MobadraTabHost(
              index: _index,
              children: [
                MobadraHomeTab(
                  username: widget.username,
                  profileImageUrl: widget.profileImageUrl,
                  heroPlaying: _index == 0,
                  onOpenProfile: () => setState(() => _index = 3),
                  onBook: () => _openBooking(context),
                  onOpenVisits: () => setState(() => _index = 1),
                  onOpenConcierge: () => setState(() => _index = 2),
                ),
                const VisitsScreen(),
                ConciergeScreen(
                  username: widget.username,
                  points: widget.points,
                  onOpenProfile: () => setState(() => _index = 3),
                ),
                ProfileScreen(
                  username: widget.username,
                  points: widget.points,
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: ConciergeNavBar(
          index: _index,
          onSelect: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}
