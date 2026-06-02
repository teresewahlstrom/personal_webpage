import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:tw_primitives/scrollbar.dart' as tw_scrollbar;

import '../config/config.dart';
import '../models/message.dart';
import 'message_bubble.dart';
import 'section_coordinator.dart';

class ChatMessageListArea extends StatefulWidget {
  const ChatMessageListArea({
    super.key,
    required this.messages,
    required this.availableWidth,
    required this.botBubbleWidth,
    required this.chatScroll,
    required this.chatFocusNode,
    required this.chatSelectionAreaKey,
    required this.messageBubbleKeys,
    required this.showChatScrollbarTrack,
    required this.isMessageTruncated,
    required this.onToggleTruncation,
    required this.onChatSelectionChanged,
    required this.selectionNotifierForMessage,
    required this.onCopySelectionRequested,
    required this.onRequestChatKeyboardTarget,
    required this.onChatPointerInteractionStart,
    required this.onChatPointerInteractionEnd,
    required this.scrollbarTopInset,
    required this.scrollbarBottomInset,
    required this.contentBottomInset,
  });

  final List<ChatMessage> messages;
  final double availableWidth;
  final double botBubbleWidth;
  final ScrollController chatScroll;
  final FocusNode chatFocusNode;
  final GlobalKey<tw_scrollbar.TwSelectableRegionState> chatSelectionAreaKey;
  final ChatMessageBubbleKeyMap messageBubbleKeys;
  final bool showChatScrollbarTrack;
  final bool Function(String messageId) isMessageTruncated;
  final ValueChanged<String> onToggleTruncation;
  final ValueChanged<SelectedContent?> onChatSelectionChanged;
  final tw_scrollbar.SelectionListenerNotifier Function(String messageId)
  selectionNotifierForMessage;
  final String Function() onCopySelectionRequested;
  final VoidCallback onRequestChatKeyboardTarget;
  final VoidCallback onChatPointerInteractionStart;
  final VoidCallback onChatPointerInteractionEnd;
  final double scrollbarTopInset;
  final double scrollbarBottomInset;
  final double contentBottomInset;

  @override
  State<ChatMessageListArea> createState() => _ChatMessageListAreaState();
}

class _ChatMessageListAreaState extends State<ChatMessageListArea> {
  @override
  Widget build(BuildContext context) {
    final tokens = ChatSkin.tokens;
    final EdgeInsets scrollbarInsets = EdgeInsets.only(
      top: widget.scrollbarTopInset,
      bottom: widget.scrollbarBottomInset,
    );
    final double reservedScrollbarSpan =
        tokens.scrollbarThickness + (tokens.scrollbarThumbCrossAxisMargin * 2);
    final double bubbleContentRightPadding =
        (tokens.bubbleViewportPadding.right - reservedScrollbarSpan)
            .clamp(0.0, double.infinity)
            .toDouble();

    return tw_scrollbar.TwSelectableScrollArea.scrollView(
      controller: widget.chatScroll,
      selectionKey: widget.chatSelectionAreaKey,
      interactionFocusNode: widget.chatFocusNode,
      onSelectionChanged: widget.onChatSelectionChanged,
      onPointerDown: () {
        widget.onChatPointerInteractionStart();
        widget.onRequestChatKeyboardTarget();
      },
      onPointerUp: widget.onChatPointerInteractionEnd,
      onPointerCancel: widget.onChatPointerInteractionEnd,
      actions: <Type, Action<Intent>>{
        CopySelectionTextIntent: CallbackAction<CopySelectionTextIntent>(
          onInvoke: (_) {
            final copyText = widget.onCopySelectionRequested();
            if (copyText.trim().isEmpty) {
              return null;
            }
            Clipboard.setData(ClipboardData(text: copyText));
            return null;
          },
        ),
      },
      magnifierConfiguration: TextMagnifierConfiguration.disabled,
      thumbColor: ChatScrollbar.thumbColor(context),
      thumbInactiveColor: ChatScrollbar.thumbInactiveColor(context),
      scrollbarTrackColor:
          widget.showChatScrollbarTrack ? ChatScrollbar.trackColor(context) : null,
      thickness: tokens.scrollbarThickness,
      minThumbLength: tokens.scrollbarMinThumbLength,
      crossAxisMargin: tokens.scrollbarThumbCrossAxisMargin,
      scrollbarColumnWidth: reservedScrollbarSpan,
      scrollbarInsets: scrollbarInsets,
      radius: tokens.scrollbarRadius,
      thumbVisibility: true,
      interactive: true,
      child: Padding(
        padding: tokens.bubbleViewportPadding.copyWith(
          top: 0,
          right: bubbleContentRightPadding,
          bottom: 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final entry in widget.messages.indexed)
              ChatMessageBubble(
                key: widget.messageBubbleKeys[entry.$2.id],
                availableWidth: widget.availableWidth,
                text: entry.$2.text,
                selectionListenerNotifier: widget.selectionNotifierForMessage(
                  entry.$2.id,
                ),
                isUserBubble: entry.$2.role == ChatRole.user,
                isTypingIndicator:
                    entry.$2.role == ChatRole.bot && entry.$2.isPending,
                isTruncated: widget.isMessageTruncated(entry.$2.id),
                isFirstMessage: entry.$1 == 0,
                isLastMessage: entry.$1 == widget.messages.length - 1,
                botBubbleWidth: widget.botBubbleWidth,
                onToggleTruncation: () =>
                    widget.onToggleTruncation(entry.$2.id),
              ),
            SizedBox(
              height: widget.contentBottomInset + tokens.chatListTrailingGap,
            ),
          ],
        ),
      ),
    );
  }
}
