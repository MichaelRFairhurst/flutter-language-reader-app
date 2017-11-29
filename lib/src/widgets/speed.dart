import 'package:flutter/material.dart';

class SpeedPainter extends CustomPainter {
  static const blockHeight = 10.0;

  SpeedPainter(this.speed);

  final double speed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = new Paint()
      ..color = Colors.blue[400]
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      new Rect.fromLTWH(
        size.height - speed / 2,
        (size.width - blockHeight) / 2.0,
        speed / 2,
        blockHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(SpeedPainter old) => speed != old.speed;
}
