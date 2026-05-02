import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/config/app_color_theme.dart';
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
