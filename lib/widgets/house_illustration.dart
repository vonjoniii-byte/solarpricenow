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