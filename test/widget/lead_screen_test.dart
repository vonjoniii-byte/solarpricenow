// Widget tests for the lead capture screen (book-a-call only — quote mode
// was removed since it was unreachable once the "Email me this estimate"
// secondary CTA was dropped from the results screen).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
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

Widget _harness(FunnelController c) {
  return ChangeNotifierProvider<FunnelController>.value(
    value: c,
    child: MaterialApp(theme: AppTheme.light, home: const LeadScreen()),
  );
}

void main() {
  group('Lead screen', () {
    testWidgets('shows phone-consultation title + form + Request my call',
        (tester) async {
      await tester.pumpWidget(_harness(_seeded()));
      await tester.pumpAndSettle();

      expect(find.text('Book your free phone consultation'), findsOneWidget);
      expect(find.text('Request my call'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets); // 4 fields + honeypot
    });
  });
}
