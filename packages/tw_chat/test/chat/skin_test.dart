import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_chat/src/config/config.dart';

void main() {
  test('shell gradients tint their matching shell background colors', () {
    for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
      final skin = ChatSkin.dataForBrightness(brightness);
      final top = skin.tokens.shellTopShadowGradient(skin.colors);
      final bottom = skin.tokens.shellBottomShadowGradient(skin.colors);

      expect(
        top.colors,
        _expectedGradientColors(
          skin.colors.shellBackgroundStart,
          skin.tokens.shellTopShadowGradientAlphas,
        ),
      );
      expect(
        bottom.colors,
        _expectedGradientColors(
          skin.colors.shellBackgroundEnd,
          skin.tokens.shellBottomShadowGradientAlphas,
        ),
      );
    }
  });

  test('light and dark shell gradients keep the same opacity strength', () {
    final light = ChatSkin.dataForBrightness(Brightness.light);
    final dark = ChatSkin.dataForBrightness(Brightness.dark);

    expect(
      _alphaBytes(light.tokens.shellTopShadowGradient(light.colors).colors),
      _alphaBytes(dark.tokens.shellTopShadowGradient(dark.colors).colors),
    );
    expect(
      _alphaBytes(light.tokens.shellBottomShadowGradient(light.colors).colors),
      _alphaBytes(dark.tokens.shellBottomShadowGradient(dark.colors).colors),
    );
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

List<Color> _expectedGradientColors(Color baseColor, List<int> alphas) {
  return alphas
      .map((alpha) => baseColor.withValues(alpha: alpha / 0xFF))
      .toList(growable: false);
}

List<int> _alphaBytes(List<Color> colors) {
  return colors.map((color) => (color.a * 0xFF).round()).toList(growable: false);
}
