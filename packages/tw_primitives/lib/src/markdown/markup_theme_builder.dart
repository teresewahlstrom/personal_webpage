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

  final Brightness twBrightness = config.isDark ? Brightness.dark : Brightness.light;
  final textStyles = TwTextStyles.forBrightness(twBrightness);

  final baseStyle = textStyles.bodyForContextless(
    color: baseColor,
    textScale: config.textScale,
  );
  final strongStyle = textStyles.strongFrom(baseStyle);
  final strikethroughStyle = textStyles.strikethroughFrom(baseStyle);
  final underlineStyle = textStyles.underlineFrom(baseStyle);
  final linkStyle = textStyles.linkFrom(baseStyle, linkColor: linkColor);

  // Provide a default pill style so consumers don't need to pass one.
  // Derive pill shadow from theme's bubble shadow (matches chat's jump button)

  // Derive pill text style to match previous chat visuals (appBarTitleStyle):
  // smallFrom(base) then scale fontSize/height using intensities 0.7 / 0.18
  final TextStyle pillBase = textStyles.bodyForContextless(color: baseColor, textScale: 1.0);
  final TextStyle pillBaseAdjusted = textStyles.smallFrom(pillBase);
  final double resolvedScale = (config.textScale.isFinite && config.textScale > 0)
      ? config.textScale.clamp(1.0, 1.6)
      : 1.0;
  final double pillFontSize = (pillBaseAdjusted.fontSize ?? 14.0) * (1 + (resolvedScale - 1) * 0.7);
  final double pillHeight = (pillBaseAdjusted.height ?? 1.0) * (1 + (resolvedScale - 1) * 0.18);
  final TextStyle pillTextStyle = textStyles.adaptBase(
    pillBaseAdjusted,
    color: colors.bubbleText,
    fontSize: pillFontSize,
    height: pillHeight,
  );

  // Derive fill/border to match ChatComposerLayout.fillColor/borderColor.
  // Use canonical markdown/link-pill lerp tokens rather than chat-only tokens.

  final TwLinkPillStyle defaultLinkPillStyle = computeDefaultTwLinkPillStyle(
    brightness: twBrightness,
    textScale: resolvedScale,
  ).copyWith(textStyle: pillTextStyle);

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
          return textStyles.h1From(baseStyle);
        }
        return textStyles.h2From(baseStyle);
      },
      transparentSelectionSpacer: textStyles.transparentSelectionSpacer,
    ),
  );
}
