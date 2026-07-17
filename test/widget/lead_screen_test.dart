// Widget tests for the mode-aware lead capture screen (book | quote).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:solar_calculator/screens/lead_screen.dart';
import 'package:solar_calculator/state/funnel_controller.dart';
import 'package:solar_calculator/engine/enums.dart';
import 'package:solar_calculator/theme/app_theme.dart';

FunnelController _seeded(String mode) {
  final c = FunnelController();
  c.setInput(
    bill2month: 500,
    setup: SetupType.nothing,
    pattern: UsagePattern.evenSplit,
  );
  c.calculate();
  c.setLeadMode(mode);
  return c;
}

Widget _harness(FunnelController c) {
  return ChangeNotifierProvider<FunnelController>.value(
    value: c,
    child: MaterialApp(theme: AppTheme.light, home: const LeadScreen()),
  );
}

void main() {
  group('Lead screen', () {
    testWidgets('book mode shows phone-consultation title + form + Request my call',
        (tester) async {
      await tester.pumpWidget(_harness(_seeded('book')));
      await tester.pumpAndSettle();

      expect(find.text('Book your free phone consultation'), findsOneWidget);
      expect(find.text('Request my call'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets); // 4 fields + honeypot
    });

    testWidgets('quote mode shows tailored-quote title + Send my tailored quote',
        (tester) async {
      await tester.pumpWidget(_harness(_seeded('quote')));
      await tester.pumpAndSettle();

      expect(find.text('Get your tailored quote'), findsOneWidget);
      expect(find.text('Send my tailored quote'), findsOneWidget);
      expect(find.text('Book your free phone consultation'), findsNothing);
    });
  });
}
