// PriceStubBadge — §3.5 / §2.4.3 of UX_SPEC.md
// Amber pill badge shown when price is a stub (STUB_PRICE = 0.0).

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/app_theme.dart';

class PriceStubBadge extends StatelessWidget {
  final String tooltipMessage;

  const PriceStubBadge({
    super.key,
    this.tooltipMessage =
        'Price pending — client is confirming final pricing.',
  });

  @override
  Widget build(BuildContext context) {
    final Widget badge = Container(
      decoration: BoxDecoration(
        color: AppColors.stubBadge,
        borderRadius: BorderRadius.circular(radiusBadge),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: const Text(
        '[PRICE STUB]',
        style: AppTypography.stubBadge,
      ),
    );

    return Semantics(
      label: 'Price stub — price pending, client is confirming final pricing',
      button: true,
      child: Tooltip(
        message: tooltipMessage,
        decoration: BoxDecoration(
          color: AppColors.tooltipBackground,
          borderRadius: BorderRadius.circular(radiusTooltip),
        ),
        textStyle: const TextStyle(
          color: AppColors.tooltipText,
          fontSize: 13,
        ),
        preferBelow: true,
        child: GestureDetector(
          onTap: () {
            // On mobile: show snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(tooltipMessage),
                duration: const Duration(seconds: 3),
              ),
            );
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.help,
            child: badge,
          ),
        ),
      ),
    );
  }
}
