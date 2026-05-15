import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart';
import 'package:tw_chat/content.dart';

import '../../config/app_ui_config.dart';
import '../../services/http_twin_reply_client.dart';
import '_chat_keyboard_scroll_target.dart';
import '_floating_controls.dart';

class ChatOverlay extends StatefulWidget {
  const ChatOverlay({
    super.key,
    required this.twinBackendUrl,
    this.chatSkinMode = ChatSkinMode.light,
  });

  final String twinBackendUrl;
  final ChatSkinMode chatSkinMode;

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay> {
  late final ConversationController _conversationController;
  double _cachedFloatingInset = 25.0;
  double _lastViewportWidth = double.infinity;
  late Size _cachedViewportSize;
  double _lastCachedViewportWidth = double.infinity;

  @override
  void initState() {
    super.initState();
    final ReplyClient replyClient = AppRuntimeConfig.useChatBackend
        ? HttpReplyClient(baseUri: Uri.parse(widget.twinBackendUrl))
        : const FixedReplyClient(
            replyText: AppRuntimeConfig.backendDisabledReply,
          );

    _conversationController = ConversationController(
      introText: prototypeIntroText,
      replyClient: replyClient,
      ownsReplyClient: true,
    );
    _cachedViewportSize = Size.zero;
  }

  double _getFloatingInset(double viewportWidth) {
    // Only recalculate if viewport width crosses a breakpoint threshold (±5 pixels tolerance)
    // This prevents chattering from scrollbar micro-adjustments or transient viewport changes
    const double breakpointTolerance = 5.0;
    if ((viewportWidth - _lastViewportWidth).abs() > breakpointTolerance) {
      _lastViewportWidth = viewportWidth;
      _cachedFloatingInset = FloatingControlInset.forViewportWidth(viewportWidth);
    }
    return _cachedFloatingInset;
  }

  Size _getCachedViewportSize(Size currentViewport) {
    // Only update cached size when width changes significantly (breakpoint crossings)
    // This reduces cascade effects from transient viewport changes
    if ((currentViewport.width - _lastCachedViewportWidth).abs() > 5.0) {
      _lastCachedViewportWidth = currentViewport.width;
      _cachedViewportSize = currentViewport;
    }
    return _cachedViewportSize;
  }

  @override
  void dispose() {
    _conversationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Size currentViewport = MediaQuery.of(context).size;
    final Size viewport = _getCachedViewportSize(currentViewport);
    final double floatingInset = _getFloatingInset(viewport.width);
    return AnimatedBuilder(
      animation: _conversationController,
      builder: (BuildContext context, Widget? child) {
        return ChatDock(
          messages: _conversationController.messages,
          onSend: _conversationController.sendMessage,
          onStop: _conversationController.stopPendingReply,
          isChatKeyboardScrollTarget: ChatKeyboardScrollTarget.isChatTarget,
          onSetChatKeyboardScrollTarget: () =>
              ChatKeyboardScrollTarget.setChatTarget(true),
          onSetPageKeyboardScrollTarget: () =>
              ChatKeyboardScrollTarget.setChatTarget(false),
          minimizedBottomOffset: floatingInset,
          minimizedRightInset: floatingInset,
          skinMode: widget.chatSkinMode,
          launcherStyle: buildChatLauncherStyle(brightness),
        );
      },
    );
  }
}
