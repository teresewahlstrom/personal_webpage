import 'package:flutter/material.dart';

import 'composer_layout.dart';
import 'skin.dart';

export 'package:tw_flutter_skin/tw_flutter_skin.dart'
    show FadingScrollbar, NoScrollbarBehavior;

/// Chat-specific scrollbar colours and track-building helpers.
///
/// The generic scrollbar widgets ([FadingScrollbar], [NoScrollbarBehavior])
/// live in `tw_flutter_skin` and are re-exported from this file for
/// convenience.
class ChatScrollbar {
  const ChatScrollbar._();

  static const visibilityOverflowThreshold = 0.5;

  static Color thumbColor(BuildContext context) => ChatComposerLayout.borderColor(context);

  static Color inactiveThumbColor(BuildContext context) => ChatComposerLayout.fillColor(context);

  static Color trackColor(BuildContext context) => ChatSkin.dataOf(context).colors.scrollbarTrack;

  static const inputTrackBorder = Border();

  static Widget buildTrack({
    required BuildContext context,
    required double thickness,
    required double crossAxisInset,
    double topInset = 0,
    double bottomInset = 0,
  }) {
    final tokens = ChatSkin.tokens;
    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.only(
          top: topInset,
          bottom: bottomInset,
          right: crossAxisInset + tokens.scrollbarTrackLeftShift,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: thickness,
            decoration: BoxDecoration(
              color: trackColor(context),
              borderRadius: tokens.scrollbarTrackRadius,
              border: inputTrackBorder,
            ),
          ),
        ),
      ),
    );
  }
}
