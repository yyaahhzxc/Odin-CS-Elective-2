import 'package:flutter/material.dart';
import '../models/fruit.dart';

/// Clean, scalable vector illustrations for the fruits.
class FruitIllustration extends StatelessWidget {
  final String slug;
  final double size;

  const FruitIllustration({
    super.key,
    required this.slug,
    this.size = 100.0,
  });

  factory FruitIllustration.fromFruit(Fruit fruit, {double size = 100.0}) {
    return FruitIllustration(slug: fruit.slug, size: size);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: CustomPaint(
          size: Size(size, size),
          painter: _getPainter(slug),
        ),
      ),
    );
  }

  CustomPainter _getPainter(String slug) {
    switch (slug.toLowerCase()) {
      case 'apple':
        return const _ApplePainter();
      case 'banana':
        return const _BananaPainter();
      case 'strawberry':
        return const _StrawberryPainter();
      case 'orange':
        return const _OrangePainter();
      case 'mango':
        return const _MangoPainter();
      case 'watermelon':
        return const _WatermelonPainter();
      default:
        return const _ApplePainter();
    }
  }
}

// ---------------------------------------------------------------------------
// 1. APPLE PAINTER
// ---------------------------------------------------------------------------
class _ApplePainter extends CustomPainter {
  const _ApplePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2 + h * 0.05);

    // Body
    final bodyPaint = Paint()
      ..color = const Color(0xFFE11D48)
      ..style = PaintingStyle.fill;

    final bodyPath = Path();
    bodyPath.moveTo(center.dx, center.dy - h * 0.32);
    bodyPath.cubicTo(center.dx + w * 0.28, center.dy - h * 0.44, center.dx + w * 0.46, center.dy - h * 0.15, center.dx + w * 0.42, center.dy + h * 0.15);
    bodyPath.cubicTo(center.dx + w * 0.38, center.dy + h * 0.38, center.dx + w * 0.15, center.dy + h * 0.42, center.dx, center.dy + h * 0.35);
    bodyPath.cubicTo(center.dx - w * 0.15, center.dy + h * 0.42, center.dx - w * 0.38, center.dy + h * 0.38, center.dx - w * 0.42, center.dy + h * 0.15);
    bodyPath.cubicTo(center.dx - w * 0.46, center.dy - h * 0.15, center.dx - w * 0.28, center.dy - h * 0.44, center.dx, center.dy - h * 0.32);
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final stemPath = Path();
    stemPath.moveTo(center.dx, center.dy - h * 0.3);
    stemPath.quadraticBezierTo(center.dx + w * 0.06, center.dy - h * 0.42, center.dx + w * 0.12, center.dy - h * 0.46);
    canvas.drawPath(stemPath, stemPaint);

    // Leaf
    final leafPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;
    final leafPath = Path();
    leafPath.moveTo(center.dx + w * 0.04, center.dy - h * 0.36);
    leafPath.quadraticBezierTo(center.dx + w * 0.28, center.dy - h * 0.48, center.dx + w * 0.34, center.dy - h * 0.34);
    leafPath.quadraticBezierTo(center.dx + w * 0.18, center.dy - h * 0.26, center.dx + w * 0.04, center.dy - h * 0.36);
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// 2. BANANA PAINTER
// ---------------------------------------------------------------------------
class _BananaPainter extends CustomPainter {
  const _BananaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body
    final bodyPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    final bodyPath = Path();
    bodyPath.moveTo(w * 0.18, h * 0.22);
    bodyPath.cubicTo(w * 0.40, h * 0.18, w * 0.85, h * 0.42, w * 0.78, h * 0.84);
    bodyPath.lineTo(w * 0.72, h * 0.86);
    bodyPath.cubicTo(w * 0.72, h * 0.54, w * 0.38, h * 0.36, w * 0.16, h * 0.32);
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Ridge line
    final ridgePaint = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;
    final ridgePath = Path();
    ridgePath.moveTo(w * 0.22, h * 0.26);
    ridgePath.cubicTo(w * 0.46, h * 0.24, w * 0.78, h * 0.45, w * 0.74, h * 0.82);
    canvas.drawPath(ridgePath, ridgePaint);

    // Stem Cap
    final stemPaint = Paint()
      ..color = const Color(0xFF65A30D)
      ..style = PaintingStyle.fill;
    final stemPath = Path();
    stemPath.moveTo(w * 0.18, h * 0.22);
    stemPath.lineTo(w * 0.10, h * 0.16);
    stemPath.lineTo(w * 0.08, h * 0.22);
    stemPath.lineTo(w * 0.16, h * 0.32);
    stemPath.close();
    canvas.drawPath(stemPath, stemPaint);

    // Tip
    final tipPaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawCircle(Offset(w * 0.76, h * 0.85), w * 0.04, tipPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// 3. STRAWBERRY PAINTER
// ---------------------------------------------------------------------------
class _StrawberryPainter extends CustomPainter {
  const _StrawberryPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // Body
    final bodyPaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.fill;

    final bodyPath = Path();
    bodyPath.moveTo(cx, h * 0.26);
    bodyPath.cubicTo(w * 0.88, h * 0.26, w * 0.82, h * 0.65, cx, h * 0.90);
    bodyPath.cubicTo(w * 0.18, h * 0.65, w * 0.12, h * 0.26, cx, h * 0.26);
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Seeds
    final seedPaint = Paint()..color = const Color(0xFFFDE047);
    final seeds = [
      Offset(cx - w * 0.14, h * 0.40),
      Offset(cx + w * 0.14, h * 0.40),
      Offset(cx - w * 0.20, h * 0.54),
      Offset(cx, h * 0.52),
      Offset(cx + w * 0.20, h * 0.54),
      Offset(cx - w * 0.10, h * 0.68),
      Offset(cx + w * 0.10, h * 0.68),
      Offset(cx, h * 0.80),
    ];
    for (final s in seeds) {
      canvas.drawOval(Rect.fromCenter(center: s, width: w * 0.035, height: h * 0.055), seedPaint);
    }

    // Leaf Calyx
    final calyxPaint = Paint()..color = const Color(0xFF16A34A);
    final calyxPath = Path();
    calyxPath.moveTo(cx, h * 0.26);
    calyxPath.lineTo(cx - w * 0.35, h * 0.20);
    calyxPath.lineTo(cx - w * 0.15, h * 0.28);
    calyxPath.lineTo(cx, h * 0.12);
    calyxPath.lineTo(cx + w * 0.15, h * 0.28);
    calyxPath.lineTo(cx + w * 0.35, h * 0.20);
    calyxPath.lineTo(cx, h * 0.26);
    calyxPath.close();
    canvas.drawPath(calyxPath, calyxPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// 4. ORANGE PAINTER
// ---------------------------------------------------------------------------
class _OrangePainter extends CustomPainter {
  const _OrangePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2 + h * 0.04);
    final radius = w * 0.38;

    // Body
    final bodyPaint = Paint()..color = const Color(0xFFEA580C);
    canvas.drawCircle(center, radius, bodyPaint);

    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(center.dx, center.dy - radius + h * 0.02), Offset(center.dx, center.dy - radius - h * 0.08), stemPaint);

    // Leaves
    final leafPaint = Paint()..color = const Color(0xFF15803D);
    final rLeaf = Path();
    rLeaf.moveTo(center.dx, center.dy - radius - h * 0.02);
    rLeaf.quadraticBezierTo(center.dx + w * 0.28, center.dy - radius - h * 0.12, center.dx + w * 0.32, center.dy - radius + h * 0.02);
    rLeaf.quadraticBezierTo(center.dx + w * 0.14, center.dy - radius + h * 0.02, center.dx, center.dy - radius - h * 0.02);
    rLeaf.close();
    canvas.drawPath(rLeaf, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// 5. MANGO PAINTER
// ---------------------------------------------------------------------------
class _MangoPainter extends CustomPainter {
  const _MangoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body
    final bodyPaint = Paint()..color = const Color(0xFFF59E0B);
    final path = Path();
    path.moveTo(w * 0.45, h * 0.22);
    path.cubicTo(w * 0.88, h * 0.24, w * 0.88, h * 0.68, w * 0.58, h * 0.88);
    path.cubicTo(w * 0.42, h * 0.94, w * 0.28, h * 0.86, w * 0.26, h * 0.72);
    path.cubicTo(w * 0.24, h * 0.50, w * 0.22, h * 0.32, w * 0.45, h * 0.22);
    path.close();
    canvas.drawPath(path, bodyPaint);

    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.45, h * 0.23), Offset(w * 0.42, h * 0.12), stemPaint);

    // Leaf
    final leafPaint = Paint()..color = const Color(0xFF16A34A);
    final leaf = Path();
    leaf.moveTo(w * 0.43, h * 0.16);
    leaf.quadraticBezierTo(w * 0.20, h * 0.10, w * 0.14, h * 0.18);
    leaf.quadraticBezierTo(w * 0.28, h * 0.22, w * 0.43, h * 0.16);
    leaf.close();
    canvas.drawPath(leaf, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// 6. WATERMELON PAINTER
// ---------------------------------------------------------------------------
class _WatermelonPainter extends CustomPainter {
  const _WatermelonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // Outer Green Rind
    final rindPaint = Paint()..color = const Color(0xFF15803D);
    final rindPath = Path();
    rindPath.moveTo(w * 0.10, h * 0.32);
    rindPath.lineTo(cx, h * 0.88);
    rindPath.lineTo(w * 0.90, h * 0.32);
    rindPath.arcToPoint(Offset(w * 0.10, h * 0.32), radius: Radius.circular(w * 0.80), clockwise: false);
    rindPath.close();
    canvas.drawPath(rindPath, rindPaint);

    // White Pith
    final pithPaint = Paint()..color = const Color(0xFFECFDF5);
    final pithPath = Path();
    pithPath.moveTo(w * 0.14, h * 0.34);
    pithPath.lineTo(cx, h * 0.82);
    pithPath.lineTo(w * 0.86, h * 0.34);
    pithPath.arcToPoint(Offset(w * 0.14, h * 0.34), radius: Radius.circular(w * 0.74), clockwise: false);
    pithPath.close();
    canvas.drawPath(pithPath, pithPaint);

    // Red Flesh
    final fleshPaint = Paint()..color = const Color(0xFFE11D48);
    final fleshPath = Path();
    fleshPath.moveTo(w * 0.18, h * 0.36);
    fleshPath.lineTo(cx, h * 0.78);
    fleshPath.lineTo(w * 0.82, h * 0.36);
    fleshPath.arcToPoint(Offset(w * 0.18, h * 0.36), radius: Radius.circular(w * 0.68), clockwise: false);
    fleshPath.close();
    canvas.drawPath(fleshPath, fleshPaint);

    // Seeds
    final seedPaint = Paint()..color = const Color(0xFF18181B);
    final seeds = [
      Offset(cx - w * 0.12, h * 0.44),
      Offset(cx + w * 0.12, h * 0.44),
      Offset(cx, h * 0.54),
    ];
    for (final s in seeds) {
      canvas.drawOval(Rect.fromCenter(center: s, width: w * 0.035, height: h * 0.06), seedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
