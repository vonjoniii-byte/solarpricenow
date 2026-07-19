import 'package:flutter/material.dart';

/// Simple front-on line-art house illustration used on the results card.
///
/// Mirrors the three reference states:
///  - bare roof            (hasSolar: false, hasBattery: false)
///  - roof + solar panels  (hasSolar: true,  hasBattery: false)
///  - roof + panels + batt (hasSolar: true,  hasBattery: true)
///
/// Pure CustomPainter — no extra package dependency (no flutter_svg etc.),
/// so it doesn't touch pubspec.yaml.
class HouseIllustration extends StatelessWidget {
  const HouseIllustration({
    super.key,
    this.hasSolar = true,
    this.hasBattery = false,
    this.lineColor = const Color(0xFF1E293B),
    this.panelStrokeColor = const Color(0xFF2563EB),
    this.panelFillColor = const Color(0xFF60A5FA),
    this.batteryColor = const Color(0xFF4CAF50),
  });

  final bool hasSolar;
  final bool hasBattery;
  final Color lineColor;
  final Color panelStrokeColor;
  final Color panelFillColor;
  final Color batteryColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _HousePainter(
        hasSolar: hasSolar,
        hasBattery: hasBattery,
        lineColor: lineColor,
        panelStrokeColor: panelStrokeColor,
        panelFillColor: panelFillColor,
        batteryColor: batteryColor,
      ),
    );
  }
}

class _HousePainter extends CustomPainter {
  _HousePainter({
    required this.hasSolar,
    required this.hasBattery,
    required this.lineColor,
    required this.panelStrokeColor,
    required this.panelFillColor,
    required this.batteryColor,
  });

  final bool hasSolar;
  final bool hasBattery;
  final Color lineColor;
  final Color panelStrokeColor;
  final Color panelFillColor;
  final Color batteryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint stroke = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // ── Layout anchors ──────────────────────────────────────────────────
    final double groundY = h * 0.86;
    final double wallTopY = h * 0.5;
    final double roofPeakY = h * 0.14;
    final double bodyLeft = w * 0.06;
    final double bodyRight = w * 0.66;
    final double eaveOverhang = w * 0.03;
    final double roofPeakX = w * 0.36;
    final double hipX = w * 0.15;

    // ── Roof (hipped, two ridge lines for depth) ───────────────────────
    canvas.drawLine(Offset(bodyLeft - eaveOverhang, wallTopY),
        Offset(roofPeakX, roofPeakY), stroke);
    canvas.drawLine(Offset(roofPeakX, roofPeakY),
        Offset(bodyRight + eaveOverhang, wallTopY), stroke);
    canvas.drawLine(
        Offset(roofPeakX, roofPeakY), Offset(hipX, wallTopY), stroke);

    // ── Walls + eave line + ground line ────────────────────────────────
    canvas.drawLine(
        Offset(bodyLeft - eaveOverhang, wallTopY),
        Offset(bodyRight + eaveOverhang, wallTopY),
        stroke);
    canvas.drawLine(
        Offset(bodyLeft, wallTopY), Offset(bodyLeft, groundY), stroke);
    canvas.drawLine(
        Offset(bodyRight, wallTopY), Offset(bodyRight, groundY), stroke);
    canvas.drawLine(Offset(bodyLeft, groundY),
        Offset(bodyRight + w * 0.10, groundY), stroke);

    // ── Garage door (louvered) ──────────────────────────────────────────
    final double garageLeft = bodyLeft + w * 0.02;
    final double garageRight = bodyLeft + w * 0.24;
    final Rect garageRect =
        Rect.fromLTRB(garageLeft, wallTopY + h * 0.02, garageRight, groundY);
    canvas.drawRect(garageRect, stroke);
    for (int i = 1; i <= 3; i++) {
      final double y = garageRect.top + (garageRect.height / 4) * i;
      canvas.drawLine(
          Offset(garageRect.left, y), Offset(garageRect.right, y), stroke);
    }

    // ── Front door ───────────────────────────────────────────────────────
    final double doorLeft = garageRight + w * 0.03;
    final double doorRight = doorLeft + w * 0.055;
    final Rect doorRect =
        Rect.fromLTRB(doorLeft, wallTopY + h * 0.06, doorRight, groundY);
    canvas.drawRect(doorRect, stroke);
    final Paint dot = Paint()..color = lineColor;
    canvas.drawCircle(
        Offset(doorRect.right - 3, doorRect.top + doorRect.height * 0.5),
        1.6,
        dot);

    // ── Windows ──────────────────────────────────────────────────────────
    final double winLeft = doorRight + w * 0.03;
    final double winRight = winLeft + w * 0.14;
    final Rect winRect = Rect.fromLTRB(
        winLeft, wallTopY + h * 0.08, winRight, wallTopY + h * 0.28);
    canvas.drawRect(winRect, stroke);
    canvas.drawLine(
        Offset((winRect.left + winRect.right) / 2, winRect.top),
        Offset((winRect.left + winRect.right) / 2, winRect.bottom),
        stroke);
    canvas.drawLine(
        Offset(winRect.left, (winRect.top + winRect.bottom) / 2),
        Offset(winRect.right, (winRect.top + winRect.bottom) / 2),
        stroke);

    // ── Bushes ───────────────────────────────────────────────────────────
    final Paint bushStroke = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final double bushBaseX = bodyRight + w * 0.02;
    final List<Offset> bushCenters = <Offset>[
      Offset(bushBaseX, groundY - h * 0.05),
      Offset(bushBaseX + w * 0.035, groundY - h * 0.07),
      Offset(bushBaseX + w * 0.07, groundY - h * 0.04),
    ];
    for (final Offset c in bushCenters) {
      canvas.drawCircle(c, w * 0.03, bushStroke);
    }

    // ── Solar panels (angled array on the right roof slope) ───────────────
    if (hasSolar) {
      final Paint panelFill = Paint()
        ..color = panelFillColor.withValues(alpha: 0.85);
      final Paint panelStroke = Paint()
        ..color = panelStrokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;

      const int cols = 4;
      const int rows = 2;
      final double arrayWidth = w * 0.30;
      final double arrayHeight = h * 0.11;
      final double originX = w * 0.34;
      final double originY = wallTopY - h * 0.16;
      final double cellW = arrayWidth / cols;
      final double cellH = arrayHeight / rows;

      canvas.save();
      canvas.translate(originX, originY);
      canvas.rotate(-0.12);
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final Rect cell = Rect.fromLTWH(
              c * cellW, r * cellH, cellW - 1.5, cellH - 1.5);
          canvas.drawRect(cell, panelFill);
          canvas.drawRect(cell, panelStroke);
        }
      }
      canvas.restore();
    }

    // ── Battery (standing box beside the house) ────────────────────────────
    if (hasBattery) {
      final Paint batteryFill = Paint()..color = batteryColor;
      final double bLeft = bodyRight + w * 0.13;
      final double bTop = groundY - h * 0.22;
      final Rect batteryRect =
          Rect.fromLTRB(bLeft, bTop, bLeft + w * 0.05, groundY);
      final RRect rrect =
          RRect.fromRectAndRadius(batteryRect, const Radius.circular(3));
      canvas.drawRRect(rrect, batteryFill);
      canvas.drawRRect(rrect, stroke);

      final Paint ventPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      canvas.drawLine(
        Offset(batteryRect.left + 3,
            batteryRect.top + batteryRect.height * 0.35),
        Offset(batteryRect.right - 3,
            batteryRect.top + batteryRect.height * 0.35),
        ventPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HousePainter oldDelegate) {
    return oldDelegate.hasSolar != hasSolar ||
        oldDelegate.hasBattery != hasBattery ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.panelStrokeColor != panelStrokeColor ||
        oldDelegate.panelFillColor != panelFillColor ||
        oldDelegate.batteryColor != batteryColor;
  }
}
