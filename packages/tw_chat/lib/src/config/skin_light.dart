import 'package:flutter/material.dart';

import 'skin_shared.dart';

const Color _chatMainAccent = Color(0xFF843F02);
const Color _chatSoftAccent = Color.fromARGB(255, 214, 214, 214);
const Color _chatComposerFill = Color(0xFFF8F9F7);

const ChatSkinData chatLightSkin = ChatSkinData(
  colors: ChatSkinColors(
    transparent: Color(0x00000000),
    bubbleText: Color(0xFF000000),
    shellBackground: Color.fromARGB(255, 238, 238, 238),
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
    bubbleFadeMaskOpaque: Color(0xFFFFFFFF),
    bubbleFadeMaskSoft: Color(0x00000000),
    markupLink: _chatMainAccent,
    scrollbarThumb: _chatSoftAccent,
    scrollbarThumbInactive: Color(0xFFFFFFFF),
    scrollbarTrack: Color(0x00F8F9F7),
  ),
);
