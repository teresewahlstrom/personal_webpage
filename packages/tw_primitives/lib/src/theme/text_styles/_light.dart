import 'package:flutter/material.dart';
import '_dark.dart' as dark;

/// Light-theme token facade that delegates to the dark canonical tokens by default.
/// This mirrors the `TwColorsLight`/`TwColorsDark` pattern and provides
/// matching static token names for symmetry across themes.
class TwTextStyleTokensLight {
  static const String twFontFamily = dark.TwTextStyleTokensDark.twFontFamily;

  // Body text tokens
  static const double twBodyBaseFontSize = dark.TwTextStyleTokensDark.twBodyBaseFontSize;
  static const FontWeight twBodyFontWeight = FontWeight.w300;
  static const double twBodyLineHeight = dark.TwTextStyleTokensDark.twBodyLineHeight;
  static const double twBodyMinTextScale = dark.TwTextStyleTokensDark.twBodyMinTextScale;
  static const double twBodyDefaultMaxTextScale = dark.TwTextStyleTokensDark.twBodyDefaultMaxTextScale;
  static const double twBodyScaleIntensity = dark.TwTextStyleTokensDark.twBodyScaleIntensity;

  // Section title tokens
  static const double twSectionBaseFontSize = dark.TwTextStyleTokensDark.twSectionBaseFontSize;
  static const double twSectionLineHeight = dark.TwTextStyleTokensDark.twSectionLineHeight;
  static const FontWeight twSectionFontWeight = FontWeight.w500;
  static const double twSectionScaleIntensity = dark.TwTextStyleTokensDark.twSectionScaleIntensity;

  // Modal tokens
  static const double twModalHeaderFontSize = dark.TwTextStyleTokensDark.twModalHeaderFontSize;
  static const double twModalHeaderLineHeight = dark.TwTextStyleTokensDark.twModalHeaderLineHeight;
  static const FontWeight twModalHeaderFontWeight = FontWeight.w400;

  // Footer tokens
  static const double twFooterBaseFontSize = dark.TwTextStyleTokensDark.twFooterBaseFontSize;

  // H1 tokens
  static const double twH1Scale = dark.TwTextStyleTokensDark.twH1Scale;
  static const FontWeight twH1FontWeight = FontWeight.w400;
  static const double twH1LetterSpacing = dark.TwTextStyleTokensDark.twH1LetterSpacing;
  static const double twH1WordSpacing = dark.TwTextStyleTokensDark.twH1WordSpacing;

  // H2 tokens
  static const double twH2Scale = dark.TwTextStyleTokensDark.twH2Scale;
  static const FontWeight twH2FontWeight = FontWeight.w400;
  static const double twH2LetterSpacing = dark.TwTextStyleTokensDark.twH2LetterSpacing;
  static const double twH2WordSpacing = dark.TwTextStyleTokensDark.twH2WordSpacing;

  static const double twBlockquoteFontSize = dark.TwTextStyleTokensDark.twBlockquoteFontSize;

  // Small UI and toolbar font sizes
  static const double twSmallFontSize = dark.TwTextStyleTokensDark.twSmallFontSize;
  static const double twToolbarFontSize = dark.TwTextStyleTokensDark.twToolbarFontSize;

  static const double twStrikethroughThickness = 0.9;
}

