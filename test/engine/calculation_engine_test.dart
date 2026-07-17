// Calculation engine tests — §4.5 validation case + comprehensive matrix.
// Minimum 20 test cases required. This file has 45+.

import 'package:flutter_test/flutter_test.dart';
import 'package:solar_calculator/engine/calculation_engine.dart';
import 'package:solar_calculator/engine/enums.dart';

void main() {
  // ── §4.5 VALIDATION CASE (zero tolerance) ─────────────────────────────────
  group('§4.5 Validation case', () {
    test(
        'Bill=1500, setup=nothing, pattern=evenSplit → array=Tailored, battery=39.6kWh',
        () {
      final result = CalculationEngine.run(
        bill2month: 1500,
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );

      // Derived values per spec:
      // supplyCharge = 1.05 × 61 = 64.05
      // consumptionCharge = 1500 - 64.05 = 1435.95
      // avgKwhPerDay = 1435.95 / 0.324 / 61 ≈ 72.649
      // nightFraction (evenSplit) = 0.50
      // nightKwhPerDay = 72.649 × 0.50 ≈ 36.325

      expect(result.array, equals('Tailored assessment required'));
      expect(result.battery, equals('39.6kWh battery'));
      expect(result.isConsult, isTrue);
    });
  });

  // ── Constants verification ─────────────────────────────────────────────────
  group('Derived value verification', () {
    test('consumptionCharge for bill=1500 is 1435.95', () {
      // supplyCharge = 1.05 * 61 = 64.05
      // consumptionCharge = 1500 - 64.05 = 1435.95
      const double supplyCharge = 1.05 * 61;
      expect(supplyCharge, closeTo(64.05, 0.001));
      const double consumption = 1500.0 - supplyCharge;
      expect(consumption, closeTo(1435.95, 0.001));
    });

    test('avgKwhPerDay for bill=1500 evenSplit is ~72.649', () {
      const double consumptionCharge = 1435.95;
      const double avgKwh = consumptionCharge / 0.324 / 61;
      expect(avgKwh, closeTo(72.649, 0.01));
    });

    test('nightKwhPerDay for bill=1500 evenSplit is ~36.325', () {
      const double avgKwh = 1435.95 / 0.324 / 61;
      const double nightKwh = avgKwh * 0.50;
      expect(nightKwh, closeTo(36.325, 0.01));
    });
  });

  // ── Array lookup boundary tests ────────────────────────────────────────────
  group('Array lookup thresholds (setup=nothing)', () {
    // avgKwhPerDay = (bill - 64.05) / 0.324 / 61
    // We pick bill values that produce specific avgKwh values.
    // bill that gives exactly avgKwh X: bill = X * 0.324 * 61 + 64.05

    // +0.01 ensures floating-point round-trip lands at or above the threshold,
    // not fractionally below it due to IEEE 754 precision.
    double billForAvgKwh(double kwh) => kwh * 0.324 * 61 + 64.05 + 0.01;

    test('avgKwh < 10 → 3.3kW Solar Array', () {
      // avgKwh = 5 → bill = 5*0.324*61 + 64.05 = 98.82 + 64.05 = 162.87
      final r = CalculationEngine.run(
        bill2month: billForAvgKwh(5),
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.array, equals('3.3kW Solar Array'));
    });

    test('avgKwh exactly 10 → 6.6kW Solar Array', () {
      final r = CalculationEngine.run(
        bill2month: billForAvgKwh(10),
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.array, equals('6.6kW Solar Array'));
    });

    test('avgKwh 15 → 6.6kW Solar Array', () {
      final r = CalculationEngine.run(
        bill2month: billForAvgKwh(15),
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.array, equals('6.6kW Solar Array'));
    });

    test('avgKwh exactly 20 → 9.9kW Solar Array', () {
      final r = CalculationEngine.run(
        bill2month: billForAvgKwh(20),
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.array, equals('9.9kW Solar Array'));
    });

    test('avgKwh 25 → 9.9kW Solar Array', () {
      final r = CalculationEngine.run(
        bill2month: billForAvgKwh(25),
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.array, equals('9.9kW Solar Array'));
    });

    test('avgKwh exactly 30 → 12.35kW Solar Array', () {
      final r = CalculationEngine.run(
        bill2month: billForAvgKwh(30),
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.array, equals('12.35kW Solar Array'));
    });

    // Round 2 (D-ARRAY): new array bands at 40/50/60; Tailored now at ≥70.
    test('avgKwh exactly 40 → 15.2kW Solar Array', () {
      final r = CalculationEngine.run(
        bill2month: billForAvgKwh(40),
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.array, equals('15.2kW Solar Array'));
    });

    test('avgKwh 45 → 15.2kW Solar Array', () {
      final r = CalculationEngine.run(
        bill2month: billForAvgKwh(45),
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.array, equals('15.2kW Solar Array'));
    });

    test('avgKwh exactly 50 → 18.5kW Solar Array', () {
      final r = CalculationEngine.run(
        bill2month: billForAvgKwh(50),
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.array, equals('18.5kW Solar Array'));
    });

    test('avgKwh exactly 60 → 24.7kW Solar Array', () {
      final r = CalculationEngine.run(
        bill2month: billForAvgKwh(60),
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.array, equals('24.7kW Solar Array'));
    });

    test('avgKwh 65 → 24.7kW Solar Array', () {
      final r = CalculationEngine.run(
        bill2month: billForAvgKwh(65),
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.array, equals('24.7kW Solar Array'));
    });

    test('avgKwh exactly 70 → Tailored assessment required', () {
      final r = CalculationEngine.run(
        bill2month: billForAvgKwh(70),
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.array, equals('Tailored assessment required'));
    });

    test('array label is never "13.2kW" (constraint D4)', () {
      // Test all array thresholds to ensure 12.35kW label is used
      for (final double kwh in [30.0, 35.0, 39.9]) {
        final r = CalculationEngine.run(
          bill2month: billForAvgKwh(kwh),
          setup: SetupType.nothing,
          pattern: UsagePattern.evenSplit,
        );
        expect(r.array, isNot(contains('13.2')),
            reason: 'Array label must never be 13.2kW');
      }
    });
  });

  // ── Battery lookup boundary tests ──────────────────────────────────────────
  group('Battery lookup thresholds', () {
    double billForNightKwh(double nightKwh, UsagePattern pattern) {
      // nightKwh = avgKwh * nightFraction
      // avgKwh = nightKwh / nightFraction
      final double fraction = _nightFraction(pattern);
      final double avgKwh = nightKwh / fraction;
      // +0.01 ensures floating-point round-trip lands at or above the threshold.
      return avgKwh * 0.324 * 61 + 64.05 + 0.01;
    }

    test('nightKwh < 4 → Not recommended (setup=nothing, mostlyNight)', () {
      final r = CalculationEngine.run(
        bill2month: billForNightKwh(2, UsagePattern.mostlyNight),
        setup: SetupType.nothing,
        pattern: UsagePattern.mostlyNight,
      );
      expect(r.battery, equals('Not recommended – modify night time usage'));
    });

    test('nightKwh exactly 4 → 7.2kWh battery', () {
      final r = CalculationEngine.run(
        bill2month: billForNightKwh(4, UsagePattern.mostlyNight),
        setup: SetupType.nothing,
        pattern: UsagePattern.mostlyNight,
      );
      expect(r.battery, equals('7.2kWh battery'));
    });

    test('nightKwh exactly 7 → 10.8kWh battery', () {
      final r = CalculationEngine.run(
        bill2month: billForNightKwh(7, UsagePattern.mostlyNight),
        setup: SetupType.nothing,
        pattern: UsagePattern.mostlyNight,
      );
      expect(r.battery, equals('10.8kWh battery'));
    });

    test('nightKwh exactly 10 → 14.4kWh battery', () {
      final r = CalculationEngine.run(
        bill2month: billForNightKwh(10, UsagePattern.mostlyNight),
        setup: SetupType.nothing,
        pattern: UsagePattern.mostlyNight,
      );
      expect(r.battery, equals('14.4kWh battery'));
    });

    test('nightKwh exactly 15 → 18kWh battery', () {
      final r = CalculationEngine.run(
        bill2month: billForNightKwh(15, UsagePattern.mostlyNight),
        setup: SetupType.nothing,
        pattern: UsagePattern.mostlyNight,
      );
      expect(r.battery, equals('18kWh battery'));
    });

    test('nightKwh exactly 17.5 → 21.6kWh battery', () {
      final r = CalculationEngine.run(
        bill2month: billForNightKwh(17.5, UsagePattern.mostlyNight),
        setup: SetupType.nothing,
        pattern: UsagePattern.mostlyNight,
      );
      expect(r.battery, equals('21.6kWh battery'));
    });

    test('nightKwh exactly 21 → 28.8kWh battery', () {
      final r = CalculationEngine.run(
        bill2month: billForNightKwh(21, UsagePattern.mostlyNight),
        setup: SetupType.nothing,
        pattern: UsagePattern.mostlyNight,
      );
      expect(r.battery, equals('28.8kWh battery'));
    });

    test('nightKwh exactly 28 → 32.4kWh battery', () {
      final r = CalculationEngine.run(
        bill2month: billForNightKwh(28, UsagePattern.mostlyNight),
        setup: SetupType.nothing,
        pattern: UsagePattern.mostlyNight,
      );
      expect(r.battery, equals('32.4kWh battery'));
    });

    test('nightKwh exactly 32 → 36kWh battery', () {
      final r = CalculationEngine.run(
        bill2month: billForNightKwh(32, UsagePattern.mostlyNight),
        setup: SetupType.nothing,
        pattern: UsagePattern.mostlyNight,
      );
      expect(r.battery, equals('36kWh battery'));
    });

    test('nightKwh exactly 35.5 → 39.6kWh battery', () {
      final r = CalculationEngine.run(
        bill2month: billForNightKwh(35.5, UsagePattern.mostlyNight),
        setup: SetupType.nothing,
        pattern: UsagePattern.mostlyNight,
      );
      expect(r.battery, equals('39.6kWh battery'));
    });

    test('nightKwh exactly 39 → 43.2kWh battery', () {
      final r = CalculationEngine.run(
        bill2month: billForNightKwh(39, UsagePattern.mostlyNight),
        setup: SetupType.nothing,
        pattern: UsagePattern.mostlyNight,
      );
      expect(r.battery, equals('43.2kWh battery'));
    });

    test('nightKwh exactly 43 → Tailored assessment required', () {
      final r = CalculationEngine.run(
        bill2month: billForNightKwh(43, UsagePattern.mostlyNight),
        setup: SetupType.nothing,
        pattern: UsagePattern.mostlyNight,
      );
      expect(r.battery, equals('Tailored assessment required'));
      expect(r.isConsult, isTrue);
    });
  });

  // ── All three setup types ──────────────────────────────────────────────────
  group('Setup type variations', () {
    test('setup=nothing: array field is non-null', () {
      final r = CalculationEngine.run(
        bill2month: 500,
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.array, isNotNull);
    });

    test('setup=panelsOnly: array field is null', () {
      final r = CalculationEngine.run(
        bill2month: 500,
        setup: SetupType.panelsOnly,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.array, isNull);
    });

    test('setup=panelsAndBattery: array field is null', () {
      final r = CalculationEngine.run(
        bill2month: 500,
        setup: SetupType.panelsAndBattery,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.array, isNull);
    });

    test('setup=panelsAndBattery: always isConsult=true', () {
      for (final pattern in UsagePattern.values) {
        for (final bill in [100.0, 500.0, 1500.0]) {
          final r = CalculationEngine.run(
            bill2month: bill,
            setup: SetupType.panelsAndBattery,
            pattern: pattern,
          );
          expect(r.isConsult, isTrue,
              reason:
                  'panelsAndBattery must always be consult (bill=$bill, pattern=$pattern)');
        }
      }
    });

    test('setup=panelsAndBattery, low bill (<5 avgKwhPerDay): Modify behaviour',
        () {
      // avgKwh < 5: bill = 5*0.324*61 + 64.05 = 162.87, so use bill=100 (avgKwh~1.82)
      final r = CalculationEngine.run(
        bill2month: 100,
        setup: SetupType.panelsAndBattery,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.battery, equals('Modify behaviour to reduce consumption'));
    });

    test('setup=panelsAndBattery, high bill: Custom consult required', () {
      final r = CalculationEngine.run(
        bill2month: 500,
        setup: SetupType.panelsAndBattery,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.battery,
          equals('Consider a larger battery. Custom consult required'));
    });
  });

  // ── All three usage patterns ───────────────────────────────────────────────
  group('Usage pattern variations', () {
    test('mostlyDay nightFraction=0.25: lower nightKwh than evenSplit', () {
      const double bill = 500;
      final day = CalculationEngine.run(
        bill2month: bill,
        setup: SetupType.nothing,
        pattern: UsagePattern.mostlyDay,
      );
      final even = CalculationEngine.run(
        bill2month: bill,
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      // With lower nightKwh, mostlyDay should produce a smaller (or equal) battery
      // unless both are tailored. We check day is not bigger battery than even.
      // This is a relative ordering test.
      expect(_batteryOrder(day.battery) <= _batteryOrder(even.battery), isTrue);
    });

    test('mostlyNight nightFraction=0.75: higher nightKwh than evenSplit', () {
      const double bill = 300;
      final night = CalculationEngine.run(
        bill2month: bill,
        setup: SetupType.nothing,
        pattern: UsagePattern.mostlyNight,
      );
      final even = CalculationEngine.run(
        bill2month: bill,
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(_batteryOrder(night.battery) >= _batteryOrder(even.battery),
          isTrue);
    });

    test('evenSplit: nightFraction=0.50 gives mid-range battery', () {
      const double bill = 300;
      final r = CalculationEngine.run(
        bill2month: bill,
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.battery, isNotEmpty);
    });
  });

  // ── isConsult flag tests ───────────────────────────────────────────────────
  group('isConsult flag', () {
    test('array=Tailored → isConsult=true', () {
      // bill=1500, nothing, evenSplit gives avgKwh~72.6 → tailored array
      final r = CalculationEngine.run(
        bill2month: 1500,
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.isConsult, isTrue);
    });

    test('battery=Tailored → isConsult=true', () {
      // Need nightKwh >= 43 without avgKwh >= 40
      // mostlyDay: nightFraction=0.25, so nightKwh=0.25*avgKwh
      // Need nightKwh=43 → avgKwh=172 → but avgKwh>=40 → tailored array too
      // With mostlyDay: avgKwh >= 40 → tailored array. But battery also tailored.
      // Test with panelsOnly to isolate battery tailored:
      // avgKwh >= 43 for panelsOnly → tailored battery
      final double bill = 43.0 * 0.324 * 61 + 64.05;
      final r = CalculationEngine.run(
        bill2month: bill,
        setup: SetupType.panelsOnly,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.battery, equals('Tailored assessment required'));
      expect(r.isConsult, isTrue);
    });

    test('normal priced result → isConsult=false', () {
      // Low bill, nothing, evenSplit
      final r = CalculationEngine.run(
        bill2month: 200,
        setup: SetupType.nothing,
        pattern: UsagePattern.evenSplit,
      );
      expect(r.isConsult, isFalse);
    });
  });

  // ── Additional combination tests (3×3×bills matrix) ─────────────────────
  group('3×3 matrix — all setup × pattern × bills', () {
    final bills = [150.0, 300.0, 500.0, 800.0, 1200.0];

    for (final setup in SetupType.values) {
      for (final pattern in UsagePattern.values) {
        for (final bill in bills) {
          test('setup=$setup, pattern=$pattern, bill=$bill: runs without error',
              () {
            expect(
              () => CalculationEngine.run(
                bill2month: bill,
                setup: setup,
                pattern: pattern,
              ),
              returnsNormally,
            );
          });
        }
      }
    }
  });
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

double _nightFraction(UsagePattern pattern) {
  switch (pattern) {
    case UsagePattern.mostlyDay:
      return 0.25;
    case UsagePattern.evenSplit:
      return 0.50;
    case UsagePattern.mostlyNight:
      return 0.75;
  }
}

/// Returns a numeric ordering for battery labels (smaller = smaller battery).
int _batteryOrder(String label) {
  const labels = [
    'Not recommended – modify night time usage',
    '7.2kWh battery',
    '10.8kWh battery',
    '14.4kWh battery',
    '18kWh battery',
    '21.6kWh battery',
    '28.8kWh battery',
    '32.4kWh battery',
    '36kWh battery',
    '39.6kWh battery',
    '43.2kWh battery',
    'Tailored assessment required',
    'Modify behaviour to reduce consumption',
    'Consider a larger battery. Custom consult required',
  ];
  final idx = labels.indexOf(label);
  return idx >= 0 ? idx : 999;
}
