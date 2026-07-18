// Widget tests for the redesigned ungated results screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:solar_calculator/screens/results_screen.dart';
import 'package:solar_calculator/state/funnel_controller.dart';
import 'package:solar_calculator/engine/enums.dart';
import 'package:solar_calculator/pricing/finance_calculator.dart';
import 'package:solar_calculator/theme/app_theme.dart';

FunnelController _seeded({
  required double bill,
  required SetupType setup,
  required UsagePattern pattern,
}) {
  final c = FunnelController();
  c.setInput(bill2month: bill, setup: setup, pattern: pattern);
  c.calculate();
  return c;
}

Widget _harness(FunnelController controller) {
  return ChangeNotifierProvider<FunnelController>.value(
    value: controller,
    child: MaterialApp(theme: AppTheme.light, home: const ResultsScreen()),
  );
}

void main() {
  group('Redesigned results', () {
    testWidgets('priced result shows figures, % off chip, caveat, CTA, no form',
        (tester) async {
      // bill=500, nothing, evenSplit → 9.9kW + 14.4kWh → priced $15,504.
      final c = _seeded(
        bill: 500,
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      await tester.pumpWidget(_harness(c));
      await tester.pumpAndSettle();

      // Real price + sentence-case metric labels.
      expect(find.text('\$15,504'), findsOneWidget);
      expect(find.text('Annual savings'), findsOneWidget);
      expect(find.text('Payback period'), findsOneWidget);

      // Combined card shows BOTH the annual saving and the bill-after figure.
      expect(find.text('BILL AFTER'), findsOneWidget);
      expect(find.text('\$64 / 2 months'), findsOneWidget);

      // Financing card: Brighte HEUF bi-monthly repayment for P=$15,504.
      final expectedFinance =
          '\$${FinanceCalculator.compute(15504)!.bimonthlyRepayment.round()}';
      expect(find.text('Finance from'), findsOneWidget);
      expect(find.text(expectedFinance), findsOneWidget);
      expect(find.textContaining('Brighte'), findsOneWidget);

      // Hero "% off your bill" chip (derived from real bill-after).
      expect(find.textContaining('% off your bill'), findsOneWidget);

      // Estimate caveat present with figures.
      expect(find.textContaining('Estimate only'), findsOneWidget);

      // Booking CTA present, no personal-details fields on this screen.
      expect(find.text('Book a free phone consultation'), findsOneWidget);
      expect(find.text('Email me this estimate'), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
    });

    testWidgets('consult result shows tailored copy + booking, no figures',
        (tester) async {
      // bill=1500, nothing, evenSplit → avgKwh≈72.6 ≥70 → Tailored (consult).
      final c = _seeded(
        bill: 1500,
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      await tester.pumpWidget(_harness(c));
      await tester.pumpAndSettle();

      expect(find.text('A tailored assessment is recommended'), findsOneWidget);
      expect(find.text('Book a free phone consultation'), findsOneWidget);
      // No priced metric cards / no % off chip in the consult variant.
      expect(find.text('Annual savings'), findsNothing);
      expect(find.textContaining('% off your bill'), findsNothing);
    });
  });
}
