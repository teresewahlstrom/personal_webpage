import 'package:flutter/material.dart';
import 'package:tw_primitives/src/colors/_light.dart' as light;
import 'package:tw_primitives/src/colors/_dark.dart' as dark;

/// Simple router that returns a collection of primitive theme colors
/// for the requested theme name. Theme name is expected to be either
/// 'light' or 'dark' (case-insensitive).
class TwColors {
  const TwColors._({
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
    required this.projectCardFillAlpha,
    required this.linkText,
    required this.linkTextHover,
    required this.modalCloseIcon,
    required this.modalCloseIconHover,
    required this.lineInteractive,
    required this.lineInteractiveHover,
    required this.modalBarrier,
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
  final double projectCardFillAlpha;
  final Color linkText;
  final Color linkTextHover;
  final Color modalCloseIcon;
  final Color modalCloseIconHover;
  final Color lineInteractive;
  final Color lineInteractiveHover;
  final Color modalBarrier;

  /// Get a `TwColors` instance by theme name ('light' | 'dark').
  static TwColors forTheme(String themeName) {
    final t = themeName.toLowerCase();
    if (t == 'dark') return TwColors._fromDark();
    return TwColors._fromLight();
  }

  /// Convenience: return by [Brightness].
  static TwColors forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? TwColors._fromDark() : TwColors._fromLight();
  }

  /// Convenience: return by [BuildContext].
  static TwColors of(BuildContext context) => TwColors.forBrightness(context.twBrightness);

  static TwColors _fromLight() => TwColors._(
        transparent: light.TwColorsLight.transparent,
        bubbleText: light.TwColorsLight.bubbleText,
        shellBackground: light.TwColorsLight.shellBackground,
        shellOuterShadow: light.TwColorsLight.shellOuterShadow,
        shellOuterBorder: light.TwColorsLight.shellOuterBorder,
        shellDivider: light.TwColorsLight.shellDivider,
        botBubbleFill: light.TwColorsLight.botBubbleFill,
        botBubbleBorder: light.TwColorsLight.botBubbleBorder,
        bubbleShadow: light.TwColorsLight.bubbleShadow,
        bubbleCollapseButton: light.TwColorsLight.bubbleCollapseButton,
        bubbleCollapseButtonIcon: light.TwColorsLight.bubbleCollapseButtonIcon,
        composerFill: light.TwColorsLight.composerFill,
        composerBorder: light.TwColorsLight.composerBorder,
        composerCursor: light.TwColorsLight.composerCursor,
        composerCornerAccent: light.TwColorsLight.composerCornerAccent,
        composerSendIcon: light.TwColorsLight.composerSendIcon,
        textFieldSelection: light.TwColorsLight.textFieldSelection,
        textFieldCaret: light.TwColorsLight.textFieldCaret,
        textFieldHint: light.TwColorsLight.textFieldHint,
        toolbarColor: light.TwColorsLight.toolbarColor,
        bubbleFadeMaskOpaque: light.TwColorsLight.bubbleFadeMaskOpaque,
        bubbleFadeMaskSoft: light.TwColorsLight.bubbleFadeMaskSoft,
        markupLink: light.TwColorsLight.markupLink,
        scrollbarThumb: light.TwColorsLight.scrollbarThumb,
        scrollbarThumbInactive: light.TwColorsLight.scrollbarThumbInactive,
        scrollbarTrack: light.TwColorsLight.scrollbarTrack,
        // app-level
        seedColor: light.TwColorsLight.seedColor,
        pageLoader: light.TwColorsLight.pageLoader,
        pageBackground: light.TwColorsLight.pageBackground,
        headerBackground: light.TwColorsLight.headerBackground,
        buttonBackground: light.TwColorsLight.buttonBackground,
        footerBackground: light.TwColorsLight.footerBackground,
        modalBackground: light.TwColorsLight.modalBackground,
        lineSubtle: light.TwColorsLight.lineSubtle,
        lineSubtleSecondary: light.TwColorsLight.lineSubtleSecondary,
        lineSubtleTertiary: light.TwColorsLight.lineSubtleTertiary,
        modalHeaderBorder: light.TwColorsLight.modalHeaderBorder,
        pageBodyText: light.TwColorsLight.pageBodyText,
        pageScrollbarThumb: light.TwColorsLight.pageScrollbarThumb,
        pageScrollbarThumbInactive: light.TwColorsLight.pageScrollbarThumbInactive,
        pageScrollbarTrack: light.TwColorsLight.pageScrollbarTrack,
        projectCardFillAlpha: light.TwColorsLight.projectCardFillAlpha,
        linkText: light.TwColorsLight.linkText,
        linkTextHover: light.TwColorsLight.linkTextHover,
        modalCloseIcon: light.TwColorsLight.modalCloseIcon,
        modalCloseIconHover: light.TwColorsLight.modalCloseIconHover,
        lineInteractive: light.TwColorsLight.lineInteractive,
        lineInteractiveHover: light.TwColorsLight.lineInteractiveHover,
        modalBarrier: light.TwColorsLight.modalBarrier,
      );

  static TwColors _fromDark() => TwColors._(
        transparent: dark.TwColorsDark.transparent,
        bubbleText: dark.TwColorsDark.bubbleText,
        shellBackground: dark.TwColorsDark.shellBackground,
        shellOuterShadow: dark.TwColorsDark.shellOuterShadow,
        shellOuterBorder: dark.TwColorsDark.shellOuterBorder,
        shellDivider: dark.TwColorsDark.shellDivider,
        botBubbleFill: dark.TwColorsDark.botBubbleFill,
        botBubbleBorder: dark.TwColorsDark.botBubbleBorder,
        bubbleShadow: dark.TwColorsDark.bubbleShadow,
        bubbleCollapseButton: dark.TwColorsDark.bubbleCollapseButton,
        bubbleCollapseButtonIcon: dark.TwColorsDark.bubbleCollapseButtonIcon,
        composerFill: dark.TwColorsDark.composerFill,
        composerBorder: dark.TwColorsDark.composerBorder,
        composerCursor: dark.TwColorsDark.composerCursor,
        composerCornerAccent: dark.TwColorsDark.composerCornerAccent,
        composerSendIcon: dark.TwColorsDark.composerSendIcon,
        textFieldSelection: dark.TwColorsDark.textFieldSelection,
        textFieldCaret: dark.TwColorsDark.textFieldCaret,
        textFieldHint: dark.TwColorsDark.textFieldHint,
        toolbarColor: dark.TwColorsDark.toolbarColor,
        bubbleFadeMaskOpaque: dark.TwColorsDark.bubbleFadeMaskOpaque,
        bubbleFadeMaskSoft: dark.TwColorsDark.bubbleFadeMaskSoft,
        markupLink: dark.TwColorsDark.markupLink,
        scrollbarThumb: dark.TwColorsDark.scrollbarThumb,
        scrollbarThumbInactive: dark.TwColorsDark.scrollbarThumbInactive,
        scrollbarTrack: dark.TwColorsDark.scrollbarTrack,
        // app-level
        seedColor: dark.TwColorsDark.seedColor,
        pageLoader: dark.TwColorsDark.pageLoader,
        pageBackground: dark.TwColorsDark.pageBackground,
        headerBackground: dark.TwColorsDark.headerBackground,
        buttonBackground: dark.TwColorsDark.buttonBackground,
        footerBackground: dark.TwColorsDark.footerBackground,
        modalBackground: dark.TwColorsDark.modalBackground,
        lineSubtle: dark.TwColorsDark.lineSubtle,
        lineSubtleSecondary: dark.TwColorsDark.lineSubtleSecondary,
        lineSubtleTertiary: dark.TwColorsDark.lineSubtleTertiary,
        modalHeaderBorder: dark.TwColorsDark.modalHeaderBorder,
        pageBodyText: dark.TwColorsDark.pageBodyText,
        pageScrollbarThumb: dark.TwColorsDark.pageScrollbarThumb,
        pageScrollbarThumbInactive: dark.TwColorsDark.pageScrollbarThumbInactive,
        pageScrollbarTrack: dark.TwColorsDark.pageScrollbarTrack,
        projectCardFillAlpha: dark.TwColorsDark.projectCardFillAlpha,
        linkText: dark.TwColorsDark.linkText,
        linkTextHover: dark.TwColorsDark.linkTextHover,
        modalCloseIcon: dark.TwColorsDark.modalCloseIcon,
        modalCloseIconHover: dark.TwColorsDark.modalCloseIconHover,
        lineInteractive: dark.TwColorsDark.lineInteractive,
        lineInteractiveHover: dark.TwColorsDark.lineInteractiveHover,
        modalBarrier: dark.TwColorsDark.modalBarrier,
      );
}

extension TwColorsBuildContextExtension on BuildContext {
  TwColors get twColors => TwColors.of(this);
}

extension TwContextBrightnessExtension on BuildContext {
  Brightness get twBrightness => Theme.of(this).brightness;
  bool get twIsDark => twBrightness == Brightness.dark;
}
