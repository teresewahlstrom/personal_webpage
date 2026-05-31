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
    required this.twStrongFontWeight,
    required this.twFooterBaseFontSize,
    required this.twTransparentSelectionSpacer,
    required this.twHeader1FontSize,
    required this.twHeader2FontSize,
    required this.twBlockquoteFontSize,
    required this.twSmallFontSize,
    required this.twToolbarFontSize,
    required this.twCardTitleScale,
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
  final FontWeight twStrongFontWeight;
  final double twFooterBaseFontSize;
  final TextStyle twTransparentSelectionSpacer;
  final double twHeader1FontSize;
  final double twHeader2FontSize;
  final double twBlockquoteFontSize;
  final double twSmallFontSize;
  final double twToolbarFontSize;
  final double twCardTitleScale;

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
        twStrongFontWeight: dark.TwTextStyleTokensDark.twStrongFontWeight,
        twFooterBaseFontSize: dark.TwTextStyleTokensDark.twFooterBaseFontSize,
        twTransparentSelectionSpacer: dark.TwTextStyleTokensDark.twTransparentSelectionSpacer,
        twHeader1FontSize: dark.TwTextStyleTokensDark.twHeader1FontSize,
        twHeader2FontSize: dark.TwTextStyleTokensDark.twHeader2FontSize,
        twBlockquoteFontSize: dark.TwTextStyleTokensDark.twBlockquoteFontSize,
        twSmallFontSize: dark.TwTextStyleTokensDark.twSmallFontSize,
        twToolbarFontSize: dark.TwTextStyleTokensDark.twToolbarFontSize,
        twCardTitleScale: dark.TwTextStyleTokensDark.twCardTitleScale,
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
        twStrongFontWeight: light.TwTextStyleTokensLight.twStrongFontWeight,
        twFooterBaseFontSize: light.TwTextStyleTokensLight.twFooterBaseFontSize,
        twTransparentSelectionSpacer: light.TwTextStyleTokensLight.twTransparentSelectionSpacer,
        twHeader1FontSize: light.TwTextStyleTokensLight.twHeader1FontSize,
        twHeader2FontSize: light.TwTextStyleTokensLight.twHeader2FontSize,
        twBlockquoteFontSize: light.TwTextStyleTokensLight.twBlockquoteFontSize,
        twSmallFontSize: light.TwTextStyleTokensLight.twSmallFontSize,
        twToolbarFontSize: light.TwTextStyleTokensLight.twToolbarFontSize,
        twCardTitleScale: light.TwTextStyleTokensLight.twCardTitleScale,
      );
}

extension TwTextStyleTokensBuildContextExtension on BuildContext {
  TwTextStyleTokens get twTextStyleTokens => TwTextStyleTokens.forBrightness(Theme.of(this).brightness);
}

/// Backwards-compatible simple router alias so callers can use a straightforward
/// conditional mapping like `RouterTextStyles.forBrightness(brightness).twBodyBaseFontSize`.
class RouterTextStyles {
  static TwTextStyleTokens forBrightness(Brightness brightness) => TwTextStyleTokens.forBrightness(brightness);
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
  TextStyle toolbarLabelFrom(TextStyle base, {Color? color}) => _impl.toolbarLabelFrom(base, color: color);
  TextStyle hintFrom(TextStyle base, {Color? color}) => _impl.hintFrom(base, color: color);
  TextStyle smallFrom(TextStyle base, {Color? color}) => _impl.smallFrom(base, color: color);
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
      transparentSelectionSpacer: tokens.twTransparentSelectionSpacer,
      header1FontSize: tokens.twHeader1FontSize,
      header2FontSize: tokens.twHeader2FontSize,
      blockquoteFontSize: tokens.twBlockquoteFontSize,
      smallFontSize: tokens.twSmallFontSize,
      toolbarFontSize: tokens.twToolbarFontSize,
      cardTitleScale: tokens.twCardTitleScale,
    );

extension TwNamedTextStylesBuildContextExtension on BuildContext {
  styles.NamedTextStyles get twNamedTextStyles => _namedFromTokens(twTextStyleTokens);
}
