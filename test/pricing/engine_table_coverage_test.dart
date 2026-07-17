// Engine-output ⇆ pricing-table coverage (Round 2).
//
// The pricing table is keyed on the exact strings the engine emits. If the
// engine ever produces a non-consult (array, battery) pairing that has no key
// in combinationsTable, the customer silently drops to "no price". This test
// sweeps the full input space and asserts every non-consult engine output is
// priced — it is the backstop that catches label drift (e.g. 15.4 vs 14.4) and
// any missing producible pairing.

import 'package:flutter_test/flutter_test.dart';
import 'package:solar_calculator/engine/calculation_engine.dart';
import 'package:solar_calculator/engine/enums.dart';
import 'package:solar_calculator/pricing/pricing_module.dart';

void main() {
  group('Engine output is always priced when not a consult', () {
    // Sweep a fine grid of bills across every priced array band (avgKwh up to
    // ~70 → Tailored at bill ≈ 1447) plus a margin into the consult zone.
    final patterns = UsagePattern.values;
    // panelsAndBattery is always consult; nothing + panelsOnly are the priced paths.
    final setups = [SetupType.nothing, SetupType.panelsOnly];

    test('every non-consult result across the input sweep has a price', () {
      final unmatched = <String>[];
      var nonConsultCount = 0;

      for (final setup in setups) {
        for (final pattern in patterns) {
          for (int billCents = 7000; billCents <= 200000; billCents += 100) {
            final double bill = billCents / 100.0;
            final rec = CalculationEngine.run(
              bill2month: bill,
              setup: setup,
              pattern: pattern,
            );
            if (rec.isConsult) continue;

            // Legitimately unpriced, non-consult outcome: a panelsOnly customer
            // (already has panels) whose night usage is too low to warrant any
            // battery → "Not recommended" with nothing to sell. The screen
            // renders the recommendation + CTA with no figures (priced == null
            // is handled). Every OTHER non-consult result must carry a price —
            // that is what guards against engine/table label drift.
            if (setup == SetupType.panelsOnly &&
                rec.battery == 'Not recommended – modify night time usage') {
              continue;
            }
            nonConsultCount++;

            final priced = PricingModule.lookup(
              result: rec,
              setup: setup,
              bill2month: bill,
            );
            if (priced == null) {
              unmatched.add(
                  'setup=$setup pattern=$pattern bill=$bill → '
                  '(${rec.array ?? '<null>'}, ${rec.battery})');
            }
          }
        }
      }

      expect(nonConsultCount, greaterThan(0),
          reason: 'sweep should produce priced results');
      expect(unmatched, isEmpty,
          reason: 'Unpriced non-consult outputs (table/engine key drift):\n'
              '${unmatched.toSet().take(20).join('\n')}');
    });

    test('the new array bands are actually reached and priced', () {
      final reachedArrays = <String>{};
      for (final pattern in patterns) {
        for (int billCents = 7000; billCents <= 200000; billCents += 100) {
          final double bill = billCents / 100.0;
          final rec = CalculationEngine.run(
            bill2month: bill,
            setup: SetupType.nothing,
            pattern: pattern,
          );
          if (!rec.isConsult && rec.array != null) {
            reachedArrays.add(rec.array!);
          }
        }
      }
      expect(reachedArrays, containsAll(<String>{
        '15.2kW Solar Array',
        '18.5kW Solar Array',
        '24.7kW Solar Array',
      }));
    });
  });
}
