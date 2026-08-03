import 'package:flutter/material.dart';

import '../ui/auth_gradient_background.dart';

/// Animated green–blue gradient background with a transparent app bar for auth flows.
class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white.withValues(alpha: 0.95)),
        foregroundColor: Colors.white.withValues(alpha: 0.95),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthGradientBackground(),
          SafeArea(child: child!),
        ],
      ),
    );
  }
}
