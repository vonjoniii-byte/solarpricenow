// AppTypography — text styles.
// Headings & numerals: Space Grotesk. Body: Inter. Both via google_fonts
// (registered in AppTheme so these fontFamily references resolve at runtime).

import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  static const String fontFamily = 'Inter'; // body
  static const String headFont = 'Space Grotesk'; // headings
  static const String numFont = 'Space Grotesk'; // big numerals

  // Display — step headlines ("See what solar could save you.")
  static const TextStyle display = TextStyle(
    fontFamily: headFont,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.08,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );

  // H1 — screen headlines, system recommendation value
  static const TextStyle h1 = TextStyle(
    fontFamily: headFont,
    fontSize: 27,
    fontWeight: FontWeight.w800,
    height: 1.1,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
  );

  // H2 — section headings, hero label
  static const TextStyle h2 = TextStyle(
    fontFamily: headFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  // H3 — sub-section headings (question titles, card titles)
  static const TextStyle h3 = TextStyle(
    fontFamily: headFont,
    fontSize: 16.5,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  // Big numeral — metric card values, bill display
  static const TextStyle metricValue = TextStyle(
    fontFamily: numFont,
    fontSize: 27,
    fontWeight: FontWeight.w800,
    height: 1.0,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );

  // Body — standard paragraph text
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  // Body semibold — field labels, card titles
  static const TextStyle bodySemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  // Body small — back link, helper text
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // Caption — metric labels, field help text
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // Caption uppercase — eyebrow labels ("QUESTION 1", "STEP X OF 3")
  static const TextStyle captionUppercase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 1.3,
    color: AppColors.primary,
  );

  // Button label
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.2,
  );

  // Stub badge text
  static const TextStyle stubBadge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.5,
    color: AppColors.stubBadgeText,
  );
}
