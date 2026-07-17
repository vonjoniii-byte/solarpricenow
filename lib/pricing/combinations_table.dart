// Combinations table — §4.6 of spec.
// Pure Dart — NO Flutter imports.
//
// Map key: (arrayLabel, batteryLabel) → installed price in AUD.
// Absence from the map means the combination is unreachable/consult-only.
//
// Source of truth: docs/Reference/Solar_Battery_Combinations_Pricing_v3.xlsx
// (Round 2). 42 of 87 combinations are producible by the engine and carry a
// real installed price (inverter + fixed costs included). The remaining 45 are
// impossible at ANY bill because the fixed 75/50/25% day-night split can never
// size those pairings — they are simply absent from this map.
//
// stubPrice / isStub is retained as a safety net (PricingModule sets
// isStub = price == stubPrice) but in normal operation it is unreachable: every
// producible config below has a real price.
//
// ────────────────────────────────────────────────────────────────────────────
// REACHABILITY — 42 producible combinations (2 array-only + 30 array+battery +
// 10 battery-only). Key construction (see pricing_module.dart):
//   • setup=nothing, battery="Not recommended …"  → (arrayLabel, "Not recommended – modify night time usage")
//   • setup=nothing, array+battery                → (arrayLabel, batteryLabel)
//   • setup=panelsOnly (battery only)             → ("",        batteryLabel)
//
// Array thresholds (avgKwh): 0–<10→3.3kW, 10–<20→6.6kW, 20–<30→9.9kW,
//   30–<40→12.35kW, 40–<50→15.2kW, 50–<60→18.5kW, 60–<70→24.7kW, ≥70→Tailored.
// Battery thresholds (kwh): <4→not recommended, 4–<7→7.2kWh, 7–<10→10.8kWh,
//   10–<15→14.4kWh, 15–<17.5→18kWh, 17.5–<21→21.6kWh, 21–<28→28.8kWh,
//   28–<32→32.4kWh, 32–<35.5→36kWh, 35.5–<39→39.6kWh, 39–<43→43.2kWh, ≥43→Tailored.
//
// The full engine-output-vs-table-key coverage test asserts that every
// non-consult engine output has a key here; keep them in lock-step.
// ────────────────────────────────────────────────────────────────────────────

const double stubPrice = 0.0;

// Key: (arrayLabel, batteryLabel)
// For battery-only (panelsOnly path): arrayLabel = "" (empty string sentinel)
const Map<(String, String), double> combinationsTable = {
  // ── Array only (setup=nothing, nightKwh < 4 → no battery) ────────────────
  ('3.3kW Solar Array', 'Not recommended – modify night time usage'): 5732,
  ('6.6kW Solar Array', 'Not recommended – modify night time usage'): 6835,

  // ── Array + battery (setup=nothing) — 30 pairings across seven arrays ─────
  ('3.3kW Solar Array', '7.2kWh battery'): 11007,
  ('3.3kW Solar Array', '10.8kWh battery'): 11956,
  ('6.6kW Solar Array', '7.2kWh battery'): 12107,
  ('6.6kW Solar Array', '10.8kWh battery'): 13056,
  ('6.6kW Solar Array', '14.4kWh battery'): 14005,
  ('9.9kW Solar Array', '7.2kWh battery'): 13606,
  ('9.9kW Solar Array', '10.8kWh battery'): 14555,
  ('9.9kW Solar Array', '14.4kWh battery'): 15504,
  ('9.9kW Solar Array', '18kWh battery'): 16749,
  ('9.9kW Solar Array', '21.6kWh battery'): 18068,
  ('9.9kW Solar Array', '28.8kWh battery'): 20669,
  ('12.35kW Solar Array', '10.8kWh battery'): 15351,
  ('12.35kW Solar Array', '18kWh battery'): 17545,
  ('12.35kW Solar Array', '21.6kWh battery'): 18864,
  ('12.35kW Solar Array', '28.8kWh battery'): 21465,
  ('12.35kW Solar Array', '32.4kWh battery'): 24332,
  ('15.2kW Solar Array', '14.4kWh battery'): 19798,
  ('15.2kW Solar Array', '21.6kWh battery'): 22362,
  ('15.2kW Solar Array', '28.8kWh battery'): 24963,
  ('15.2kW Solar Array', '32.4kWh battery'): 26430,
  ('15.2kW Solar Array', '36kWh battery'): 29119,
  ('15.2kW Solar Array', '39.6kWh battery'): 30808,
  ('18.5kW Solar Array', '14.4kWh battery'): 21034,
  ('18.5kW Solar Array', '28.8kWh battery'): 26199,
  ('18.5kW Solar Array', '32.4kWh battery'): 27666,
  ('18.5kW Solar Array', '39.6kWh battery'): 32044,
  ('18.5kW Solar Array', '43.2kWh battery'): 33696,
  ('24.7kW Solar Array', '18kWh battery'): 25735,
  ('24.7kW Solar Array', '32.4kWh battery'): 31112,
  ('24.7kW Solar Array', '36kWh battery'): 33801,

  // ── Battery only (setup=panelsOnly, empty string sentinel) — 10 sizes ─────
  ('', '7.2kWh battery'): 7772,
  ('', '10.8kWh battery'): 8721,
  ('', '14.4kWh battery'): 9670,
  ('', '18kWh battery'): 10915,
  ('', '21.6kWh battery'): 12234,
  ('', '28.8kWh battery'): 14835,
  ('', '32.4kWh battery'): 17702,
  ('', '36kWh battery'): 20391,
  ('', '39.6kWh battery'): 22080,
  ('', '43.2kWh battery'): 23732,
};
