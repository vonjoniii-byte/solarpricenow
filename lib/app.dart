// App — MaterialApp.router root widget with go_router configuration.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'state/funnel_controller.dart';
import 'screens/step1_input_screen.dart';
import 'screens/calculating_screen.dart';
import 'screens/results_screen.dart';
import 'screens/lead_screen.dart';
import 'theme/app_theme.dart';

class SolarCalculatorApp extends StatefulWidget {
  const SolarCalculatorApp({super.key});

  @override
  State<SolarCalculatorApp> createState() => _SolarCalculatorAppState();
}

class _SolarCalculatorAppState extends State<SolarCalculatorApp> {
  GoRouter? _router;

  GoRouter _getRouter(FunnelController controller) {
    _router ??= GoRouter(
      initialLocation: '/',
      refreshListenable: controller,
      redirect: (BuildContext ctx, GoRouterState state) {
        final String location = state.matchedLocation;
        // /calculating needs Step 1 to have been completed (setInput called).
        if (location == '/calculating' && controller.input == null) {
          return '/';
        }
        // Results are ungated beyond that; the only guard is that a
        // calculation must exist.
        if ((location == '/result' || location == '/lead') &&
            controller.recommendation == null) {
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => _buildPage(
            state,
            const Step1InputScreen(),
            forward: false,
          ),
        ),
        GoRoute(
          path: '/calculating',
          pageBuilder: (context, state) => _buildPage(
            state,
            const CalculatingScreen(),
            forward: true,
          ),
        ),
        GoRoute(
          path: '/result',
          pageBuilder: (context, state) => _buildPage(
            state,
            const ResultsScreen(),
            forward: true,
          ),
        ),
        GoRoute(
          path: '/lead',
          pageBuilder: (context, state) => _buildPage(
            state,
            const LeadScreen(),
            forward: true,
          ),
        ),
      ],
    );
    return _router!;
  }

  CustomTransitionPage<void> _buildPage(
    GoRouterState state,
    Widget child, {
    required bool forward,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final bool disableAnimations =
            MediaQuery.of(context).disableAnimations;
        if (disableAnimations) return child;
        final Offset begin =
            forward ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
        const Offset end = Offset.zero;
        final Animatable<Offset> tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _router?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FunnelController controller =
        Provider.of<FunnelController>(context, listen: false);

    return MaterialApp.router(
      title: 'Solar Price Now',
      theme: AppTheme.light,
      routerConfig: _getRouter(controller),
      debugShowCheckedModeBanner: false,
    );
  }
}
