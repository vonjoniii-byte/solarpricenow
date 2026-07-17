// AppColors — design tokens.
// Solar Price Now brand palette: sky blue (trust/clarity), sun amber (energy/
// optimism, nods to Perth's bright light rather than a generic solar-yellow
// cliché), and a verified-green reserved only for trust signals. Token NAMES
// are kept stable so every component inherits these values automatically.

import 'package:flutter/material.dart';

class AppColors {
  // Primary / accent — sky blue (brand board --sky #2E6E9E / --sky-deep #1B4A6B)
  static const Color primary = Color(0xFF2E6E9E); // accent
  static const Color primaryLight = Color(0xFF4B8CBE); // hover / lighter accent
  static const Color primaryTint = Color(0xFFE7F0F7); // selected card background (--sel-bg)

  // Secondary — verified/"good" green (brand board --verified #2F9E63); lock icons, trust signals
  static const Color secondary = Color(0xFF2F9E63);
  static const Color secondaryDark = Color(0xFF25824F); // hover state

  // Tertiary accent — sun amber (brand board --sun #E8A33D), used in chips/eyebrows on dark
  static const Color accent2 = Color(0xFFE8A33D);

  // Backgrounds
  static const Color background = Color(0xFFF4F1EC); // page — warm off-white, not clinical
  static const Color bg2 = Color(0xFFFAF8F4); // muted inset (--bg2)
  static const Color surface = Color(0xFFFFFFFF); // card/panel (--card)

  // Borders / lines
  static const Color borderDefault = Color(0xFFE7E1D6); // --line / --card border
  static const Color line = Color(0xFFE7E1D6); // alias for dividers
  static const Color borderFocus = Color(0xFF2E6E9E); // = primary

  // Text (ink scale)
  static const Color textPrimary = Color(0xFF16232D); // --ink (brand board)
  static const Color textSecondary = Color(0xFF4A5560);
  static const Color textMuted = Color(0xFF6B7178); // brand board --muted
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Error
  static const Color error = Color(0xFFD92D20); // --err
  static const Color errorBackground = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFCA5A5);

  // Energy / solar accent (sun motif) — matches accent2 above
  static const Color solarAmber = Color(0xFFE8A33D); // star / sun mark
  static const Color solarGold = Color(0xFFF3C778); // lighter glow

  // Hero gradient (results recommendation card) — sky blue deep, matching brand board
  static const Color heroGradientStart = Color(0xFF16232D);
  static const Color heroGradientEnd = Color(0xFF1B4A6B);

  // Stub badge (retained safety net; unreachable in normal flow)
  static const Color stubBadge = Color(0xFFE8A33D);
  static const Color stubBadgeText = Color(0xFFFFFFFF);

  // Tooltip / dark surface
  static const Color tooltipBackground = Color(0xFF1F2937);
  static const Color tooltipText = Color(0xFFFFFFFF);
}
