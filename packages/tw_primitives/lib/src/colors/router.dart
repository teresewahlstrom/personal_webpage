import 'package:flutter/material.dart';
import 'package:tw_primitives/src/colors/light.dart' as light;
import 'package:tw_primitives/src/colors/dark.dart' as dark;

/// Simple router that returns a collection of primitive theme colors
/// for the requested theme name. Theme name is expected to be either
/// 'light' or 'dark' (case-insensitive).
class TwColors {
  const TwColors._({
    required this.chatMainAccent,
    required this.chatSoftAccent,
    required this.chatComposerFill,
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
  });

  final Color chatMainAccent;
  final Color chatSoftAccent;
  final Color chatComposerFill;

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

  static TwColors _fromLight() => TwColors._(
        chatMainAccent: light.TwColorsLight.chatMainAccent,
        chatSoftAccent: light.TwColorsLight.chatSoftAccent,
        chatComposerFill: light.TwColorsLight.chatComposerFill,
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
      );

  static TwColors _fromDark() => TwColors._(
        chatMainAccent: dark.TwColorsDark.chatMainAccent,
        chatSoftAccent: dark.TwColorsDark.chatSoftAccent,
        chatComposerFill: dark.TwColorsDark.chatComposerFill,
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
      );
}
