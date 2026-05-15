import 'package:flutter/material.dart';
import 'package:tw_primitives/chat_api.dart';

import 'skin.dart';

export 'package:tw_primitives/chat_api.dart'
    show TwNoScrollbarBehavior, TwScrollbar, TwScrollbarTrack;

class ChatScrollbar {
  const ChatScrollbar._();

  static const visibilityOverflowThreshold =
      TwScrollbarDefaults.visibilityOverflowThreshold;
  static Color thumbColor(BuildContext context) =>
      ChatSkin.dataOf(context).colors.scrollbarThumb;
  static Color thumbInactiveColor(BuildContext context) =>
      ChatSkin.dataOf(context).colors.scrollbarThumbInactive;
  static Color trackColor(BuildContext context) =>
      ChatSkin.dataOf(context).colors.scrollbarTrack;
  static const inputTrackBorder = TwScrollbarDefaults.trackBorder;
  static const thumbFadeDuration = TwScrollbarDefaults.thumbFadeDuration;
  static const thumbFadeOutDelay = TwScrollbarDefaults.thumbFadeOutDelay;

  static Widget buildTrack({
    required BuildContext context,
    required double thickness,
    required double crossAxisInset,
    double topInset = 0,
    double bottomInset = 0,
  }) {
    final tokens = ChatSkin.tokens;
    return TwScrollbarTrack(
      color: trackColor(context),
      thickness: thickness,
      crossAxisInset: crossAxisInset,
      topInset: topInset,
      bottomInset: bottomInset,
      rightShift: tokens.scrollbarTrackLeftShift,
      borderRadius: tokens.scrollbarTrackRadius,
      border: inputTrackBorder,
    );
  }
}
