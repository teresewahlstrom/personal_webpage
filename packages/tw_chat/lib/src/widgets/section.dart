import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/config.dart';
import '../logic/keyboard_event_router.dart';
import '../logic/web_copy_interceptor.dart';
import '../models/message.dart';
import 'section_coordinator.dart';
import 'composer_row.dart';
import 'message_list_area.dart';

class ChatSection extends StatefulWidget {
  const ChatSection({
    super.key,
    required this.messages,
    required this.onSend,
    required this.onStop,
    required this.isChatKeyboardScrollTarget,
    required this.onSetChatKeyboardScrollTarget,
    required this.isVisible,
  });
  final List<ChatMessage> messages;
  final void Function(String text) onSend;
  final VoidCallback onStop;
  final ValueListenable<bool> isChatKeyboardScrollTarget;
  final VoidCallback onSetChatKeyboardScrollTarget;
  final bool isVisible;

  @override
  State<ChatSection> createState() => _ChatSectionState();
}

class _ChatSectionState extends State<ChatSection> {
  late final SectionCoordinator _coordinator;
  late final ChatWebCopyInterceptor _webCopyInterceptor;

  bool _prefersReducedMotion() {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery != null) {
      return mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;
    }
    return WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
  }

  @override
  void initState() {
    super.initState();
    _coordinator = SectionCoordinator(
      isMounted: () => mounted,
      onSetChatKeyboardScrollTarget: widget.onSetChatKeyboardScrollTarget,
    );
    _coordinator.initialize(messages: widget.messages);
    _webCopyInterceptor = ChatWebCopyInterceptor(
      () => _coordinator.resolveSelectionCopyText(widget.messages),
    )..attach();
    HardwareKeyboard.instance.addHandler(_handleChatKeyEvent);
  }

  bool _handleChatKeyEvent(KeyEvent event) {
    final command = ChatKeyboardEventRouter.resolve(
      event: event,
      chatHasClients: _coordinator.chatScroll.hasClients,
      isVisible: widget.isVisible,
      isChatKeyboardScrollTarget: widget.isChatKeyboardScrollTarget.value,
      inputHasPrimaryFocus: _coordinator.inputFocusNode.hasPrimaryFocus,
      isChatSelectionActive: _coordinator.isChatSelectionActive,
    );
    if (command == null) {
      return false;
    }

    if (command is RedirectCharacterToInputCommand) {
      if (!command.transferFocusOnly) {
        _coordinator.insertCharacterIntoInput(command.character);
      }
      _coordinator.transferFocusToInput();
      return true;
    }

    return _coordinator.animateChatScrollBy(
      (command as ScrollChatByCommand).delta,
      animate: !_prefersReducedMotion(),
    );
  }

  void _submitMessage() {
    _coordinator.submitMessage(onSend: widget.onSend);
  }

  void _stopPendingReply() {
    _coordinator.stopPendingReply(onStop: widget.onStop);
  }

  @override
  void didUpdateWidget(covariant ChatSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onSetChatKeyboardScrollTarget !=
        widget.onSetChatKeyboardScrollTarget) {
      _coordinator.updateCallbacks(
        onSetChatKeyboardScrollTarget: widget.onSetChatKeyboardScrollTarget,
      );
    }

    _coordinator.handleWidgetUpdate(
      messages: widget.messages,
      becameVisible: !oldWidget.isVisible && widget.isVisible,
      isVisible: widget.isVisible,
    );
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleChatKeyEvent);
    _webCopyInterceptor.detach();
    _coordinator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final skin = ChatSkin.data;
        final colors = skin.colors;
        final tokens = skin.tokens;
        final textStyles = skin.textStyles;
        final textScale = MediaQuery.textScalerOf(context).scale(1.0);
        final composerMetrics = ChatComposerLayout.resolveMetrics(
          panelHeight: constraints.maxHeight,
          textScale: textScale,
        );

        return Column(
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _coordinator.chatViewListenable,
              builder: (_, _, _) {
                final jumpToLatestLabel = _coordinator.newMessageCount == 1
                    ? 'New message'
                    : '${_coordinator.newMessageCount} new messages';

                return ChatMessageListArea(
                  messages: widget.messages,
                  availableWidth: constraints.maxWidth,
                  chatScroll: _coordinator.chatScroll,
                  chatFocusNode: _coordinator.chatFocusNode,
                  chatSelectionAreaKey: _coordinator.chatSelectionAreaKey,
                  messageBubbleKeys: _coordinator.messageBubbleKeys,
                  showChatScrollbarTrack: _coordinator.showChatScrollbarTrack,
                  isMessageTruncated: _coordinator.isMessageTruncated,
                  onToggleTruncation: _coordinator.toggleMessageTruncation,
                  onChatSelectionChanged:
                      _coordinator.handleChatSelectionChanged,
                  selectionNotifierForMessage:
                      _coordinator.selectionNotifierForMessage,
                  onCopySelectionRequested: () =>
                      _coordinator.resolveSelectionCopyText(widget.messages),
                  onRequestChatKeyboardTarget:
                      widget.onSetChatKeyboardScrollTarget,
                  onChatPointerInteractionStart:
                      _coordinator.handleChatPointerInteractionStart,
                  onChatPointerInteractionEnd:
                      _coordinator.handleChatPointerInteractionEnd,
                  jumpToLatestButton: _coordinator.newMessageCount == 0
                      ? null
                      : FilledButton.icon(
                          onPressed: _coordinator.jumpToLatest,
                          icon: Icon(
                            Icons.south_rounded,
                            size: tokens.jumpToLatestButtonIconSize,
                          ),
                          label: Text(jumpToLatestLabel),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.composerFill,
                            foregroundColor: ChatComposerLayout.sendIconColor,
                            side: BorderSide(
                              color: ChatComposerLayout.sendIconColor,
                            ),
                            elevation: tokens.jumpToLatestButtonElevation,
                            padding: tokens.jumpToLatestButtonPadding,
                            textStyle: textStyles
                                .composerHintStyle(textScale, colors)
                                .copyWith(
                                  color: ChatComposerLayout.sendIconColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                  buildScrollbarTrack: ChatScrollbar.buildTrack,
                );
              },
            ),
            SizedBox(height: tokens.composerGap),
            ValueListenableBuilder<int>(
              valueListenable: _coordinator.composerViewListenable,
              builder: (_, _, _) => ChatComposerRow(
                controller: _coordinator.controller,
                inputFocusNode: _coordinator.inputFocusNode,
                inputScroll: _coordinator.inputScroll,
                showInputScrollbarTrack: _coordinator.showInputScrollbarTrack,
                minInputHeight: composerMetrics.minInputHeight,
                maxInputHeight: composerMetrics.maxInputHeight,
                sendButtonMinWidth: composerMetrics.sendButtonMinWidth,
                isAwaitingResponse: widget.messages.any(
                  (message) => message.isPending,
                ),
                onSubmit: _submitMessage,
                onStop: _stopPendingReply,
              ),
            ),
          ],
        );
      },
    );
  }
}
