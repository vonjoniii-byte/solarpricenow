import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Front-on house illustration for the results card.
///
/// This is a direct 1:1 port of a reference SVG (300x200 viewBox) supplied
/// by Paul, so every coordinate/color below is intentionally hard-coded to
/// match that source exactly rather than being re-derived — do not "clean
/// up" the numbers without checking against the original SVG first.
///
/// States:
///  - hasSolar: false, hasBattery: false -> bare roof
///  - hasSolar: true,  hasBattery: false -> roof + 2 solar panels
///  - hasSolar: true,  hasBattery: true  -> roof + panels + battery
///
/// Pure CustomPainter — no extra package dependency (no flutter_svg etc.),
/// so it doesn't touch pubspec.yaml.
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

  // Reference SVG viewBox is 300x200 — every coordinate below is taken
  // directly from that source.
  static const double _viewW = 300;
  static const double _viewH = 200;

  // Colors, taken directly from the reference SVG's hex values.
  static const Color _roofFill = Color(0xFFD66B3B);
  static const Color _outline = Color(0xFF333333);
  static const Color _bodyFill = Color(0xFFF4F4F4);
  static const Color _garageFill = Color(0xFFE0E0E0);
  static const Color _garageLine = Color(0xFF777777);
  static const Color _doorFill = Color(0xFFC49A6C);
  static const Color _windowFill = Color(0xFFCFE9FF);
  static const Color _bushFill = Color(0xFF4CAF50);
  static const Color _solarFill = Color(0xFF2196F3);
  static const Color _solarStroke = Color(0xFF0D47A1);
  static const Color _batteryFill = Color(0xFF4CAF50);
  static const Color _batteryStroke = Color(0xFF2E7D32);

  @override
  void paint(Canvas canvas, Size size) {
    // Uniform scale-to-fit + center, so the 300x200 illustration keeps its
    // aspect ratio instead of stretching inside whatever box Flutter gives it.
    final double scale = math.min(size.width / _viewW, size.height / _viewH);
    final double dx = (size.width - _viewW * scale) / 2;
    final double dy = (size.height - _viewH * scale) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    // ── Roof ── polygon points="60,60 200,60 130,20"
    final Path roof = Path()
      ..moveTo(60, 60)
      ..lineTo(200, 60)
      ..lineTo(130, 20)
      ..close();
    canvas.drawPath(roof, Paint()..color = _roofFill);
    canvas.drawPath(roof, _strokePaint(_outline, 2));

    // ── House body ── rect x=60 y=60 w=140 h=90 rx=4
    final RRect body = RRect.fromRectAndRadius(
        const Rect.fromLTWH(60, 60, 140, 90), const Radius.circular(4));
    canvas.drawRRect(body, Paint()..color = _bodyFill);
    canvas.drawRRect(body, _strokePaint(_outline, 2));

    // ── Garage ── rect x=200 y=80 w=80 h=70 rx=4
    final RRect garage = RRect.fromRectAndRadius(
        const Rect.fromLTWH(200, 80, 80, 70), const Radius.circular(4));
    canvas.drawRRect(garage, Paint()..color = _garageFill);
    canvas.drawRRect(garage, _strokePaint(_outline, 2));

    // ── Garage lines ── y=95,110,125 from x=210 to x=270
    final Paint garageLinePaint = _strokePaint(_garageLine, 2);
    for (final double y in <double>[95, 110, 125]) {
      canvas.drawLine(Offset(210, y), Offset(270, y), garageLinePaint);
    }

    // ── Door ── rect x=80 y=90 w=25 h=60 rx=2 + knob circle cx=100 cy=120 r=2
    final RRect door = RRect.fromRectAndRadius(
        const Rect.fromLTWH(80, 90, 25, 60), const Radius.circular(2));
    canvas.drawRRect(door, Paint()..color = _doorFill);
    canvas.drawRRect(door, _strokePaint(_outline, 2));
    canvas.drawCircle(const Offset(100, 120), 2, Paint()..color = _outline);

    // ── Window ── rect x=120 y=85 w=40 h=30 rx=2 + cross mullions
    final RRect window = RRect.fromRectAndRadius(
        const Rect.fromLTWH(120, 85, 40, 30), const Radius.circular(2));
    canvas.drawRRect(window, Paint()..color = _windowFill);
    canvas.drawRRect(window, _strokePaint(_outline, 2));
    final Paint mullion = _strokePaint(_outline, 1);
    canvas.drawLine(const Offset(140, 85), const Offset(140, 115), mullion);
    canvas.drawLine(const Offset(120, 100), const Offset(160, 100), mullion);

    // ── Bushes ── 3 solid circles r=10 at (80,150) (100,150) (120,150)
    final Paint bushPaint = Paint()..color = _bushFill;
    for (final double cx in <double>[80, 100, 120]) {
      canvas.drawCircle(Offset(cx, 150), 10, bushPaint);
    }

    // ── Solar panels ── two rects, only when hasSolar
    if (hasSolar) {
      final Paint solarFillPaint = Paint()..color = _solarFill;
      final Paint solarStrokePaint = _strokePaint(_solarStroke, 1.5);
      for (final double x in <double>[80, 130]) {
        final RRect panel = RRect.fromRectAndRadius(
            Rect.fromLTWH(x, 35, 40, 20), const Radius.circular(2));
        canvas.drawRRect(panel, solarFillPaint);
        canvas.drawRRect(panel, solarStrokePaint);
      }
    }

    // ── Battery ── rect + white plus symbol, only when hasBattery
    if (hasBattery) {
      final RRect battery = RRect.fromRectAndRadius(
          const Rect.fromLTWH(140, 140, 40, 25), const Radius.circular(3));
      canvas.drawRRect(battery, Paint()..color = _batteryFill);
      canvas.drawRRect(battery, _strokePaint(_batteryStroke, 2));
      final Paint plus = _strokePaint(Colors.white, 2);
      canvas.drawLine(const Offset(150, 150), const Offset(170, 150), plus);
      canvas.drawLine(const Offset(160, 145), const Offset(160, 155), plus);
    }

    canvas.restore();
  }

  Paint _strokePaint(Color color, double width) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
  }

  @override
  bool shouldRepaint(covariant _HousePainter oldDelegate) {
    return oldDelegate.hasSolar != hasSolar ||
        oldDelegate.hasBattery != hasBattery;
  }
}
