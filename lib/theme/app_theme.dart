// AppTheme — ThemeData assembly.
// Imports the "Solar Savings Calculator" design: Space Grotesk headings (registered
// here via google_fonts), Inter body, soft cards, vivid-blue accent.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'typography.dart';

// Border radius tokens
const double radiusCard = 16.0; // sections, hero, metric cards (--card-r)
const double radiusCardSm = 12.0; // option cards, inset boxes (--card-r-sm)
const double radiusButton = 13.0; // primary buttons (--btn-r)
const double radiusInput = 12.0; // text fields
const double radiusBadge = 6.0; // PriceStubBadge
const double radiusTooltip = 8.0; // Tooltip background

// Shadow tokens (design --card-sh / --shadow-lg / --btn-sh / --sel-sh)
const List<BoxShadow> shadowCard = [
  BoxShadow(color: Color(0x0A16232D), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0F16232D), blurRadius: 26, offset: Offset(0, 10)),
];

const List<BoxShadow> shadowCardElevated = [
  BoxShadow(color: Color(0x3816232D), blurRadius: 48, offset: Offset(0, 18)),
];

const List<BoxShadow> shadowCta = [
  BoxShadow(color: Color(0x4D2E6E9E), blurRadius: 24, offset: Offset(0, 10)),
];

const List<BoxShadow> shadowSelected = [
  BoxShadow(color: Color(0x292E6E9E), blurRadius: 22, offset: Offset(0, 8)),
];

// Hero gradient — dark navy (design --hero-grad)
const LinearGradient heroGradient = LinearGradient(
  begin: Alignment(-0.6, -1),
  end: Alignment(1, 1),
  colors: [AppColors.heroGradientStart, AppColors.heroGradientEnd],
);

// Brand mark gradient (design --mark-bg)
const LinearGradient markGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.primary, AppColors.accent2],
);

class AppTheme {
  static ThemeData get light {
    final TextTheme interBase = GoogleFonts.interTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        bodySmall: TextStyle(color: AppColors.textSecondary),
        labelLarge: TextStyle(color: AppColors.textPrimary),
        labelMedium: TextStyle(color: AppColors.textSecondary),
        labelSmall: TextStyle(color: AppColors.textSecondary),
      ),
    );
    // Register Space Grotesk and apply it to the heading slots. This global
    // registration is what lets AppTypography's fontFamily:'Space Grotesk'
    // const styles resolve at runtime.
    final TextTheme headings = GoogleFonts.spaceGroteskTextTheme(interBase);
    final TextTheme textTheme = interBase.copyWith(
      displayLarge: headings.displayLarge,
      displayMedium: headings.displayMedium,
      displaySmall: headings.displaySmall,
      headlineLarge: headings.headlineLarge,
      headlineMedium: headings.headlineMedium,
      headlineSmall: headings.headlineSmall,
      titleLarge: headings.titleLarge,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: AppTypography.buttonLabel,
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bg2,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          height: 1.0,
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.borderDefault,
        thumbColor: AppColors.surface,
        overlayColor: AppColors.primary.withValues(alpha: 0.1),
        thumbShape: const _CustomThumbShape(),
        trackHeight: 10,
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.tooltipBackground,
          borderRadius: BorderRadius.circular(radiusTooltip),
        ),
        textStyle: const TextStyle(color: AppColors.tooltipText, fontSize: 13),
        constraints: const BoxConstraints(maxWidth: 260),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }
}

/// Custom slider thumb: white circle with primary border and shadow.
class _CustomThumbShape extends SliderComponentShape {
  const _CustomThumbShape();

  static const double _thumbRadius = 15.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size.fromRadius(_thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final Paint shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center + const Offset(0, 4), _thumbRadius, shadowPaint);

    final Paint fillPaint = Paint()..color = AppColors.surface;
    canvas.drawCircle(center, _thumbRadius, fillPaint);

    final Paint borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, _thumbRadius - 1.5, borderPaint);
  }
}