import 'package:flutter/material.dart';

import '../utils/math.dart';
import 'skin.dart';

class ChatBubbleRules {
  const ChatBubbleRules._();

  static const userFill = ChatColors.userBubbleFill;
  static const botFill = ChatColors.botBubbleFill;
  static const userBorder = ChatColors.userBubbleBorder;
  static const botBorder = ChatColors.botBubbleBorder;

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
  static const collapseButtonColor = ChatColors.bubbleCollapseButton;
  static const collapseButtonIconColor = ChatColors.bubbleCollapseButtonIcon;

  static TextStyle textStyle(double textScale) {
    return ChatTextStyles.bubbleTextStyle(textScale);
  }

  static double horizontalTextInset(double textScale) {
    return _scaledInset(ChatTokens.bubbleTextInsetLeft, textScale);
  }

  static double verticalTextInset(double textScale) {
    return _scaledInset(ChatTokens.bubbleTextInsetTopBottom, textScale);
  }

  static double _scaledInset(double base, double textScale) {
    return ChatMath.tapered(
      base,
      textScale,
      ChatTextStyles.minTextScale,
      ChatTextStyles.defaultMaxTextScale,
      ChatTokens.bubbleMinInsetScaleFactor,
    );
  }
}
