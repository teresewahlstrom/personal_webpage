import 'package:flutter/material.dart';
import 'package:tw_primitives/src/theme/text_styles/_dark.dart' as dark;

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

  static const double twFooterBaseFontSize = dark.TwTextStyleTokensDark.twFooterBaseFontSize;

  static const TextStyle twTransparentSelectionSpacer = dark.TwTextStyleTokensDark.twTransparentSelectionSpacer;

  // Header/hint tokens
  static const double twHeader1FontSize = dark.TwTextStyleTokensDark.twHeader1FontSize;
  static const double twHeader2FontSize = dark.TwTextStyleTokensDark.twHeader2FontSize;
  static const double twBlockquoteFontSize = dark.TwTextStyleTokensDark.twBlockquoteFontSize;
  static const double twSmallFontSize = dark.TwTextStyleTokensDark.twSmallFontSize;
  static const double twToolbarFontSize = dark.TwTextStyleTokensDark.twToolbarFontSize;
  static const double twCardTitleScale = dark.TwTextStyleTokensDark.twCardTitleScale;
}

