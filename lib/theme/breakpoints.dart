// Breakpoints — centralised responsive thresholds (Round 2, WI-1).
// Previously inlined as magic numbers across screens. Layout must stay usable
// and overflow-free from 320px upward.

class Breakpoints {
  Breakpoints._();

  /// Below this, cards stack to a single column.
  static const double compact = 360;

  /// At/above this, option cards lay out in a row; below, they stack.
  static const double tablet = 640;

  /// At/above this, content is centred with a max width and metrics go 4-across.
  static const double desktop = 1280;

  static bool isCompact(double width) => width < compact;
  static bool isTablet(double width) => width >= tablet;
  static bool isDesktop(double width) => width >= desktop;
}
