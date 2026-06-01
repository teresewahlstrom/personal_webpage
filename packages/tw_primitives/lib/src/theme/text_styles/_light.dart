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
  static const double twHeader1FontSize = dark.TwTextStyleTokensDark.twHeader1FontSize;
  static const double twHeader2FontSize = dark.TwTextStyleTokensDark.twHeader2FontSize;
  static const double twHeading1LetterSpacing = dark.TwTextStyleTokensDark.twHeading1LetterSpacing;
  static const double twHeading1WordSpacing = dark.TwTextStyleTokensDark.twHeading1WordSpacing;
  static const double twHeading2LetterSpacing = dark.TwTextStyleTokensDark.twHeading2LetterSpacing;
  static const double twHeading2WordSpacing = dark.TwTextStyleTokensDark.twHeading2WordSpacing;
  static const double twBlockquoteFontSize = dark.TwTextStyleTokensDark.twBlockquoteFontSize;
  static const double twSmallFontSize = dark.TwTextStyleTokensDark.twSmallFontSize;
  static const double twToolbarFontSize = dark.TwTextStyleTokensDark.twToolbarFontSize;
  static const double twCardTitleScale = dark.TwTextStyleTokensDark.twCardTitleScale;
}
