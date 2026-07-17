// LeadModel — payload for POST /api/leads
// Wire format: snake_case JSON keys per ARCHITECTURE.md §5.

import '../engine/enums.dart';

class LeadModel {
  final String name;
  final String email;
  final String phone;
  final String postcode;
  final double bill2month;
  final SetupType setup;
  final UsagePattern pattern;
  final String? recommendedArray;
  final String recommendedBattery;
  final double? estimatedPrice;
  final double? annualSaving;
  final double? paybackYears;
  final String timestamp;
  // Honeypot — must be empty string on legitimate submissions
  final String company;

  const LeadModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.postcode,
    required this.bill2month,
    required this.setup,
    required this.pattern,
    required this.recommendedArray,
    required this.recommendedBattery,
    this.estimatedPrice,
    this.annualSaving,
    this.paybackYears,
    required this.timestamp,
    this.company = '',
  });

  /// Converts to JSON using snake_case keys per ARCHITECTURE.md §5.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'postcode': postcode,
      'bill_2month': bill2month,
      'setup': _setupToWire(setup),
      'pattern': _patternToWire(pattern),
      'recommended_array': recommendedArray,
      'recommended_battery': recommendedBattery,
      'estimated_price': estimatedPrice,
      'annual_saving': annualSaving,
      'payback_years': paybackYears,
      'timestamp': timestamp,
      'company': company,
    };
  }

  static String _setupToWire(SetupType setup) {
    switch (setup) {
      case SetupType.nothing:
        return 'nothing';
      case SetupType.panelsOnly:
        return 'panels_only';
      case SetupType.panelsAndBattery:
        return 'panels_and_battery';
    }
  }

  static String _patternToWire(UsagePattern pattern) {
    switch (pattern) {
      case UsagePattern.mostlyDay:
        return 'mostly_day';
      case UsagePattern.evenSplit:
        return 'even_split';
      case UsagePattern.mostlyNight:
        return 'mostly_night';
    }
  }
}
