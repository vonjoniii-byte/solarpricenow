// FinanceCalculator tests — Brighte HEUF amortising loan + $13,000 validation.

import 'package:flutter_test/flutter_test.dart';
import 'package:solar_calculator/pricing/finance_calculator.dart';

void main() {
  group('FinanceCalculator — Brighte HEUF (7.99% fixed amortising, 10yr)', () {
    test('VALIDATION: price=\$13,000 → financed 13199, amortised ≈ 320.86, '
        'fee 23.40, bimonthly ≈ 344.26', () {
      final f = FinanceCalculator.compute(13000)!;
      expect(f.financedPrincipal, closeTo(13199.0, 0.01)); // 13000 + 199
      expect(f.amortisedPayment, closeTo(320.86, 0.05));
      expect(f.accountFeePeriod, closeTo(23.40, 0.001)); // 2.70 × 52 / 6
      expect(f.bimonthlyRepayment, closeTo(344.26, 0.05));
    });

    test('account fee per period is fixed at 23.40 regardless of price', () {
      for (final p in [5000.0, 15504.0, 33696.0]) {
        expect(FinanceCalculator.compute(p)!.accountFeePeriod, closeTo(23.40, 0.001));
      }
    });

    test('bimonthly = amortised + account fee for an arbitrary price', () {
      final f = FinanceCalculator.compute(15504)!;
      expect(f.bimonthlyRepayment,
          closeTo(f.amortisedPayment + f.accountFeePeriod, 0.0001));
    });

    test('amortising repayment is LESS than the old flat-rate figure', () {
      // Sanity: reducing-balance < flat-rate for the same headline rate/term.
      // (Old flat HEUF-less model gave 413.18 for \$13,000.)
      expect(FinanceCalculator.compute(13000)!.bimonthlyRepayment, lessThan(413.18));
    });

    // ── Eligibility / edge cases → null (UI shows "Available on quote") ────────
    test('no real price → null (zero)', () {
      expect(FinanceCalculator.compute(0), isNull);
    });

    test('no real price → null (negative)', () {
      expect(FinanceCalculator.compute(-1), isNull);
    });

    test('financed amount below \$2,000 → null', () {
      // price 1500 → financed 1699 < 2000.
      expect(FinanceCalculator.compute(1500), isNull);
    });

    test('financed amount above \$60,000 → null', () {
      // price 60000 → financed 60199 > 60000.
      expect(FinanceCalculator.compute(60000), isNull);
    });

    test('boundary: price 59801 → financed exactly 60000 → priced (not null)', () {
      expect(FinanceCalculator.compute(59801), isNotNull);
    });

    test('all real config prices (5732–33801) are financeable', () {
      for (final p in [5732.0, 13606.0, 24332.0, 33801.0]) {
        expect(FinanceCalculator.compute(p), isNotNull);
      }
    });
  });
}
