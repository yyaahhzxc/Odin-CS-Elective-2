import 'package:flutter/material.dart';

/// Standard breakpoint constants for responsive layouts.
class Breakpoints {
  static const double mobileMax = 767.0;
  static const double tabletMax = 1023.0;
  static const double desktopMin = 1024.0;
  static const double maxContentWidth = 1200.0;
}

/// Helper utilities to query device viewports cleanly.
class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= Breakpoints.mobileMax;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > Breakpoints.mobileMax && width <= Breakpoints.tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > Breakpoints.tabletMax;

  static bool isWebOrDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > Breakpoints.mobileMax;
}

/// Responsive builder widget that renders appropriate layout based on screen width.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > Breakpoints.tabletMax) {
      return desktop;
    } else if (width > Breakpoints.mobileMax && tablet != null) {
      return tablet!;
    } else if (width > Breakpoints.mobileMax) {
      return desktop;
    } else {
      return mobile;
    }
  }
}

/// Centered container constraining max content width on wide monitors.
class WebContentContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const WebContentContainer({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
