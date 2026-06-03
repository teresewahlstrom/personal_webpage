import 'package:flutter/material.dart';

/// Small centralized helpers for constructing named TextStyles.
///
/// Keep this file minimal so designers can tweak produced TextStyles
/// in one place without touching the per-brightness implementations.

TextStyle buildTextStyle({
  String? fontFamily,
  FontWeight? fontWeight,
  double? fontSize,
  double? height,
  Color? color,
  TextDecoration? decoration,
  double? decorationThickness,
  Color? backgroundColor,
  Color? decorationColor,
  List<Shadow>? shadows,
  FontStyle? fontStyle,
}) {
  return TextStyle(
    fontFamily: fontFamily,
    fontWeight: fontWeight,
    fontSize: fontSize,
    height: height,
    decoration: decoration,
    decorationThickness: decorationThickness,
    backgroundColor: backgroundColor,
    decorationColor: decorationColor,
    shadows: shadows,
    fontStyle: fontStyle,
  ).copyWith(color: color);
}

/// Convenience for small glyphs used as modal close icons.
TextStyle modalCloseGlyphStyle({required Color color, double? fontSize}) {
  return buildTextStyle(fontSize: fontSize ?? 14.0, color: color, height: 1.0);
}

/// Convenience for modal header titles.
TextStyle modalHeaderTitleStyle({required String fontFamily, required FontWeight fontWeight, required double fontSize, required double height, required Color color}) {
  return buildTextStyle(fontFamily: fontFamily, fontWeight: fontWeight, fontSize: fontSize, height: height, color: color);
}

const TextStyle twTransparentSelectionSpacer = TextStyle(
  color: Colors.transparent,
  fontSize: 0.01,
  height: 1.0,
);

/// Designer-friendly named styles container.
///
/// This aggregates the token values and named `TextStyle` bases so a
/// designer can tweak styles in one place. Instances are provided for
/// light/dark brightness in this file.
class NamedTextStyles {
  const NamedTextStyles({
    required this.fontFamily,
    // body tokens
    required this.bodyBaseFontSize,
    required this.bodyFontWeight,
    required this.bodyLineHeight,
    required this.bodyMinTextScale,
    required this.bodyDefaultMaxTextScale,
    required this.bodyScaleIntensity,
    // section tokens
    required this.sectionBaseFontSize,
    required this.sectionLineHeight,
    required this.sectionFontWeight,
    required this.sectionScaleIntensity,
    // modal tokens
    required this.modalHeaderFontSize,
    required this.modalHeaderLineHeight,
    required this.modalHeaderFontWeight,
    // footer
    required this.footerBaseFontSize,
    // misc
    required this.blockquoteFontSize,
    required this.smallFontSize,
    required this.toolbarFontSize,
    // new tokens for assembly
    required this.h1FontWeight,
    required this.h2FontWeight,
    required this.h1LetterSpacing,
    required this.h1WordSpacing,
    required this.h2LetterSpacing,
    required this.h2WordSpacing,
    required this.h1Scale,
    required this.h2Scale,
    required this.strikethroughThickness,
  });

  final String fontFamily;
  final double bodyBaseFontSize;
  final FontWeight bodyFontWeight;
  final double bodyLineHeight;
  final double bodyMinTextScale;
  final double bodyDefaultMaxTextScale;
  final double bodyScaleIntensity;

  final double sectionBaseFontSize;
  final double sectionLineHeight;
  final FontWeight sectionFontWeight;
  final double sectionScaleIntensity;

  final double modalHeaderFontSize;
  final double modalHeaderLineHeight;
  final FontWeight modalHeaderFontWeight;

  final double footerBaseFontSize;

  final double blockquoteFontSize;
  final double smallFontSize;
  final double toolbarFontSize;

  final FontWeight h1FontWeight;
  final FontWeight h2FontWeight;
  final double h1LetterSpacing;
  final double h1WordSpacing;
  final double h2LetterSpacing;
  final double h2WordSpacing;
  final double h1Scale;
  final double h2Scale;
  final double strikethroughThickness;

  double _resolveTextScale(double textScale, {double? maxTextScale}) {
    final double max = maxTextScale ?? bodyDefaultMaxTextScale;
    if (!textScale.isFinite || textScale <= 0) {
      return bodyMinTextScale;
    }
    return textScale.clamp(bodyMinTextScale, max).toDouble();
  }

  double _scaledFontSize(double base, double textScale, {double? intensity}) {
    final double eff = intensity ?? bodyScaleIntensity;
    return base * (1 + (textScale - 1) * eff);
  }

  TextStyle bodyForContext(BuildContext context, {required Color color, double? baseSize}) {
    final double base = baseSize ?? bodyBaseFontSize;
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(base) / base);
    return buildTextStyle(
      fontFamily: fontFamily,
      fontWeight: bodyFontWeight,
      fontSize: _scaledFontSize(base, resolvedTextScale),
      height: bodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  TextStyle bodyForContextless({required Color color, required double textScale}) {
    final resolved = _resolveTextScale(textScale);
    return buildTextStyle(
      fontFamily: fontFamily,
      fontWeight: bodyFontWeight,
      fontSize: _scaledFontSize(bodyBaseFontSize, resolved),
      height: bodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  TextStyle sectionTitleForContext(BuildContext context, {required Color color, double? baseSize}) {
    final double base = baseSize ?? sectionBaseFontSize;
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(base) / base, maxTextScale: 2.0);
    return buildTextStyle(
      fontFamily: fontFamily,
      fontWeight: sectionFontWeight,
      fontSize: _scaledFontSize(base, resolvedTextScale, intensity: sectionScaleIntensity),
      height: sectionLineHeight,
      color: color,
    );
  }

  TextStyle modalHeaderTitle({required Color color}) => modalHeaderTitleStyle(
        fontFamily: fontFamily,
        fontWeight: modalHeaderFontWeight,
        fontSize: modalHeaderFontSize,
        height: modalHeaderLineHeight,
        color: color,
      );

  TextStyle modalCloseGlyph({required Color color}) => modalCloseGlyphStyle(
        fontSize: modalHeaderFontSize,
        color: color,
      );

  TextStyle footerBodyForContext(BuildContext context, {required Color color}) {
    final resolvedTextScale = _resolveTextScale(MediaQuery.textScalerOf(context).scale(footerBaseFontSize) / footerBaseFontSize);
    return buildTextStyle(
      fontFamily: fontFamily,
      fontWeight: bodyFontWeight,
      fontSize: _scaledFontSize(footerBaseFontSize, resolvedTextScale),
      height: bodyLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  TextStyle adaptBase(TextStyle base, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? decorationThickness,
    Color? backgroundColor,
    Color? decorationColor,
    List<Shadow>? shadows,
  }) {
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

  TextStyle buttonLabelFrom(TextStyle base, {Color? color}) {
    return adaptBase(base, color: color, fontWeight: FontWeight.w700);
  }

  TextStyle cardTitleFrom(TextStyle base, {Color? color}) {
    return adaptBase(base, color: color);
  }

  TextStyle smallFrom(TextStyle base, {Color? color}) {
    return adaptBase(base, color: color, fontSize: smallFontSize);
  }

  TextStyle strongFrom(TextStyle base) {
    final Color baseColor = base.color ?? Colors.black;
    final hsl = HSLColor.fromColor(baseColor);
    final lifted = hsl.withLightness((hsl.lightness * 1.10).clamp(0.0, 1.0));
    return base.copyWith(
      fontWeight: FontWeight.w700,
      color: lifted.toColor(),
    );
  }

  TextStyle blockquoteFrom(TextStyle base) => base.copyWith(fontStyle: FontStyle.italic);

  TextStyle strikethroughFrom(TextStyle base) => base.copyWith(
        decoration: TextDecoration.lineThrough,
        decorationColor: base.color,
        decorationThickness: strikethroughThickness,
      );

  TextStyle underlineFrom(TextStyle base) => base.copyWith(
        decoration: TextDecoration.underline,
        decorationColor: base.color,
        decorationThickness: 1.75,
      );

  TextStyle linkFrom(TextStyle base, {required Color linkColor}) => base.copyWith(
        color: linkColor,
        decoration: TextDecoration.underline,
        decorationColor: linkColor,
        decorationThickness: 1.75,
      );

  TextStyle h1From(TextStyle base) {
    final strong = strongFrom(base);
    return strong.copyWith(
      fontSize: base.fontSize! * h1Scale,
      fontWeight: h1FontWeight,
      height: 1.2,
      letterSpacing: h1LetterSpacing,
      wordSpacing: h1WordSpacing,
    );
  }

  TextStyle h2From(TextStyle base) {
    final strong = strongFrom(base);
    return strong.copyWith(
      fontSize: base.fontSize! * h2Scale,
      fontWeight: h2FontWeight,
      height: 1.2,
      letterSpacing: h2LetterSpacing,
      wordSpacing: h2WordSpacing,
    );
  }
}

