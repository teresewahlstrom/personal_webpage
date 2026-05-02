import 'package:flutter/material.dart';

import 'skin_shared.dart';

const Color _accentCyan = Color(0xFF90E8F8);
const Color _accentCyanBorder = Color(0x3990E8F8);
const Color _accentCyanScrollbar = Color(0x7690E8F8);
const Color _accentCyanTransparent = Color(0x0090E8F8);

const ChatSkinData chatDarkSkin = ChatSkinData(
  colors: ChatSkinColors(
    transparent: Color(0x00000000),
    shellTopShadowStrong: Color(0x80000000),
    shellTopShadowSoft: Color(0x08000000),
    appBarTitle: Color(0xEBDCF6F8),
    bubbleText: Color(0xD6DCF6F8),
    shellBackgroundBaseStart: Color(0xFF212835),
    shellBackgroundBaseEnd: Color(0xFF101B34),
    shellBackgroundStart: Color(0xFF212835),
    shellBackgroundEnd: Color(0xFF101B34),
    shellOuterShadow: Color(0x8A000000),
    shellOuterBorder: _accentCyanBorder,
    shellDivider: Color(0xFF2B364A),
    userBubbleFill: Color(0xFF212835),
    userBubbleBorder: Color(0xFF2B364A),
    botBubbleFill: Color(0xFF101B34),
    botBubbleBorder: _accentCyanBorder,
    bubbleShadow: Color(0x47000000),
    bubbleCollapseButton: _accentCyan,
    bubbleCollapseButtonIcon: Color(0xFF101B34),
    composerHint: Color(0xA6DCF6F8),
    composerFill: Color(0xFF101B34),
    composerBorder: _accentCyanBorder,
    composerCursor: _accentCyan,
    composerCornerAccent: _accentCyan,
    composerSendIcon: _accentCyan,
    markupFadeMaskOpaque: Color(0xFFFFFFFF),
    markupFadeMaskSoft: Color(0x50FFFFFF),
    markupBlockquoteRail: _accentCyan,
    markupLink: _accentCyan,
    markupLinkDecoration: _accentCyan,
    scrollbarThumb: _accentCyanScrollbar,
    scrollbarThumbInactive: Color(0xFF2F4A63),
    scrollbarTrack: _accentCyanTransparent,
  ),
);
