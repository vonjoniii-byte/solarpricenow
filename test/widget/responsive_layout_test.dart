// Responsive smoke tests (Round 2, WI-1) — no overflow from 320px up.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:solar_calculator/screens/results_screen.dart';
import 'package:solar_calculator/screens/step1_input_screen.dart';
import 'package:solar_calculator/screens/lead_screen.dart';
import 'package:solar_calculator/state/funnel_controller.dart';
import 'package:solar_calculator/engine/enums.dart';
import 'package:solar_calculator/theme/app_theme.dart';

FunnelController _seeded() {
  final c = FunnelController();
  c.setInput(
    bill2month: 500,
    setup: SetupType.nothing,
    pattern: UsagePattern.evenSplit,
  );
  c.calculate();
  return c;
}

Widget _harness(FunnelController c, Widget screen) {
  return ChangeNotifierProvider<FunnelController>.value(
    value: c,
    child: MaterialApp(theme: AppTheme.light, home: screen),
  );
}

Future<void> _pumpAt(WidgetTester tester, Size size, Widget child) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(child);
  await tester.pumpAndSettle();
}

void main() {
  const widths = <double>[320, 375, 768, 1024, 1440];

  group('No overflow across breakpoints', () {
    for (final w in widths) {
      testWidgets('results screen at ${w.toInt()}px', (tester) async {
        await _pumpAt(
          tester,
          Size(w, 900),
          _harness(_seeded(), const ResultsScreen()),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('input screen at ${w.toInt()}px', (tester) async {
        await _pumpAt(
          tester,
          Size(w, 900),
          _harness(FunnelController(), const Step1InputScreen()),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('lead screen at ${w.toInt()}px', (tester) async {
        await _pumpAt(
          tester,
          Size(w, 900),
          _harness(_seeded(), const LeadScreen()),
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
