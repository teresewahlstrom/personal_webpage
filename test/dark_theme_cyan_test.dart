import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/config/app_ui_config.dart';
import 'package:personal_webpage/widgets/shell/_floating_controls.dart';
import 'package:tw_chat/src/config/skin.dart';
import 'package:tw_keywords/tw_keywords.dart';

void main() {
  const sendButtonCyan = Color(0xFF90E8F8);

  test('dark app interactive accents use the send-button cyan', () {
    expect(AppColorTheme.linkTextFor(Brightness.dark), sendButtonCyan);
    expect(AppColorTheme.linkTextHoverFor(Brightness.dark), sendButtonCyan);
    expect(AppColorTheme.modalCloseIconFor(Brightness.dark), sendButtonCyan);
    expect(
      AppColorTheme.modalCloseIconHoverFor(Brightness.dark),
      sendButtonCyan,
    );
    expect(AppColorTheme.lineInteractiveFor(Brightness.dark), sendButtonCyan);
    expect(
      AppColorTheme.lineInteractiveHoverFor(Brightness.dark),
      sendButtonCyan,
    );
  });

  test('project card fill alphas stay aligned with the tinted panel theme', () {
    expect(AppColorTheme.projectCardFillAlphaFor(Brightness.light), 0.70);
    expect(AppColorTheme.projectCardFillAlphaFor(Brightness.dark), 0.65);
  });

  test('floating controls reuse project card colors and chat glow', () {
    final darkStyle = floatingControlVisualStyleFor(Brightness.dark);
    final darkBorder = ShellUiConfig.gridLineFor(Brightness.dark);
    final darkSkin = ChatSkin.dataForMode(ChatSkinMode.dark);
    final darkGlow = darkSkin.tokens.shellShadow(darkSkin.colors);

    expect(
      darkStyle.fillColor,
      ShellUiConfig.projectCardFillFor(Brightness.dark),
    );
    expect(darkStyle.outlineStyle.color, darkBorder.color);
    expect(darkStyle.outlineStyle.width, darkBorder.width);
    expect(darkStyle.iconColor, PagePalette.bodyFor(Brightness.dark));
    expect(darkStyle.glow.color, darkGlow.color);
    expect(darkStyle.glow.blurRadius, darkGlow.blurRadius);
    expect(darkStyle.glow.offset, darkGlow.offset);
  });

  test('chat launcher style matches the floating control styling', () {
    final visualStyle = floatingControlVisualStyleFor(Brightness.light);
    final launcherStyle = buildChatLauncherStyle(Brightness.light);

    expect(launcherStyle.backgroundColor, visualStyle.fillColor);
    expect(launcherStyle.foregroundColor, visualStyle.iconColor);
    expect(launcherStyle.hoverForegroundColor, visualStyle.iconColor);
    expect(launcherStyle.borderColor, visualStyle.outlineStyle.color);
    expect(launcherStyle.hoverBorderColor, visualStyle.outlineStyle.color);
    expect(launcherStyle.borderWidth, visualStyle.outlineStyle.width);
    expect(launcherStyle.boxShadow, hasLength(1));
    expect(launcherStyle.boxShadow.single.color, visualStyle.glow.color);
    expect(
      launcherStyle.boxShadow.single.blurRadius,
      visualStyle.glow.blurRadius,
    );
    expect(launcherStyle.boxShadow.single.offset, visualStyle.glow.offset);
  });

  test('dark chat accents use the send-button cyan', () {
    final colors = ChatSkin.dataForMode(ChatSkinMode.dark).colors;

    expect(colors.composerSendIcon, sendButtonCyan);
    expect(colors.composerCursor, sendButtonCyan);
    expect(colors.composerCornerAccent, sendButtonCyan);
    expect(colors.markupLink, sendButtonCyan);
    expect(colors.markupLinkDecoration, sendButtonCyan);
    expect(colors.bubbleCollapseButton, sendButtonCyan);
  });

  test('dark keyword cyan uses the send-button cyan', () {
    expect(
      KeywordSkin.textColorForToken(
        KeywordTextColorToken.cyan,
        Brightness.dark,
      ),
      sendButtonCyan,
    );
  });
}
