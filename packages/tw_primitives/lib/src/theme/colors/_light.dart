import 'package:flutter/material.dart';
import 'router.dart';

const Color _chatMainAccent = Color(0xFF843F02);
const Color _chatSoftAccent = Color.fromARGB(255, 214, 214, 214);
const Color _chatComposerFill = Color(0xFFF8F9F7);

const Color _interactive = Color(0xFF394183);
const Color _interactiveHover = Color(0xFF843F02);

const Color _text =  Color(0xFF000000);
const Color _mainBgd = Color.fromARGB(255, 238, 238, 238);

/// Light-theme color tokens used by primitives and chat skin.
const TwColors twColorsLight = TwColors.create(
  transparent: Color(0x00000000),
  bubbleText: _text,
  shellBackground: _mainBgd,
  shellOuterShadow: Color(0x14000000),
  shellOuterBorder: _chatSoftAccent,
  shellDivider: Color(0xFFFFFFFF),
  botBubbleFill: _chatComposerFill,
  botBubbleBorder: _chatSoftAccent,
  bubbleShadow: Color(0x10000000),
  bubbleCollapseButton: _chatMainAccent,
  bubbleCollapseButtonIcon: _chatComposerFill,
  composerFill: _chatComposerFill,
  composerBorder: _chatSoftAccent,
  composerCursor: _chatMainAccent,
  composerCornerAccent: _chatMainAccent,
  composerSendIcon: _chatMainAccent,

  // text-field tokens
  textFieldSelection: Color(0xFFACCEF7),
  textFieldCaret: _text,
  textFieldHint: Color(0xFF777777),
  toolbarColor: Color(0xFFE2E2EA),

  bubbleFadeMaskOpaque: Color(0xFFFFFFFF),
  bubbleFadeMaskSoft: Color(0x00000000),
  markupLink: _chatMainAccent,
  scrollbarThumb: _chatSoftAccent,
  scrollbarThumbInactive: Color(0xFFFFFFFF),
  scrollbarTrack: Color(0x00F8F9F7),

  // App-level tokens (from AppColorTheme _AppLightColors)
  seedColor: Color(0xFF394183),
  pageLoader: _text,
  pageBackground: _mainBgd,
  headerBackground: _mainBgd,
  buttonBackground: _mainBgd,
  footerBackground: _mainBgd,
  modalBackground: _mainBgd,

  lineSubtle: Color(0xFFFFFFFF),
  lineSubtleSecondary: Color(0xFFFFFFFF),
  lineSubtleTertiary: Color(0xFFFFFFFF),
  modalHeaderBorder: Color(0xFFFFFFFF),

  pageBodyText: _text,
  pageScrollbarThumb: Color(0xFFFFFFFF),
  pageScrollbarThumbInactive: Color(0xFFFFFFFF),
  pageScrollbarTrack: Color(0x00F8F9F7),
  projectCardFillAlpha: 0.70,

  linkText: _interactive,
  linkTextHover: _interactiveHover,
  lineInteractive: _interactive,
  lineInteractiveHover: _interactiveHover,

  modalCloseIcon: _interactive,
  modalCloseIconHover: _interactiveHover,
  modalBarrier: Color(0xBF000000),
);
