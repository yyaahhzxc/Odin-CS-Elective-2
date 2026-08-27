import 'package:flutter/material.dart';

/// Semantic color palette adhering to the wireframe dashboard aesthetic.
class AppColors {
  AppColors._();

  /// Dark background used for top application bars and title headers.
  static const Color appBarBackground = Color(0xFF1E1E1E);

  /// Off-white / light slate tone for dashboard scaffolding and surfaces.
  static const Color scaffoldBackground = Color(0xFFEBEBEB);

  /// Primary neutral grey used for prominent wireframe grid boxes and primary cards.
  static const Color wireframeBox = Color(0xFFB0B0B0);

  /// Secondary lighter neutral grey used for wireframe list tiles and secondary cards.
  static const Color wireframeTile = Color(0xFFDCDCDC);

  /// Background color for the navigation drawer and desktop sidebar.
  static const Color drawerBackground = Color(0xFFF7F7F7);

  /// Text and icon primary color for dark surfaces.
  static const Color textLight = Color(0xFFFFFFFF);

  /// Text and icon primary color for light surfaces.
  static const Color textDark = Color(0xFF222222);

  /// Muted subtitle / label color.
  static const Color textMuted = Color(0xFF757575);
}
