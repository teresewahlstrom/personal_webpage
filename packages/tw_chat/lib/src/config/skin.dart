import 'skin_shared.dart';
import 'package:flutter/material.dart';
import 'package:tw_primitives/theme.dart';
export 'skin_shared.dart'
    show ChatSkinColors, ChatSkinData, ChatSkinTextStyles, ChatSkinTokens;

enum ChatSkinMode { light, dark }

class ChatSkin {
  ChatSkin._();

  static const ChatSkinTokens tokens = ChatSkinTokens();
  static const ChatSkinTextStyles textStyles = ChatSkinTextStyles();

  static ChatSkinData dataForMode(ChatSkinMode mode) {
    final tw = mode == ChatSkinMode.dark
        ? TwColors.forTheme('dark')
        : TwColors.forTheme('light');
    return ChatSkinData(colors: _fromTw(tw));
  }

  static ChatSkinData dataForBrightness(Brightness brightness) {
    final tw = brightness == Brightness.dark
        ? TwColors.forBrightness(Brightness.dark)
        : TwColors.forBrightness(Brightness.light);
    return ChatSkinData(colors: _fromTw(tw));
  }

  static ChatSkinMode modeForBrightness(Brightness brightness) {
    return brightness == Brightness.dark
        ? ChatSkinMode.dark
        : ChatSkinMode.light;
  }

  static ChatSkinMode modeOf(BuildContext context) {
    final ChatSkinMode? scoped = ChatSkinScope.maybeModeOf(context);
    if (scoped != null) {
      return scoped;
    }
    return modeForBrightness(
      context.twIsDark ? Brightness.dark : Brightness.light,
    );
  }

  static ChatSkinData dataOf(BuildContext context) {
    return dataForMode(modeOf(context));
  }

  static bool isDarkOf(BuildContext context) {
    return modeOf(context) == ChatSkinMode.dark;
  }
}

ChatSkinColors _fromTw(TwColors tw) {
  return ChatSkinColors(
    transparent: tw.transparent,
    bubbleText: tw.bubbleText,
    shellBackground: tw.shellBackground,
    shellOuterShadow: tw.shellOuterShadow,
    shellOuterBorder: tw.shellOuterBorder,
    shellDivider: tw.shellDivider,
    botBubbleFill: tw.botBubbleFill,
    botBubbleBorder: tw.botBubbleBorder,
    bubbleShadow: tw.bubbleShadow,
    bubbleCollapseButton: tw.bubbleCollapseButton,
    bubbleCollapseButtonIcon: tw.bubbleCollapseButtonIcon,
    composerFill: tw.composerFill,
    composerBorder: tw.composerBorder,
    composerCursor: tw.composerCursor,
    composerCornerAccent: tw.composerCornerAccent,
    composerSendIcon: tw.composerSendIcon,
    textFieldSelection: tw.textFieldSelection,
    textFieldCaret: tw.textFieldCaret,
    toolbarColor: tw.toolbarColor,
    bubbleFadeMaskOpaque: tw.bubbleFadeMaskOpaque,
    bubbleFadeMaskSoft: tw.bubbleFadeMaskSoft,
    markupLink: tw.markupLink,
    scrollbarThumb: tw.scrollbarThumb,
    scrollbarThumbInactive: tw.scrollbarThumbInactive,
    scrollbarTrack: tw.scrollbarTrack,
  );
}

class ChatSkinScope extends InheritedWidget {
  const ChatSkinScope({super.key, required this.mode, required super.child});

  final ChatSkinMode mode;

  static ChatSkinMode? maybeModeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ChatSkinScope>();
    return scope?.mode;
  }

  @override
  bool updateShouldNotify(covariant ChatSkinScope oldWidget) {
    return mode != oldWidget.mode;
  }
}
