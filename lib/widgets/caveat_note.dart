// CaveatNote — estimate disclaimer shown wherever a price/saving/payback figure
// appears. Styled as the imported design's info box (info icon + muted copy in
// a soft inset), with an expandable detail for the full assumptions.

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/app_theme.dart';

const String kCaveatShort =
    'Estimate only — based on your answers and typical Australian usage and '
    'pricing. Your phone consultation confirms the exact figures.';

const String kCaveatDetail =
    'Final pricing and system specifics are confirmed at a free phone '
    'consultation and may change based on your property and confirmation of '
    'your details. Savings and payback are estimates based on your stated '
    'electricity bill using a (bill − supply charge) × 6 model, and assume the '
    'recommended system offsets your usage — your actual results will vary.';

class CaveatNote extends StatefulWidget {
  const CaveatNote({super.key});

  @override
  State<CaveatNote> createState() => _CaveatNoteState();
}

class _CaveatNoteState extends State<CaveatNote> {
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(radiusCardSm),
        border: Border.all(color: AppColors.borderDefault),
      ),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Semantics(
        container: true,
        label: '$kCaveatShort $kCaveatDetail',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    kCaveatShort,
                    style: AppTypography.caption.copyWith(height: 1.55),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 27),
              child: Semantics(
                button: true,
                label:
                    _expanded ? 'Hide estimate details' : 'Show estimate details',
                child: InkWell(
                  onTap: _toggle,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _expanded ? 'Hide details' : 'How we estimate',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.only(left: 27, right: 2, bottom: 2),
                child: Text(
                  kCaveatDetail,
                  style: AppTypography.caption.copyWith(height: 1.55),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
