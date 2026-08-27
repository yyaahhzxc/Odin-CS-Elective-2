/// Breakpoint constants used to partition screen sizes into Mobile, Tablet, and Desktop tiers.
class AppBreakpoints {
  AppBreakpoints._();

  /// Maximum screen width for standard phone layouts.
  static const double mobileMaxWidth = 600.0;

  /// Maximum screen width for tablet / iPad layouts before transitioning to desktop multi-column view.
  static const double tabletMaxWidth = 1100.0;
}
