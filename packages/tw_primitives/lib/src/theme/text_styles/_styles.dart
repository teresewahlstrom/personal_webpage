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
    required this.transparentSelectionSpacer,
    // misc
    required this.header1FontSize,
    required this.header2FontSize,
    required this.blockquoteFontSize,
    required this.smallFontSize,
    required this.toolbarFontSize,
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
  final TextStyle transparentSelectionSpacer;

  final double header1FontSize;
  final double header2FontSize;
  final double blockquoteFontSize;
  final double smallFontSize;
  final double toolbarFontSize;

  // Designer-facing base TextStyle builders. Callers should pass the desired
  // color so dynamic color tokens remain separate from the typographic bases.
  TextStyle bodyBase({required Color color}) => buildTextStyle(
        fontFamily: fontFamily,
        fontWeight: bodyFontWeight,
        fontSize: bodyBaseFontSize,
        height: bodyLineHeight,
        color: color,
      );

  TextStyle sectionBase({required Color color, double? baseSize}) => buildTextStyle(
        fontFamily: fontFamily,
        fontWeight: sectionFontWeight,
        fontSize: baseSize ?? sectionBaseFontSize,
        height: sectionLineHeight,
        color: color,
      );

  TextStyle modalHeaderBase({required Color color}) => buildTextStyle(
        fontFamily: fontFamily,
        fontWeight: modalHeaderFontWeight,
        fontSize: modalHeaderFontSize,
        height: modalHeaderLineHeight,
        color: color,
      );

  TextStyle modalCloseGlyphBase({required Color color}) => modalCloseGlyphStyle(
    fontSize: modalHeaderFontSize, 
    color: color
    );

  TextStyle footerBodyBase({required Color color}) => buildTextStyle(
        fontFamily: fontFamily,
        fontWeight: bodyFontWeight,
        fontSize: footerBaseFontSize,
        height: bodyLineHeight,
        color: color,
      );

  TextStyle smallBase({required Color color}) => buildTextStyle(fontFamily: fontFamily, fontWeight: bodyFontWeight, fontSize: smallFontSize, height: bodyLineHeight, color: color);

  // Additional designer-facing named styles for common roles.
  TextStyle header1({required Color color}) => buildTextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: header1FontSize,
        height: 1.0,
        color: color,
      );

  TextStyle header2({required Color color}) => buildTextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: header2FontSize,
        height: 1.0,
        color: color,
      );

  TextStyle blockquoteBase({required Color color}) => buildTextStyle(
        fontFamily: fontFamily,
        fontStyle: FontStyle.italic,
        fontSize: blockquoteFontSize,
        height: bodyLineHeight,
        color: color,
      );

  TextStyle toolbarLabelBase({required Color color}) => buildTextStyle(
        fontFamily: fontFamily,
        fontSize: toolbarFontSize,
        fontWeight: bodyFontWeight,
        height: bodyLineHeight,
        color: color,
      );

  TextStyle cardTitleBase({required Color color}) => buildTextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: bodyBaseFontSize,
        height: bodyLineHeight,
        color: color,
      );
}
