import 'package:flutter/material.dart';

import 'package:tw_primitives/theme.dart';

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
  static const double interactiveWidth = 1;

  static AppLineStyle subtleFor(Brightness brightness) {
    return AppLineStyle(
      color: TwColors.forBrightness(brightness).lineSubtle,
      width: subtleWidth,
    );
  }

  static AppLineStyle subtleSecondaryFor(Brightness brightness) {
    return AppLineStyle(
      color: TwColors.forBrightness(brightness).lineSubtleSecondary,
      width: subtleSecondaryWidth,
    );
  }

  static AppLineStyle subtleTertiaryFor(Brightness brightness) {
    return AppLineStyle(
      color: TwColors.forBrightness(brightness).lineSubtleTertiary,
      width: subtleTertiaryWidth,
    );
  }

  static AppLineStyle interactiveFor(Brightness brightness, {bool hovered = false}) {
    return AppLineStyle(
      color: hovered
          ? TwColors.forBrightness(brightness).lineInteractiveHover
          : TwColors.forBrightness(brightness).lineInteractive,
      width: interactiveWidth,
    );
  }
}