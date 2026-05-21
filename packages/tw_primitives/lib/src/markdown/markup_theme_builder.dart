import 'package:flutter/material.dart';

import 'markup_model.dart';

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

const TextStyle _baseTextStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 14.0,
  fontWeight: FontWeight.w500,
  height: 1.38,
  letterSpacing: 0.0,
);

MarkupTheme buildMarkdownTheme(MarkdownThemeConfig config) {
  final baseStyle = _baseTextStyle.copyWith(
    color: config.baseTextColor,
  );
  final baseColor = baseStyle.color ?? config.baseTextColor;
  final hsl = HSLColor.fromColor(baseColor);
  final lifted = hsl.withLightness((hsl.lightness * 1.10).clamp(0.0, 1.0));
  final baseLetterSpacing = baseStyle.letterSpacing ?? 0.0;
  final strongBase = _isNunitoFamily(baseStyle.fontFamily)
      ? baseStyle.copyWith(
          fontSize: baseStyle.fontSize,
          height: baseStyle.height,
          color: baseColor,
          fontWeight: FontWeight.w700,
        )
      : baseStyle;

  final strongStyle = strongBase.copyWith(
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

      double? fontSize = baseStyle.fontSize == null
          ? null
          : baseStyle.fontSize! * scales[index];
      if (clampedLevel == 1 && fontSize != null) {
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

bool _isNunitoFamily(String? family) {
  if (family == null || family.isEmpty) {
    return false;
  }
  return family.trim().toLowerCase() == 'nunito';
}
