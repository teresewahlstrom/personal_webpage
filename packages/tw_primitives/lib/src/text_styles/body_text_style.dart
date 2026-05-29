import 'package:flutter/material.dart';

final class TwBodyTextStyle {
  static const String fontFamily = 'Nunito';
  static const double baseFontSize = 18.0;
  static const FontWeight fontWeight = FontWeight.w300;
  static const double lineHeight = 1.42;
  static const double minTextScale = 1.0;
  static const double defaultMaxTextScale = 1.6;
  static const double scaleIntensity = 0.7;

  static double contextTextScale(BuildContext context) {
    return MediaQuery.textScalerOf(context).scale(baseFontSize) / baseFontSize;
  }

  static TextStyle bodyForContext({
    required BuildContext context,
    required Color color,
    double baseSize = baseFontSize,
    double lineHeight = TwBodyTextStyle.lineHeight,
    FontWeight weight = fontWeight,
    TextDecoration decoration = TextDecoration.none,
    double maxTextScale = defaultMaxTextScale,
    double intensity = scaleIntensity,
  }) {
    final resolvedTextScale = resolveTextScale(
      MediaQuery.textScalerOf(context).scale(baseSize) / baseSize,
      maxTextScale: maxTextScale,
    );
    return TextStyle(
      fontFamily: fontFamily,
      fontWeight: weight,
      fontSize: scaledFontSize(
        baseSize,
        resolvedTextScale,
        intensity: intensity,
      ),
      height: lineHeight,
      decoration: decoration,
      color: color,
    );
  }

  static double resolveTextScale(
    double textScale, {
    double maxTextScale = defaultMaxTextScale,
  }) {
    if (!textScale.isFinite || textScale <= 0) {
      return minTextScale;
    }
    return textScale.clamp(minTextScale, maxTextScale).toDouble();
  }

  static double scaledFontSize(
    double base,
    double textScale, {
    double intensity = scaleIntensity,
  }) {
    return base * (1 + (textScale - 1) * intensity);
  }

  static TextStyle body({
    required Color color,
    required double textScale,
    double maxTextScale = defaultMaxTextScale,
  }) {
    return bodyForContextless(
      color: color,
      textScale: textScale,
      baseSize: baseFontSize,
      lineHeight: lineHeight,
      weight: fontWeight,
      decoration: TextDecoration.none,
      maxTextScale: maxTextScale,
      intensity: scaleIntensity,
    );
  }

  static TextStyle bodyForContextless({
    required Color color,
    required double textScale,
    required double baseSize,
    required double lineHeight,
    required FontWeight weight,
    required TextDecoration decoration,
    double maxTextScale = defaultMaxTextScale,
    double intensity = scaleIntensity,
  }) {
    final resolvedTextScale = resolveTextScale(
      textScale,
      maxTextScale: maxTextScale,
    );
    return TextStyle(
      fontFamily: fontFamily,
      fontWeight: weight,
      fontSize: scaledFontSize(baseSize, resolvedTextScale, intensity: intensity),
      height: lineHeight,
      decoration: decoration,
      color: color,
    );
  }
}