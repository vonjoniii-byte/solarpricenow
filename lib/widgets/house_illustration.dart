import 'package:flutter/material.dart';

/// House illustration for the results card.
///
/// This is a thin wrapper around three static PNG assets (cropped directly
/// from Paul's original reference image, one per system state) rather than
/// a hand-drawn CustomPainter — after several rounds of coordinate/rotation
/// issues trying to redraw it procedurally, using the real reference image
/// as static assets is simpler and guarantees a pixel-perfect match.
///
/// Requires these entries under `flutter: assets:` in pubspec.yaml:
///   - assets/images/house_bare.png
///   - assets/images/house_solar.png
///   - assets/images/house_solar_battery.png
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
    final String assetPath = !hasSolar
        ? 'assets/images/house_bare.png'
        : hasBattery
            ? 'assets/images/house_solar_battery.png'
            : 'assets/images/house_solar.png';

    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
    );
  }
}
