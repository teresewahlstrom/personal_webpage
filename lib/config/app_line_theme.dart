import 'package:flutter/material.dart';

final class AppLineStyle {
  const AppLineStyle({required this.color, required this.width});

  final Color color;
  final double width;

  BorderSide get borderSide => BorderSide(color: color, width: width);

  Border get borderAll => Border.all(color: color, width: width);

  Paint createPaint() => Paint()
    ..color = color
    ..strokeWidth = width;
}

final class AppLineTheme {
  static const double subtleWidth = 1;
}
