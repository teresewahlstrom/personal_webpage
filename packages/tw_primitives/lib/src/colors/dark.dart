import 'package:flutter/material.dart';

/// Dark-theme color tokens used by primitives and chat skin.
class TwColorsDark {
  static const Color chatMainAccent = Color(0xFF90E8F8);
  static const Color chatSoftAccent = Color(0x397199FF);
  static const Color chatComposerFill = Color(0xFF101B34);

  static const Color transparent = Color(0x00000000);
  static const Color bubbleText = Color(0xD6DCF6F8);
  static const Color shellBackground = Color(0xFF212835);
  static const Color shellOuterShadow = Color(0x8A000000);
  static const Color shellOuterBorder = chatSoftAccent;
  static const Color shellDivider = Color(0xFF2B364A);
  static const Color botBubbleFill = chatComposerFill;
  static const Color botBubbleBorder = chatSoftAccent;
  static const Color bubbleShadow = Color(0x47000000);
  static const Color bubbleCollapseButton = chatMainAccent;
  static const Color bubbleCollapseButtonIcon = chatComposerFill;
  static const Color composerFill = chatComposerFill;
  static const Color composerBorder = chatSoftAccent;
  static const Color composerCursor = chatMainAccent;
  static const Color composerCornerAccent = chatMainAccent;
  static const Color composerSendIcon = chatMainAccent;

  // text-field tokens
  static const Color textFieldSelection = Color(0xFF90E8F8);
  static const Color textFieldCaret = Color(0xD6DCF6F8);
  static const Color textFieldHint = Color(0xFF9AA6B2);
  static const Color toolbarColor = Color(0xFF33343A);

  static const Color bubbleFadeMaskOpaque = Color(0xFFFFFFFF);
  static const Color bubbleFadeMaskSoft = Color(0x50FFFFFF);
  static const Color markupLink = chatMainAccent;
  static const Color scrollbarThumb = chatSoftAccent;
  static const Color scrollbarThumbInactive = Color(0xFF283143);
  static const Color scrollbarTrack = Color(0x004EF0FF);
}
