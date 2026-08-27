import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A horizontal rectangular wireframe tile representing list item rows.
class WireframeTile extends StatelessWidget {
  /// Optional vertical height. When null, expands to fill parent constraints.
  final double? height;

  /// Outer padding / margin around the tile.
  final EdgeInsetsGeometry margin;

  /// Background color of the tile. Defaults to [AppColors.wireframeTile].
  final Color? color;

  /// Corner radius of the tile.
  final double borderRadius;

  const WireframeTile({
    super.key,
    this.height,
    this.margin = const EdgeInsets.only(bottom: 12.0),
    this.color,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.wireframeTile,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
