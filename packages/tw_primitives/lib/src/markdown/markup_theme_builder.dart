import 'package:flutter/material.dart';

import 'markup_rendering.dart';

class MarkdownThemeConfig {
  const MarkdownThemeConfig({
    required this.baseTextColor,
    required this.linkColor,
    required this.isDark,
  });

  final Color baseTextColor;
  final Color linkColor;
  final bool isDark;
}

const double _underlineThickness = 1.9;
const double _strikethroughLightThickness = 2.8;
const double _strikethroughDarkThickness = 5.9;

MarkupTheme buildMarkdownTheme(MarkdownThemeConfig config) {
  final baseStyle = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 15.0,
    fontWeight: FontWeight.w300,
    height: 1.3,
    letterSpacing: 0.0,
  ).copyWith(color: config.baseTextColor);
  final baseColor = config.baseTextColor;
  final hsl = HSLColor.fromColor(baseColor);
  final lifted = hsl.withLightness((hsl.lightness * 1.10).clamp(0.0, 1.0));
  final baseLetterSpacing = baseStyle.letterSpacing!;
  final strongStyle = baseStyle.copyWith(
    fontWeight: FontWeight.w900,
    color: lifted.toColor(),
    letterSpacing: baseLetterSpacing + 0.45,
  );

  final double strikeThickness = config.isDark
      ? _strikethroughDarkThickness
      : _strikethroughLightThickness;
  final strikethroughStyle = baseStyle.copyWith(
    decoration: TextDecoration.lineThrough,
    decorationColor: baseStyle.color,
    decorationThickness: strikeThickness,
  );

  final underlineStyle = baseStyle.copyWith(
    decoration: TextDecoration.underline,
    decorationColor: baseStyle.color,
    decorationThickness: _underlineThickness,
  );

  final linkStyle = baseStyle.copyWith(
    color: config.linkColor,
    decoration: TextDecoration.underline,
    decorationColor: config.linkColor,
    decorationThickness: _underlineThickness,
  );

  return MarkupTheme(
    baseStyle: baseStyle,
    strongStyle: strongStyle,
    emphasisStyle: baseStyle.copyWith(fontStyle: FontStyle.italic),
    strikethroughStyle: strikethroughStyle,
    underlineStyle: underlineStyle,
    linkStyle: linkStyle,
    blockquoteStyle: baseStyle.copyWith(fontStyle: FontStyle.italic),
    headingStyleResolver: (int level) {
      const scales = <double>[1.55, 1.36];
      const weights = <FontWeight>[FontWeight.w600, FontWeight.w700];
      final clampedLevel = level.clamp(1, 2);
      final index = clampedLevel - 1;

      double fontSize = baseStyle.fontSize! * scales[index];
      if (clampedLevel == 1) {
        fontSize += 2.0;
      }

      return strongStyle.copyWith(
        fontSize: fontSize,
        fontWeight: weights[index],
        height: 1.2,
      );
    },
  );
}
