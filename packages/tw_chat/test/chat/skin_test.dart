import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_chat/src/config/skin.dart';

void main() {
  group('ChatSkin palette audit', () {
    test('top and bottom shell gradients use the explicit shadow tokens', () {
      for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
        final colors = ChatSkin.dataForBrightness(brightness).colors;
        final expectedGradientColors = <Color>[
          colors.shellTopShadowStrong,
          Color.lerp(
            colors.shellTopShadowStrong,
            colors.shellTopShadowSoft,
            0.35,
          )!,
          Color.lerp(
            colors.shellTopShadowStrong,
            colors.shellTopShadowSoft,
            0.75,
          )!,
          colors.shellTopShadowSoft.withValues(alpha: 0),
        ];

        expect(
          ChatSkin.tokens.shellTopShadowGradient(colors).colors,
          expectedGradientColors,
        );
        expect(
          ChatSkin.tokens.shellBottomShadowGradient(colors).colors,
          expectedGradientColors,
        );
      }
    });

    test('dark theme reuses one accent cyan across interactive elements', () {
      final colors = ChatSkin.dataForBrightness(Brightness.dark).colors;
      const accent = Color(0xFF90E8F8);

      expect(colors.bubbleCollapseButton, accent);
      expect(colors.composerCursor, accent);
      expect(colors.composerCornerAccent, accent);
      expect(colors.composerSendIcon, accent);
      expect(colors.markupBlockquoteRail, accent);
      expect(colors.markupLink, accent);
      expect(colors.markupLinkDecoration, accent);
      expect(colors.scrollbarThumb, const Color(0x7690E8F8));
      expect(colors.scrollbarTrack, const Color(0x0090E8F8));
    });

    test('dark theme shadows stay stronger than light without being extreme', () {
      final lightColors = ChatSkin.dataForBrightness(Brightness.light).colors;
      final darkColors = ChatSkin.dataForBrightness(Brightness.dark).colors;

      expect(lightColors.shellOuterShadow, const Color(0x08000000));
      expect(darkColors.shellOuterShadow, const Color(0x24000000));
      expect(lightColors.bubbleShadow, const Color(0x08000000));
      expect(darkColors.bubbleShadow, const Color(0x1A000000));
      expect(darkColors.shellOuterShadow.a, greaterThan(lightColors.shellOuterShadow.a));
      expect(darkColors.bubbleShadow.a, greaterThan(lightColors.bubbleShadow.a));
    });
  });
}
