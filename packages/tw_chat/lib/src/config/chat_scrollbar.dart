import 'package:flutter/material.dart';
import 'package:tw_primitives/scrollbar.dart';

import 'skin.dart';

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
}
