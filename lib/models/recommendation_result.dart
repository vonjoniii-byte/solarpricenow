// RecommendationResult — output of CalculationEngine.run()
// Pure Dart — NO Flutter imports.

class RecommendationResult {
  /// null when setup != nothing (array recommendation only applies when user has no existing setup)
  final String? array;

  /// Battery recommendation string from lookup table or special message
  final String battery;

  /// True when a tailored assessment or manual consult is required
  final bool isConsult;

  /// Human-readable reason for why a consult is needed (null when isConsult == false)
  final String? consultReason;

  const RecommendationResult({
    required this.array,
    required this.battery,
    required this.isConsult,
    this.consultReason,
  });

  @override
  String toString() =>
      'RecommendationResult(array: $array, battery: $battery, isConsult: $isConsult, consultReason: $consultReason)';
}
