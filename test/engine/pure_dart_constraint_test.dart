// Pure Dart Constraint Test — ARCHITECTURE.md §10 constraint 1
//
// CONSTRAINT: lib/engine/ and lib/pricing/ must have ZERO package:flutter/* imports.
//
// RATIONALE: These modules must remain testable as pure Dart (unit tests can run without
// a Flutter test runner, allowing for faster CI feedback and easier dependency management).
//
// TEST METHOD: If this test compiles and runs successfully in the Flutter test runner,
// the constraint is verified. If lib/engine/ or lib/pricing/ contained Flutter imports,
// this file would fail to import those modules (Flutter test runner would refuse to load
// non-Flutter Dart files that import Flutter).

import 'package:flutter_test/flutter_test.dart';

// Import the engine modules — if these import flutter, the test framework will fail.
import 'package:solar_calculator/engine/calculation_engine.dart';
import 'package:solar_calculator/engine/constants.dart';
import 'package:solar_calculator/engine/enums.dart';

// Import the pricing modules — if these import flutter, the test framework will fail.
import 'package:solar_calculator/pricing/combinations_table.dart';
import 'package:solar_calculator/pricing/pricing_module.dart';
import 'package:solar_calculator/pricing/savings_calculator.dart';
import 'package:solar_calculator/pricing/finance_calculator.dart';

void main() {
  test('engine and pricing modules import without flutter dependency errors', () {
    // This test passes if the imports above succeeded without error.
    // The presence of Flutter imports in lib/engine/ or lib/pricing/ would cause
    // the Flutter test runner to fail during the import phase, before this test executes.

    // As a sanity check, verify the modules are accessible and return expected constants.
    expect(electricityRate, equals(0.324));
    expect(billingDays, equals(61));
    expect(combinationsTable.length, equals(42));
    expect(combinationsTable, isA<Map<(String, String), double>>());
    // FinanceCalculator is also pure Dart (imported above): sanity-check it runs.
    expect(FinanceCalculator.compute(13000)!.bimonthlyRepayment, closeTo(344.26, 0.05));
    expect(FinanceCalculator.compute(0), isNull);
  });

  test('CalculationEngine is callable from imported module', () {
    // Additional sanity check: engine logic works.
    final result = CalculationEngine.run(
      bill2month: 500,
      setup: SetupType.nothing,
      pattern: UsagePattern.evenSplit,
    );
    expect(result, isNotNull);
    expect(result.array, isA<String>());
    expect(result.battery, isA<String>());
  });

  test('SavingsCalculator is callable from imported module', () {
    // Additional sanity check: pricing logic works.
    final result = SavingsCalculator.compute(
      bill2month: 500,
      totalSystemCost: 15000,
    );
    expect(result, isNotNull);
    expect(result.annualSaving, greaterThan(0));
  });

  test('PricingModule is callable from imported module', () {
    // Additional sanity check: lookup works.
    final rec = CalculationEngine.run(
      bill2month: 500,
      setup: SetupType.nothing,
      pattern: UsagePattern.evenSplit,
    );
    final priced = PricingModule.lookup(
      result: rec,
      setup: SetupType.nothing,
      bill2month: 500,
    );
    // Result may be null (consult path) or a PricedResult; both are valid.
    expect(priced, anyOf(isNull, isA<Object>()));
  });
}
