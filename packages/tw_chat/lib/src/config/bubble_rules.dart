import 'package:flutter/material.dart';

import '../utils/math.dart';
import 'skin.dart';

class ChatBubbleRules {
  const ChatBubbleRules._();

  static Color get userFill => ChatSkin.data.colors.userBubbleFill;
  static Color get botFill => ChatSkin.data.colors.botBubbleFill;
  static Color get userBorder => ChatSkin.data.colors.userBubbleBorder;
  static Color get botBorder => ChatSkin.data.colors.botBubbleBorder;

  /// Target max bubble width across layouts.
  ///
  /// This keeps line lengths readable while preserving room for shell chrome
  /// and scrollbar affordances.
  static const maxWidthFactor = 0.78;

  /// Number of lines required before the collapse control appears.
  ///
  /// Seven lines is a compromise: long enough to preserve context while
  /// avoiding very tall messages dominating the viewport.
  static const collapsibleLineThreshold = 7;

  /// Number of lines shown while a bubble is collapsed.
  ///
  /// Matches [collapsibleLineThreshold] so expanding is only offered when
  /// additional content is actually hidden.
  static const collapsedVisibleLines = 7;
  static Color get collapseButtonColor =>
      ChatSkin.data.colors.bubbleCollapseButton;
  static Color get collapseButtonIconColor =>
      ChatSkin.data.colors.bubbleCollapseButtonIcon;

  static TextStyle textStyle(double textScale) {
    final skin = ChatSkin.data;
    return skin.textStyles.bubbleTextStyle(textScale, skin.colors);
  }

  static double horizontalTextInset(double textScale) {
    return _scaledInset(ChatSkin.data.tokens.bubbleTextInsetLeft, textScale);
  }

  static double verticalTextInset(double textScale) {
    return _scaledInset(
      ChatSkin.data.tokens.bubbleTextInsetTopBottom,
      textScale,
    );
  }

  static double _scaledInset(double base, double textScale) {
    final skin = ChatSkin.data;
    return ChatMath.tapered(
      base,
      textScale,
      skin.textStyles.minTextScale,
      skin.textStyles.defaultMaxTextScale,
      skin.tokens.bubbleMinInsetScaleFactor,
    );
  }
}
