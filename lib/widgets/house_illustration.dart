import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Front-on house illustration for the results card.
///
/// Coordinates below were measured directly (pixel analysis) from Paul's
/// reference image (3-house line art: bare / solar / solar+battery), not
/// guessed from eyeballing — roof peak, ground line, wall-top line, solar
/// panel bounding box + slope angle, and battery position are all derived
/// from actual pixel measurements of that image. Door/window/garage/bush
/// positions are close visual estimates from the same reference.
///
/// States:
///  - hasSolar: false, hasBattery: false -> bare roof
///  - hasSolar: true,  hasBattery: false -> roof + solar panel array
///  - hasSolar: true,  hasBattery: true  -> roof + panels + battery
///
/// Pure CustomPainter — no extra package dependency, doesn't touch pubspec.yaml.
class HouseIllustration extends StatelessWidget {
  const HouseIllustration({
    super.key,
    this.hasSolar = true,
    this.hasBattery = false,
  });

  final bool hasSolar;
  final bool hasBattery;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _HousePainter(hasSolar: hasSolar, hasBattery: hasBattery),
    );
  }
}

class _HousePainter extends CustomPainter {
  _HousePainter({required this.hasSolar, required this.hasBattery});

  final bool hasSolar;
  final bool hasBattery;

  static const Color _outline = Color(0xFF1A1A1A);
  static const Color _solarFill = Color(0xFF2E7DE6);
  static const Color _solarStroke = Color(0xFF0D3C82);
  static const Color _batteryFill = Color(0xFF6FBE44);
  static const Color _batteryStroke = Color(0xFF3F7D22);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint stroke = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // ── Measured anchors (fractions of w/h, from pixel analysis) ──────────
    final double groundY = h * 0.97;
    final double wallTopY = h * 0.47;
    final double roofPeakX = w * 0.417;
    final double roofPeakY = h * 0.02;
    final double hipX = w * 0.20; // secondary ridge for hip-roof depth
    final double bodyLeft = w * 0.03;
    final double bodyRight = w * 0.985; // roof spans the full structure

    // ── Roof (single hip roof over the whole structure) ────────────────
    final Offset peak = Offset(roofPeakX, roofPeakY);
    canvas.drawLine(Offset(bodyLeft, wallTopY), peak, stroke);
    canvas.drawLine(peak, Offset(bodyRight, wallTopY), stroke);
    canvas.drawLine(peak, Offset(hipX, wallTopY), stroke);
    canvas.drawLine(Offset(bodyLeft, wallTopY), Offset(bodyRight, wallTopY), stroke);

    // ── Walls + ground line ─────────────────────────────────────────────
    canvas.drawLine(Offset(bodyLeft, wallTopY), Offset(bodyLeft, groundY), stroke);
    canvas.drawLine(Offset(bodyRight, wallTopY), Offset(bodyRight, groundY), stroke);
    canvas.drawLine(Offset(bodyLeft, groundY), Offset(bodyRight, groundY), stroke);

    // ── Garage door (wide, louvered, left side) ─────────────────────────
    final Rect garageRect = Rect.fromLTRB(w * 0.03, wallTopY, w * 0.42, groundY);
    canvas.drawRect(garageRect, stroke);
    for (int i = 1; i <= 3; i++) {
      final double y = garageRect.top + (garageRect.height / 4) * i;
      canvas.drawLine(Offset(garageRect.left, y), Offset(garageRect.right, y), stroke);
    }

    // ── Front door ───────────────────────────────────────────────────────
    final Rect doorRect =
        Rect.fromLTRB(w * 0.455, wallTopY + h * 0.06, w * 0.51, groundY);
    canvas.drawRect(doorRect, stroke);
    canvas.drawCircle(Offset(doorRect.right - 3, doorRect.top + doorRect.height * 0.5),
        1.6, Paint()..color = _outline);

    // ── Window (2x2 pane grid) ─────────────────────────────────────────
    final Rect winRect =
        Rect.fromLTRB(w * 0.555, wallTopY + h * 0.03, w * 0.70, wallTopY + h * 0.28);
    canvas.drawRect(winRect, stroke);
    canvas.drawLine(Offset((winRect.left + winRect.right) / 2, winRect.top),
        Offset((winRect.left + winRect.right) / 2, winRect.bottom), stroke);
    canvas.drawLine(Offset(winRect.left, (winRect.top + winRect.bottom) / 2),
        Offset(winRect.right, (winRect.top + winRect.bottom) / 2), stroke);

    // ── Solar panel array — measured bbox + roof-slope angle ───────────
    if (hasSolar) {
      final double angle = math.atan2(wallTopY - roofPeakY, bodyRight - roofPeakX);
      final double arrayLen = w * 0.42;
      final double arrayThickness = h * 0.30;
      const int cols = 4;
      const int rows = 2;
      final double cellW = arrayLen / cols;
      final double cellH = arrayThickness / rows;
      const double gap = 1.6;

      final Paint panelFill = Paint()..color = _solarFill;
      final Paint panelStroke = Paint()
        ..color = _solarStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3;

      canvas.save();
      // Anchor near the measured panel bbox top-left, then follow the roof
      // slope angle from there.
      canvas.translate(w * 0.356, h * 0.104);
      canvas.rotate(angle);
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final Rect cell = Rect.fromLTWH(
              c * cellW + gap / 2, r * cellH + gap / 2, cellW - gap, cellH - gap);
          canvas.drawRect(cell, panelFill);
          canvas.drawRect(cell, panelStroke);
        }
      }
      canvas.drawRect(Rect.fromLTWH(0, 0, arrayLen, arrayThickness),
          Paint()
            ..color = _solarStroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8);
      canvas.restore();
    }

    // ── Bush (solid filled cluster, right of window) ────────────────────
    final Paint bushPaint = Paint()..color = const Color(0xFFFFFFFF);
    final Paint bushStroke = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;
    final double bushCenterX = w * 0.755;
    final double bushBaseY = groundY - h * 0.02;
    final List<MapEntry<Offset, double>> lobes = <MapEntry<Offset, double>>[
      MapEntry(Offset(bushCenterX - w * 0.028, bushBaseY - h * 0.015), w * 0.028),
      MapEntry(Offset(bushCenterX, bushBaseY - h * 0.045), w * 0.034),
      MapEntry(Offset(bushCenterX + w * 0.028, bushBaseY - h * 0.012), w * 0.026),
    ];
    Path bushPath = Path();
    for (final MapEntry<Offset, double> lobe in lobes) {
      bushPath = Path.combine(PathOperation.union, bushPath,
          Path()..addOval(Rect.fromCircle(center: lobe.key, radius: lobe.value)));
    }
    canvas.drawPath(bushPath, bushPaint);
    canvas.drawPath(bushPath, bushStroke);

    // ── Battery — measured bbox, right side ──────────────────────────────
    if (hasBattery) {
      final Rect batteryRect =
          Rect.fromLTRB(w * 0.794, h * 0.724, w * 0.862, h * 0.953);
      final RRect rrect = RRect.fromRectAndRadius(batteryRect, const Radius.circular(3));
      canvas.drawRRect(rrect, Paint()..color = _batteryFill);
      canvas.drawRRect(rrect, Paint()
        ..color = _batteryStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
      final Paint vent = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawLine(
          Offset(batteryRect.left + 4, batteryRect.top + batteryRect.height * 0.4),
          Offset(batteryRect.right - 4, batteryRect.top + batteryRect.height * 0.4),
          vent);
    }
  }

  @override
  bool shouldRepaint(covariant _HousePainter oldDelegate) {
    return oldDelegate.hasSolar != hasSolar || oldDelegate.hasBattery != hasBattery;
  }
}
