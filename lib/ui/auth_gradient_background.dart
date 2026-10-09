import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Live light-blue mesh background inspired by CSS keyframe blob motion
/// (`moveVertical`, `moveInCircle`, `moveHorizontal`).
class AuthGradientBackground extends StatefulWidget {
  const AuthGradientBackground({super.key});

  @override
  State<AuthGradientBackground> createState() => _AuthGradientBackgroundState();
}

class _AuthGradientBackgroundState extends State<AuthGradientBackground>
    with TickerProviderStateMixin {
  late final AnimationController _vertical;
  late final AnimationController _circleShort;
  late final AnimationController _circleLong;
  late final AnimationController _horizontal;
  late final AnimationController _circleFifth;

  @override
  void initState() {
    super.initState();
    _vertical = AnimationController(vsync: this, duration: const Duration(seconds: 30))..repeat();
    _circleShort = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat(reverse: true);
    _circleLong = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    _horizontal = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    _circleFifth = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _vertical.dispose();
    _circleShort.dispose();
    _circleLong.dispose();
    _horizontal.dispose();
    _circleFifth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A1612),
                    Color(0xFF0C0C0C),
                    Color(0xFF14110E),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: Listenable.merge([
                _vertical,
                _circleShort,
                _circleLong,
                _horizontal,
                _circleFifth,
              ]),
              builder: (context, _) {
                return CustomPaint(
                  size: Size(w, h),
                  painter: _AuthBlobPainter(
                    tVertical: _vertical.value,
                    tCircleShort: _circleShort.value,
                    tCircleLong: _circleLong.value,
                    tHorizontal: _horizontal.value,
                    tCircleFifth: _circleFifth.value,
                    width: w,
                    height: h,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _AuthBlobPainter extends CustomPainter {
  _AuthBlobPainter({
    required this.tVertical,
    required this.tCircleShort,
    required this.tCircleLong,
    required this.tHorizontal,
    required this.tCircleFifth,
    required this.width,
    required this.height,
  });

  final double tVertical;
  final double tCircleShort;
  final double tCircleLong;
  final double tHorizontal;
  final double tCircleFifth;
  final double width;
  final double height;

  void _blob(Canvas canvas, Offset c, double r, Color color, double opacity) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0),
        ],
        stops: const [0.15, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = width;
    final h = height;

    // moveVertical 30s
    final yVert = math.sin(tVertical * math.pi * 2) * h * 0.28;
    _blob(canvas, Offset(w * 0.12, h * 0.32 + yVert), w * 0.58, const Color(0xFFE7D3BE), 0.22);

    // moveInCircle 20s reverse
    final a1 = -tCircleShort * math.pi * 2;
    _blob(
      canvas,
      Offset(w * 0.48 + math.cos(a1) * w * 0.22, h * 0.42 + math.sin(a1) * h * 0.18),
      w * 0.48,
      const Color(0xFFC9A27C),
      0.30,
    );

    // moveInCircle 40s
    final a2 = tCircleLong * math.pi * 2;
    _blob(
      canvas,
      Offset(w * 0.78 + math.cos(a2) * w * 0.16, h * 0.28 + math.sin(a2) * h * 0.22),
      w * 0.42,
      const Color(0xFF8A735C),
      0.28,
    );

    // moveHorizontal 40s
    final xHoriz = math.sin(tHorizontal * math.pi * 2) * w * 0.32;
    _blob(canvas, Offset(w * 0.52 + xHoriz, h * 0.68), w * 0.52, const Color(0xFFF3E6D8), 0.16);

    // moveInCircle 20s
    final a3 = tCircleFifth * math.pi * 2;
    _blob(
      canvas,
      Offset(w * 0.28 + math.cos(a3) * w * 0.26, h * 0.55 + math.sin(a3) * h * 0.2),
      w * 0.38,
      const Color(0xFFA8886C),
      0.24,
    );
  }

  @override
  bool shouldRepaint(covariant _AuthBlobPainter old) {
    return old.tVertical != tVertical ||
        old.tCircleShort != tCircleShort ||
        old.tCircleLong != tCircleLong ||
        old.tHorizontal != tHorizontal ||
        old.tCircleFifth != tCircleFifth ||
        old.width != width ||
        old.height != height;
  }
}
