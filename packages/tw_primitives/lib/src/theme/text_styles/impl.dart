import 'package:flutter/material.dart';
import '_styles.dart' as styles;

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

  TextStyle strongFrom(TextStyle base);
  TextStyle blockquoteFrom(TextStyle base);
  TextStyle strikethroughFrom(TextStyle base);
  TextStyle underlineFrom(TextStyle base);
  TextStyle linkFrom(TextStyle base, {required Color linkColor});
  TextStyle h1From(TextStyle base);
  TextStyle h2From(TextStyle base);
}

// Dark-theme implementation delegating to NamedTextStyles.
class TwTextStylesDark implements TwTextStylesImpl {
  TwTextStylesDark(this.named);

  final styles.NamedTextStyles named;

  @override
  TextStyle bodyForContext({required BuildContext context, required Color color, double? baseSize}) =>
      named.bodyForContext(context, color: color, baseSize: baseSize);

  @override
  TextStyle bodyForContextless({required Color color, required double textScale}) =>
      named.bodyForContextless(color: color, textScale: textScale);

  @override
  TextStyle sectionTitleForContext({required BuildContext context, required Color color, double? baseSize}) =>
      named.sectionTitleForContext(context, color: color, baseSize: baseSize);

  @override
  TextStyle modalHeaderTitle({required Color color}) =>
      named.modalHeaderTitle(color: color);

  @override
  TextStyle modalCloseGlyph({required Color color}) =>
      named.modalCloseGlyph(color: color);

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
          List<Shadow>? shadows}) =>
      named.adaptBase(base,
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: height,
          fontStyle: fontStyle,
          decoration: decoration,
          decorationThickness: decorationThickness,
          backgroundColor: backgroundColor,
          decorationColor: decorationColor,
          shadows: shadows);

  @override
  TextStyle buttonLabelFrom(TextStyle base, {Color? color}) =>
      named.buttonLabelFrom(base, color: color);

  @override
  TextStyle cardTitleFrom(TextStyle base, {Color? color}) =>
      named.cardTitleFrom(base, color: color);

  @override
  TextStyle smallFrom(TextStyle base, {Color? color}) =>
      named.smallFrom(base, color: color);

  @override
  TextStyle footerBodyForContext({required BuildContext context, required Color color}) =>
      named.footerBodyForContext(context, color: color);

  @override
  TextStyle get transparentSelectionSpacer => named.transparentSelectionSpacer;

  @override
  TextStyle strongFrom(TextStyle base) => named.strongFrom(base);

  @override
  TextStyle blockquoteFrom(TextStyle base) => named.blockquoteFrom(base);

  @override
  TextStyle strikethroughFrom(TextStyle base) => named.strikethroughFrom(base);

  @override
  TextStyle underlineFrom(TextStyle base) => named.underlineFrom(base);

  @override
  TextStyle linkFrom(TextStyle base, {required Color linkColor}) =>
      named.linkFrom(base, linkColor: linkColor);

  @override
  TextStyle h1From(TextStyle base) => named.h1From(base);

  @override
  TextStyle h2From(TextStyle base) => named.h2From(base);
}

// Light-theme implementation also delegating to NamedTextStyles.
class TwTextStylesLight implements TwTextStylesImpl {
  TwTextStylesLight(this.named);

  final styles.NamedTextStyles named;

  @override
  TextStyle bodyForContext({required BuildContext context, required Color color, double? baseSize}) =>
      named.bodyForContext(context, color: color, baseSize: baseSize);

  @override
  TextStyle bodyForContextless({required Color color, required double textScale}) =>
      named.bodyForContextless(color: color, textScale: textScale);

  @override
  TextStyle sectionTitleForContext({required BuildContext context, required Color color, double? baseSize}) =>
      named.sectionTitleForContext(context, color: color, baseSize: baseSize);

  @override
  TextStyle modalHeaderTitle({required Color color}) =>
      named.modalHeaderTitle(color: color);

  @override
  TextStyle modalCloseGlyph({required Color color}) =>
      named.modalCloseGlyph(color: color);

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
          List<Shadow>? shadows}) =>
      named.adaptBase(base,
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: height,
          fontStyle: fontStyle,
          decoration: decoration,
          decorationThickness: decorationThickness,
          backgroundColor: backgroundColor,
          decorationColor: decorationColor,
          shadows: shadows);

  @override
  TextStyle buttonLabelFrom(TextStyle base, {Color? color}) =>
      named.buttonLabelFrom(base, color: color);

  @override
  TextStyle cardTitleFrom(TextStyle base, {Color? color}) =>
      named.cardTitleFrom(base, color: color);

  @override
  TextStyle smallFrom(TextStyle base, {Color? color}) =>
      named.smallFrom(base, color: color);

  @override
  TextStyle footerBodyForContext({required BuildContext context, required Color color}) =>
      named.footerBodyForContext(context, color: color);

  @override
  TextStyle get transparentSelectionSpacer => named.transparentSelectionSpacer;

  @override
  TextStyle strongFrom(TextStyle base) => named.strongFrom(base);

  @override
  TextStyle blockquoteFrom(TextStyle base) => named.blockquoteFrom(base);

  @override
  TextStyle strikethroughFrom(TextStyle base) => named.strikethroughFrom(base);

  @override
  TextStyle underlineFrom(TextStyle base) => named.underlineFrom(base);

  @override
  TextStyle linkFrom(TextStyle base, {required Color linkColor}) =>
      named.linkFrom(base, linkColor: linkColor);

  @override
  TextStyle h1From(TextStyle base) => named.h1From(base);

  @override
  TextStyle h2From(TextStyle base) => named.h2From(base);
}
