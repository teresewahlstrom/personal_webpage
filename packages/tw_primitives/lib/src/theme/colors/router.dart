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
    required this.textFieldHint,
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
    required this.headerBackground,
    required this.buttonBackground,
    required this.footerBackground,
    required this.modalBackground,
    required this.lineSubtle,
    required this.lineSubtleSecondary,
    required this.lineSubtleTertiary,
    required this.modalHeaderBorder,
    required this.pageBodyText,
    required this.pageScrollbarThumb,
    required this.pageScrollbarThumbInactive,
    required this.pageScrollbarTrack,
    required this.cardFillAlpha,
    required this.linkText,
    required this.linkTextHover,
    required this.modalCloseIcon,
    required this.modalCloseIconHover,
    required this.lineInteractive,
    required this.lineInteractiveHover,
    required this.modalBarrier,
    required this.cardMarkdownOpacity,
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
  final Color textFieldHint;
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
  final Color headerBackground;
  final Color buttonBackground;
  final Color footerBackground;
  final Color modalBackground;
  final Color lineSubtle;
  final Color lineSubtleSecondary;
  final Color lineSubtleTertiary;
  final Color modalHeaderBorder;
  final Color pageBodyText;
  final Color pageScrollbarThumb;
  final Color pageScrollbarThumbInactive;
  final Color pageScrollbarTrack;
  final double cardFillAlpha;
  final Color linkText;
  final Color linkTextHover;
  final Color modalCloseIcon;
  final Color modalCloseIconHover;
  final Color lineInteractive;
  final Color lineInteractiveHover;
  final Color modalBarrier;
  final double cardMarkdownOpacity;

  /// Get a `TwColors` instance by theme name ('light' | 'dark').
  static TwColors forTheme(String themeName) {
    final t = themeName.toLowerCase();
    if (t == 'dark') return dark.twColorsDark;
    return light.twColorsLight;
  }

  /// Convenience: return by [Brightness].
  static TwColors forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark.twColorsDark : light.twColorsLight;
  }

  /// Convenience: return by [BuildContext].
  static TwColors of(BuildContext context) => TwColors.forBrightness(context.twBrightness);
}

extension TwColorsBuildContextExtension on BuildContext {
  TwColors get twColors => TwColors.of(this);
}

extension TwContextBrightnessExtension on BuildContext {
  Brightness get twBrightness => Theme.of(this).brightness;
  bool get twIsDark => twBrightness == Brightness.dark;
}
