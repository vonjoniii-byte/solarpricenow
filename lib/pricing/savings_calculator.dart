// SavingsCalculator — §4.7 savings, bill-after, payback formulas.
// Pure Dart — NO Flutter imports (dart:math is core Dart, not Flutter).

import 'dart:math' as math;
import '../engine/constants.dart';

class SavingsResult {
  final double annualSaving;

  /// Estimated 2-month bill after installation (supply charge only)
  final double estBillAfter2mo;

  final double paybackYears;

  const SavingsResult({
    required this.annualSaving,
    required this.estBillAfter2mo,
    required this.paybackYears,
  });
}

class SavingsCalculator {
  /// Compute savings metrics per §4.7.
  ///
  /// [bill2month] — 2-month electricity bill in AUD
  /// [totalSystemCost] — total installed system price in AUD
  static SavingsResult compute({
    required double bill2month,
    required double totalSystemCost,
  }) {
    // §4.7 formulas. S1 (Year-1 annual saving) is unchanged.
    final double energyPurchased2mo =
        bill2month - (dailySupplyCharge * billingDays);
    final double annualSaving = energyPurchased2mo * 6; // S1
    final double estBillAfter2mo =
        dailySupplyCharge * billingDays; // = 64.05

    // Savings escalate at savingsEscalationRate, compounding per year, so payback
    // solves: system_cost = S1 × ((1+r)^t − 1) / r  →  t = ln(1 + r·cost/S1)/ln(1+r).
    final double s1 = annualSaving;
    final double paybackYears = (totalSystemCost > 0 && s1 > 0)
        ? math.log(1 + savingsEscalationRate * totalSystemCost / s1) /
            math.log(1 + savingsEscalationRate)
        : 0.0;

    return SavingsResult(
      annualSaving: annualSaving,
      estBillAfter2mo: estBillAfter2mo,
      paybackYears: paybackYears,
    );
  }

  /// Year-n annual saving with compounding escalation: Sn = S1 × (1 + r)^(n − 1).
  static double savingForYear(double s1, int year) =>
      s1 * math.pow(1 + savingsEscalationRate, year - 1).toDouble();

  /// Cumulative saving through year t: C(t) = S1 × ((1 + r)^t − 1) / r.
  static double cumulativeSaving(double s1, int years) =>
      s1 *
      (math.pow(1 + savingsEscalationRate, years).toDouble() - 1) /
      savingsEscalationRate;
}
