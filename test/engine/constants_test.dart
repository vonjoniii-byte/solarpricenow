// Constants tests — verify §4.1 values exactly.

import 'package:flutter_test/flutter_test.dart';
import 'package:solar_calculator/engine/constants.dart';

void main() {
  group('Engine constants (§4.1)', () {
    test('electricityRate is 0.324', () {
      expect(electricityRate, equals(0.324));
    });

    test('dailySupplyCharge is 1.05', () {
      expect(dailySupplyCharge, equals(1.05));
    });

    test('billingDays is 61', () {
      expect(billingDays, equals(61));
    });

    test('supplyCharge (dailySupplyCharge × billingDays) = 64.05', () {
      expect(dailySupplyCharge * billingDays, closeTo(64.05, 0.001));
    });
  });
}
