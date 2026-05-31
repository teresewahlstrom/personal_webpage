import 'package:flutter/material.dart';

const Color _chatMainAccent = Color(0xFF90E8F8);
const Color _chatSoftAccent = Color(0x397199FF);
const Color _chatComposerFill = Color(0xFF101B34);

const Color _interactive = Color(0xFF90E8F8);
const Color _interactiveHover = Color(0xFF90E8F8);

const Color _text =  Color(0xD6DCF6F8);
const Color _mainBgd = Color(0xFF212835);

/// Dark-theme color tokens used by primitives and chat skin.
class TwColorsDark {
  static const Color transparent = Color(0x00000000);
  static const Color bubbleText = _text;
  static const Color shellBackground =_mainBgd;
  static const Color shellOuterShadow = Color(0x8A000000);
  static const Color shellOuterBorder = _chatSoftAccent;
  static const Color shellDivider = Color(0xFF2B364A);
  static const Color botBubbleFill = _chatComposerFill;
  static const Color botBubbleBorder = _chatSoftAccent;
  static const Color bubbleShadow = Color(0x47000000);
  static const Color bubbleCollapseButton = _chatMainAccent;
  static const Color bubbleCollapseButtonIcon = _chatComposerFill;
  static const Color composerFill = _chatComposerFill;
  static const Color composerBorder = _chatSoftAccent;
  static const Color composerCursor = _chatMainAccent;
  static const Color composerCornerAccent = _chatMainAccent;
  static const Color composerSendIcon = _chatMainAccent;

  // text-field tokens
  static const Color textFieldSelection = Color(0xFF90E8F8);
  static const Color textFieldCaret = _text;
  static const Color textFieldHint = Color(0xFF9AA6B2);
  static const Color toolbarColor = Color.fromARGB(255, 58, 51, 51);

  static const Color bubbleFadeMaskOpaque = Color(0xFFFFFFFF);
  static const Color bubbleFadeMaskSoft = Color(0x50FFFFFF);
  static const Color markupLink = _chatMainAccent;
  static const Color scrollbarThumb = _chatSoftAccent;
  static const Color scrollbarThumbInactive = Color(0xFF283143);
  static const Color scrollbarTrack = Color(0x004EF0FF);

  // App-level tokens (from _AppDarkColors)
  static const Color seedColor = Color(0xFF90E8F8);
  static const Color pageLoader = Color(0xFF90E8F8);
  static const Color pageBackground =_mainBgd;
  static const Color headerBackground = _mainBgd;
  static const Color buttonBackground = _mainBgd;
  static const Color footerBackground = _mainBgd;
  static const Color modalBackground = _mainBgd;

  static const Color lineSubtle = Color(0xFF2B364A);
  static const Color lineSubtleSecondary = Color(0x397199FF);
  static const Color lineSubtleTertiary = Color(0x397199FF);
  static const Color modalHeaderBorder = Color(0x3390E8F8);

  static const Color pageBodyText = _text;
  static const Color pageScrollbarThumb = Color(0x397199FF);
  static const Color pageScrollbarThumbInactive = Color(0xFF283143);
  static const Color pageScrollbarTrack = Color(0x004EF0FF);
  static const double projectCardFillAlpha = 0.65;

  static const Color linkText = _interactive;
  static const Color linkTextHover = _interactiveHover;
  static const Color lineInteractive = _interactive;
  static const Color lineInteractiveHover = _interactiveHover;

  static const Color modalCloseIcon = _interactive;
  static const Color modalCloseIconHover = _interactiveHover;
  static const Color modalBarrier = Color(0xBF000000);
}
