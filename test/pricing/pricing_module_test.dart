// PricingModule tests — all 42 producible configurations (Round 2, real prices).

import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_calculator/engine/enums.dart';
import 'package:solar_calculator/models/recommendation_result.dart';
import 'package:solar_calculator/pricing/pricing_module.dart';
import 'package:solar_calculator/pricing/combinations_table.dart';

const String _notRecommended = 'Not recommended – modify night time usage';

void main() {
  group('PricingModule', () {
    test('isConsult=true → returns null', () {
      const result = RecommendationResult(
        array: null,
        battery: 'Tailored assessment required',
        isConsult: true,
        consultReason: 'test',
      );
      final priced = PricingModule.lookup(
        result: result,
        setup: SetupType.nothing,
        bill2month: 500,
      );
      expect(priced, isNull);
    });

    test('panelsAndBattery always returns null (always consult)', () {
      const result = RecommendationResult(
        array: null,
        battery: 'Consider a larger battery. Custom consult required',
        isConsult: true,
      );
      final priced = PricingModule.lookup(
        result: result,
        setup: SetupType.panelsAndBattery,
        bill2month: 500,
      );
      expect(priced, isNull);
    });

    // Every producible config in the table must price out with a real (non-stub)
    // value. Iterating the table keeps this test in lock-step with the data.
    group('All 42 producible configs price with real values (isStub=false)', () {
      combinationsTable.forEach((key, price) {
        final (arrayLabel, batteryLabel) = key;
        // Reconstruct the setup + RecommendationResult that produces this key.
        final SetupType setup;
        final String? array;
        if (arrayLabel.isEmpty) {
          // Battery-only → panelsOnly path (array sentinel = "")
          setup = SetupType.panelsOnly;
          array = null;
        } else {
          setup = SetupType.nothing;
          array = arrayLabel;
        }

        test('($arrayLabel, $batteryLabel) → priced \$$price, isStub=false', () {
          final result = RecommendationResult(
            array: array,
            battery: batteryLabel,
            isConsult: false,
          );
          final priced = PricingModule.lookup(
            result: result,
            setup: setup,
            bill2month: 500,
          );
          expect(priced, isNotNull,
              reason: 'Combination ($arrayLabel, $batteryLabel) not priced');
          expect(priced!.price, equals(price));
          expect(priced.isStub, isFalse,
              reason: 'All Round 2 producible configs carry a real price');
        });
      });
    });

    test('Total combinations table has exactly 42 entries', () {
      expect(combinationsTable.length, equals(42));
    });

    test('Composition: 2 array-only + 30 array+battery + 10 battery-only', () {
      final arrayOnly = combinationsTable.keys
          .where((k) => k.$1.isNotEmpty && k.$2 == _notRecommended)
          .length;
      final batteryOnly =
          combinationsTable.keys.where((k) => k.$1.isEmpty).length;
      final arrayPlusBattery = combinationsTable.keys
          .where((k) => k.$1.isNotEmpty && k.$2 != _notRecommended)
          .length;
      expect(arrayOnly, equals(2));
      expect(arrayPlusBattery, equals(30));
      expect(batteryOnly, equals(10));
    });

    test('New arrays are present and priced', () {
      expect(combinationsTable[('15.2kW Solar Array', '14.4kWh battery')],
          equals(19798));
      expect(combinationsTable[('18.5kW Solar Array', '43.2kWh battery')],
          equals(33696));
      expect(combinationsTable[('24.7kW Solar Array', '18kWh battery')],
          equals(25735));
    });

    test('Non-existent combination returns null', () {
      // (3.3kW, 36kWh) is NOT in the table — nightKwh would need to be ≥32
      // but 3.3kW means avgKwh<10, even mostlyNight max nightKwh=7.5 < 32
      const result = RecommendationResult(
        array: '3.3kW Solar Array',
        battery: '36kWh battery',
        isConsult: false,
      );
      final priced = PricingModule.lookup(
        result: result,
        setup: SetupType.nothing,
        bill2month: 500,
      );
      expect(priced, isNull);
    });

    test('PricedResult has savings computed from bill', () {
      const result = RecommendationResult(
        array: '6.6kW Solar Array',
        battery: _notRecommended,
        isConsult: false,
      );
      final priced = PricingModule.lookup(
        result: result,
        setup: SetupType.nothing,
        bill2month: 500,
      );
      expect(priced, isNotNull);
      // annualSaving = (500 - 64.05) * 6 = 2615.70 (Year-1, unchanged)
      expect(priced!.annualSaving, closeTo(2615.70, 0.01));
      // Escalated payback (4.5%/yr): ln(1 + 0.045*6835/2615.70)/ln(1.045) ≈ 2.53.
      expect(
        priced.paybackYears,
        closeTo(math.log(1 + 0.045 * 6835 / 2615.70) / math.log(1.045), 0.01),
      );
    });

    test('9.9kW + Not recommended is NOT in table (unreachable combination)',
        () {
      expect(
        combinationsTable.containsKey(('9.9kW Solar Array', _notRecommended)),
        isFalse,
      );
    });

    test('12.35kW + Not recommended is NOT in table (unreachable combination)',
        () {
      expect(
        combinationsTable.containsKey(('12.35kW Solar Array', _notRecommended)),
        isFalse,
      );
    });
  });
}
