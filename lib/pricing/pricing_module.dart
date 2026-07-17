// PricingModule — §4.6 config-type + combinations table lookup.
// Pure Dart — NO Flutter imports.

import '../engine/enums.dart';
import '../models/recommendation_result.dart';
import '../models/priced_result.dart';
import 'combinations_table.dart';
import 'savings_calculator.dart';

class PricingModule {
  /// Look up the price for a given recommendation result.
  ///
  /// Returns [PricedResult] when a producible combination is found (including
  /// stub entries). Returns null when:
  ///   - result.isConsult == true, OR
  ///   - the (array, battery) key is not in the combinations table.
  static PricedResult? lookup({
    required RecommendationResult result,
    required SetupType setup,
    required double bill2month,
  }) {
    // Consult path → no price figures
    if (result.isConsult) return null;

    // Determine the key for the combinations table
    final (String, String) key;

    switch (setup) {
      case SetupType.nothing:
        // Array + battery combination
        final String arrayLabel = result.array ?? '';
        key = (arrayLabel, result.battery);

      case SetupType.panelsOnly:
        // Battery-only; use empty string sentinel for array
        key = ('', result.battery);

      case SetupType.panelsAndBattery:
        // Always consult — should have been caught above, but guard anyway
        return null;
    }

    // Look up in combinations table
    final double? price = combinationsTable[key];
    if (price == null) {
      // Combination not in table → treat as consult
      return null;
    }

    final bool isStub = price == stubPrice;

    // Compute savings even for stub prices (the formula is independent of price)
    final SavingsResult savings = SavingsCalculator.compute(
      bill2month: bill2month,
      totalSystemCost: price,
    );

    return PricedResult(
      price: price,
      annualSaving: savings.annualSaving,
      estBillAfter2mo: savings.estBillAfter2mo,
      paybackYears: savings.paybackYears,
      isStub: isStub,
    );
  }
}
