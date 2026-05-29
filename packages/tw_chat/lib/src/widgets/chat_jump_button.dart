import 'package:flutter/material.dart';

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
    final TextStyle buttonTextStyle = ChatBubbleRules.textStyle(
      context,
      textScale,
    ).copyWith(color: colors.bubbleText, fontWeight: FontWeight.w700);
    final BorderSide buttonBorder = BorderSide(
      color: ChatComposerLayout.borderColor(context),
      width: 1.0,
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
      child: Tooltip(
        message: showNewMessage ? 'Jump to latest message' : 'Jump to bottom',
        child: showNewMessage
            ? FilledButton.icon(
                onPressed: () {
                  Tooltip.dismissAllToolTips();
                  onJumpToLatest();
                },
                icon: arrowIcon,
                label: const Text('new message'),
                style: FilledButton.styleFrom(
                  backgroundColor: ChatComposerLayout.fillColor(context),
                  foregroundColor: colors.bubbleText,
                  shape: const StadiumBorder(),
                  side: buttonBorder,
                  elevation: tokens.jumpToLatestButtonElevation,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size(0, buttonSize),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: buttonTextStyle,
                ),
              )
            : SizedBox.square(
                dimension: buttonSize,
                child: FilledButton(
                  onPressed: () {
                    Tooltip.dismissAllToolTips();
                    onJumpToBottom();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: ChatComposerLayout.fillColor(context),
                    foregroundColor: colors.bubbleText,
                    shape: const CircleBorder(),
                    side: buttonBorder,
                    elevation: tokens.jumpToLatestButtonElevation,
                    padding: tokens.jumpToLatestButtonPadding,
                    minimumSize: Size.zero,
                    maximumSize: Size.square(buttonSize),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: buttonTextStyle,
                  ),
                  child: arrowIcon,
                ),
              ),
      ),
    );
  }
}
