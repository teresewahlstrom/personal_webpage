import 'package:flutter/material.dart';
import '_styles.dart' as styles;
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
  TextStyle smallFrom(TextStyle base, {Color? color});
  TextStyle get transparentSelectionSpacer;
}

// Dark-theme implementation moved here for centralized implementations.
class TwTextStylesDark implements TwTextStylesImpl {
  TwTextStylesDark(this.named);

  final styles.NamedTextStyles named;
  // Helpers copied from legacy body text helpers but kept local to the impl.
  double _resolveTextScale(double textScale, {double? maxTextScale}) {
    final double max = maxTextScale ?? named.bodyDefaultMaxTextScale;
    if (!textScale.isFinite || textScale <= 0) {
      return named.bodyMinTextScale;
    }
    return textScale.clamp(named.bodyMinTextScale, max).toDouble();
  }

  double _scaledFontSize(double base, double textScale, {double? intensity}) {
    final double eff = intensity ?? named.bodyScaleIntensity;
    return base * (1 + (textScale - 1) * eff);
  }

  @override
  TextStyle bodyForContext({required BuildContext context, required Color color, double? baseSize}) {
    final double base = baseSize ?? named.bodyBaseFontSize;
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(base) / base);
    return styles.buildTextStyle(
      fontFamily: named.fontFamily,
      fontWeight: named.bodyFontWeight,
      fontSize: _scaledFontSize(base, resolvedTextScale),
      height: named.bodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  @override
  TextStyle bodyForContextless({required Color color, required double textScale}) {
    final resolved = _resolveTextScale(textScale);
    return styles.buildTextStyle(
      fontFamily: named.fontFamily,
      fontWeight: named.bodyFontWeight,
      fontSize: _scaledFontSize(named.bodyBaseFontSize, resolved),
      height: named.bodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  @override
  TextStyle sectionTitleForContext({required BuildContext context, required Color color, double? baseSize}) {
    final double base = baseSize ?? named.sectionBaseFontSize;
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(base) / base, maxTextScale: 2.0);
    return styles.buildTextStyle(
      fontFamily: named.fontFamily,
      fontWeight: named.sectionFontWeight,
      fontSize: _scaledFontSize(base, resolvedTextScale, intensity: named.sectionScaleIntensity),
      height: named.sectionLineHeight,
      color: color,
    );
  }

  @override
  TextStyle modalHeaderTitle({required Color color}) => styles.modalHeaderTitleStyle(
        fontFamily: named.fontFamily,
        fontWeight: named.modalHeaderFontWeight,
        fontSize: named.modalHeaderFontSize,
        height: named.modalHeaderLineHeight,
        color: color,
      );

  @override
  TextStyle modalCloseGlyph({required Color color}) => styles.modalCloseGlyphStyle(fontSize: named.modalHeaderFontSize, color: color);

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
    return adaptBase(base, color: color);
  }

  @override
  TextStyle smallFrom(TextStyle base, {Color? color}) {
    return adaptBase(base, color: color, fontSize: named.smallFontSize);
  }

  @override
  TextStyle footerBodyForContext({required BuildContext context, required Color color}) {
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(named.footerBaseFontSize) / named.footerBaseFontSize);
    return styles.buildTextStyle(
      fontFamily: named.fontFamily,
      fontWeight: named.bodyFontWeight,
      fontSize: _scaledFontSize(named.footerBaseFontSize, resolvedTextScale),
      height: named.bodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  @override
  TextStyle get transparentSelectionSpacer => named.transparentSelectionSpacer;
}

// Light-theme impl delegates to the dark impl by default but remains a distinct type.
class TwTextStylesLight implements TwTextStylesImpl {
  TwTextStylesLight(this.named);

  final styles.NamedTextStyles named;

  double _resolveTextScale(double textScale, {double? maxTextScale}) {
    final double max = maxTextScale ?? named.bodyDefaultMaxTextScale;
    if (!textScale.isFinite || textScale <= 0) {
      return named.bodyMinTextScale;
    }
    return textScale.clamp(named.bodyMinTextScale, max).toDouble();
  }

  double _scaledFontSize(double base, double textScale, {double? intensity}) {
    final double eff = intensity ?? named.bodyScaleIntensity;
    return base * (1 + (textScale - 1) * eff);
  }

  @override
  TextStyle bodyForContext({required BuildContext context, required Color color, double? baseSize}) {
    final double base = baseSize ?? named.bodyBaseFontSize;
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(base) / base);
    return styles.buildTextStyle(
      fontFamily: named.fontFamily,
      fontWeight: named.bodyFontWeight,
      fontSize: _scaledFontSize(base, resolvedTextScale),
      height: named.bodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  @override
  TextStyle bodyForContextless({required Color color, required double textScale}) {
    final resolved = _resolveTextScale(textScale);
    return styles.buildTextStyle(
      fontFamily: named.fontFamily,
      fontWeight: named.bodyFontWeight,
      fontSize: _scaledFontSize(named.bodyBaseFontSize, resolved),
      height: named.bodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  @override
  TextStyle sectionTitleForContext({required BuildContext context, required Color color, double? baseSize}) {
    final double base = baseSize ?? named.sectionBaseFontSize;
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(base) / base, maxTextScale: 2.0);
    return styles.buildTextStyle(
      fontFamily: named.fontFamily,
      fontWeight: named.sectionFontWeight,
      fontSize: _scaledFontSize(base, resolvedTextScale, intensity: named.sectionScaleIntensity),
      height: named.sectionLineHeight,
      color: color,
    );
  }

  

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
    return adaptBase(base, color: color);
  }

  @override
  TextStyle smallFrom(TextStyle base, {Color? color}) {
    return adaptBase(base, color: color, fontSize: named.smallFontSize);
  }

  @override
  TextStyle footerBodyForContext({required BuildContext context, required Color color}) {
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(named.footerBaseFontSize) / named.footerBaseFontSize);
    return styles.buildTextStyle(
      fontFamily: named.fontFamily,
      fontWeight: named.bodyFontWeight,
      fontSize: _scaledFontSize(named.footerBaseFontSize, resolvedTextScale),
      height: named.bodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }
  @override
  TextStyle modalHeaderTitle({required Color color}) => styles.modalHeaderTitleStyle(
        fontFamily: named.fontFamily,
        fontWeight: named.modalHeaderFontWeight,
        fontSize: named.modalHeaderFontSize,
        height: named.modalHeaderLineHeight,
        color: color,
      );

  @override
  TextStyle modalCloseGlyph({required Color color}) => styles.modalCloseGlyphStyle(fontSize: named.modalHeaderFontSize, color: color);

  @override
  TextStyle get transparentSelectionSpacer => named.transparentSelectionSpacer;
}
