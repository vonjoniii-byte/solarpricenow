// TrustSection — themeable social-proof / credentials block.
//
// The imported design includes a reviews + credentials block ("4.9 from 382
// reviews", "CEC accredited", "25-year warranty", "12 years in business"). Those
// are placeholder marketing claims and MUST NOT ship unverified on a live
// lead-gen site. Per the client decision, this slot renders NOTHING until real,
// verified values are supplied here — then the layout below activates.
//
// To enable later: populate [kTrustRating]/[kTrustReviewCount] with confirmed
// figures and [kTrustStats] with confirmed credentials. The widget self-hides
// while they are empty.

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/app_theme.dart';

/// Confirmed average rating, e.g. '4.9'. Empty = hidden.
const String kTrustRating = '';

/// Confirmed verified-review count, e.g. '382'. Empty = hidden.
const String kTrustReviewCount = '';

/// Confirmed credentials. Each: (icon, label). Empty list = hidden.
const List<(IconData, String)> kTrustStats = <(IconData, String)>[];

class TrustSection extends StatelessWidget {
  const TrustSection({super.key});

  static bool get _hasContent =>
      kTrustRating.isNotEmpty ||
      kTrustReviewCount.isNotEmpty ||
      kTrustStats.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: shadowCard,
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kTrustRating.isNotEmpty || kTrustReviewCount.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.solarAmber, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    kTrustRating,
                    style: AppTypography.bodySemibold,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      kTrustReviewCount.isNotEmpty
                          ? 'from $kTrustReviewCount verified reviews'
                          : 'verified reviews',
                      style: AppTypography.caption,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.verified_rounded,
                      color: AppColors.secondary, size: 28),
                ],
              ),
            ),
          if (kTrustStats.isNotEmpty)
            Row(
              children: [
                for (final (icon, label) in kTrustStats)
                  Expanded(
                    child: Column(
                      children: [
                        Icon(icon, color: AppColors.primary, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
