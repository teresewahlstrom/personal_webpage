import 'package:flutter/material.dart';
import 'package:tw_primitives/theme.dart';
// Use public tokens from the text styles router rather than internal files.
import 'markup_rendering.dart';
import 'markup_view_style.dart';

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

// Use canonical markdown decoration thickness constants from
// `markup_view_style.dart` to avoid duplicated values. Refer to the
// static members on `MarkupViewStyle`.
const double _underlineThickness = MarkupViewStyle.underlineThickness;
const double _strikethroughLightThickness = MarkupViewStyle.strikethroughLightThickness;
const double _strikethroughDarkThickness = MarkupViewStyle.strikethroughDarkThickness;

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
  final tokens = TwTextStyleTokens.forBrightness(config.isDark ? Brightness.dark : Brightness.light);
  final Color baseColor = config.baseTextColor ?? colors.pageBodyText;
  final Color linkColor = config.linkColor ?? colors.linkText;

  final baseStyle = TwTextStyles.forBrightness(
    config.isDark ? Brightness.dark : Brightness.light,
  ).bodyForContextless(
    color: baseColor,
    textScale: config.textScale,
  );
  final hsl = HSLColor.fromColor(baseColor);
  final lifted = hsl.withLightness((hsl.lightness * 1.10).clamp(0.0, 1.0));
  final FontWeight strongFontWeight = tokens.twStrongFontWeight;
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
    color: linkColor,
    decoration: TextDecoration.underline,
    decorationColor: linkColor,
    decorationThickness: _underlineThickness,
  );

  // Provide a default pill style so consumers don't need to pass one.
  // Derive pill shadow from theme's bubble shadow (matches chat's jump button)

  // Derive pill text style to match previous chat visuals (appBarTitleStyle):
  // smallFrom(base) then scale fontSize/height using intensities 0.7 / 0.18
  final Brightness twBrightness = config.isDark ? Brightness.dark : Brightness.light;
  final TextStyle pillBase = TwTextStyles.forBrightness(twBrightness)
      .bodyForContextless(color: baseColor, textScale: 1.0);
  final TextStyle pillBaseAdjusted = TwTextStyles.forBrightness(twBrightness)
      .smallFrom(pillBase);
  final double resolvedScale = (config.textScale.isFinite && config.textScale > 0)
      ? config.textScale.clamp(1.0, 1.6)
      : 1.0;
  final double pillFontSize = (pillBaseAdjusted.fontSize ?? 14.0) * (1 + (resolvedScale - 1) * 0.7);
  final double pillHeight = (pillBaseAdjusted.height ?? 1.0) * (1 + (resolvedScale - 1) * 0.18);
  final TextStyle pillTextStyle = TwTextStyles.forBrightness(twBrightness).adaptBase(
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
      blockquoteStyle: baseStyle.copyWith(fontStyle: FontStyle.italic),
      headingStyleResolver: (int level) {
        final scales = <double>[2.1, tokens.twProfessionalStoryH2Scale];
        final weights = <FontWeight>[tokens.twH1FontWeight, tokens.twH2FontWeight];
        final clampedLevel = level.clamp(1, 2);
        final index = clampedLevel - 1;

        final double? letterSpacing = clampedLevel == 1
            ? tokens.twH1LetterSpacing
            : (clampedLevel == 2 ? tokens.twH2LetterSpacing : null);
        final double? wordSpacing = clampedLevel == 1
            ? tokens.twH1WordSpacing
            : (clampedLevel == 2 ? tokens.twH2WordSpacing : null);

        return strongStyle.copyWith(
          fontSize: baseStyle.fontSize! * scales[index],
          fontWeight: weights[index],
          height: 1.2,
          letterSpacing: letterSpacing,
          wordSpacing: wordSpacing,
        );
      },
      transparentSelectionSpacer: tokens.twTransparentSelectionSpacer,
    ),
  );
}
