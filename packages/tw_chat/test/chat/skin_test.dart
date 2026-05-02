import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_chat/src/config/config.dart';

void main() {
  test('shell top and bottom gradients share the theme shadow ramp', () {
    for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
      final skin = ChatSkin.dataForBrightness(brightness);
      final top = skin.tokens.shellTopShadowGradient(skin.colors);
      final bottom = skin.tokens.shellBottomShadowGradient(skin.colors);

      expect(top.colors.first, skin.colors.shellTopShadowStrong);
      expect(top.colors[2], skin.colors.shellTopShadowSoft);
      expect(top.colors.last, skin.colors.transparent);

      expect(bottom.colors, top.colors);
    }
  });

  test('dark theme accent cyan stays consistent', () {
    final colors = ChatSkin.dataForBrightness(Brightness.dark).colors;
    const accentCyan = Color(0xFF90E8F8);

    expect(colors.shellOuterBorder, const Color(0x3990E8F8));
    expect(colors.botBubbleBorder, const Color(0x3990E8F8));
    expect(colors.bubbleCollapseButton, accentCyan);
    expect(colors.composerBorder, const Color(0x3990E8F8));
    expect(colors.composerCursor, accentCyan);
    expect(colors.composerCornerAccent, accentCyan);
    expect(colors.composerSendIcon, accentCyan);
    expect(colors.markupBlockquoteRail, accentCyan);
    expect(colors.markupLink, accentCyan);
    expect(colors.markupLinkDecoration, accentCyan);
    expect(colors.scrollbarThumb, const Color(0x7690E8F8));
    expect(colors.scrollbarTrack, const Color(0x0090E8F8));
  });
}
