// AppSpacing — spacing tokens per UX_SPEC.md §4.3
// Base unit: 8px. All values are multiples of 4px or 8px.

class AppSpacing {
  // Base unit
  static const double unit = 8.0;

  // Screen-level padding (horizontal only; applied to content column)
  static const double screenPaddingH = 16.0; // 2× base unit
  static const double screenPaddingHDesktop = 32.0; // 4× base unit

  // Centered content column max width (design composition is a 520px column)
  static const double contentMaxWidth = 520.0;

  // Between major sections on a screen
  static const double sectionGap = 24.0; // 3× unit

  // Between OptionCards in a column (mobile stack)
  static const double cardGap = 8.0; // 1× unit

  // Between OptionCards in a row (tablet/desktop)
  static const double cardGapRow = 8.0; // 1× unit

  // Internal card padding
  static const double cardPadding = 16.0; // 2× unit

  // Between form fields
  static const double fieldGap = 16.0; // 2× unit

  // Button height (PrimaryButton, BookAssessmentCta)
  static const double buttonHeight = 52.0; // PrimaryButton
  static const double ctaButtonHeight = 56.0; // BookAssessmentCta (slightly taller for emphasis)

  // AppHeader height
  static const double headerHeight = 56.0; // 7× unit

  // StickyFooter height
  static const double stickyFooterHeight = 72.0; // 9× unit

  // Section divider height (space + rule)
  static const double dividerH = 8.0;

  // Bottom screen padding (above safe area)
  static const double bottomPadding = 32.0; // 4× unit

  // Metric card gap (within 2×2 grid)
  static const double metricCardGap = 12.0;

  // Metric card internal padding
  static const double metricCardPadding = 16.0; // 2× unit

  // Metric card height — FIXED so all grid cards are identical size (the
  // combined savings+bill card is the tallest; this fits it with headroom).
  static const double metricCardHeight = 160.0;
}
