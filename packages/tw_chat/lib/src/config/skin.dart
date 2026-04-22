import 'skin_dark.dart' as dark;
import 'skin_light.dart' as light;
import 'skin_shared.dart';
import 'package:flutter/material.dart';
export 'skin_shared.dart'
    show ChatSkinColors, ChatSkinData, ChatSkinTextStyles, ChatSkinTokens;

enum ChatSkinMode { light, dark }

class ChatSkin {
  ChatSkin._();

  static const ChatSkinTokens tokens = ChatSkinTokens();
  static const ChatSkinTextStyles textStyles = ChatSkinTextStyles();

  static ChatSkinData dataForMode(ChatSkinMode mode) {
    return mode == ChatSkinMode.dark ? dark.chatDarkSkin : light.chatLightSkin;
  }

  static ChatSkinData dataForBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark.chatDarkSkin : light.chatLightSkin;
  }

  static ChatSkinMode modeForBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? ChatSkinMode.dark : ChatSkinMode.light;
  }

  static ChatSkinMode modeOf(BuildContext context) {
    final ChatSkinMode? scoped = ChatSkinScope.maybeModeOf(context);
    if (scoped != null) {
      return scoped;
    }
    return modeForBrightness(Theme.of(context).brightness);
  }

  static ChatSkinData dataOf(BuildContext context) {
    return dataForMode(modeOf(context));
  }

  static bool isDarkOf(BuildContext context) {
    return modeOf(context) == ChatSkinMode.dark;
  }
}

class ChatSkinScope extends InheritedWidget {
  const ChatSkinScope({
    super.key,
    required this.mode,
    required super.child,
  });

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
