import 'package:flutter/material.dart';
import 'package:tw_primitives/theme.dart';

import '../config/config.dart';

class ChatJumpButton extends StatelessWidget {
  const ChatJumpButton({
    super.key,
    required this.showNewMessage,
    required this.onJumpToLatest,
    required this.onJumpToBottom,
  });

  final bool showNewMessage;
  final VoidCallback onJumpToLatest;
  final VoidCallback onJumpToBottom;

  @override
  Widget build(BuildContext context) {
    final skin = ChatSkin.dataOf(context);
    final colors = skin.colors;
    final tokens = skin.tokens;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final double buttonSize = tokens.jumpToLatestButtonFixedSize;
    final TextStyle bubbleTextStyle = ChatBubbleRules.textStyle(
      context,
      textScale,
    );
    final TextStyle newMessageTextStyle = TwTextStyles.of(
      context,
    ).adaptBase(bubbleTextStyle, color: colors.bubbleText);
    final TwLinkPillStyle newMessagePillStyle =
        computeDefaultTwLinkPillStyle(
          brightness: ChatSkin.isDarkOf(context)
              ? Brightness.dark
              : Brightness.light,
          textScale: textScale,
        ).copyWith(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          textStyle: newMessageTextStyle,
        );
    final Icon arrowIcon = Icon(
      Icons.south_rounded,
      size: buttonSize * tokens.jumpToLatestButtonIconRatio,
    );

    if (showNewMessage) {
      return TwLinkPill(
        label: 'new message',
        leading: arrowIcon,
        style: newMessagePillStyle,
        onTap: () {
          Tooltip.dismissAllToolTips();
          onJumpToLatest();
        },
      );
    }

    return SizedBox.square(
      dimension: buttonSize,
      child: TwLinkPill(
        label: '',
        leading: arrowIcon,
        onTap: () {
          Tooltip.dismissAllToolTips();
          onJumpToBottom();
        },
      ),
    );
  }
}
