// SunburstMark — the Solar Price Now brand mark: a circle with 8 evenly
// spaced rays. Used standalone (header lockup) and animated (calculating
// screen). Kept as one shared, correctly-implemented widget so both usages
// always render identically — no duplicated painting logic to drift apart.

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/colors.dart';

class SunburstMark extends StatelessWidget {
  final double size;
  const SunburstMark({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SunburstPainter(),
      ),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double coreRadius = size.width * 0.20;
    final double rayInner = size.width * 0.32;
    final double rayOuter = size.width * 0.5;

    final Paint corePaint = Paint()..color = AppColors.solarAmber;
    canvas.drawCircle(center, coreRadius, corePaint);

    final Paint rayPaint = Paint()
      ..color = AppColors.accent2
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final double angle = (i / 8) * 2 * math.pi;
      final Offset from = Offset(
        center.dx + rayInner * math.cos(angle),
        center.dy + rayInner * math.sin(angle),
      );
      final Offset to = Offset(
        center.dx + rayOuter * math.cos(angle),
        center.dy + rayOuter * math.sin(angle),
      );
      canvas.drawLine(from, to, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
