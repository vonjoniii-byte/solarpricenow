// PricedResult — output of PricingModule + SavingsCalculator
// Pure Dart — NO Flutter imports.

class PricedResult {
  /// Total system price in AUD (may be STUB_PRICE = 0.0)
  final double price;

  /// Estimated annual saving in AUD
  final double annualSaving;

  /// Estimated 2-month bill after installation in AUD (supply charge only)
  final double estBillAfter2mo;

  /// Simple payback period in years
  final double paybackYears;

  /// True when price == STUB_PRICE (0.0) — UI shows [PRICE STUB] badge
  final bool isStub;

  const PricedResult({
    required this.price,
    required this.annualSaving,
    required this.estBillAfter2mo,
    required this.paybackYears,
    required this.isStub,
  });
}
