import 'package:flutter/material.dart';
import '_dark.dart' as dark;
import '_light.dart' as light;
// NOTE: keep this file minimal — implementations live in per-brightness files.

/// Internal interface implemented by per-brightness text-style providers.
abstract class TwTextStylesImpl {
  TextStyle bodyForContext({required BuildContext context, required Color color, double baseSize});
  TextStyle bodyForContextless({required Color color, required double textScale});
  TextStyle sectionTitleForContext({required BuildContext context, required Color color, double baseSize});
  TextStyle modalHeaderTitle({required Color color});
  TextStyle modalCloseGlyph({required Color color});
  TextStyle footerBodyForContext({required BuildContext context, required Color color});
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
      List<Shadow>? shadows});
  TextStyle buttonLabelFrom(TextStyle base, {Color? color});
  TextStyle cardTitleFrom(TextStyle base, {Color? color});
  TextStyle toolbarLabelFrom(TextStyle base, {Color? color});
  TextStyle hintFrom(TextStyle base, {Color? color});
  TextStyle smallFrom(TextStyle base, {Color? color});
  TextStyle get transparentSelectionSpacer;
}

// Dark-theme implementation moved here for centralized implementations.
class TwTextStylesDark implements TwTextStylesImpl {
  // Helpers copied from legacy body text helpers but kept local to the impl.
  double _resolveTextScale(double textScale, {double maxTextScale = dark.TwTextStyleTokensDark.twBodyDefaultMaxTextScale}) {
    if (!textScale.isFinite || textScale <= 0) {
      return dark.TwTextStyleTokensDark.twBodyMinTextScale;
    }
    return textScale.clamp(dark.TwTextStyleTokensDark.twBodyMinTextScale, maxTextScale).toDouble();
  }

  double _scaledFontSize(double base, double textScale, {double intensity = dark.TwTextStyleTokensDark.twBodyScaleIntensity}) {
    return base * (1 + (textScale - 1) * intensity);
  }

  @override
  TextStyle bodyForContext({required BuildContext context, required Color color, double baseSize = dark.TwTextStyleTokensDark.twBodyBaseFontSize}) {
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(baseSize) / baseSize);
    return TextStyle(
      fontFamily: dark.TwTextStyleTokensDark.twFontFamily,
      fontWeight: dark.TwTextStyleTokensDark.twBodyFontWeight,
      fontSize: _scaledFontSize(baseSize, resolvedTextScale, intensity: dark.TwTextStyleTokensDark.twBodyScaleIntensity),
      height: dark.TwTextStyleTokensDark.twBodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  @override
  TextStyle bodyForContextless({required Color color, required double textScale}) {
    final resolved = _resolveTextScale(textScale);
    return TextStyle(
      fontFamily: dark.TwTextStyleTokensDark.twFontFamily,
      fontWeight: dark.TwTextStyleTokensDark.twBodyFontWeight,
      fontSize: _scaledFontSize(dark.TwTextStyleTokensDark.twBodyBaseFontSize, resolved, intensity: dark.TwTextStyleTokensDark.twBodyScaleIntensity),
      height: dark.TwTextStyleTokensDark.twBodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  @override
  TextStyle sectionTitleForContext({required BuildContext context, required Color color, double baseSize = dark.TwTextStyleTokensDark.twSectionBaseFontSize}) {
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(baseSize) / baseSize, maxTextScale: 2.0);
    return TextStyle(
      fontFamily: dark.TwTextStyleTokensDark.twFontFamily,
      fontWeight: dark.TwTextStyleTokensDark.twSectionFontWeight,
      fontSize: _scaledFontSize(baseSize, resolvedTextScale, intensity: dark.TwTextStyleTokensDark.twSectionScaleIntensity),
      height: dark.TwTextStyleTokensDark.twSectionLineHeight,
      color: color,
    );
  }

  @override
  TextStyle modalHeaderTitle({required Color color}) =>
      const TextStyle(fontFamily: dark.TwTextStyleTokensDark.twFontFamily, fontWeight: dark.TwTextStyleTokensDark.twModalHeaderFontWeight, fontSize: dark.TwTextStyleTokensDark.twModalHeaderFontSize, height: dark.TwTextStyleTokensDark.twModalHeaderLineHeight).copyWith(color: color);

  @override
  TextStyle modalCloseGlyph({required Color color}) => const TextStyle(fontSize: dark.TwTextStyleTokensDark.twModalHeaderFontSize, height: 1).copyWith(color: color);

  @override
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
    return base.copyWith(
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

  @override
  TextStyle buttonLabelFrom(TextStyle base, {Color? color}) {
    return adaptBase(base, color: color, fontWeight: FontWeight.w700);
  }

  @override
  TextStyle cardTitleFrom(TextStyle base, {Color? color}) {
    // Apply card title scale relative to base font size (fall back to H2 token).
    final double baseSize = base.fontSize ?? dark.TwTextStyleTokensDark.twHeader2FontSize;
    return adaptBase(base, color: color, fontSize: baseSize * dark.TwTextStyleTokensDark.twCardTitleScale);
  }

  @override
  TextStyle toolbarLabelFrom(TextStyle base, {Color? color}) {
    return adaptBase(base, color: color, fontSize: dark.TwTextStyleTokensDark.twToolbarFontSize, fontWeight: FontWeight.w300);
  }

  @override
  TextStyle hintFrom(TextStyle base, {Color? color}) {
    return adaptBase(base, color: color, height: 1.4);
  }

  @override
  TextStyle smallFrom(TextStyle base, {Color? color}) {
    return adaptBase(base, color: color, fontSize: dark.TwTextStyleTokensDark.twSmallFontSize);
  }

  @override
  TextStyle footerBodyForContext({required BuildContext context, required Color color}) {
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(dark.TwTextStyleTokensDark.twFooterBaseFontSize) / dark.TwTextStyleTokensDark.twFooterBaseFontSize);
    return TextStyle(
      fontFamily: dark.TwTextStyleTokensDark.twFontFamily,
      fontWeight: dark.TwTextStyleTokensDark.twBodyFontWeight,
      fontSize: _scaledFontSize(dark.TwTextStyleTokensDark.twFooterBaseFontSize, resolvedTextScale),
      height: dark.TwTextStyleTokensDark.twBodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  @override
  TextStyle get transparentSelectionSpacer => dark.TwTextStyleTokensDark.twTransparentSelectionSpacer;
}

// Light-theme impl delegates to the dark impl by default but remains a distinct type.
class TwTextStylesLight implements TwTextStylesImpl {
  // Light implementation mirrors the dark one but uses light tokens so the
  // themes can diverge at runtime.
  double _resolveTextScale(double textScale, {double maxTextScale = light.TwTextStyleTokensLight.twBodyDefaultMaxTextScale}) {
    if (!textScale.isFinite || textScale <= 0) {
      return light.TwTextStyleTokensLight.twBodyMinTextScale;
    }
    return textScale.clamp(light.TwTextStyleTokensLight.twBodyMinTextScale, maxTextScale).toDouble();
  }

  double _scaledFontSize(double base, double textScale, {double intensity = light.TwTextStyleTokensLight.twBodyScaleIntensity}) {
    return base * (1 + (textScale - 1) * intensity);
  }

  @override
  TextStyle bodyForContext({required BuildContext context, required Color color, double baseSize = light.TwTextStyleTokensLight.twBodyBaseFontSize}) {
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(baseSize) / baseSize);
    return TextStyle(
      fontFamily: light.TwTextStyleTokensLight.twFontFamily,
      fontWeight: light.TwTextStyleTokensLight.twBodyFontWeight,
      fontSize: _scaledFontSize(baseSize, resolvedTextScale, intensity: light.TwTextStyleTokensLight.twBodyScaleIntensity),
      height: light.TwTextStyleTokensLight.twBodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  @override
  TextStyle bodyForContextless({required Color color, required double textScale}) {
    final resolved = _resolveTextScale(textScale);
    return TextStyle(
      fontFamily: light.TwTextStyleTokensLight.twFontFamily,
      fontWeight: light.TwTextStyleTokensLight.twBodyFontWeight,
      fontSize: _scaledFontSize(light.TwTextStyleTokensLight.twBodyBaseFontSize, resolved, intensity: light.TwTextStyleTokensLight.twBodyScaleIntensity),
      height: light.TwTextStyleTokensLight.twBodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  @override
  TextStyle sectionTitleForContext({required BuildContext context, required Color color, double baseSize = light.TwTextStyleTokensLight.twSectionBaseFontSize}) {
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(baseSize) / baseSize, maxTextScale: 2.0);
    return TextStyle(
      fontFamily: light.TwTextStyleTokensLight.twFontFamily,
      fontWeight: light.TwTextStyleTokensLight.twSectionFontWeight,
      fontSize: _scaledFontSize(baseSize, resolvedTextScale, intensity: light.TwTextStyleTokensLight.twSectionScaleIntensity),
      height: light.TwTextStyleTokensLight.twSectionLineHeight,
      color: color,
    );
  }

  @override
  TextStyle modalHeaderTitle({required Color color}) => const TextStyle(fontFamily: light.TwTextStyleTokensLight.twFontFamily, fontWeight: light.TwTextStyleTokensLight.twModalHeaderFontWeight, fontSize: light.TwTextStyleTokensLight.twModalHeaderFontSize, height: light.TwTextStyleTokensLight.twModalHeaderLineHeight).copyWith(color: color);

  @override
  TextStyle modalCloseGlyph({required Color color}) => const TextStyle(fontSize: light.TwTextStyleTokensLight.twModalHeaderFontSize, height: 1).copyWith(color: color);

  @override
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
    return base.copyWith(
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

  @override
  TextStyle buttonLabelFrom(TextStyle base, {Color? color}) {
    return adaptBase(base, color: color, fontWeight: FontWeight.w700);
  }

  @override
  TextStyle cardTitleFrom(TextStyle base, {Color? color}) {
    final double baseSize = base.fontSize ?? light.TwTextStyleTokensLight.twHeader2FontSize;
    return adaptBase(base, color: color, fontSize: baseSize * light.TwTextStyleTokensLight.twCardTitleScale);
  }

  @override
  TextStyle toolbarLabelFrom(TextStyle base, {Color? color}) {
    return adaptBase(base, color: color, fontSize: light.TwTextStyleTokensLight.twToolbarFontSize, fontWeight: FontWeight.w300);
  }

  @override
  TextStyle hintFrom(TextStyle base, {Color? color}) {
    return adaptBase(base, color: color, height: 1.4);
  }

  @override
  TextStyle smallFrom(TextStyle base, {Color? color}) {
    return adaptBase(base, color: color, fontSize: light.TwTextStyleTokensLight.twSmallFontSize);
  }

  @override
  TextStyle footerBodyForContext({required BuildContext context, required Color color}) {
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(light.TwTextStyleTokensLight.twFooterBaseFontSize) / light.TwTextStyleTokensLight.twFooterBaseFontSize);
    return TextStyle(
      fontFamily: light.TwTextStyleTokensLight.twFontFamily,
      fontWeight: light.TwTextStyleTokensLight.twBodyFontWeight,
      fontSize: _scaledFontSize(light.TwTextStyleTokensLight.twFooterBaseFontSize, resolvedTextScale),
      height: light.TwTextStyleTokensLight.twBodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  @override
  TextStyle get transparentSelectionSpacer => light.TwTextStyleTokensLight.twTransparentSelectionSpacer;
}
