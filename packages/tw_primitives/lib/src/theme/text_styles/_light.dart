import 'package:flutter/material.dart';
import '_dark.dart' as dark;

/// Light-theme token facade that delegates to the dark canonical tokens by default.
/// This mirrors the `TwColorsLight`/`TwColorsDark` pattern and provides
/// matching static token names for symmetry across themes.
class TwTextStyleTokensLight {
  static const String twFontFamily = dark.TwTextStyleTokensDark.twFontFamily;

  static const double twBodyBaseFontSize = dark.TwTextStyleTokensDark.twBodyBaseFontSize;
  static const FontWeight twBodyFontWeight = dark.TwTextStyleTokensDark.twBodyFontWeight;
  static const double twBodyLineHeight = dark.TwTextStyleTokensDark.twBodyLineHeight;
  static const double twBodyMinTextScale = dark.TwTextStyleTokensDark.twBodyMinTextScale;
  static const double twBodyDefaultMaxTextScale = dark.TwTextStyleTokensDark.twBodyDefaultMaxTextScale;
  static const double twBodyScaleIntensity = dark.TwTextStyleTokensDark.twBodyScaleIntensity;

  static const double twSectionBaseFontSize = dark.TwTextStyleTokensDark.twSectionBaseFontSize;
  static const double twSectionLineHeight = dark.TwTextStyleTokensDark.twSectionLineHeight;
  static const FontWeight twSectionFontWeight = dark.TwTextStyleTokensDark.twSectionFontWeight;
  static const double twSectionScaleIntensity = dark.TwTextStyleTokensDark.twSectionScaleIntensity;

  static const double twModalHeaderFontSize = dark.TwTextStyleTokensDark.twModalHeaderFontSize;
  static const double twModalHeaderLineHeight = dark.TwTextStyleTokensDark.twModalHeaderLineHeight;
  static const FontWeight twModalHeaderFontWeight = dark.TwTextStyleTokensDark.twModalHeaderFontWeight;

  // Strong/bold font weight used for markdown/heading emphasis in light theme
  static const FontWeight twStrongFontWeight = FontWeight.w500;

  static const double twFooterBaseFontSize = dark.TwTextStyleTokensDark.twFooterBaseFontSize;

  static const TextStyle twTransparentSelectionSpacer = dark.TwTextStyleTokensDark.twTransparentSelectionSpacer;

  // Header/hint tokens
  static const double twH1FontSize = dark.TwTextStyleTokensDark.twH1FontSize;
  static const double twH2FontSize = dark.TwTextStyleTokensDark.twH2FontSize;
  static const double twCardH2Scale = dark.TwTextStyleTokensDark.twCardH2Scale;
  static const FontWeight twH1FontWeight = dark.TwTextStyleTokensDark.twH1FontWeight;
  static const FontWeight twH2FontWeight = dark.TwTextStyleTokensDark.twH2FontWeight;
  static const double twH1LetterSpacing = dark.TwTextStyleTokensDark.twH1LetterSpacing;
  static const double twH1WordSpacing = dark.TwTextStyleTokensDark.twH1WordSpacing;
  static const double twH2LetterSpacing = dark.TwTextStyleTokensDark.twH2LetterSpacing;
  static const double twH2WordSpacing = dark.TwTextStyleTokensDark.twH2WordSpacing;
  static const double twBlockquoteFontSize = dark.TwTextStyleTokensDark.twBlockquoteFontSize;
  static const double twSmallFontSize = dark.TwTextStyleTokensDark.twSmallFontSize;
  static const double twToolbarFontSize = dark.TwTextStyleTokensDark.twToolbarFontSize;
}
