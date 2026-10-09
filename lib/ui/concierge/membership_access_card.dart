import 'package:flutter/material.dart';

import 'package:cms/screens/signin_screen.dart';
import 'package:cms/screens/signup_screen.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/theme/concierge_theme.dart';
import 'package:cms/ui/concierge/concierge_button.dart';
import 'package:cms/ui/concierge/quiet_card.dart';

/// Guest membership gate. Ivory surface, emerald icon, thin gold rule.
class MembershipAccessCard extends StatelessWidget {
  const MembershipAccessCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ink = ConciergePalette.ink(context);
    final muted = ConciergePalette.muted(context);
    final emerald = ConciergePalette.emerald(context);
    return QuietCard(
      accent: QuietAccent.gold,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadii.lg)),
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: _ArcPainter())),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: ConciergePalette.emeraldWash(context),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Icon(Icons.lock_outline_rounded, size: 18, color: emerald),
                  ),
                  const SizedBox(height: 14),
                  Text('Unlock member benefits', style: ConciergeType.title(ink).copyWith(fontSize: 18)),
                  const SizedBox(height: 6),
                  Text(
                    'Partner discounts and hospital privileges, reserved for members.',
                    style: ConciergeType.caption(muted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ConciergeTextAction(
                        label: 'Sign in',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      ConciergeTextAction(
                        label: 'Join now',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(builder: (_) => const SignupScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.emerald.withValues(alpha: 0.16);
    final origin = Offset(size.width + 8, 18);
    canvas.drawArc(Rect.fromCircle(center: origin, radius: 78), 1.6, 2.2, false, paint);
    canvas.drawArc(Rect.fromCircle(center: origin.translate(6, 8), radius: 52), 1.7, 2.0, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
