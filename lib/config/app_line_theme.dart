import 'package:flutter/material.dart';

import 'app_color_theme.dart';

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
  static const double subtle2Width = 1.5;
  static const double subtle3Width = 2;
  static const double accent1Width = 1;

  static AppLineStyle subtleFor(Brightness brightness) {
    return AppLineStyle(
      color: AppColorTheme.lineSubtleFor(brightness),
      width: subtleWidth,
    );
  }

  static AppLineStyle subtle2For(Brightness brightness) {
    return AppLineStyle(
      color: AppColorTheme.lineSubtle2For(brightness),
      width: subtle2Width,
    );
  }

  static AppLineStyle subtle3For(Brightness brightness) {
    return AppLineStyle(
      color: AppColorTheme.lineSubtle3For(brightness),
      width: subtle3Width,
    );
  }

  static AppLineStyle accent1For(Brightness brightness, {bool hovered = false}) {
    return AppLineStyle(
      color: hovered
          ? AppColorTheme.lineAccent1HoverFor(brightness)
          : AppColorTheme.lineAccent1For(brightness),
      width: accent1Width,
    );
  }
}