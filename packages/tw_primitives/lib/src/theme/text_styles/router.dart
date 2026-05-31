import 'package:flutter/material.dart';
import '_dark.dart' as dark;
import 'impl.dart';

// Public convenience accessor for the canonical font family token.
// This allows consumers to import the public `package:tw_primitives/theme.dart`
// and use `twFontFamily` without reaching into `lib/src` implementation files.
const String twFontFamily = dark.TwTextStyleTokensDark.twFontFamily;

// Expose core base-size tokens publicly so other packages can compute scales
// without importing internal implementation files.
const double twBodyBaseFontSize = dark.TwTextStyleTokensDark.twBodyBaseFontSize;
const double twSectionBaseFontSize = dark.TwTextStyleTokensDark.twSectionBaseFontSize;
const double twFooterBaseFontSize = dark.TwTextStyleTokensDark.twFooterBaseFontSize;
const double twModalHeaderFontSize = dark.TwTextStyleTokensDark.twModalHeaderFontSize;
const double twBodyDefaultMaxTextScale = dark.TwTextStyleTokensDark.twBodyDefaultMaxTextScale;
const double twHeader1FontSize = dark.TwTextStyleTokensDark.twHeader1FontSize;
const double twHeader2FontSize = dark.TwTextStyleTokensDark.twHeader2FontSize;
const double twBlockquoteFontSize = dark.TwTextStyleTokensDark.twBlockquoteFontSize;
const double twSmallFontSize = dark.TwTextStyleTokensDark.twSmallFontSize;
const double twToolbarFontSize = dark.TwTextStyleTokensDark.twToolbarFontSize;
// Line-heights and default weights
const double twBodyLineHeight = dark.TwTextStyleTokensDark.twBodyLineHeight;
const FontWeight twBodyFontWeight = dark.TwTextStyleTokensDark.twBodyFontWeight;
const double twSectionLineHeight = dark.TwTextStyleTokensDark.twSectionLineHeight;
const FontWeight twSectionFontWeight = dark.TwTextStyleTokensDark.twSectionFontWeight;
const double twModalHeaderLineHeight = dark.TwTextStyleTokensDark.twModalHeaderLineHeight;
const FontWeight twModalHeaderFontWeight = dark.TwTextStyleTokensDark.twModalHeaderFontWeight;
// Transparent spacer style for selection/copy use (contextless).
const TextStyle twTransparentSelectionSpacer = dark.TwTextStyleTokensDark.twTransparentSelectionSpacer;
// Professional card title scale (multiplier applied to H2/base header size).
const double twCardTitleScale = dark.TwTextStyleTokensDark.twCardTitleScale;

/// Router that exposes text-style helpers per-brightness (light/dark).
class TwTextStyles {
  const TwTextStyles._(this._impl);

  final TwTextStylesImpl _impl;

  /// Convenience: return by [Brightness].
  static TwTextStyles forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? TwTextStyles._(TwTextStylesDark()) : TwTextStyles._(TwTextStylesLight());
  }

  /// Convenience: return by [BuildContext].
  static TwTextStyles of(BuildContext context) => TwTextStyles.forBrightness(Theme.of(context).brightness);

  TextStyle bodyForContext({required BuildContext context, required Color color, double baseSize = twBodyBaseFontSize}) =>
      _impl.bodyForContext(context: context, color: color, baseSize: baseSize);

  TextStyle bodyForContextless({required Color color, required double textScale}) =>
      _impl.bodyForContextless(color: color, textScale: textScale);

  TextStyle sectionTitleForContext({required BuildContext context, required Color color, double baseSize = twSectionBaseFontSize}) =>
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
