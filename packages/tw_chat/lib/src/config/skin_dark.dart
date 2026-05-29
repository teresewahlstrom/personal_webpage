import 'package:flutter/material.dart';

import 'skin_shared.dart';

const Color _chatMainAccent = Color(0xFF90E8F8);
const Color _chatSoftAccent = Color(0x397199FF);
const Color _chatComposerFill = Color(0xFF101B34);


const ChatSkinData chatDarkSkin = ChatSkinData(
  colors: ChatSkinColors(
    transparent: Color(0x00000000),
    bubbleText: Color(0xD6DCF6F8),
    shellBackground: Color(0xFF212835),
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
    bubbleFadeMaskOpaque: Color(0xFFFFFFFF),
    bubbleFadeMaskSoft: Color(0x50FFFFFF),
    markupLink: _chatMainAccent,
    scrollbarThumb: _chatSoftAccent,
    scrollbarThumbInactive: Color(0xFF283143),
    scrollbarTrack: Color(0x004EF0FF),
  ),
);
