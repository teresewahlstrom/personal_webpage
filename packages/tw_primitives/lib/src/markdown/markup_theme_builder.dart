import 'package:flutter/material.dart';

import '../text_styles/body_text_style.dart';
import 'markup_rendering.dart';

class MarkdownThemeConfig {
  const MarkdownThemeConfig({
    required this.baseTextColor,
    required this.linkColor,
    required this.isDark,
    this.textScale = TwBodyTextStyle.minTextScale,
    this.linkPillStyle,
  });

  static double bodyTextScaleOf(BuildContext context) {
    return TwBodyTextStyle.contextTextScale(context);
  }

  final Color baseTextColor;
  final Color linkColor;
  final bool isDark;
  final double textScale;
  final MarkupLinkPillStyle? linkPillStyle;
}

const double _underlineThickness = 1.9;
const double _strikethroughLightThickness = 2.8;
const double _strikethroughDarkThickness = 5.9;

class MarkdownSurfaceStyle {
  const MarkdownSurfaceStyle({
    required this.bodyTextStyle,
    required this.theme,
    required this.blockquoteRailColor,
  });

  final TextStyle bodyTextStyle;
  final MarkupTheme theme;
  final Color blockquoteRailColor;
}

MarkdownSurfaceStyle buildMarkdownSurfaceStyle(MarkdownThemeConfig config) {
  final baseStyle = TwBodyTextStyle.body(
    color: config.baseTextColor,
    textScale: config.textScale,
  );
  final baseColor = config.baseTextColor;
  final hsl = HSLColor.fromColor(baseColor);
  final lifted = hsl.withLightness((hsl.lightness * 1.10).clamp(0.0, 1.0));
  final FontWeight strongFontWeight = config.isDark
      ? FontWeight.w600
      : FontWeight.w500;
  final strongStyle = baseStyle.copyWith(
    fontWeight: strongFontWeight,
    color: lifted.toColor(),
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

  return MarkdownSurfaceStyle(
    bodyTextStyle: baseStyle,
    blockquoteRailColor: baseColor,
    theme: MarkupTheme(
      baseStyle: baseStyle,
      strongStyle: strongStyle,
      emphasisStyle: baseStyle.copyWith(fontStyle: FontStyle.italic),
      strikethroughStyle: strikethroughStyle,
      underlineStyle: underlineStyle,
      linkStyle: linkStyle,
      linkPillStyle: config.linkPillStyle,
      blockquoteStyle: baseStyle.copyWith(fontStyle: FontStyle.italic),
      headingStyleResolver: (int level) {
        const scales = <double>[2.1, 1.5];
        const weights = <FontWeight>[FontWeight.w300, FontWeight.w400];
        final clampedLevel = level.clamp(1, 2);
        final index = clampedLevel - 1;

        // Apply letterSpacing/wordSpacing for H1 and H2
        return strongStyle.copyWith(
          fontSize: baseStyle.fontSize! * scales[index],
          fontWeight: weights[index],
          height: 1.2,
          letterSpacing: level == 1 ? 0.2 : (level == 2 ? 1.15 : null),
          wordSpacing: level == 1 ? 2.2 : (level == 2 ? 2.2 : null),
        );
      },
    ),
  );
}
