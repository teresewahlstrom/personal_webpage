import 'skin_dark.dart' as dark;
import 'skin_light.dart' as light;
import 'skin_shared.dart';
export 'skin_shared.dart'
    show ChatSkinColors, ChatSkinData, ChatSkinTextStyles, ChatSkinTokens;

enum ChatSkinMode { light, dark }

class ChatSkin {
  ChatSkin._();

  static ChatSkinMode _mode = ChatSkinMode.light;

  static ChatSkinMode get mode => _mode;
  static bool get isDark => _mode == ChatSkinMode.dark;

  static ChatSkinData get data =>
      isDark ? dark.chatDarkSkin : light.chatLightSkin;

  static void setMode(ChatSkinMode mode) {
    _mode = mode;
  }
}
