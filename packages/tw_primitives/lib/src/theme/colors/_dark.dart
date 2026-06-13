import 'package:flutter/material.dart';
import 'router.dart';

const Color _chatMainAccent = Color(0xFF90E8F8);
const Color _chatSoftAccent = Color(0x397199FF);
const Color _chatComposerFill = Color(0xFF101B34);

const Color _interactive = Color(0xFF90E8F8);
const Color _interactiveHover = Color(0xFF90E8F8);

const Color _text = Color.fromARGB(255, 157, 178, 199);
const Color _mainBgd = Color(0xFF212835);

/// Dark-theme color tokens used by primitives and chat skin.
const TwColors twColorsDark = TwColors.create(
  transparent: Color(0x00000000),
  bubbleText: _text,
  shellBackground: _mainBgd,
  shellOuterShadow: Color(0x8A000000),
  shellOuterBorder: _chatSoftAccent,
  shellDivider: Color(0xFF2B364A),
  botBubbleFill: _chatComposerFill,
  botBubbleBorder: _chatSoftAccent,
  bubbleShadow: Color(0x47000000),
  bubbleCollapseButton: _chatMainAccent,
  bubbleCollapseButtonIcon: _chatComposerFill,
  composerFill: _chatComposerFill,
  composerBorder: _chatSoftAccent,
  composerCursor: _chatMainAccent,
  composerCornerAccent: _chatMainAccent,
  composerSendIcon: _chatMainAccent,

  // text-field tokens
  textFieldSelection: Color(0xFF90E8F8),
  textFieldCaret: _text,
  toolbarColor: Color.fromARGB(255, 58, 51, 51),

  bubbleFadeMaskOpaque: Color(0xFFFFFFFF),
  bubbleFadeMaskSoft: Color(0x50FFFFFF),
  markupLink: _chatMainAccent,
  scrollbarThumb: _chatSoftAccent,
  scrollbarThumbInactive: Color(0xFF283143),
  scrollbarTrack: Color(0x004EF0FF),

  // App-level tokens (from _AppDarkColors)
  seedColor: Color(0xFF90E8F8),
  pageLoader: Color(0xFF90E8F8),
  pageBackground: _mainBgd,
  pageBackgroundBottom: Color(0xFF1B212C),
  modalBackground: _mainBgd,

  gridLine: Color.fromARGB(255, 41, 63, 100),
  grainColor: Color.fromARGB(183, 24, 46, 66),

  pageBodyText: _text,
  pageHeadingText: Color(0xFFE2E9F0),
  headerLogoTint: _text,
  headerLogoOpacity: 0.9,
  pageScrollbarThumb: Color(0x397199FF),
  pageScrollbarThumbInactive: Color(0xFF283143),

  linkText: _interactive,
  linkTextHover: _interactiveHover,
  modalBarrier: Color(0xBF000000),

  cardMarkdownOpacity: 0.85,
  cardFillAlpha: 0.65,
  heroPortraitOpacity: 0.70,
  // capability card tokens
  capabilityCardText: Color(0xFFE3E9F0),
  capabilityCardDesc: Color(0xFFA2AEBB),
  capabilityCardCategory: Color(0xFF90E8F8),
  capabilityCardDivider: Color(0xFF2E3B50),
  capabilityCardActive: Color(0xFF90E8F8),
  // custom design tokens
  goldAccent: Color(0xFFFFD700),
  goldAccentLine: Color(0x33FFD700),
  capabilityCardBgStart: Color(0xFF161C28),
  capabilityCardBgMid: Color(0xFF1C2331),
  capabilityCardBgEnd: Color(0xFF242C3C),
  capabilityCardShadowColor: Color(0xFF000000),
  capabilityCardShadowHoverColor: Color(0xFF000000),
  capabilityCardBevelHighlight: Color(0xFFFFFFFF),
  capabilityCardBevelShadow: Color(0xFF0D1117),
  gridBackgroundGrain: Color(0xFFFFFFFF),
);
