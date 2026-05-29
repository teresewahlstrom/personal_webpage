import 'package:flutter/material.dart';

import 'body_text_style.dart';

final class TwSectionTitleTextStyle {
  static const double baseFontSize = 35.0;
  static const double lineHeight = 1.0;
  static const FontWeight fontWeight = FontWeight.w700;
  static const double scaleIntensity = 0.5;

  static TextStyle forContext({
    required BuildContext context,
    required Color color,
    double baseSize = baseFontSize,
  }) {
    final resolvedTextScale = TwBodyTextStyle.resolveTextScale(
      MediaQuery.textScalerOf(context).scale(baseSize) / baseSize,
    );
    return TextStyle(
      fontFamily: 'ComingSoon',
      fontWeight: fontWeight,
      fontSize: TwBodyTextStyle.scaledFontSize(
        baseSize,
        resolvedTextScale,
        intensity: scaleIntensity,
      ),
      height: lineHeight,
      color: color,
    );
  }
}