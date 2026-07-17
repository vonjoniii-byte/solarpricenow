// AppHeader + StepProgressIndicator — shared header widgets.
// Restyled to the imported design: brand mark tile + wordmark (rating chip
// omitted — no unverified claims), and a 3-segment progress bar.

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import 'sunburst_mark.dart';

// Neutral, themeable brand wordmark (design's "Solhaus" is a placeholder).
const String kBrandName = 'Solar Price Now';
const String kBrandTagline = 'Your price. Right now.';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
        vertical: 14,
      ),
      child: Row(
        children: [
          // Brand mark — standalone sunburst, matching the brand board lockup
          const SunburstMark(size: 34),
          const SizedBox(width: 11),
          // Wordmark
          Flexible(
            child: Semantics(
              header: true,
              label: '$kBrandName — $kBrandTagline',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    kBrandName,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.h3.copyWith(
                      fontSize: 19,
                      letterSpacing: -0.3,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    kBrandTagline,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3-segment progress bar with step name + counter (design Step indicator).
class StepProgressIndicator extends StatelessWidget {
  final int currentStep; // 1..3
  final String stepName;
  static const int totalSteps = 3;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.stepName,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step $currentStep of $totalSteps: $stepName',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingH,
          vertical: 6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (int i = 1; i <= totalSteps; i++) ...[
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= currentStep
                            ? AppColors.primary
                            : AppColors.borderDefault,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  if (i < totalSteps) const SizedBox(width: 6),
                ],
              ],
            ),
            const SizedBox(height: 9),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    stepName.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.captionUppercase.copyWith(
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                Text(
                  'Step $currentStep of $totalSteps',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
