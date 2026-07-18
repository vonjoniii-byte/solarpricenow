// LeadModel serialization tests — verifies enum → wire format mapping.
// CRITICAL: Pattern and Setup enum serialization must match backend Zod schema exactly.

import 'package:flutter_test/flutter_test.dart';
import 'package:solar_calculator/models/lead_model.dart';
import 'package:solar_calculator/engine/enums.dart';

void main() {
  group('LeadModel.toJson()', () {
    // ── Pattern enum serialization (CRITICAL) ──────────────────────────────
    group('Pattern enum wire values (backend Zod: mostly_day|even_split|mostly_night)',
        () {
      test('UsagePattern.mostlyDay → "mostly_day"', () {
        final lead = LeadModel(
          name: 'Test',
          email: 'test@example.com',
          phone: '0412345678',
          postcode: '2000',
          bill2month: 500,
          setup: SetupType.nothing,
          pattern: UsagePattern.mostlyDay,
          recommendedArray: '12.35kW',
          recommendedBattery: '10.8kWh battery',
          estimatedPrice: 15000,
          annualSaving: 2600,
          paybackYears: 5.7,
          timestamp: '2026-06-10T00:00:00.000Z',
        );

        final json = lead.toJson();
        expect(json['pattern'], equals('mostly_day'));
      });

      test('UsagePattern.evenSplit → "even_split"', () {
        final lead = LeadModel(
          name: 'Test',
          email: 'test@example.com',
          phone: '0412345678',
          postcode: '2000',
          bill2month: 500,
          setup: SetupType.nothing,
          pattern: UsagePattern.evenSplit,
          recommendedArray: '12.35kW',
          recommendedBattery: '10.8kWh battery',
          estimatedPrice: 15000,
          annualSaving: 2600,
          paybackYears: 5.7,
          timestamp: '2026-06-10T00:00:00.000Z',
        );

        final json = lead.toJson();
        expect(json['pattern'], equals('even_split'));
      });

      test('UsagePattern.mostlyNight → "mostly_night"', () {
        final lead = LeadModel(
          name: 'Test',
          email: 'test@example.com',
          phone: '0412345678',
          postcode: '2000',
          bill2month: 500,
          setup: SetupType.nothing,
          pattern: UsagePattern.mostlyNight,
          recommendedArray: '12.35kW',
          recommendedBattery: '10.8kWh battery',
          estimatedPrice: 15000,
          annualSaving: 2600,
          paybackYears: 5.7,
          timestamp: '2026-06-10T00:00:00.000Z',
        );

        final json = lead.toJson();
        expect(json['pattern'], equals('mostly_night'));
      });
    });

    // ── Setup enum serialization (CRITICAL) ────────────────────────────────
    group('Setup enum wire values (backend Zod: nothing|panels_only|panels_and_battery)',
        () {
      test('SetupType.nothing → "nothing"', () {
        final lead = LeadModel(
          name: 'Test',
          email: 'test@example.com',
          phone: '0412345678',
          postcode: '2000',
          bill2month: 500,
          setup: SetupType.nothing,
          pattern: UsagePattern.evenSplit,
          recommendedArray: '12.35kW',
          recommendedBattery: '10.8kWh battery',
          estimatedPrice: 15000,
          annualSaving: 2600,
          paybackYears: 5.7,
          timestamp: '2026-06-10T00:00:00.000Z',
        );

        final json = lead.toJson();
        expect(json['setup'], equals('nothing'));
      });

      test('SetupType.panelsOnly → "panels_only"', () {
        final lead = LeadModel(
          name: 'Test',
          email: 'test@example.com',
          phone: '0412345678',
          postcode: '2000',
          bill2month: 500,
          setup: SetupType.panelsOnly,
          pattern: UsagePattern.evenSplit,
          recommendedArray: '6.6kW Solar Array',
          recommendedBattery: 'Not recommended – modify night time usage',
          estimatedPrice: 8000,
          annualSaving: 2200,
          paybackYears: 3.6,
          timestamp: '2026-06-10T00:00:00.000Z',
        );

        final json = lead.toJson();
        expect(json['setup'], equals('panels_only'));
      });

      test('SetupType.panelsAndBattery → "panels_and_battery"', () {
        final lead = LeadModel(
          name: 'Test',
          email: 'test@example.com',
          phone: '0412345678',
          postcode: '2000',
          bill2month: 500,
          setup: SetupType.panelsAndBattery,
          pattern: UsagePattern.evenSplit,
          recommendedArray: null,
          recommendedBattery: 'Custom assessment required',
          estimatedPrice: null,
          annualSaving: null,
          paybackYears: null,
          timestamp: '2026-06-10T00:00:00.000Z',
        );

        final json = lead.toJson();
        expect(json['setup'], equals('panels_and_battery'));
      });
    });

    // ── All fields serialized correctly to snake_case ──────────────────────
    group('All fields in toJson()', () {
      test('all required fields present in toJson() output', () {
        final lead = LeadModel(
          name: 'Jane Smith',
          email: 'jane@example.com',
          phone: '0412345678',
          postcode: '2000',
          bill2month: 450,
          setup: SetupType.nothing,
          pattern: UsagePattern.mostlyDay,
          recommendedArray: '12.35kW',
          recommendedBattery: '13.5kWh battery',
          estimatedPrice: 12500,
          annualSaving: 2200,
          paybackYears: 5.7,
          timestamp: '2026-06-10T08:00:00.000Z',
          company: '',
        );

        final json = lead.toJson();

        // Verify all required fields are present.
        expect(json.containsKey('name'), isTrue);
        expect(json.containsKey('email'), isTrue);
        expect(json.containsKey('phone'), isTrue);
        expect(json.containsKey('postcode'), isTrue);
        expect(json.containsKey('bill_2month'), isTrue);
        expect(json.containsKey('setup'), isTrue);
        expect(json.containsKey('pattern'), isTrue);
        expect(json.containsKey('recommended_array'), isTrue);
        expect(json.containsKey('recommended_battery'), isTrue);
        expect(json.containsKey('estimated_price'), isTrue);
        expect(json.containsKey('annual_saving'), isTrue);
        expect(json.containsKey('payback_years'), isTrue);
        expect(json.containsKey('timestamp'), isTrue);
        expect(json.containsKey('company'), isTrue);
        expect(json.containsKey('marketing_opt_in'), isTrue);

        // Verify values
        expect(json['name'], equals('Jane Smith'));
        expect(json['email'], equals('jane@example.com'));
        expect(json['phone'], equals('0412345678'));
        expect(json['postcode'], equals('2000'));
        expect(json['bill_2month'], equals(450));
        expect(json['setup'], equals('nothing'));
        expect(json['pattern'], equals('mostly_day'));
        expect(json['recommended_array'], equals('12.35kW'));
        expect(json['recommended_battery'], equals('13.5kWh battery'));
        expect(json['estimated_price'], equals(12500));
        expect(json['annual_saving'], equals(2200));
        expect(json['payback_years'], equals(5.7));
        expect(json['timestamp'], equals('2026-06-10T08:00:00.000Z'));
        expect(json['company'], equals(''));
        expect(json['marketing_opt_in'], isFalse); // default when unspecified
      });

      test('marketing_opt_in serializes true when set', () {
        final lead = LeadModel(
          name: 'Jane Smith',
          email: 'jane@example.com',
          phone: '0412345678',
          postcode: '2000',
          bill2month: 450,
          setup: SetupType.nothing,
          pattern: UsagePattern.mostlyDay,
          recommendedArray: '12.35kW',
          recommendedBattery: '13.5kWh battery',
          timestamp: '2026-06-10T08:00:00.000Z',
          marketingOptIn: true,
        );

        final json = lead.toJson();
        expect(json['marketing_opt_in'], isTrue);
      });

      test('null values are serialized as null', () {
        final lead = LeadModel(
          name: 'Bob Jones',
          email: 'bob@example.com',
          phone: '0298765432',
          postcode: '3000',
          bill2month: 1500,
          setup: SetupType.nothing,
          pattern: UsagePattern.evenSplit,
          recommendedArray: 'Tailored assessment required',
          recommendedBattery: '39.6kWh battery',
          estimatedPrice: null,
          annualSaving: null,
          paybackYears: null,
          timestamp: '2026-06-10T09:00:00.000Z',
        );

        final json = lead.toJson();
        expect(json['estimated_price'], isNull);
        expect(json['annual_saving'], isNull);
        expect(json['payback_years'], isNull);
      });

      test('honeypot (company) field serialized correctly', () {
        final lead = LeadModel(
          name: 'Test',
          email: 'test@example.com',
          phone: '0412345678',
          postcode: '2000',
          bill2month: 500,
          setup: SetupType.nothing,
          pattern: UsagePattern.evenSplit,
          recommendedArray: '12.35kW',
          recommendedBattery: '10.8kWh battery',
          estimatedPrice: 15000,
          annualSaving: 2600,
          paybackYears: 5.7,
          timestamp: '2026-06-10T00:00:00.000Z',
          company: '', // default — empty for legitimate submissions
        );

        final json = lead.toJson();
        expect(json['company'], equals(''));
      });
    });
  });
}
