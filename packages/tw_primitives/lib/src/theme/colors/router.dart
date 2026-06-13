import 'package:flutter/material.dart';
import '_light.dart' as light;
import '_dark.dart' as dark;

/// Simple router that returns a collection of primitive theme colors
/// for the requested theme name. Theme name is expected to be either
/// 'light' or 'dark' (case-insensitive).
class TwColors {
  const TwColors.create({
    required this.transparent,
    required this.bubbleText,
    required this.shellBackground,
    required this.shellOuterShadow,
    required this.shellOuterBorder,
    required this.shellDivider,
    required this.botBubbleFill,
    required this.botBubbleBorder,
    required this.bubbleShadow,
    required this.bubbleCollapseButton,
    required this.bubbleCollapseButtonIcon,
    required this.composerFill,
    required this.composerBorder,
    required this.composerCursor,
    required this.composerCornerAccent,
    required this.composerSendIcon,
    required this.textFieldSelection,
    required this.textFieldCaret,
    required this.toolbarColor,
    required this.bubbleFadeMaskOpaque,
    required this.bubbleFadeMaskSoft,
    required this.markupLink,
    required this.scrollbarThumb,
    required this.scrollbarThumbInactive,
    required this.scrollbarTrack,
    // app-level tokens
    required this.seedColor,
    required this.pageLoader,
    required this.pageBackground,
    required this.pageBackgroundBottom,
    required this.modalBackground,
    required this.gridLine,
    required this.grainColor,
    required this.pageBodyText,
    required this.pageHeadingText,
    required this.headerLogoTint,
    required this.headerLogoOpacity,
    required this.pageScrollbarThumb,
    required this.pageScrollbarThumbInactive,
    required this.cardFillAlpha,
    required this.linkText,
    required this.linkTextHover,
    required this.modalBarrier,
    required this.cardMarkdownOpacity,
    required this.heroPortraitOpacity,
    // capability card tokens
    required this.capabilityCardText,
    required this.capabilityCardDesc,
    required this.capabilityCardCategory,
    required this.capabilityCardDivider,
    required this.capabilityCardActive,
    // custom design tokens
    required this.goldAccent,
    required this.goldAccentLine,
    required this.capabilityCardBgStart,
    required this.capabilityCardBgMid,
    required this.capabilityCardBgEnd,
    required this.capabilityCardShadowColor,
    required this.capabilityCardShadowHoverColor,
    required this.capabilityCardBevelHighlight,
    required this.capabilityCardBevelShadow,
    required this.gridBackgroundGrain,
  });

  final Color transparent;
  final Color bubbleText;
  final Color shellBackground;
  final Color shellOuterShadow;
  final Color shellOuterBorder;
  final Color shellDivider;
  final Color botBubbleFill;
  final Color botBubbleBorder;
  final Color bubbleShadow;
  final Color bubbleCollapseButton;
  final Color bubbleCollapseButtonIcon;
  final Color composerFill;
  final Color composerBorder;
  final Color composerCursor;
  final Color composerCornerAccent;
  final Color composerSendIcon;

  // text-field tokens
  final Color textFieldSelection;
  final Color textFieldCaret;
  final Color toolbarColor;

  final Color bubbleFadeMaskOpaque;
  final Color bubbleFadeMaskSoft;
  final Color markupLink;
  final Color scrollbarThumb;
  final Color scrollbarThumbInactive;
  final Color scrollbarTrack;

  // app-level tokens
  final Color seedColor;
  final Color pageLoader;
  final Color pageBackground;
  final Color pageBackgroundBottom;
  final Color modalBackground;
  final Color gridLine;
  final Color grainColor;
  final Color pageBodyText;
  final Color pageHeadingText;
  final Color headerLogoTint;
  final double headerLogoOpacity;
  final Color pageScrollbarThumb;
  final Color pageScrollbarThumbInactive;
  final double cardFillAlpha;
  final Color linkText;
  final Color linkTextHover;
  final Color modalBarrier;
  final double cardMarkdownOpacity;
  final double heroPortraitOpacity;
  // capability card tokens
  final Color capabilityCardText;
  final Color capabilityCardDesc;
  final Color capabilityCardCategory;
  final Color capabilityCardDivider;
  final Color capabilityCardActive;
  // custom design tokens
  final Color goldAccent;
  final Color goldAccentLine;
  final Color capabilityCardBgStart;
  final Color capabilityCardBgMid;
  final Color capabilityCardBgEnd;
  final Color capabilityCardShadowColor;
  final Color capabilityCardShadowHoverColor;
  final Color capabilityCardBevelHighlight;
  final Color capabilityCardBevelShadow;
  final Color gridBackgroundGrain;

  /// Get a `TwColors` instance by theme name ('light' | 'dark').
  static TwColors forTheme(String themeName) {
    final t = themeName.toLowerCase();
    if (t == 'dark') return dark.twColorsDark;
    return light.twColorsLight;
  }

  /// Convenience: return by [Brightness].
  static TwColors forBrightness(Brightness brightness) {
    return brightness == Brightness.dark
        ? dark.twColorsDark
        : light.twColorsLight;
  }

  /// Convenience: return by [BuildContext].
  static TwColors of(BuildContext context) =>
      TwColors.forBrightness(context.twBrightness);
}

extension TwColorsBuildContextExtension on BuildContext {
  TwColors get twColors => TwColors.of(this);
}

extension TwContextBrightnessExtension on BuildContext {
  Brightness get twBrightness => Theme.of(this).brightness;
  bool get twIsDark => twBrightness == Brightness.dark;
}
