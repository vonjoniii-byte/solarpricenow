// FunnelController — ChangeNotifier for 3-step funnel state.
// Drives Provider state management across screens.

import 'package:flutter/foundation.dart';
import '../engine/calculation_engine.dart';
import '../engine/enums.dart';
import '../models/calculator_input.dart';
import '../models/recommendation_result.dart';
import '../models/priced_result.dart';
import '../pricing/pricing_module.dart';

class FunnelController extends ChangeNotifier {
  CalculatorInput? input;
  RecommendationResult? recommendation;
  PricedResult? pricedResult;

  // ---------------------------------------------------------------------------
  // Step 1 — set inputs
  // ---------------------------------------------------------------------------

  void setInput({
    required double bill2month,
    required SetupType setup,
    required UsagePattern pattern,
  }) {
    input = CalculatorInput(
      bill2month: bill2month,
      setup: setup,
      pattern: pattern,
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Step 1 — calculate (runs engine + pricing synchronously)
  // ---------------------------------------------------------------------------

  void calculate() {
    final CalculatorInput? currentInput = input;
    if (currentInput == null) return;

    // Run calculation engine
    recommendation = CalculationEngine.run(
      bill2month: currentInput.bill2month,
      setup: currentInput.setup,
      pattern: currentInput.pattern,
    );

    // Run pricing lookup
    final RecommendationResult rec = recommendation!;
    pricedResult = PricingModule.lookup(
      result: rec,
      setup: currentInput.setup,
      bill2month: currentInput.bill2month,
    );

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Reset — clears all state (used by "Start over" link)
  // ---------------------------------------------------------------------------

  void reset() {
    input = null;
    recommendation = null;
    pricedResult = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Convenience getters
  // ---------------------------------------------------------------------------

  /// Percentage reduction of the 2-month bill, derived from the REAL engine
  /// figures (bill-after vs. original bill). Null on the consult path or before
  /// a calculation. Clamped to 0–99 for display.
  int? get reductionPercent {
    final CalculatorInput? inp = input;
    final PricedResult? priced = pricedResult;
    if (inp == null || priced == null) return null;
    if (recommendation?.isConsult ?? true) return null;
    if (inp.bill2month <= 0) return null;
    final double pct = (1 - priced.estBillAfter2mo / inp.bill2month) * 100;
    return pct.clamp(0, 99).round();
  }

  /// System label for display (e.g. "6.6kW Solar + 10.8kWh Battery")
  String get systemLabel {
    final RecommendationResult? rec = recommendation;
    if (rec == null) return '';

    if (rec.isConsult) return 'Tailored Assessment';

    final String? array = rec.array;
    final String battery = rec.battery;

    // panelsOnly: battery only
    if (array == null) return battery;

    // nothing with battery
    if (battery == 'Not recommended – modify night time usage') {
      return array;
    }

    // nothing with array + battery
    return '$array + $battery';
  }
}
