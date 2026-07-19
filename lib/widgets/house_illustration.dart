import 'dart:math' as math;
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
    this.panelFillColor = const Color(0xFF4C8FF0),
    this.batteryColor = const Color(0xFF4CAF50),
    // Should match the surface the illustration sits on (e.g. AppColors.surface)
    // so the bush "blob" blends in rather than showing a mismatched box.
    this.backgroundColor = Colors.white,
  });

  final bool hasSolar;
  final bool hasBattery;
  final Color lineColor;
  final Color panelStrokeColor;
  final Color panelFillColor;
  final Color batteryColor;
  final Color backgroundColor;

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
        backgroundColor: backgroundColor,
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
    required this.backgroundColor,
  });

  final bool hasSolar;
  final bool hasBattery;
  final Color lineColor;
  final Color panelStrokeColor;
  final Color panelFillColor;
  final Color batteryColor;
  final Color backgroundColor;

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
    final double bodyRight = w * 0.62;
    final double eaveOverhang = w * 0.03;
    final double roofPeakX = w * 0.34;
    final double hipX = w * 0.14;
    final Offset roofPeak = Offset(roofPeakX, roofPeakY);
    final Offset eaveRight = Offset(bodyRight + eaveOverhang, wallTopY);

    // ── Roof (hipped, two ridge lines for depth) ───────────────────────
    canvas.drawLine(
        Offset(bodyLeft - eaveOverhang, wallTopY), roofPeak, stroke);
    canvas.drawLine(roofPeak, eaveRight, stroke);
    canvas.drawLine(roofPeak, Offset(hipX, wallTopY), stroke);

    // ── Walls + eave line + ground line ────────────────────────────────
    canvas.drawLine(Offset(bodyLeft - eaveOverhang, wallTopY), eaveRight,
        stroke);
    canvas.drawLine(
        Offset(bodyLeft, wallTopY), Offset(bodyLeft, groundY), stroke);
    canvas.drawLine(
        Offset(bodyRight, wallTopY), Offset(bodyRight, groundY), stroke);
    final double groundRightX = bodyRight + w * 0.20;
    canvas.drawLine(
        Offset(bodyLeft, groundY), Offset(groundRightX, groundY), stroke);

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
    final double winRight = winLeft + w * 0.16;
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

    // ── Solar panels — aligned to the actual right-roof-slope angle ───────
    if (hasSolar) {
      final double dx = eaveRight.dx - roofPeak.dx;
      final double dy = eaveRight.dy - roofPeak.dy;
      final double slopeLen = math.sqrt(dx * dx + dy * dy);
      final double angle = math.atan2(dy, dx);

      const int cols = 4;
      const int rows = 2;
      final double insetStart = slopeLen * 0.16;
      final double arrayLen = slopeLen * 0.62;
      final double arrayThickness = h * 0.10;
      final double cellW = arrayLen / cols;
      final double cellH = arrayThickness / rows;
      const double gap = 1.6;

      final Paint panelFill = Paint()..color = panelFillColor;
      final Paint panelStroke = Paint()
        ..color = panelStrokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      final Paint frameStroke = Paint()
        ..color = panelStrokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      canvas.save();
      canvas.translate(roofPeak.dx, roofPeak.dy);
      canvas.rotate(angle);
      // Move along the slope by the inset, and lift up off the roofline
      // (negative local y in this rotated frame points outward/up off the
      // roof surface) so the array sits visibly on top of the roof.
      canvas.translate(insetStart, -arrayThickness - h * 0.012);

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final Rect cell = Rect.fromLTWH(
            c * cellW + gap / 2,
            r * cellH + gap / 2,
            cellW - gap,
            cellH - gap,
          );
          canvas.drawRect(cell, panelFill);
          canvas.drawRect(cell, panelStroke);
        }
      }
      // Outer frame ties the grid together into one clean panel bank.
      canvas.drawRect(
          Rect.fromLTWH(0, 0, arrayLen, arrayThickness), frameStroke);
      canvas.restore();
    }

    // ── Bush — single filled "blob" made from unioned circles ─────────────
    final double bushCenterX = bodyRight + w * 0.045;
    final double bushBaseY = groundY - h * 0.03;
    final List<MapEntry<Offset, double>> lobes = <MapEntry<Offset, double>>[
      MapEntry(
          Offset(bushCenterX - w * 0.028, bushBaseY - h * 0.015), w * 0.030),
      MapEntry(Offset(bushCenterX, bushBaseY - h * 0.048), w * 0.037),
      MapEntry(
          Offset(bushCenterX + w * 0.030, bushBaseY - h * 0.012), w * 0.028),
    ];
    Path bushPath = Path();
    for (final MapEntry<Offset, double> lobe in lobes) {
      bushPath = Path.combine(
        PathOperation.union,
        bushPath,
        Path()..addOval(Rect.fromCircle(center: lobe.key, radius: lobe.value)),
      );
    }
    final Paint bushFill = Paint()..color = backgroundColor;
    final Paint bushStroke = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(bushPath, bushFill);
    canvas.drawPath(bushPath, bushStroke);

    // ── Battery — standing right against the house wall, beside the bush ──
    if (hasBattery) {
      final double batteryLeft = bushCenterX + w * 0.075;
      final double batteryWidth = w * 0.042;
      final double bTop = groundY - h * 0.20;
      final Rect batteryRect =
          Rect.fromLTRB(batteryLeft, bTop, batteryLeft + batteryWidth, groundY);
      final RRect rrect =
          RRect.fromRectAndRadius(batteryRect, const Radius.circular(3));
      final Paint batteryFill = Paint()..color = batteryColor;
      canvas.drawRRect(rrect, batteryFill);
      canvas.drawRRect(rrect, stroke);

      final Paint ventPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
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
        oldDelegate.batteryColor != batteryColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
