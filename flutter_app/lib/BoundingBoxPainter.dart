import 'dart:ui';
import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  BoundingBoxPainter(this.boxes);

  final List<Rect> boxes;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.green
      ..strokeWidth = 3;

    if (boxes.isNotEmpty) {
      for (var box in boxes) {
        canvas.drawRect(box, paint);
      }
    }
  }

  @override
  bool shouldRepaint(BoundingBoxPainter oldDelegate) =>
      boxes != oldDelegate.boxes;
}
