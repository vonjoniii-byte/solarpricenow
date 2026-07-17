// SavingsCalculator tests — §4.7 worked examples + 4.5% escalation model.

import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_calculator/pricing/savings_calculator.dart';

// Escalated payback: t = ln(1 + r·cost/S1) / ln(1 + r), r = 0.045.
double _escalatedPayback(double cost, double s1) =>
    math.log(1 + 0.045 * cost / s1) / math.log(1.045);

void main() {
  group('SavingsCalculator (§4.7)', () {
    // §4.7 worked example: bill=500
    // energyPurchased2mo = 500 - 64.05 = 435.95
    // annualSaving = 435.95 × 6 = 2615.70
    // estBillAfter2mo = 64.05
    test('bill=500 → annualSaving=2615.70', () {
      final r = SavingsCalculator.compute(
        bill2month: 500,
        totalSystemCost: 14990,
      );
      expect(r.annualSaving, closeTo(2615.70, 0.01));
    });

    test('bill=500 → estBillAfter2mo=64.05', () {
      final r = SavingsCalculator.compute(
        bill2month: 500,
        totalSystemCost: 14990,
      );
      expect(r.estBillAfter2mo, closeTo(64.05, 0.001));
    });

    test('escalated payback with bill=500, price=14990 (≈5.21, shorter than flat 5.73)',
        () {
      final r = SavingsCalculator.compute(
        bill2month: 500,
        totalSystemCost: 14990,
      );
      // Escalated (4.5%/yr) payback < flat 14990/2615.70 = 5.73.
      expect(r.paybackYears, closeTo(_escalatedPayback(14990, 2615.70), 0.01));
      expect(r.paybackYears, closeTo(5.21, 0.02));
      expect(r.paybackYears, lessThan(14990.0 / 2615.70));
    });

    test('bill=1000 → annualSaving correct', () {
      final r = SavingsCalculator.compute(
        bill2month: 1000,
        totalSystemCost: 20000,
      );
      // energyPurchased2mo = 1000 - 64.05 = 935.95
      // annualSaving = 935.95 * 6 = 5615.70
      expect(r.annualSaving, closeTo(5615.70, 0.01));
    });

    test('estBillAfter2mo is always supply charge only (64.05)', () {
      for (final bill in [100.0, 500.0, 1000.0, 1500.0]) {
        final r = SavingsCalculator.compute(
          bill2month: bill,
          totalSystemCost: 10000,
        );
        expect(r.estBillAfter2mo, closeTo(64.05, 0.001),
            reason: 'Supply charge must be 64.05 regardless of bill');
      }
    });

    test('paybackYears follows the escalated formula ln(1+r·cost/S1)/ln(1+r)', () {
      const double bill = 800;
      const double price = 18000;
      final r = SavingsCalculator.compute(
        bill2month: bill,
        totalSystemCost: price,
      );
      final double s1 = (bill - 64.05) * 6;
      expect(r.paybackYears, closeTo(_escalatedPayback(price, s1), 0.0001));
    });

    test('zero system cost → paybackYears = 0.0 (not infinity)', () {
      final r = SavingsCalculator.compute(
        bill2month: 500,
        totalSystemCost: 0,
      );
      expect(r.paybackYears, equals(0.0));
    });
  });

  // ── 4.5% compounding escalation model ──────────────────────────────────────
  group('Savings escalation (r = 4.5%/yr, compounding)', () {
    const double s1 = 2615.70; // bill=500 → (500-64.05)*6

    test('Year-1 saving S1 = 2615.70 (base, unchanged)', () {
      final r = SavingsCalculator.compute(bill2month: 500, totalSystemCost: 1);
      expect(r.annualSaving, closeTo(s1, 0.01));
      expect(SavingsCalculator.savingForYear(s1, 1), closeTo(s1, 0.0001));
    });

    test('Year-2 saving = 2733.41', () {
      expect(SavingsCalculator.savingForYear(s1, 2), closeTo(2733.41, 0.01));
    });

    test('Year-3 saving = 2856.42', () {
      // 2615.70 × 1.045² = 2856.4098; spec value is display-rounded to 2856.42.
      expect(SavingsCalculator.savingForYear(s1, 3), closeTo(2856.42, 0.02));
    });

    test('cumulative C(3) = S1 + S2 + S3 ≈ 8205.5', () {
      final double sum = SavingsCalculator.savingForYear(s1, 1) +
          SavingsCalculator.savingForYear(s1, 2) +
          SavingsCalculator.savingForYear(s1, 3);
      expect(SavingsCalculator.cumulativeSaving(s1, 3), closeTo(sum, 0.01));
      expect(SavingsCalculator.cumulativeSaving(s1, 3), closeTo(8205.53, 0.1));
    });

    test('VALIDATION: \$13,000 system, bill=500 → escalated payback ≈ 4.59 yrs', () {
      final r =
          SavingsCalculator.compute(bill2month: 500, totalSystemCost: 13000);
      expect(r.paybackYears, closeTo(4.59, 0.01));
      // Strictly shorter than the old flat payback (13000/2615.70 = 4.97).
      expect(r.paybackYears, lessThan(13000.0 / s1));
    });
  });
}
