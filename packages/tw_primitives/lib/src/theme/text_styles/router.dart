import 'package:flutter/material.dart';
import '_dark.dart' as dark;
import '_light.dart' as light;
import 'impl.dart';
import '_styles.dart' as styles;

// Public convenience accessor for the canonical font family token.
// This allows consumers to import the public `package:tw_primitives/theme.dart`
// and use `twFontFamily` without reaching into `lib/src` implementation files.
const String twFontFamily = dark.TwTextStyleTokensDark.twFontFamily;

// Router exposing token values per-brightness. Use `TwTextStyleTokens.forBrightness`
// or the `twTextStyleTokens` BuildContext extension to access brightness-aware
// token values (preferred over top-level constants).
class TwTextStyleTokens {
  const TwTextStyleTokens._({
    required this.twFontFamily,
    required this.twBodyBaseFontSize,
    required this.twBodyFontWeight,
    required this.twBodyLineHeight,
    required this.twBodyMinTextScale,
    required this.twBodyDefaultMaxTextScale,
    required this.twBodyScaleIntensity,
    required this.twSectionBaseFontSize,
    required this.twSectionLineHeight,
    required this.twSectionFontWeight,
    required this.twSectionScaleIntensity,
    required this.twModalHeaderFontSize,
    required this.twModalHeaderLineHeight,
    required this.twModalHeaderFontWeight,
    required this.twFooterBaseFontSize,
    required this.twH1Scale,
    required this.twH2Scale,
    required this.twH1FontWeight,
    required this.twH2FontWeight,
    required this.twH1LetterSpacing,
    required this.twH1WordSpacing,
    required this.twH2LetterSpacing,
    required this.twH2WordSpacing,
    required this.twBlockquoteFontSize,
    required this.twSmallFontSize,
    required this.twToolbarFontSize,
    required this.twStrikethroughThickness,
    required this.twCardTitleShadows,
  });

  final String twFontFamily;
  final double twBodyBaseFontSize;
  final FontWeight twBodyFontWeight;
  final double twBodyLineHeight;
  final double twBodyMinTextScale;
  final double twBodyDefaultMaxTextScale;
  final double twBodyScaleIntensity;
  final double twSectionBaseFontSize;
  final double twSectionLineHeight;
  final FontWeight twSectionFontWeight;
  final double twSectionScaleIntensity;
  final double twModalHeaderFontSize;
  final double twModalHeaderLineHeight;
  final FontWeight twModalHeaderFontWeight;
  final double twFooterBaseFontSize;
  final double twH1Scale;
  final double twH2Scale;
  final FontWeight twH1FontWeight;
  final FontWeight twH2FontWeight;
  final double twH1LetterSpacing;
  final double twH1WordSpacing;
  final double twH2LetterSpacing;
  final double twH2WordSpacing;
  final double twBlockquoteFontSize;
  final double twSmallFontSize;
  final double twToolbarFontSize;
  final double twStrikethroughThickness;
  final List<Shadow> twCardTitleShadows;

  static TwTextStyleTokens forBrightness(Brightness brightness) {
    if (brightness == Brightness.dark) return TwTextStyleTokens._fromDark();
    return TwTextStyleTokens._fromLight();
  }

  static TwTextStyleTokens _fromDark() => TwTextStyleTokens._(
        twFontFamily: dark.TwTextStyleTokensDark.twFontFamily,
        twBodyBaseFontSize: dark.TwTextStyleTokensDark.twBodyBaseFontSize,
        twBodyFontWeight: dark.TwTextStyleTokensDark.twBodyFontWeight,
        twBodyLineHeight: dark.TwTextStyleTokensDark.twBodyLineHeight,
        twBodyMinTextScale: dark.TwTextStyleTokensDark.twBodyMinTextScale,
        twBodyDefaultMaxTextScale: dark.TwTextStyleTokensDark.twBodyDefaultMaxTextScale,
        twBodyScaleIntensity: dark.TwTextStyleTokensDark.twBodyScaleIntensity,
        twSectionBaseFontSize: dark.TwTextStyleTokensDark.twSectionBaseFontSize,
        twSectionLineHeight: dark.TwTextStyleTokensDark.twSectionLineHeight,
        twSectionFontWeight: dark.TwTextStyleTokensDark.twSectionFontWeight,
        twSectionScaleIntensity: dark.TwTextStyleTokensDark.twSectionScaleIntensity,
        twModalHeaderFontSize: dark.TwTextStyleTokensDark.twModalHeaderFontSize,
        twModalHeaderLineHeight: dark.TwTextStyleTokensDark.twModalHeaderLineHeight,
        twModalHeaderFontWeight: dark.TwTextStyleTokensDark.twModalHeaderFontWeight,
        twFooterBaseFontSize: dark.TwTextStyleTokensDark.twFooterBaseFontSize,
        twH1Scale: dark.TwTextStyleTokensDark.twH1Scale,
        twH2Scale: dark.TwTextStyleTokensDark.twH2Scale,
        twH1FontWeight: dark.TwTextStyleTokensDark.twH1FontWeight,
        twH2FontWeight: dark.TwTextStyleTokensDark.twH2FontWeight,
        twH1LetterSpacing: dark.TwTextStyleTokensDark.twH1LetterSpacing,
        twH1WordSpacing: dark.TwTextStyleTokensDark.twH1WordSpacing,
        twH2LetterSpacing: dark.TwTextStyleTokensDark.twH2LetterSpacing,
        twH2WordSpacing: dark.TwTextStyleTokensDark.twH2WordSpacing,
        twBlockquoteFontSize: dark.TwTextStyleTokensDark.twBlockquoteFontSize,
        twSmallFontSize: dark.TwTextStyleTokensDark.twSmallFontSize,
        twToolbarFontSize: dark.TwTextStyleTokensDark.twToolbarFontSize,
        twStrikethroughThickness: dark.TwTextStyleTokensDark.twStrikethroughThickness,
        twCardTitleShadows: dark.TwTextStyleTokensDark.twCardTitleShadows,
      );

  static TwTextStyleTokens _fromLight() => TwTextStyleTokens._(
        twFontFamily: dark.TwTextStyleTokensDark.twFontFamily,
        twBodyBaseFontSize: light.TwTextStyleTokensLight.twBodyBaseFontSize,
        twBodyFontWeight: light.TwTextStyleTokensLight.twBodyFontWeight,
        twBodyLineHeight: light.TwTextStyleTokensLight.twBodyLineHeight,
        twBodyMinTextScale: light.TwTextStyleTokensLight.twBodyMinTextScale,
        twBodyDefaultMaxTextScale: light.TwTextStyleTokensLight.twBodyDefaultMaxTextScale,
        twBodyScaleIntensity: light.TwTextStyleTokensLight.twBodyScaleIntensity,
        twSectionBaseFontSize: light.TwTextStyleTokensLight.twSectionBaseFontSize,
        twSectionLineHeight: light.TwTextStyleTokensLight.twSectionLineHeight,
        twSectionFontWeight: light.TwTextStyleTokensLight.twSectionFontWeight,
        twSectionScaleIntensity: light.TwTextStyleTokensLight.twSectionScaleIntensity,
        twModalHeaderFontSize: light.TwTextStyleTokensLight.twModalHeaderFontSize,
        twModalHeaderLineHeight: light.TwTextStyleTokensLight.twModalHeaderLineHeight,
        twModalHeaderFontWeight: light.TwTextStyleTokensLight.twModalHeaderFontWeight,
        twFooterBaseFontSize: light.TwTextStyleTokensLight.twFooterBaseFontSize,
        twH1Scale: light.TwTextStyleTokensLight.twH1Scale,
        twH2Scale: light.TwTextStyleTokensLight.twH2Scale,
        twH1FontWeight: light.TwTextStyleTokensLight.twH1FontWeight,
        twH2FontWeight: light.TwTextStyleTokensLight.twH2FontWeight,
        twH1LetterSpacing: light.TwTextStyleTokensLight.twH1LetterSpacing,
        twH1WordSpacing: light.TwTextStyleTokensLight.twH1WordSpacing,
        twH2LetterSpacing: light.TwTextStyleTokensLight.twH2LetterSpacing,
        twH2WordSpacing: light.TwTextStyleTokensLight.twH2WordSpacing,
        twBlockquoteFontSize: light.TwTextStyleTokensLight.twBlockquoteFontSize,
        twSmallFontSize: light.TwTextStyleTokensLight.twSmallFontSize,
        twToolbarFontSize: light.TwTextStyleTokensLight.twToolbarFontSize,
        twStrikethroughThickness: light.TwTextStyleTokensLight.twStrikethroughThickness,
        twCardTitleShadows: light.TwTextStyleTokensLight.twCardTitleShadows,
      );

}

extension TwTextStyleTokensBuildContextExtension on BuildContext {
  TwTextStyleTokens get twTextStyleTokens => TwTextStyleTokens.forBrightness(Theme.of(this).brightness);
}

/// Router that exposes text-style helpers per-brightness (light/dark).
class TwTextStyles {
  const TwTextStyles._(this._impl);

  final TwTextStylesImpl _impl;

  /// Convenience: return by [Brightness].
  static TwTextStyles forBrightness(Brightness brightness) {
    final tokens = TwTextStyleTokens.forBrightness(brightness);
    final named = _namedFromTokens(tokens);
    return TwTextStyles._(brightness == Brightness.dark
      ? TwTextStylesDark(named)
      : TwTextStylesLight(named));
  }

  /// Convenience: return by [BuildContext].
  static TwTextStyles of(BuildContext context) => TwTextStyles.forBrightness(Theme.of(context).brightness);

    TextStyle bodyForContext({required BuildContext context, required Color color, double baseSize = dark.TwTextStyleTokensDark.twBodyBaseFontSize}) =>
      _impl.bodyForContext(context: context, color: color, baseSize: baseSize);

  TextStyle bodyForContextless({required Color color, required double textScale}) =>
      _impl.bodyForContextless(color: color, textScale: textScale);

    TextStyle sectionTitleForContext({required BuildContext context, required Color color, double baseSize = dark.TwTextStyleTokensDark.twSectionBaseFontSize}) =>
      _impl.sectionTitleForContext(context: context, color: color, baseSize: baseSize);

  TextStyle modalHeaderTitle({required Color color}) => _impl.modalHeaderTitle(color: color);

  TextStyle modalCloseGlyph({required Color color}) => _impl.modalCloseGlyph(color: color);

  TextStyle footerBodyForContext({required BuildContext context, required Color color}) =>
      _impl.footerBodyForContext(context: context, color: color);

  /// Build an H1 display style by deriving from body base size at current text scale.
  TextStyle h1DisplayForContext({required BuildContext context, required Color color}) {
    final tokens = TwTextStyleTokens.forBrightness(Theme.of(context).brightness);
    final baseStyle = bodyForContextless(
      color: color,
      textScale:
          MediaQuery.textScalerOf(context).scale(tokens.twBodyBaseFontSize) /
          tokens.twBodyBaseFontSize,
    );
    return h1From(baseStyle);
  }

  TextStyle get transparentSelectionSpacer => _impl.transparentSelectionSpacer;

  /// Adapt an existing [TextStyle] using centralized copy rules.
  /// Use this to avoid calling `.copyWith` outside of the `text_styles` package.
  TextStyle adaptBase(TextStyle base,
      {Color? color,
      double? fontSize,
      FontWeight? fontWeight,
      double? height,
      FontStyle? fontStyle,
      TextDecoration? decoration,
      double? decorationThickness,
      Color? backgroundColor,
      Color? decorationColor,
      List<Shadow>? shadows}) {
    return _impl.adaptBase(
      base,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationThickness: decorationThickness,
      backgroundColor: backgroundColor,
      decorationColor: decorationColor,
      shadows: shadows,
    );
  }

  // Convenience named helpers to keep callers succinct.
  TextStyle buttonLabelFrom(TextStyle base, {Color? color}) => _impl.buttonLabelFrom(base, color: color);
  TextStyle cardTitleFrom(TextStyle base, {Color? color}) => _impl.cardTitleFrom(base, color: color);
  TextStyle smallFrom(TextStyle base, {Color? color}) => _impl.smallFrom(base, color: color);
  TextStyle strongFrom(TextStyle base) => _impl.strongFrom(base);
  TextStyle blockquoteFrom(TextStyle base) => _impl.blockquoteFrom(base);
  TextStyle strikethroughFrom(TextStyle base) => _impl.strikethroughFrom(base);
  TextStyle underlineFrom(TextStyle base) => _impl.underlineFrom(base);
  TextStyle linkFrom(TextStyle base, {required Color linkColor}) => _impl.linkFrom(base, linkColor: linkColor);
  TextStyle h1From(TextStyle base) => _impl.h1From(base);
  TextStyle h2From(TextStyle base) => _impl.h2From(base);
}


extension TwTextStylesBuildContextExtension on BuildContext {
  TwTextStyles get twTextStyles => TwTextStyles.of(this);
}

styles.NamedTextStyles _namedFromTokens(TwTextStyleTokens tokens) => styles.NamedTextStyles(
      fontFamily: tokens.twFontFamily,
      bodyBaseFontSize: tokens.twBodyBaseFontSize,
      bodyFontWeight: tokens.twBodyFontWeight,
      bodyLineHeight: tokens.twBodyLineHeight,
      bodyMinTextScale: tokens.twBodyMinTextScale,
      bodyDefaultMaxTextScale: tokens.twBodyDefaultMaxTextScale,
      bodyScaleIntensity: tokens.twBodyScaleIntensity,
      sectionBaseFontSize: tokens.twSectionBaseFontSize,
      sectionLineHeight: tokens.twSectionLineHeight,
      sectionFontWeight: tokens.twSectionFontWeight,
      sectionScaleIntensity: tokens.twSectionScaleIntensity,
      modalHeaderFontSize: tokens.twModalHeaderFontSize,
      modalHeaderLineHeight: tokens.twModalHeaderLineHeight,
      modalHeaderFontWeight: tokens.twModalHeaderFontWeight,
      footerBaseFontSize: tokens.twFooterBaseFontSize,
      blockquoteFontSize: tokens.twBlockquoteFontSize,
      smallFontSize: tokens.twSmallFontSize,
      toolbarFontSize: tokens.twToolbarFontSize,
      h1FontWeight: tokens.twH1FontWeight,
      h2FontWeight: tokens.twH2FontWeight,
      h1LetterSpacing: tokens.twH1LetterSpacing,
      h1WordSpacing: tokens.twH1WordSpacing,
      h2LetterSpacing: tokens.twH2LetterSpacing,
      h2WordSpacing: tokens.twH2WordSpacing,
      h1Scale: tokens.twH1Scale,
      h2Scale: tokens.twH2Scale,
      strikethroughThickness: tokens.twStrikethroughThickness,
      twCardTitleShadows: tokens.twCardTitleShadows,
    );

