import 'package:flutter/material.dart';
import 'package:tw_primitives/src/theme/text_styles/impl.dart';

// Canonical token values for dark theme text styles. Edit these values to
// change defaults for all text styles in the dark theme.
const String twFontFamily = 'Rubik';

// Body text tokens
const double twBodyBaseFontSize = 17.0;
const FontWeight twBodyFontWeight = FontWeight.w100;
const double twBodyLineHeight = 1.42;
const double twBodyMinTextScale = 1.0;
const double twBodyDefaultMaxTextScale = 1.6;
const double twBodyScaleIntensity = 0.7;

// Section title tokens
const double twSectionBaseFontSize = 40.0;
const double twSectionLineHeight = 1.0;
const FontWeight twSectionFontWeight = FontWeight.w300;
const double twSectionScaleIntensity = 0.5;

// Modal tokens
const double twModalHeaderFontSize = 28.0;
const double twModalHeaderLineHeight = 1.0;
const FontWeight twModalHeaderFontWeight = FontWeight.w300;

// Footer tokens
const double twFooterBaseFontSize = 16.0;

// Utility
const TextStyle twTransparentSelectionSpacer = TextStyle(
  color: Colors.transparent,
  fontSize: 0.01,
  height: 1.0,
);

class TwTextStylesDark implements TwTextStylesImpl {
  // Helpers copied from legacy body text helpers but kept local to the impl.
  double _resolveTextScale(double textScale, {double maxTextScale = twBodyDefaultMaxTextScale}) {
    if (!textScale.isFinite || textScale <= 0) {
      return twBodyMinTextScale;
    }
    return textScale.clamp(twBodyMinTextScale, maxTextScale).toDouble();
  }

  double _scaledFontSize(double base, double textScale, {double intensity = twBodyScaleIntensity}) {
    return base * (1 + (textScale - 1) * intensity);
  }

  @override
  TextStyle bodyForContext({required BuildContext context, required Color color, double baseSize = twBodyBaseFontSize}) {
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(baseSize) / baseSize);
    return TextStyle(
      fontFamily: twFontFamily,
      fontWeight: twBodyFontWeight,
      fontSize: _scaledFontSize(baseSize, resolvedTextScale, intensity: twBodyScaleIntensity),
      height: twBodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  @override
  TextStyle bodyForContextless({required Color color, required double textScale}) {
    final resolved = _resolveTextScale(textScale);
    return TextStyle(
      fontFamily: twFontFamily,
      fontWeight: twBodyFontWeight,
      fontSize: _scaledFontSize(twBodyBaseFontSize, resolved, intensity: twBodyScaleIntensity),
      height: twBodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  @override
  TextStyle sectionTitleForContext({required BuildContext context, required Color color, double baseSize = twSectionBaseFontSize}) {
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(baseSize) / baseSize, maxTextScale: 2.0);
    return TextStyle(
      fontFamily: twFontFamily,
      fontWeight: twSectionFontWeight,
      fontSize: _scaledFontSize(baseSize, resolvedTextScale, intensity: twSectionScaleIntensity),
      height: twSectionLineHeight,
      color: color,
    );
  }

  @override
  TextStyle modalHeaderTitle({required Color color}) =>
      const TextStyle(fontFamily: twFontFamily, fontWeight: twModalHeaderFontWeight, fontSize: twModalHeaderFontSize, height: twModalHeaderLineHeight).copyWith(color: color);

  @override
  TextStyle modalCloseGlyph({required Color color}) => const TextStyle(fontSize: twModalHeaderFontSize, height: 1).copyWith(color: color);

  @override
  TextStyle footerBodyForContext({required BuildContext context, required Color color}) {
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(twFooterBaseFontSize) / twFooterBaseFontSize);
    return TextStyle(
      fontFamily: twFontFamily,
      fontWeight: twBodyFontWeight,
      fontSize: _scaledFontSize(twFooterBaseFontSize, resolvedTextScale),
      height: twBodyLineHeight,
      color: color,
    );
  }

  @override
  TextStyle get transparentSelectionSpacer => twTransparentSelectionSpacer;
}
