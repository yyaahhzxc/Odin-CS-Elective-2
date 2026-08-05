import 'package:flutter/material.dart';

class BarcodeWidget extends StatelessWidget {
  final double height;
  final Color color;

  const BarcodeWidget({
    super.key,
    this.height = 45.0,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPainterWidget(
        painter: BarcodePainter(color: color),
      ),
    );
  }
}

class CustomPainterWidget extends StatelessWidget {
  final CustomPainter painter;
  const CustomPainterWidget({super.key, required this.painter});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: painter,
      size: Size.infinite,
    );
  }
}

class BarcodePainter extends CustomPainter {
  final Color color;

  BarcodePainter({this.color = Colors.black});

  // Pattern array representing bar widths and gap widths
  final List<double> barPattern = const [
    3, 2, 1, 3, 4, 1, 2, 3, 1, 2, 4, 2, 1, 3, 2, 4, 1, 3, 2, 1, 4, 2, 3, 1, 2, 3, 4, 1, 2, 3, 1, 4, 2, 1, 3
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double currentX = 0.0;
    // Calculate total pattern units to scale across width
    double totalUnits = 0;
    for (int i = 0; i < barPattern.length; i++) {
      totalUnits += barPattern[i] + (i % 2 == 0 ? 1.5 : 1.0);
    }

    final unitWidth = size.width / totalUnits;

    for (int i = 0; i < barPattern.length; i++) {
      final width = barPattern[i] * unitWidth;
      final isBar = i % 2 == 0;

      if (isBar) {
        final rect = Rect.fromLTWH(currentX, 0, width, size.height);
        canvas.drawRect(rect, paint);
      }
      currentX += width + (isBar ? unitWidth * 1.5 : unitWidth);
    }
  }

  @override
  bool shouldRepaint(covariant BarcodePainter oldDelegate) => oldDelegate.color != color;
}
