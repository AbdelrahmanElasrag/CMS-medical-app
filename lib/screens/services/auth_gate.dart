// lib/screens/services/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main_shell.dart';
import '../splash_screen.dart';
import '../../services/auth_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future.wait([
      AuthService.instance.restoreSession(),
      Future<void>.delayed(const Duration(milliseconds: 2000)),
    ]);
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SplashView();
    }

    final auth = context.watch<AuthService>();
    final p = auth.currentPatient;

    return MainShell(
      username: p?.displayName ?? 'Guest',
      points: p?.points ?? 0,
      profileImageUrl: p?.profileImageUrl,
    );
  }
}
