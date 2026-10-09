import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Pale botanical mark beside the Ivory Concierge greeting.
class IvoryBloom extends StatelessWidget {
  const IvoryBloom({super.key, this.size = 128});

  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      size: Size.square(size),
      painter: _BloomPainter(
        petal: dark ? const Color(0xFF3A3F78) : const Color(0xFFD9DEFF),
        stroke: dark ? const Color(0xFFA5B4FC) : const Color(0xFF8B93E8),
        leaf: dark ? const Color(0xFF2A3358) : const Color(0xFFC9D6FF),
      ),
    );
  }
}

class _BloomPainter extends CustomPainter {
  const _BloomPainter({
    required this.petal,
    required this.stroke,
    required this.leaf,
  });

  final Color petal;
  final Color stroke;
  final Color leaf;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round
      ..color = stroke;
    final petalFill = Paint()..color = petal.withValues(alpha: 0.72);
    final leafFill = Paint()..color = leaf.withValues(alpha: 0.8);

    final center = Offset(size.width * 0.58, size.height * 0.34);

    for (var i = 0; i < 6; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * math.pi / 3 - 0.3);
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(11, -14, 0, -26)
        ..quadraticBezierTo(-11, -14, 0, 0);
      canvas.drawPath(path, petalFill);
      canvas.drawPath(path, line);
      canvas.restore();
    }

    canvas.drawCircle(center, 3.5, petalFill);
    canvas.drawCircle(center, 3.5, line);

    final stem = Path()
      ..moveTo(center.dx + 1, center.dy + 10)
      ..quadraticBezierTo(size.width * 0.78, size.height * 0.62, size.width * 0.92, size.height * 0.92);
    canvas.drawPath(stem, line);

    canvas.save();
    canvas.translate(size.width * 0.74, size.height * 0.58);
    canvas.rotate(-0.6);
    final leafPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(16, -8, 28, 2)
      ..quadraticBezierTo(14, 8, 0, 0);
    canvas.drawPath(leafPath, leafFill);
    canvas.drawPath(leafPath, line);
    canvas.restore();

    canvas.save();
    canvas.translate(size.width * 0.8, size.height * 0.74);
    canvas.rotate(0.5);
    final leafPath2 = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(12, -10, 22, -1)
      ..quadraticBezierTo(10, 8, 0, 0);
    canvas.drawPath(leafPath2, leafFill);
    canvas.drawPath(leafPath2, line);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BloomPainter oldDelegate) =>
      oldDelegate.petal != petal || oldDelegate.stroke != stroke || oldDelegate.leaf != leaf;
}
