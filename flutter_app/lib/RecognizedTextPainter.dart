import 'dart:ui';
import 'package:flutter/material.dart';

class RecognizedTextPainter extends CustomPainter {
  RecognizedTextPainter(this.texts, this.positions);

  final List<String> texts;
  final List<Offset> positions;

  @override
  void paint(Canvas canvas, Size size) {
    var style = TextStyle(color: Colors.white, fontSize: 24);
    if (texts.length != positions.length) {
      print("Number of texts is not equal to number of rectangles!");
    }
    for (var i = 0; i < texts.length; i++) {
      var text = texts[i];
      var position = positions[i];
      var span = TextSpan(text: text, style: style);
      var painter = TextPainter(text: span, textDirection: TextDirection.ltr);

      painter.layout();
      painter.paint(canvas, position);
    }
  }

  @override
  bool shouldRepaint(RecognizedTextPainter oldDelegate) =>
        texts != oldDelegate.texts || positions != oldDelegate.positions;
}
