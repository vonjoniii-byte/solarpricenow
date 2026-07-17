// Calculation constants — §4.1 of spec
// Pure Dart — NO Flutter imports.

const double electricityRate = 0.324;
const double dailySupplyCharge = 1.05;
const int billingDays = 61;

/// Annual savings escalation rate (compounding) — reflects rising energy prices.
const double savingsEscalationRate = 0.045;
