// CalculationEngine — §4.2–4.5 of spec
// Pure Dart — NO Flutter imports.

import 'constants.dart';
import 'enums.dart';
import '../models/recommendation_result.dart';

class CalculationEngine {
  /// Run the calculation engine.
  ///
  /// [bill2month] — 2-month electricity bill in AUD
  /// [setup] — user's existing setup type
  /// [pattern] — user's electricity usage pattern
  ///
  /// Returns [RecommendationResult] with array/battery recommendations and
  /// isConsult flag.
  static RecommendationResult run({
    required double bill2month,
    required SetupType setup,
    required UsagePattern pattern,
  }) {
    // §4.2 — derived values
    final double supplyCharge = dailySupplyCharge * billingDays; // = 64.05
    final double consumptionCharge = bill2month - supplyCharge;
    final double avgKwhPerDay =
        consumptionCharge / electricityRate / billingDays;

    // §4.2 — day/night fractions
    final double dayFraction = _dayFraction(pattern);
    final double nightFraction = 1.0 - dayFraction;
    final double nightKwhPerDay = avgKwhPerDay * nightFraction;

    // §4.3 — array recommendation (only when setup == nothing)
    final String? array =
        setup == SetupType.nothing ? _arrayRecommendation(avgKwhPerDay) : null;

    // §4.4 — battery recommendation
    final String battery = _batteryRecommendation(
      setup: setup,
      avgKwhPerDay: avgKwhPerDay,
      nightKwhPerDay: nightKwhPerDay,
    );

    // §4.4 — isConsult determination
    final bool isConsult = _computeIsConsult(
      setup: setup,
      array: array,
      battery: battery,
    );

    final String? consultReason = isConsult ? _consultReason(setup, array, battery) : null;

    return RecommendationResult(
      array: array,
      battery: battery,
      isConsult: isConsult,
      consultReason: consultReason,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static double _dayFraction(UsagePattern pattern) {
    switch (pattern) {
      case UsagePattern.mostlyDay:
        return 0.75;
      case UsagePattern.evenSplit:
        return 0.50;
      case UsagePattern.mostlyNight:
        return 0.25;
    }
  }

  /// §4.3 Array recommendation lookup.
  /// Largest threshold ≤ value — iterate from highest to lowest.
  /// Bands 0–40 are unchanged; 40/50/60 add the larger arrays (Round 2, D-ARRAY).
  static String _arrayRecommendation(double avgKwhPerDay) {
    if (avgKwhPerDay >= 70) return 'Tailored assessment required';
    if (avgKwhPerDay >= 60) return '24.7kW Solar Array';
    if (avgKwhPerDay >= 50) return '18.5kW Solar Array';
    if (avgKwhPerDay >= 40) return '15.2kW Solar Array';
    if (avgKwhPerDay >= 30) return '12.35kW Solar Array';
    if (avgKwhPerDay >= 20) return '9.9kW Solar Array';
    if (avgKwhPerDay >= 10) return '6.6kW Solar Array';
    return '3.3kW Solar Array'; // avgKwhPerDay >= 0
  }

  /// §4.4 Battery recommendation logic.
  static String _batteryRecommendation({
    required SetupType setup,
    required double avgKwhPerDay,
    required double nightKwhPerDay,
  }) {
    switch (setup) {
      case SetupType.panelsAndBattery:
        // Special messages for panelsAndBattery path
        if (avgKwhPerDay < 5) {
          return 'Modify behaviour to reduce consumption';
        }
        return 'Consider a larger battery. Custom consult required';

      case SetupType.panelsOnly:
        // Lookup table uses avgKwhPerDay
        return _batteryLookup(avgKwhPerDay);

      case SetupType.nothing:
        // Lookup table uses nightKwhPerDay
        return _batteryLookup(nightKwhPerDay);
    }
  }

  /// §4.4 Battery lookup table.
  /// Largest threshold ≤ value — iterate from highest to lowest.
  static String _batteryLookup(double kwh) {
    if (kwh >= 43) return 'Tailored assessment required';
    if (kwh >= 39) return '43.2kWh battery';
    if (kwh >= 35.5) return '39.6kWh battery';
    if (kwh >= 32) return '36kWh battery';
    if (kwh >= 28) return '32.4kWh battery';
    if (kwh >= 21) return '28.8kWh battery';
    if (kwh >= 17.5) return '21.6kWh battery';
    if (kwh >= 15) return '18kWh battery';
    if (kwh >= 10) return '14.4kWh battery';
    if (kwh >= 7) return '10.8kWh battery';
    if (kwh >= 4) return '7.2kWh battery';
    return 'Not recommended – modify night time usage'; // kwh >= 0
  }

  /// §4.4 isConsult determination.
  static bool _computeIsConsult({
    required SetupType setup,
    required String? array,
    required String battery,
  }) {
    if (array == 'Tailored assessment required') return true;
    if (battery == 'Tailored assessment required') return true;
    if (battery == 'Modify behaviour to reduce consumption') return true;
    if (battery == 'Consider a larger battery. Custom consult required') return true;
    if (setup == SetupType.panelsAndBattery) return true;
    return false;
  }

  static String _consultReason(
    SetupType setup,
    String? array,
    String battery,
  ) {
    if (setup == SetupType.panelsAndBattery) {
      return battery;
    }
    if (array == 'Tailored assessment required') {
      return 'Tailored assessment required — usage exceeds standard package thresholds.';
    }
    if (battery == 'Tailored assessment required') {
      return 'Tailored assessment required — battery size exceeds standard package thresholds.';
    }
    if (battery == 'Modify behaviour to reduce consumption') {
      return battery;
    }
    return 'Custom consultation required.';
  }
}
