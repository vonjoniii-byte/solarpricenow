// PrimaryCta / SecondaryCta — full-width buttons matching the imported design.
// Primary = accent fill with leading icon + hover lift. Secondary = outline.
// BOOKING_URL handling lives at the call site.

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/app_theme.dart';

/// Primary accent CTA. Kept the name BookAssessmentCta for call-site stability;
/// the label and icon are parameterised.
class BookAssessmentCta extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  const BookAssessmentCta({
    super.key,
    required this.onTap,
    this.label = 'Get my tailored quote',
    this.icon = Icons.event_available_rounded,
  });

  @override
  State<BookAssessmentCta> createState() => _BookAssessmentCtaState();
}

class _BookAssessmentCtaState extends State<BookAssessmentCta> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radiusButton),
            boxShadow: shadowCta,
          ),
          child: ElevatedButton(
            onPressed: widget.onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isHovered
                  ? AppColors.primaryLight
                  : AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              minimumSize: const Size(double.infinity, 54),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusButton),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 20),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: AppTypography.buttonLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary outline CTA (e.g. "Email me this estimate").
class SecondaryCta extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  const SecondaryCta({
    super.key,
    required this.onTap,
    required this.label,
    this.icon = Icons.mail_outline_rounded,
  });

  @override
  State<SecondaryCta> createState() => _SecondaryCtaState();
}

class _SecondaryCtaState extends State<SecondaryCta> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: OutlinedButton(
          onPressed: widget.onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor:
                _isHovered ? AppColors.bg2 : AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: AppColors.borderDefault),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusButton),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
