import 'package:flutter/material.dart';
import 'package:tw_primitives/markdown.dart';

import '../utils/math.dart';
import 'composer_layout.dart';
import 'skin.dart';

class ChatBubbleRules {
  const ChatBubbleRules._();

  static Color userFill(BuildContext context) =>
      ChatComposerLayout.fillColor(context);
  static Color botFill(BuildContext context) =>
    ChatSkin.dataOf(context).colors.botBubbleFill;
  static Color userBorder(BuildContext context) =>
      ChatComposerLayout.borderColor(context);
  static Color botBorder(BuildContext context) =>
    ChatSkin.dataOf(context).colors.botBubbleBorder;

  /// Target max bubble width across layouts.
  ///
  /// This keeps line lengths readable while preserving room for shell chrome
  /// and scrollbar affordances.
  static const maxWidthFactor = 0.78;

  /// Minimum width for user bubbles as a fraction of the available chat width.
  ///
  /// Ensures short messages still occupy a recognisable pill-shaped area
  /// without growing taller than necessary.
  static const minWidthFactor = 0.1667;

  /// Number of lines required before the collapse control appears.
  ///
  /// Four lines keeps shorter responses fully visible while still truncating
  /// anything meaningfully long.
  static const collapsibleLineThreshold = 4;

  /// Number of lines shown while a bubble is collapsed.
  ///
  /// Matches [collapsibleLineThreshold] so expanding is only offered when
  /// additional content is actually hidden.
  static const collapsedVisibleLines = 4;
  static Color collapseButtonColor(BuildContext context) =>
      ChatSkin.dataOf(context).colors.bubbleCollapseButton;
  static Color collapseButtonIconColor(BuildContext context) =>
      ChatSkin.dataOf(context).colors.bubbleCollapseButtonIcon;

  static TextStyle textStyle(BuildContext context, double textScale) {
    return buildMarkdownSurfaceStyle(
      MarkdownThemeConfig(
        isDark: ChatSkin.isDarkOf(context),
        textScale: textScale,
      ),
    ).bodyTextStyle;
  }

  static double horizontalTextInset(double textScale) {
    return _scaledInset(ChatSkin.tokens.bubbleTextInsetLeft, textScale);
  }

  static double verticalTextInset(double textScale) {
    return _scaledInset(
      ChatSkin.tokens.bubbleTextInsetTopBottom,
      textScale,
    );
  }

  static double _scaledInset(double base, double textScale) {
    return ChatMath.tapered(
      base,
      textScale,
      ChatSkin.textStyles.minTextScale,
      ChatSkin.textStyles.defaultMaxTextScale,
      ChatSkin.tokens.bubbleMinInsetScaleFactor,
    );
  }
}
