import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A reusable wireframe card widget rendered with rounded corners and neutral fill.
///
/// Designed to serve as the visual placeholder for dashboard metrics and top grid cards.
class WireframeBox extends StatelessWidget {
  /// The fill color of the box. Defaults to [AppColors.wireframeBox].
  final Color? color;

  /// Optional height constraint if not sized by a parent AspectRatio/Grid.
  final double? height;

  /// Optional width constraint.
  final double? width;

  /// Optional child widget inside the wireframe container.
  final Widget? child;

  /// Corner radius of the container.
  final double borderRadius;

  const WireframeBox({
    super.key,
    this.color,
    this.height,
    this.width,
    this.child,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.wireframeBox,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
