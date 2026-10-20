import 'package:flutter/material.dart';

/// Clean custom painter rendering a Pokeball icon.
///
/// Supports two distinct visual states:
/// - Inactive / Outlined: Subtle slate hairline outline with transparent interior.
/// - Active / Caught: Classic Pokeball coloring with vivid red top dome,
///   clean white bottom dome, crisp black dividing band, and center button.
class PokeballIcon extends StatelessWidget {
  final bool isFavorite;
  final double size;

  const PokeballIcon({
    super.key,
    required this.isFavorite,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PokeballPainter(isFavorite: isFavorite),
    );
  }
}

class _PokeballPainter extends CustomPainter {
  final bool isFavorite;

  _PokeballPainter({required this.isFavorite});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.085;

    if (!isFavorite) {
      // Inactive / Outlined state (Shadcn-inspired subtle slate)
      final outlinePaint = Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..isAntiAlias = true;

      // Outer circle
      canvas.drawCircle(center, radius - strokeWidth / 2, outlinePaint);

      // Horizontal midline divider
      canvas.drawLine(
        Offset(strokeWidth / 2, center.dy),
        Offset(size.width - strokeWidth / 2, center.dy),
        outlinePaint,
      );

      // Center ring
      final centerRingPaint = Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..isAntiAlias = true;

      canvas.drawCircle(center, radius * 0.28, centerRingPaint);
      return;
    }

    // Active state: Vivid filled Pokeball
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.save();
    canvas.clipPath(clipPath);

    // Top dome (Red)
    final topDomePaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height / 2),
      topDomePaint,
    );

    // Bottom dome (White)
    final bottomDomePaint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2),
      bottomDomePaint,
    );

    canvas.restore();

    // Dark dividing band
    final bandPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.3
      ..isAntiAlias = true;

    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      bandPaint,
    );

    // Outer border ring
    final borderPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius - strokeWidth / 2, borderPaint);

    // Outer Center Button (Dark outline)
    final centerOuterPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.32, centerOuterPaint);

    // Inner Center Button (White)
    final centerInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.18, centerInnerPaint);
  }

  @override
  bool shouldRepaint(covariant _PokeballPainter oldDelegate) {
    return oldDelegate.isFavorite != isFavorite;
  }
}
