import 'package:flutter/material.dart';

import '../screens/signin_screen.dart';
import '../screens/signup_screen.dart';
import 'package:cms/theme/concierge_theme.dart';

/// Shown when a guest tries to book; drives sign-up funnel.
Future<void> showBookingAuthPrompt(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (ctx) => Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF2E2E30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: EditorialPalette.cardInner,
                ),
                child: const Icon(Icons.person_add_alt_1_rounded, color: EditorialPalette.headline, size: 28),
              ),
              const SizedBox(height: 14),
              Text(
                'Create an account to book',
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: EditorialPalette.headline,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up free to request visits, track appointments, and earn member points.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: EditorialPalette.muted, height: 1.4, fontSize: 15),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: EditorialPalette.ivory,
                    foregroundColor: EditorialPalette.ivoryInk,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push<void>(
                      ctx,
                      MaterialPageRoute<void>(builder: (_) => const SignupScreen()),
                    );
                  },
                  child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EditorialPalette.headline,
                    side: const BorderSide(color: Color(0x66F7F4EF)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push<void>(
                      ctx,
                      MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
                    );
                  },
                  child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: EditorialPalette.muted,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Not now'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
