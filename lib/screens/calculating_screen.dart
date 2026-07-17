// CalculatingScreen (/calculating) — brief "processing" beat between Step 1
// and the results screen. Runs the real calculation immediately (it's
// synchronous and effectively instant) but holds on this screen for a short,
// deliberate moment so the instant answer feels *earned* rather than
// suspiciously immediate. The sunburst mark spins fast and settles into its
// resting position — chaos resolving into a clear answer, echoing the brand's
// "clarity, fast" promise. No new dependencies: built entirely from core
// Flutter animation APIs (AnimationController + Transform), matching the
// mark drawn in app_header's brand tile.

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../state/funnel_controller.dart';
import '../widgets/sunburst_mark.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

const List<String> kCalculatingSteps = [
  'Checking your usage…',
  'Sizing your system…',
  'Almost there…',
];

const Duration kCalculatingDuration = Duration(milliseconds: 1400);
const Duration kCalculatingTextInterval = Duration(milliseconds: 470);

class CalculatingScreen extends StatefulWidget {
  const CalculatingScreen({super.key});

  @override
  State<CalculatingScreen> createState() => _CalculatingScreenState();
}

class _CalculatingScreenState extends State<CalculatingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _spin;
  Timer? _textTimer;
  int _textIndex = 0;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Run the actual calculation now — it's synchronous and cheap. By the
    // time the animation finishes, pricedResult/recommendation are ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FunnelController>().calculate();
    });

    _controller = AnimationController(
      vsync: this,
      duration: kCalculatingDuration,
    );

    // Several fast spins decelerating to a dead stop at 0 — the "settling"
    // motion. easeOutCubic gives that natural spin-down feel.
    _spin = Tween<double>(begin: 4 * math.pi * 2, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _textTimer = Timer.periodic(kCalculatingTextInterval, (_) {
      if (!mounted) return;
      setState(() {
        _textIndex = (_textIndex + 1) % kCalculatingSteps.length;
      });
    });

    _controller
      ..addStatusListener(_onAnimationStatus)
      ..forward();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_navigated) {
      _navigated = true;
      // Replace so the back button skips this screen entirely.
      if (mounted) context.go('/result');
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _spin,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _spin.value,
                  child: child,
                );
              },
              child: const SunburstMark(size: 64),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 22,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  kCalculatingSteps[_textIndex],
                  key: ValueKey<int>(_textIndex),
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
