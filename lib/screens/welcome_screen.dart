import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import '../ui/mobadra_motion.dart';
import '../widgets/custom_scaffold.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _pillRadius = 28.0;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          height: 1.15,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 3),
            ),
          ],
        );

    return CustomScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  _WelcomeLogoBadge().mobadraFadeSlide(),
                  const SizedBox(height: 28),
                  Text(
                    'Creative Mobadra',
                    textAlign: TextAlign.center,
                    style: titleStyle,
                  ).mobadraFadeSlide(delayMs: 40),
                  const SizedBox(height: 12),
                  Text(
                    'Your member hub for partner care in the UAE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                      letterSpacing: 0.35,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ).mobadraFadeSlide(delayMs: 60),
                  const SizedBox(height: 44),
                  Row(
                    children: [
                      Expanded(
                        child: _WelcomeOutlineButton(
                          label: 'Sign In',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _WelcomePrimaryButton(
                          label: 'Sign Up',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(builder: (_) => const SignupScreen()),
                          ),
                        ),
                      ),
                    ],
                  ).mobadraFadeSlide(delayMs: 90),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Frosted plate behind the mark so dark-green artwork reads on the gradient.
class _WelcomeLogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.white.withValues(alpha: 0.16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.38),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/newlogo.png',
            height: 88,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _WelcomeOutlineButton extends StatelessWidget {
  const _WelcomeOutlineButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(WelcomeScreen._pillRadius),
        splashColor: Colors.white.withValues(alpha: 0.12),
        highlightColor: Colors.white.withValues(alpha: 0.06),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(WelcomeScreen._pillRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.92),
              width: 1.5,
            ),
            color: Colors.white.withValues(alpha: 0.06),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15.5,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomePrimaryButton extends StatelessWidget {
  const _WelcomePrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WelcomeScreen._pillRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.45),
            blurRadius: 22,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(WelcomeScreen._pillRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          highlightColor: AppColors.primary.withValues(alpha: 0.06),
          child: SizedBox(
            height: 52,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15.5,
                  letterSpacing: 0.15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
