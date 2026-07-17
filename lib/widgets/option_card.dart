// OptionCard — §3.2 of UX_SPEC.md
// Reusable tappable card for setup type and usage pattern selection.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/app_theme.dart';

class OptionCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String semanticsLabel;

  const OptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.semanticsLabel,
  });

  @override
  State<OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<OptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    final bool disableAnimations =
        MediaQuery.of(context).disableAnimations;
    if (!disableAnimations) {
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    _scaleController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.isSelected;

    final Widget iconTile = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: sel ? AppColors.primary : AppColors.bg2,
        borderRadius: BorderRadius.circular(radiusCardSm),
      ),
      child: Icon(
        widget.icon,
        size: 24,
        color: sel ? AppColors.textOnPrimary : AppColors.textSecondary,
      ),
    );

    final Widget cardContent = Container(
      decoration: BoxDecoration(
        color: sel ? AppColors.primaryTint : AppColors.surface,
        borderRadius: BorderRadius.circular(radiusCardSm),
        border: Border.all(
          color: (sel || _isFocused)
              ? AppColors.primary
              : AppColors.borderDefault,
          width: (sel || _isFocused) ? 2.0 : 1.5,
        ),
        boxShadow: sel ? shadowSelected : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        children: [
          iconTile,
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Animated check circle
          AnimatedScale(
            scale: sel ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check,
                  color: AppColors.textOnPrimary, size: 16),
            ),
          ),
          if (_isFocused)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.circle, size: 0),
            ),
        ],
      ),
    );

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: widget.isSelected,
      label: widget.semanticsLabel,
      button: true,
      child: Focus(
        onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            widget.onTap();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: cardContent,
            ),
          ),
        ),
      ),
    );
  }
}
