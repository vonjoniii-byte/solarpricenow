import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A clean, self-designed house illustration for the results card (not a
/// pixel-match of any external reference — verified via a Python/matplotlib
/// prototype before porting, to avoid the rotation/overshoot bugs from
/// earlier attempts). Solar panels and the battery are drawn in bold color
/// since they're the "included in this system" components; the house
/// structure itself (roof, walls, garage, door, window) stays in a neutral
/// palette so the colored components visually stand out.
///
/// Points for the solar panel array are computed with explicit rotation
/// matrices (not canvas.rotate/translate) so the math is easy to verify by
/// eye against the prototype rather than trusting canvas transform state.
///
/// States:
///  - hasSolar: false, hasBattery: false -> bare roof
///  - hasSolar: true,  hasBattery: false -> roof + solar panel array
///  - hasSolar: true,  hasBattery: true  -> roof + panels + battery
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

  static const Color _outline = Color(0xFF33414F);
  static const Color _roofFill = Color(0xFFEDEDED);
  static const Color _bodyFill = Color(0xFFFAFAFA);
  static const Color _garageFill = Color(0xFFE3E3E3);
  static const Color _garageLine = Color(0xFF8A8A8A);
  static const Color _doorFill = Color(0xFFD8CBB4);
  static const Color _windowFill = Color(0xFFE7EFF4);
  static const Color _bushFill = Color(0xFFB7CBAF);
  static const Color _solarFill = Color(0xFF2E7DE6);
  static const Color _solarStroke = Color(0xFF0D3C82);
  static const Color _batteryFill = Color(0xFF4CAF50);
  static const Color _batteryStroke = Color(0xFF2E7D22);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint outlinePaint = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final double groundY = h * 0.92;
    final double eaveY = h * 0.55;
    final double roofPeakY = h * 0.10;
    final double roofPeakX = w * 0.5;
    final double bodyLeft = w * 0.05;
    final double bodyRight = w * 0.95;
    final double overhang = w * 0.02;

    // ── Roof (single symmetric gable over the whole structure) ──────────
    final Path roof = Path()
      ..moveTo(bodyLeft - overhang, eaveY)
      ..lineTo(roofPeakX, roofPeakY)
      ..lineTo(bodyRight + overhang, eaveY)
      ..close();
    canvas.drawPath(roof, Paint()..color = _roofFill);
    canvas.drawPath(roof, outlinePaint);

    // ── Body + ground line ────────────────────────────────────────────
    final Rect bodyRect = Rect.fromLTRB(bodyLeft, eaveY, bodyRight, groundY);
    canvas.drawRect(bodyRect, Paint()..color = _bodyFill);
    canvas.drawRect(bodyRect, outlinePaint);
    canvas.drawLine(Offset(bodyLeft - overhang, groundY),
        Offset(bodyRight + overhang, groundY), outlinePaint);

    // ── Garage (wide, louvered, left side) ───────────────────────────────
    final Rect garageRect = Rect.fromLTRB(w * 0.05, eaveY, w * 0.40, groundY);
    canvas.drawRect(garageRect, Paint()..color = _garageFill);
    canvas.drawRect(garageRect, outlinePaint);
    final Paint garageLinePaint = Paint()
      ..color = _garageLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (int i = 1; i <= 3; i++) {
      final double y = garageRect.top + (garageRect.height / 4) * i;
      canvas.drawLine(
          Offset(garageRect.left, y), Offset(garageRect.right, y), garageLinePaint);
    }

    // ── Front door ─────────────────────────────────────────────────────
    final Rect doorRect =
        Rect.fromLTRB(w * 0.46, eaveY + h * 0.05, w * 0.53, groundY);
    canvas.drawRect(doorRect, Paint()..color = _doorFill);
    canvas.drawRect(doorRect, outlinePaint);
    canvas.drawCircle(Offset(doorRect.right - 3, (doorRect.top + doorRect.bottom) / 2),
        1.6, Paint()..color = _outline);

    // ── Window (2x2 pane grid) ────────────────────────────────────────
    final Rect winRect =
        Rect.fromLTRB(w * 0.60, eaveY + h * 0.03, w * 0.78, eaveY + h * 0.23);
    canvas.drawRect(winRect, Paint()..color = _windowFill);
    canvas.drawRect(winRect, outlinePaint);
    final Paint mullion = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset((winRect.left + winRect.right) / 2, winRect.top),
        Offset((winRect.left + winRect.right) / 2, winRect.bottom), mullion);
    canvas.drawLine(Offset(winRect.left, (winRect.top + winRect.bottom) / 2),
        Offset(winRect.right, (winRect.top + winRect.bottom) / 2), mullion);

    // ── Solar panels — explicit rotation matrix, anchored + confined to
    // the right roof slope so they can never overshoot past the eave ──────
    if (hasSolar) {
      final double dx = (bodyRight + overhang) - roofPeakX;
      final double dy = eaveY - roofPeakY;
      final double slopeLen = math.sqrt(dx * dx + dy * dy);
      final double angle = math.atan2(dy, dx);
      final double ca = math.cos(angle);
      final double sa = math.sin(angle);

      final double insetStart = slopeLen * 0.18;
      final double arrayLen = slopeLen * 0.55;
      final double arrayThickness = (eaveY - roofPeakY) * 0.55;
      const int cols = 4;
      const int rows = 2;
      final double cellW = arrayLen / cols;
      final double cellH = arrayThickness / rows;
      const double gap = 1.6;

      // Anchor point on the slope, then lifted outward (up off the roof
      // surface) along the slope's outward normal.
      final double ox = roofPeakX + ca * insetStart;
      final double oy = roofPeakY + sa * insetStart;
      final double px = sa; // outward normal x
      final double py = -ca; // outward normal y
      final double lift = arrayThickness + h * 0.01;
      final double ox2 = ox + px * lift;
      final double oy2 = oy + py * lift;

      Offset toGlobal(double lx, double ly) =>
          Offset(ox2 + ca * lx - sa * ly, oy2 + sa * lx + ca * ly);

      final Paint panelFill = Paint()..color = _solarFill;
      final Paint panelStroke = Paint()
        ..color = _solarStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1;

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final double lx0 = c * cellW + gap / 2;
          final double ly0 = r * cellH + gap / 2;
          final double lx1 = (c + 1) * cellW - gap / 2;
          final double ly1 = (r + 1) * cellH - gap / 2;
          final Path cell = Path()
            ..moveTo(toGlobal(lx0, ly0).dx, toGlobal(lx0, ly0).dy)
            ..lineTo(toGlobal(lx1, ly0).dx, toGlobal(lx1, ly0).dy)
            ..lineTo(toGlobal(lx1, ly1).dx, toGlobal(lx1, ly1).dy)
            ..lineTo(toGlobal(lx0, ly1).dx, toGlobal(lx0, ly1).dy)
            ..close();
          canvas.drawPath(cell, panelFill);
          canvas.drawPath(cell, panelStroke);
        }
      }
      final Path frame = Path()
        ..moveTo(toGlobal(0, 0).dx, toGlobal(0, 0).dy)
        ..lineTo(toGlobal(arrayLen, 0).dx, toGlobal(arrayLen, 0).dy)
        ..lineTo(toGlobal(arrayLen, arrayThickness).dx,
            toGlobal(arrayLen, arrayThickness).dy)
        ..lineTo(toGlobal(0, arrayThickness).dx, toGlobal(0, arrayThickness).dy)
        ..close();
      canvas.drawPath(
          frame,
          Paint()
            ..color = _solarStroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6);
    }

    // ── Bush (neutral decoration, always shown) ──────────────────────────
    final Paint bushPaint = Paint()..color = _bushFill;
    final double bx = w * 0.83;
    final List<MapEntry<Offset, double>> lobes = <MapEntry<Offset, double>>[
      MapEntry(Offset(bx - w * 0.019, groundY - h * 0.033), w * 0.022),
      MapEntry(Offset(bx, groundY - h * 0.078), w * 0.028),
      MapEntry(Offset(bx + w * 0.019, groundY - h * 0.028), w * 0.020),
    ];
    for (final MapEntry<Offset, double> lobe in lobes) {
      canvas.drawCircle(lobe.key, lobe.value, bushPaint);
      canvas.drawCircle(lobe.key, lobe.value, outlinePaint);
    }

    // ── Battery — standing on the ground, right side ─────────────────────
    if (hasBattery) {
      final Rect batteryRect =
          Rect.fromLTRB(w * 0.88, groundY - h * 0.22, w * 0.95, groundY);
      final RRect rrect =
          RRect.fromRectAndRadius(batteryRect, const Radius.circular(3));
      canvas.drawRRect(rrect, Paint()..color = _batteryFill);
      canvas.drawRRect(
          rrect,
          Paint()
            ..color = _batteryStroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8);
      final Paint vent = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      final double vy = batteryRect.top + batteryRect.height * 0.4;
      canvas.drawLine(
          Offset(batteryRect.left + 4, vy), Offset(batteryRect.right - 4, vy), vent);
    }
  }

  @override
  bool shouldRepaint(covariant _HousePainter oldDelegate) {
    return oldDelegate.hasSolar != hasSolar || oldDelegate.hasBattery != hasBattery;
  }
}
