import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:tw_primitives/scrollbar.dart' show TwScrollArea;

import '../models/message.dart';
import '../config/config.dart';
import '../logic/web_secondary_click_selection_guard.dart';
import 'section_coordinator.dart';
import 'message_bubble.dart';

class ChatMessageListArea extends StatefulWidget {
  const ChatMessageListArea({
    super.key,
    required this.messages,
    required this.availableWidth,
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
    this.shouldPreserveSelectionOnSecondaryClick,
    required this.scrollbarTopInset,
    required this.scrollbarBottomInset,
    required this.contentBottomInset,
    required this.jumpToLatestButton,
    required this.buildScrollbarTrack,
  });

  final List<ChatMessage> messages;
  final double availableWidth;
  final ScrollController chatScroll;
  final FocusNode chatFocusNode;
  final GlobalKey<SelectionAreaState> chatSelectionAreaKey;
  final ChatMessageBubbleKeyMap messageBubbleKeys;
  final bool showChatScrollbarTrack;
  final bool Function(String messageId) isMessageTruncated;
  final ValueChanged<String> onToggleTruncation;
  final ValueChanged<SelectedContent?> onChatSelectionChanged;
  final SelectionListenerNotifier Function(String messageId)
  selectionNotifierForMessage;
  final String Function() onCopySelectionRequested;
  final VoidCallback onRequestChatKeyboardTarget;
  final VoidCallback onChatPointerInteractionStart;
  final VoidCallback onChatPointerInteractionEnd;
  final bool Function()? shouldPreserveSelectionOnSecondaryClick;
  final double scrollbarTopInset;
  final double scrollbarBottomInset;
  final double contentBottomInset;
  final Widget? jumpToLatestButton;
  final Widget Function({
    required double thickness,
    required double crossAxisInset,
    required double topInset,
    required double bottomInset,
  })
  buildScrollbarTrack;

  @override
  State<ChatMessageListArea> createState() => _ChatMessageListAreaState();
}

class _ChatMessageListAreaState extends State<ChatMessageListArea> {
  late final ChatWebSecondaryClickSelectionGuard
  _secondaryClickSelectionGuard;

  @override
  void initState() {
    super.initState();
    _secondaryClickSelectionGuard = ChatWebSecondaryClickSelectionGuard(
      shouldGuard: () =>
          widget.shouldPreserveSelectionOnSecondaryClick?.call() ?? false,
      boundsResolver: _resolveGlobalBounds,
    )..attach();
  }

  @override
  void dispose() {
    _secondaryClickSelectionGuard.detach();
    super.dispose();
  }

  Rect? _resolveGlobalBounds() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }
    final topLeft = renderObject.localToGlobal(Offset.zero);
    return topLeft & renderObject.size;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ChatSkin.tokens;
    return Focus(
      focusNode: widget.chatFocusNode,
      canRequestFocus: true,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          widget.onChatPointerInteractionStart();
          widget.onRequestChatKeyboardTarget();
        },
        onPointerUp: (_) => widget.onChatPointerInteractionEnd(),
        onPointerCancel: (_) => widget.onChatPointerInteractionEnd(),
        child: TwScrollArea.scrollView(
          controller: widget.chatScroll,
          thumbColor: ChatScrollbar.thumbColor(context),
          thumbInactiveColor: ChatScrollbar.thumbInactiveColor(context),
          trackColor: ChatScrollbar.trackColor(context),
          thickness: tokens.scrollbarThickness,
          minThumbLength: tokens.scrollbarMinThumbLength,
          crossAxisMargin: tokens.scrollbarThumbCrossAxisMargin,
          mainAxisMargin: 0,
          padding: EdgeInsets.only(
            top: widget.scrollbarTopInset,
            bottom: widget.scrollbarBottomInset,
          ),
          radius: tokens.scrollbarRadius,
          thumbVisibility: true,
          interactive: true,
          trackVisibility: false,
          track: widget.showChatScrollbarTrack
              ? widget.buildScrollbarTrack(
                  thickness: tokens.scrollbarThickness,
                  crossAxisInset: tokens.scrollbarThumbCrossAxisMargin,
                  topInset: widget.scrollbarTopInset,
                  bottomInset: widget.scrollbarBottomInset,
                )
              : null,
          overlayChildren: [
            if (widget.jumpToLatestButton != null)
              Positioned(
                right: tokens.jumpToLatestButtonRightInset,
                bottom: tokens.jumpToLatestButtonBottomInset,
                child: widget.jumpToLatestButton!,
              ),
          ],
          child: Actions(
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
            child: SelectionArea(
              key: widget.chatSelectionAreaKey,
              onSelectionChanged: widget.onChatSelectionChanged,
              magnifierConfiguration: TextMagnifierConfiguration.disabled,
              child: Padding(
                padding: tokens.bubbleViewportPadding.copyWith(top: 0, bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final entry in widget.messages.indexed)
                      ChatMessageBubble(
                        key: widget.messageBubbleKeys[entry.$2.id],
                        availableWidth: widget.availableWidth,
                        text: entry.$2.text,
                        selectionListenerNotifier:
                            widget.selectionNotifierForMessage(entry.$2.id),
                        isUserBubble: entry.$2.role == ChatRole.user,
                        isTypingIndicator:
                            entry.$2.role == ChatRole.bot && entry.$2.isPending,
                        isTruncated: widget.isMessageTruncated(entry.$2.id),
                        isFirstMessage: entry.$1 == 0,
                        isLastMessage: entry.$1 == widget.messages.length - 1,
                        onToggleTruncation: () =>
                            widget.onToggleTruncation(entry.$2.id),
                      ),
                    SizedBox(
                      height:
                          widget.contentBottomInset +
                          tokens.chatListTrailingGap,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
