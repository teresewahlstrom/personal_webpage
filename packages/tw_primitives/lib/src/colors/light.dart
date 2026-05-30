import 'package:flutter/material.dart';

/// Light-theme color tokens used by primitives and chat skin.
class TwColorsLight {
  static const Color chatMainAccent = Color(0xFF843F02);
  static const Color chatSoftAccent = Color.fromARGB(255, 214, 214, 214);
  static const Color chatComposerFill = Color(0xFFF8F9F7);

  static const Color transparent = Color(0x00000000);
  static const Color bubbleText = Color(0xFF000000);
  static const Color shellBackground = Color.fromARGB(255, 238, 238, 238);
  static const Color shellOuterShadow = Color(0x14000000);
  static const Color shellOuterBorder = chatSoftAccent;
  static const Color shellDivider = Color(0xFFFFFFFF);
  static const Color botBubbleFill = chatComposerFill;
  static const Color botBubbleBorder = chatSoftAccent;
  static const Color bubbleShadow = Color(0x10000000);
  static const Color bubbleCollapseButton = chatMainAccent;
  static const Color bubbleCollapseButtonIcon = chatComposerFill;
  static const Color composerFill = chatComposerFill;
  static const Color composerBorder = chatSoftAccent;
  static const Color composerCursor = chatMainAccent;
  static const Color composerCornerAccent = chatMainAccent;
  static const Color composerSendIcon = chatMainAccent;

  // text-field tokens
  static const Color textFieldSelection = Color(0xFFACCEF7);
  static const Color textFieldCaret = Color(0xFF000000);
  static const Color textFieldHint = Color(0xFF777777);
  static const Color toolbarColor = Color(0xFFE2E2EA);

  static const Color bubbleFadeMaskOpaque = Color(0xFFFFFFFF);
  static const Color bubbleFadeMaskSoft = Color(0x00000000);
  static const Color markupLink = chatMainAccent;
  static const Color scrollbarThumb = chatSoftAccent;
  static const Color scrollbarThumbInactive = Color(0xFFFFFFFF);
  static const Color scrollbarTrack = Color(0x00F8F9F7);
}
