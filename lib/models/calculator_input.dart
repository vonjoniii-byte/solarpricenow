// CalculatorInput — user inputs from Step 1
// May be pure Dart (no Flutter dependency required).

import '../engine/enums.dart';

class CalculatorInput {
  final double bill2month;
  final SetupType setup;
  final UsagePattern pattern;

  const CalculatorInput({
    required this.bill2month,
    required this.setup,
    required this.pattern,
  });
}
