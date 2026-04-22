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
  static const double subtleSecondaryWidth = 1.5;
  static const double subtleTertiaryWidth = 2;
  static const double accentWidth = 1;

  static AppLineStyle subtleFor(Brightness brightness) {
    return AppLineStyle(
      color: AppColorTheme.lineSubtleFor(brightness),
      width: subtleWidth,
    );
  }

  static AppLineStyle subtleSecondaryFor(Brightness brightness) {
    return AppLineStyle(
      color: AppColorTheme.lineSubtleSecondaryFor(brightness),
      width: subtleSecondaryWidth,
    );
  }

  static AppLineStyle subtleTertiaryFor(Brightness brightness) {
    return AppLineStyle(
      color: AppColorTheme.lineSubtleTertiaryFor(brightness),
      width: subtleTertiaryWidth,
    );
  }

  static AppLineStyle accentFor(Brightness brightness, {bool hovered = false}) {
    return AppLineStyle(
      color: hovered
          ? AppColorTheme.lineAccentHoverFor(brightness)
          : AppColorTheme.lineAccentFor(brightness),
      width: accentWidth,
    );
  }
}