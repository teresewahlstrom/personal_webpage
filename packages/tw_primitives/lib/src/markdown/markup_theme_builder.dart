import 'package:flutter/material.dart';

import 'message_markup_model.dart';

class TwinMarkdownThemeConfig {
  const TwinMarkdownThemeConfig({
    required this.baseStyle,
    required this.baseTextColorFallback,
    required this.linkColor,
    required this.linkDecorationColor,
    required this.decorationThickness,
    required this.strikethroughLightThicknessBias,
    required this.strikethroughDarkThicknessBias,
    required this.isDark,
  });

  final TextStyle baseStyle;
  final Color baseTextColorFallback;
  final Color linkColor;
  final Color linkDecorationColor;
  final double decorationThickness;
  final double strikethroughLightThicknessBias;
  final double strikethroughDarkThicknessBias;
  final bool isDark;
}

ChatMarkupTheme buildTwinMarkdownTheme(TwinMarkdownThemeConfig config) {
  final baseStyle = config.baseStyle;
  final baseColor = baseStyle.color ?? config.baseTextColorFallback;
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

  final double strikeThicknessBias = config.isDark
      ? config.strikethroughDarkThicknessBias
      : config.strikethroughLightThicknessBias;
  final strikethroughStyle = baseStyle.copyWith(
    decoration: TextDecoration.lineThrough,
    decorationColor: baseStyle.color,
    decorationThickness: config.decorationThickness + strikeThicknessBias,
  );

  final underlineStyle = baseStyle.copyWith(
    decoration: TextDecoration.underline,
    decorationColor: baseStyle.color,
    decorationThickness: config.decorationThickness,
  );

  final linkStyle = baseStyle.copyWith(
    color: config.linkColor,
    decoration: TextDecoration.underline,
    decorationColor: config.linkDecorationColor,
    decorationThickness: config.decorationThickness,
  );

  return ChatMarkupTheme(
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
