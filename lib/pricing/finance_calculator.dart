// FinanceCalculator — indicative repayment for the recommended system, based on
// the Brighte HEUF Discounted Green Loan: a FIXED-RATE AMORTISING (reducing-
// balance) loan. Pure Dart — NO Flutter imports (isolated + unit-tested).
// Brighte is one of several finance options we can arrange — this calculator
// covers Brighte specifically since it's the one with published, quotable terms.
//
// The $399 establishment fee is financed (interest applies to it). The weekly
// account-keeping fee is added to each repayment. Repayment is presented
// bi-monthly (every 2 months) to match the billing cycle.

import 'dart:math' as math;

class FinanceResult {
  /// price + establishment fee (the amount financed).
  final double financedPrincipal;

  /// Amortised loan payment per 2-month period (excludes the account fee).
  final double amortisedPayment;

  /// Account-keeping fee per 2-month period.
  final double accountFeePeriod;

  /// Indicative total repayment per 2-month period (amortised + fee).
  final double bimonthlyRepayment;

  const FinanceResult({
    required this.financedPrincipal,
    required this.amortisedPayment,
    required this.accountFeePeriod,
    required this.bimonthlyRepayment,
  });
}

class FinanceCalculator {
  /// Fixed annual interest rate (amortising / reducing-balance).
  static const double annualRate = 0.0799;

  /// Comparison rate — disclosure only (not used in the calculation).
  static const double comparisonRate = 0.0949;

  /// Loan term in years.
  static const int termYears = 10;

  /// Establishment fee, financed (added to principal).
  static const double establishmentFee = 399.0;

  /// Weekly account-keeping fee.
  static const double weeklyFee = 2.70;

  /// Weeks per year (for the account-keeping fee).
  static const int weeksPerYear = 52;

  /// Repayments per year (bi-monthly = every 2 months).
  static const int paymentsPerYear = 6;

  /// HEUF eligible finance amount (applied to the financed principal).
  static const double minFinance = 2000.0;
  static const double maxFinance = 60000.0;

  /// Compute the indicative HEUF figures for [price] (the all-in installed
  /// price). Returns null — UI then shows "Available on quote" — when there is
  /// no real price (≤ 0) or the financed amount falls outside HEUF's
  /// $2,000–$60,000 eligibility window.
  static FinanceResult? compute(double price) {
    if (price <= 0) return null;

    final double financedPrincipal = price + establishmentFee;
    if (financedPrincipal < minFinance || financedPrincipal > maxFinance) {
      return null;
    }

    final double periodRate = annualRate / paymentsPerYear;
    final int n = termYears * paymentsPerYear;
    final double amortisedPayment = financedPrincipal *
        periodRate /
        (1 - math.pow(1 + periodRate, -n));
    final double accountFeePeriod =
        weeklyFee * weeksPerYear / paymentsPerYear; // = 23.40

    return FinanceResult(
      financedPrincipal: financedPrincipal,
      amortisedPayment: amortisedPayment,
      accountFeePeriod: accountFeePeriod,
      bimonthlyRepayment: amortisedPayment + accountFeePeriod,
    );
  }
}
