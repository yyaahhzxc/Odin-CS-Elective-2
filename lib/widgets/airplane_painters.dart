import 'package:flutter/material.dart';

/// Custom painter for the line-art airplane with trailing speed lines
class AirplaneLineArtPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  AirplaneLineArtPainter({
    this.color = Colors.white,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final width = size.width;
    final height = size.height;

    // Scale & center translation matrix
    canvas.save();
    canvas.translate(width * 0.1, height * 0.1);
    canvas.scale(width * 0.8 / 100, height * 0.8 / 100);

    // Fuselage & Nose path
    final fuselage = Path();
    fuselage.moveTo(85, 15); // Nose (top right direction)
    fuselage.quadraticBezierTo(70, 30, 45, 45); // Upper body
    fuselage.lineTo(15, 60); // Tail section
    fuselage.quadraticBezierTo(20, 50, 30, 40); // Underbody
    fuselage.lineTo(65, 20);
    fuselage.close();
    canvas.drawPath(fuselage, paint);

    // Right/Top Wing
    final topWing = Path();
    topWing.moveTo(55, 30);
    topWing.lineTo(40, 5);
    topWing.lineTo(25, 20);
    topWing.lineTo(45, 38);
    canvas.drawPath(topWing, paint);

    // Left/Bottom Wing
    final bottomWing = Path();
    bottomWing.moveTo(45, 45);
    bottomWing.lineTo(60, 85);
    bottomWing.lineTo(72, 75);
    bottomWing.lineTo(60, 38);
    canvas.drawPath(bottomWing, paint);

    // Tail fin
    final tailFin = Path();
    tailFin.moveTo(20, 57);
    tailFin.lineTo(5, 50);
    tailFin.lineTo(10, 68);
    canvas.drawPath(tailFin, paint);

    // Trailing motion lines
    canvas.drawLine(const Offset(0, 75), const Offset(25, 55), paint);
    canvas.drawLine(const Offset(10, 85), const Offset(30, 68), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AirplaneLineArtPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Large background watermark airplane outline
class AirplaneWatermarkPainter extends CustomPainter {
  final Color color;

  AirplaneWatermarkPainter({
    this.color = const Color(0x1AFFFFFF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;

    final path = Path();
    // Large stylized airplane outline path
    path.moveTo(width * 0.85, height * 0.15);
    path.cubicTo(width * 0.70, height * 0.25, width * 0.50, height * 0.40, width * 0.35, height * 0.55);
    path.lineTo(width * 0.15, height * 0.70);
    // Tail
    path.lineTo(width * 0.05, height * 0.60);
    path.lineTo(width * 0.12, height * 0.80);
    path.lineTo(width * 0.28, height * 0.72);
    // Wing
    path.lineTo(width * 0.45, height * 0.95);
    path.lineTo(width * 0.60, height * 0.90);
    path.lineTo(width * 0.50, height * 0.58);
    // Top Wing
    path.lineTo(width * 0.70, height * 0.10);
    path.lineTo(width * 0.55, height * 0.22);
    path.lineTo(width * 0.62, height * 0.45);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AirplaneWatermarkPainter oldDelegate) => false;
}

/// Flight trajectory arrow painter (used between city codes SFO -> NYC)
class FlightTrajectoryPainter extends CustomPainter {
  final Color color;
  final bool isReturn;

  FlightTrajectoryPainter({
    required this.color,
    this.isReturn = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final cy = size.height / 2;

    // Flight path with center loop/wave or line
    final path = Path();
    path.moveTo(0, cy);
    path.quadraticBezierTo(width * 0.4, cy - 8, width * 0.5, cy);
    path.quadraticBezierTo(width * 0.6, cy + 8, width, cy);
    canvas.drawPath(path, paint);

    // Draw small airplane in center
    canvas.save();
    canvas.translate(width / 2, cy);
    if (isReturn) {
      canvas.scale(-1, 1);
    }

    final planePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final planePath = Path();
    planePath.moveTo(12, 0);
    planePath.lineTo(-6, -6);
    planePath.lineTo(-2, 0);
    planePath.lineTo(-6, 6);
    planePath.close();

    // Wings
    planePath.moveTo(2, 0);
    planePath.lineTo(-3, -10);
    planePath.lineTo(1, -10);
    planePath.lineTo(6, 0);

    planePath.moveTo(2, 0);
    planePath.lineTo(-3, 10);
    planePath.lineTo(1, 10);
    planePath.lineTo(6, 0);

    canvas.drawPath(planePath, planePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FlightTrajectoryPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isReturn != isReturn;
}
