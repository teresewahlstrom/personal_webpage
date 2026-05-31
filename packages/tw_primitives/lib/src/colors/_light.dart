import 'package:flutter/material.dart';

const Color _chatMainAccent = Color(0xFF843F02);
const Color _chatSoftAccent = Color.fromARGB(255, 214, 214, 214);
const Color _chatComposerFill = Color(0xFFF8F9F7);

const Color _interactive = Color(0xFF394183);
const Color _interactiveHover = Color(0xFF843F02);

const Color _text =  Color(0xFF000000);
const Color _mainBgd = Color.fromARGB(255, 238, 238, 238); 

/// Light-theme color tokens used by primitives and chat skin.
class TwColorsLight {
  static const Color transparent = Color(0x00000000);
  static const Color bubbleText = _text;
  static const Color shellBackground = _mainBgd;
  static const Color shellOuterShadow = Color(0x14000000);
  static const Color shellOuterBorder = _chatSoftAccent;
  static const Color shellDivider = Color(0xFFFFFFFF);
  static const Color botBubbleFill = _chatComposerFill;
  static const Color botBubbleBorder = _chatSoftAccent;
  static const Color bubbleShadow = Color(0x10000000);
  static const Color bubbleCollapseButton = _chatMainAccent;
  static const Color bubbleCollapseButtonIcon = _chatComposerFill;
  static const Color composerFill = _chatComposerFill;
  static const Color composerBorder = _chatSoftAccent;
  static const Color composerCursor = _chatMainAccent;
  static const Color composerCornerAccent = _chatMainAccent;
  static const Color composerSendIcon = _chatMainAccent;

  // text-field tokens
  static const Color textFieldSelection = Color(0xFFACCEF7);
  static const Color textFieldCaret = _text;
  static const Color textFieldHint = Color(0xFF777777);
  static const Color toolbarColor = Color(0xFFE2E2EA);

  static const Color bubbleFadeMaskOpaque = Color(0xFFFFFFFF);
  static const Color bubbleFadeMaskSoft = Color(0x00000000);
  static const Color markupLink = _chatMainAccent;
  static const Color scrollbarThumb = _chatSoftAccent;
  static const Color scrollbarThumbInactive = Color(0xFFFFFFFF);
  static const Color scrollbarTrack = Color(0x00F8F9F7);

  // App-level tokens (from AppColorTheme _AppLightColors)
  static const Color seedColor = Color(0xFF394183);
  static const Color pageLoader = pageBodyText;
  static const Color pageBackground = _mainBgd;
  static const Color headerBackground = _mainBgd;
  static const Color buttonBackground = _mainBgd;
  static const Color footerBackground = _mainBgd;
  static const Color modalBackground = _mainBgd;

  static const Color lineSubtle = Color(0xFFFFFFFF);
  static const Color lineSubtleSecondary = Color(0xFFFFFFFF);
  static const Color lineSubtleTertiary = Color(0xFFFFFFFF);
  static const Color modalHeaderBorder = Color(0xFFFFFFFF);

  static const Color pageBodyText = _text;
  static const Color pageScrollbarThumb = Color(0xFFFFFFFF);
  static const Color pageScrollbarThumbInactive = Color(0xFFFFFFFF);
  static const Color pageScrollbarTrack = Color(0x00F8F9F7);
  static const double projectCardFillAlpha = 0.70;

  static const Color linkText = _interactive;
  static const Color linkTextHover = _interactiveHover;
  static const Color lineInteractive = _interactive;
  static const Color lineInteractiveHover = _interactiveHover;

  static const Color modalCloseIcon = _interactive;
  static const Color modalCloseIconHover = _interactiveHover;
  static const Color modalBarrier = Color(0xBF000000);
}
