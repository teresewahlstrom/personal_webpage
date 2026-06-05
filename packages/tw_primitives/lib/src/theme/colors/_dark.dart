import 'package:flutter/material.dart';
import 'router.dart';

const Color _chatMainAccent = Color(0xFF90E8F8);
const Color _chatSoftAccent = Color(0x397199FF);
const Color _chatComposerFill = Color(0xFF101B34);

const Color _interactive = Color(0xFF90E8F8);
const Color _interactiveHover = Color(0xFF90E8F8);

const Color _text =  Color(0xD6DCF6F8);
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
  textFieldHint: Color(0xFF9AA6B2),
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
  headerBackground: _mainBgd,
  footerBackground: _mainBgd,
  modalBackground: _mainBgd,

  lineSubtle: Color(0xFF2B364A),
  lineSubtleSecondary: Color(0x397199FF),

  pageBodyText: _text,
  headerLogoTint: _text,
  pageScrollbarThumb: Color(0x397199FF),
  pageScrollbarThumbInactive: Color(0xFF283143),

  linkText: _interactive,
  linkTextHover: _interactiveHover,
  modalBarrier: Color(0xBF000000),

  cardMarkdownOpacity: 0.85,
  cardFillAlpha: 0.65,
  heroPortraitOpacity: 0.40,
);
