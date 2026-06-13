import 'package:flutter/material.dart';
import 'package:tw_primitives/theme.dart';
import 'markup_rendering.dart';

class MarkdownThemeConfig {
  const MarkdownThemeConfig({
    this.baseTextColor,
    this.linkColor,
    required this.isDark,
    this.textScale = 1.0,
    this.linkPillStyle,
  });

  static double bodyTextScaleOf(BuildContext context) {
    final base = context.twTextStyleTokens.twBodyBaseFontSize;
    return MediaQuery.textScalerOf(context).scale(base) / base;
  }

  final Color? baseTextColor;
  final Color? linkColor;
  final bool isDark;
  final double textScale;
  final TwLinkPillStyle? linkPillStyle;
}

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
  final TwColors colors = TwColors.forBrightness(
    config.isDark ? Brightness.dark : Brightness.light,
  );
  final Color baseColor = config.baseTextColor ?? colors.pageBodyText;
  final Color linkColor = config.linkColor ?? colors.linkText;

  final Brightness twBrightness = config.isDark
      ? Brightness.dark
      : Brightness.light;
  final textStyles = TwTextStyles.forBrightness(twBrightness);

  final baseStyle = textStyles.bodyForContextless(
    color: baseColor,
    textScale: config.textScale,
  );
  final strongStyle = textStyles.strongFrom(baseStyle);
  final strikethroughStyle = textStyles.strikethroughFrom(baseStyle);
  final underlineStyle = textStyles.underlineFrom(baseStyle);
  final linkStyle = textStyles.linkFrom(baseStyle, linkColor: linkColor);

  final TwLinkPillStyle defaultLinkPillStyle = computeDefaultTwLinkPillStyle(
    brightness: twBrightness,
    textScale: config.textScale,
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
      linkPillStyle: config.linkPillStyle ?? defaultLinkPillStyle,
      blockquoteStyle: textStyles.blockquoteFrom(baseStyle),
      headingStyleResolver: (int level) {
        if (level == 1) {
          return textStyles.h1From(baseStyle).copyWith(color: colors.pageHeadingText);
        }
        return textStyles.h2From(baseStyle).copyWith(color: colors.pageHeadingText);
      },
      transparentSelectionSpacer: textStyles.transparentSelectionSpacer,
    ),
  );
}
