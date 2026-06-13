import 'package:flutter/material.dart';
import 'router.dart';

const Color _chatMainAccent = Color(0xFF843F02);
const Color _chatSoftAccent = Color.fromARGB(255, 214, 214, 214);
const Color _chatComposerFill = Color(0xFFF8F9F7);

const Color _interactive = Color(0xFF394183);
const Color _interactiveHover = Color(0xFF843F02);

const Color _text = Color(0xFF4A3C36);
const Color _mainBgd = Color(0xFFE8DBCF);

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
  pageBackgroundBottom: Color(0xFFDFD2C5),
  modalBackground: _mainBgd,

  gridLine: Color.fromARGB(255, 196, 188, 181),
  grainColor: Color(0x09000000),

  pageBodyText: _text,
  pageHeadingText: _text,
  headerLogoTint: _text,
  headerLogoOpacity: 1.0,
  pageScrollbarThumb: _chatSoftAccent,
  pageScrollbarThumbInactive: Color(0xFFFFFFFF),

  linkText: _interactive,
  linkTextHover: _interactiveHover,
  modalBarrier: Color(0xBF000000),

  cardMarkdownOpacity: 0.85,
  cardFillAlpha: 0.80,
  heroPortraitOpacity: 0.90,
  // capability card tokens
  capabilityCardText: Color(0xFF1E1715),
  capabilityCardDesc: Color(0xFF4E4542),
  capabilityCardCategory: Color(0xFF1B355A),
  capabilityCardDivider: Color(0xFFD6C8BB),
  capabilityCardActive: Color(0xFF1B355A),
  // custom design tokens
  goldAccent: Color.fromARGB(255, 221, 179, 101),
  goldAccentLine: Color.fromARGB(184, 94, 47, 44),
  capabilityCardBgStart: Color(0xFFECE0D3),
  capabilityCardBgMid: Color(0xFFE7D9CC),
  capabilityCardBgEnd: Color(0xFFE1D2C5),
  capabilityCardShadowColor: Color(0xFF734F37),
  capabilityCardShadowHoverColor: Color(0xFF734F37),
  capabilityCardBevelHighlight: Color(0xFFFFFDF6),
  capabilityCardBevelShadow: Color(0xFF795E49),
  gridBackgroundGrain: Color(0xFFFFFFFF),
);
