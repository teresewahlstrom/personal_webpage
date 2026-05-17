import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/config.dart';
import '../logic/keyboard_event_router.dart';
import '../logic/web_copy_interceptor.dart';
import '../models/message.dart';
import 'section_coordinator.dart';
import 'chat_jump_button.dart';
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
  double _composerMeasuredHeight = 0.0;

  void _handleComposerHeightChanged(double height) {
    if ((_composerMeasuredHeight - height).abs() <= 0.5) {
      return;
    }
    setState(() {
      _composerMeasuredHeight = height;
    });
  }

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
        final skin = ChatSkin.dataOf(context);
        final colors = skin.colors;
        final tokens = skin.tokens;
        final textScale = MediaQuery.textScalerOf(context).scale(1.0);
        final composerMetrics = ChatComposerLayout.resolveMetrics(
          context: context,
          panelHeight: constraints.maxHeight,
          textScale: textScale,
        );
        final composerHeight =
            (_composerMeasuredHeight > 0
                    ? _composerMeasuredHeight
                    : composerMetrics.minInputHeight)
                .clamp(
                  composerMetrics.minInputHeight,
                  composerMetrics.maxInputHeight,
                );
        final chatScrollbarTopInset = tokens.chatListTopShadowHeight;
        final chatContentBottomInset =
            tokens.shellContentPadding.bottom +
            composerHeight +
            tokens.composerGap +
            tokens.composerRowTopSpacing;
        final chatScrollbarBottomInset = tokens.shellBottomShadowHeight(
          composerHeight,
        );

        return Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  left: tokens.shellContentPadding.left,
                  right: tokens.shellContentPadding.right,
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: _coordinator.chatViewListenable,
                  builder: (_, _, _) {
                    return ChatMessageListArea(
                      messages: widget.messages,
                      availableWidth:
                          constraints.maxWidth -
                          tokens.shellContentPadding.left -
                          tokens.shellContentPadding.right -
                          tokens.bubbleViewportPadding.left -
                          tokens.bubbleViewportPadding.right,
                      chatScroll: _coordinator.chatScroll,
                      chatFocusNode: _coordinator.chatFocusNode,
                      chatSelectionAreaKey: _coordinator.chatSelectionAreaKey,
                      messageBubbleKeys: _coordinator.messageBubbleKeys,
                      showChatScrollbarTrack:
                          _coordinator.showChatScrollbarTrack,
                      isMessageTruncated: _coordinator.isMessageTruncated,
                      onToggleTruncation: _coordinator.toggleMessageTruncation,
                      onChatSelectionChanged:
                          _coordinator.handleChatSelectionChanged,
                      selectionNotifierForMessage:
                          _coordinator.selectionNotifierForMessage,
                      onCopySelectionRequested: () => _coordinator
                          .resolveSelectionCopyText(widget.messages),
                      onRequestChatKeyboardTarget:
                          widget.onSetChatKeyboardScrollTarget,
                      onChatPointerInteractionStart:
                          _coordinator.handleChatPointerInteractionStart,
                      onChatPointerInteractionEnd:
                          _coordinator.handleChatPointerInteractionEnd,
                      scrollbarTopInset: chatScrollbarTopInset,
                      scrollbarBottomInset: chatScrollbarBottomInset,
                      contentBottomInset: chatContentBottomInset,
                      jumpToLatestButton: null,
                      buildScrollbarTrack:
                          ({
                            required double thickness,
                            required double crossAxisInset,
                            required double topInset,
                            required double bottomInset,
                          }) => ChatScrollbar.buildTrack(
                            context: context,
                            thickness: thickness,
                            crossAxisInset: crossAxisInset,
                            topInset: topInset,
                            bottomInset: bottomInset,
                          ),
                    );
                  },
                ),
              ),
            ),
            // Absorb any pointer event that lands in the composer zone but
            // misses the Composer's exact Positioned bounds (e.g. the extended
            // touch-target of the caret handle sitting just above the text
            // field's top edge).  The Composer is the *last* Stack child so it
            // is always hit-tested first and wins for precise hits.  This
            // shield is the fallback: it ensures ChatMessageListArea's
            // SelectionArea never participates in gesture-arena resolution for
            // any pointer originating within the composer zone.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: chatScrollbarBottomInset,
              child: AbsorbPointer(child: const SizedBox.expand()),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom:
                  tokens.shellContentPadding.bottom +
                  composerHeight +
                  tokens.composerGap +
                  tokens.composerRowTopSpacing +
                  tokens.jumpToLatestButtonBottomInset,
              child: Center(
                child: ValueListenableBuilder<int>(
                  valueListenable: _coordinator.chatViewListenable,
                  builder: (_, _, _) {
                    final bool showJumpButton =
                        !_coordinator.isNearChatBottom;
                    if (!showJumpButton) {
                      return const SizedBox.shrink();
                    }
                    return ChatJumpButton(
                      showNewMessage: _coordinator.hasUnseenLatestBotMessage,
                      onJumpToLatest: _coordinator.jumpToLatest,
                      onJumpToBottom: _coordinator.jumpToBottom,
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: tokens.chatListTopShadowHeight,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: tokens.shellTopShadowGradient(colors),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: tokens.shellBottomShadowHeight(composerHeight),
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: tokens.shellBottomShadowGradient(colors),
                  ),
                ),
              ),
            ),
            Positioned(
              left: tokens.shellContentPadding.left,
              right: tokens.shellContentPadding.right,
              bottom: tokens.shellContentPadding.bottom,
              child: ValueListenableBuilder<int>(
                valueListenable: _coordinator.composerViewListenable,
                builder: (_, _, _) => Padding(
                  padding: EdgeInsets.only(top: tokens.composerRowTopSpacing),
                  child: ChatComposerRow(
                    controller: _coordinator.controller,
                    inputFocusNode: _coordinator.inputFocusNode,
                    minInputHeight: composerMetrics.minInputHeight,
                    maxInputHeight: composerMetrics.maxInputHeight,
                    sendButtonMinWidth: composerMetrics.sendButtonMinWidth,
                    isAwaitingResponse: widget.messages.any(
                      (message) => message.isPending,
                    ),
                    onSubmit: _submitMessage,
                    onStop: _stopPendingReply,
                    onMeasuredHeight: _handleComposerHeightChanged,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
