import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../models/message.dart';
import '../config/config.dart';
import 'section_coordinator.dart';
import 'message_bubble.dart';

class ChatMessageListArea extends StatelessWidget {
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
  final Widget? jumpToLatestButton;
  final Widget Function({
    required double thickness,
    required double crossAxisInset,
  })
  buildScrollbarTrack;

  bool _isPrimaryActivationPointer(PointerDownEvent event) {
    final kind = event.kind;
    if (kind == PointerDeviceKind.touch ||
        kind == PointerDeviceKind.stylus ||
        kind == PointerDeviceKind.invertedStylus) {
      return true;
    }
    return event.buttons == kPrimaryButton;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ChatSkin.data.tokens;
    return Expanded(
      child: Focus(
        focusNode: chatFocusNode,
        canRequestFocus: true,
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            if (!_isPrimaryActivationPointer(event)) {
              return;
            }
            onChatPointerInteractionStart();
            onRequestChatKeyboardTarget();
          },
          onPointerUp: (_) => onChatPointerInteractionEnd(),
          onPointerCancel: (_) => onChatPointerInteractionEnd(),
          child: ScrollConfiguration(
            behavior: const ChatNoScrollbarBehavior(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (showChatScrollbarTrack)
                  buildScrollbarTrack(
                    thickness: tokens.scrollbarThickness,
                    crossAxisInset: 0,
                  ),
                ChatFadingScrollbar(
                  controller: chatScroll,
                  thickness: tokens.scrollbarThickness,
                  minThumbLength: tokens.scrollbarMinThumbLength,
                  crossAxisMargin: tokens.scrollbarThumbCrossAxisMargin,
                  mainAxisMargin: 0,
                  padding: EdgeInsets.only(top: tokens.chatListTopShadowHeight),
                  radius: tokens.scrollbarRadius,
                  thumbVisibility: true,
                  interactive: true,
                  trackVisibility: false,
                  child: Actions(
                    actions: <Type, Action<Intent>>{
                      CopySelectionTextIntent:
                          CallbackAction<CopySelectionTextIntent>(
                            onInvoke: (_) {
                              final copyText = onCopySelectionRequested();
                              if (copyText.trim().isEmpty) {
                                return null;
                              }
                              Clipboard.setData(ClipboardData(text: copyText));
                              return null;
                            },
                          ),
                    },
                    child: SelectionArea(
                      key: chatSelectionAreaKey,
                      onSelectionChanged: onChatSelectionChanged,
                      child: SingleChildScrollView(
                        controller: chatScroll,
                        physics: const ClampingScrollPhysics(),
                        child: Padding(
                          padding: tokens.bubbleViewportPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final entry in messages.indexed)
                                ChatMessageBubble(
                                  key: messageBubbleKeys[entry.$2.id],
                                  availableWidth: availableWidth,
                                  text: entry.$2.text,
                                  selectionListenerNotifier:
                                      selectionNotifierForMessage(entry.$2.id),
                                  isUser: entry.$2.role == ChatRole.user,
                                  isTypingIndicator:
                                      entry.$2.role == ChatRole.bot &&
                                      entry.$2.isPending,
                                  isTruncated: isMessageTruncated(entry.$2.id),
                                  isFirstMessage: entry.$1 == 0,
                                  isLastMessage:
                                      entry.$1 == messages.length - 1,
                                  onToggleTruncation: () =>
                                      onToggleTruncation(entry.$2.id),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (jumpToLatestButton != null)
                  Positioned(
                    right: tokens.jumpToLatestButtonRightInset,
                    bottom: tokens.jumpToLatestButtonBottomInset,
                    child: jumpToLatestButton!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
