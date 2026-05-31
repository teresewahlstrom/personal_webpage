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
    TwTextStyles.of(context).buttonLabelFrom(
      ChatBubbleRules.textStyle(
        context,
        textScale,
      ),
      color: colors.bubbleText,
    );
    final Icon arrowIcon = Icon(
      Icons.south_rounded,
      size: buttonSize * tokens.jumpToLatestButtonIconRatio,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: showNewMessage ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: showNewMessage
            ? BorderRadius.circular(buttonSize / 2)
            : null,
        boxShadow: [tokens.jumpToLatestButtonShadow(colors)],
      ),
      child: showNewMessage
          ? TwLinkPill(
              label: 'new message',
              leading: arrowIcon,
              onTap: () {
                Tooltip.dismissAllToolTips();
                onJumpToLatest();
              },
              tooltip: 'Jump to latest message',
              semanticsLabel: 'Jump to latest message',
            )
          : SizedBox.square(
              dimension: buttonSize,
                child: TwLinkPill(
                  label: '',
                  leading: arrowIcon,
                  onTap: () {
                    Tooltip.dismissAllToolTips();
                    onJumpToBottom();
                  },
                  tooltip: 'Jump to bottom',
                  semanticsLabel: 'Jump to bottom',
                ),
            ),
    );
  }
}
