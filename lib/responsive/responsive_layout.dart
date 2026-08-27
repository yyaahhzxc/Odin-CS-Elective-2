import 'package:flutter/material.dart';
import '../constants/app_breakpoints.dart';

/// A responsive builder widget that renders the appropriate body based on screen width.
///
/// Uses [LayoutBuilder] to observe incoming box constraints:
/// - Mobile: `maxWidth < 600`
/// - Tablet: `600 <= maxWidth < 1100`
/// - Desktop: `maxWidth >= 1100`
class ResponsiveLayout extends StatelessWidget {
  /// Widget displayed on mobile device screens (< 600px).
  final Widget mobileBody;

  /// Widget displayed on tablet device screens (600px - 1100px).
  final Widget tabletBody;

  /// Widget displayed on desktop / large displays (>= 1100px).
  final Widget desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.tabletBody,
    required this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobileMaxWidth) {
          return mobileBody;
        } else if (constraints.maxWidth < AppBreakpoints.tabletMaxWidth) {
          return tabletBody;
        } else {
          return desktopBody;
        }
      },
    );
  }
}
