import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart';
import 'package:tw_chat/content.dart';

import '../../config/app_ui_config.dart';
import '../../services/http_twin_reply_client.dart';
import 'chat_keyboard_scroll_target.dart';
import 'floating_control_inset.dart';

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
  }

  @override
  void dispose() {
    _conversationController.dispose();
    super.dispose();
  }

  void _setChatKeyboardScrollTarget(bool value) {
    ChatKeyboardScrollTarget.setChatTarget(value);
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Size viewport = MediaQuery.of(context).size;
    final double floatingInset = FloatingControlInset.forViewportWidth(
      viewport.width,
    );
    return AnimatedBuilder(
      animation: _conversationController,
      builder: (BuildContext context, Widget? child) {
        return ChatDock(
          messages: _conversationController.messages,
          onSend: _conversationController.sendMessage,
          onStop: _conversationController.stopPendingReply,
          isChatKeyboardScrollTarget: ChatKeyboardScrollTarget.isChatTarget,
          onSetChatKeyboardScrollTarget: () =>
              _setChatKeyboardScrollTarget(true),
          onSetPageKeyboardScrollTarget: () =>
              _setChatKeyboardScrollTarget(false),
          minimizedBottomOffset: floatingInset,
          minimizedRightInset: floatingInset,
          skinMode: widget.chatSkinMode,
          launcherStyle: ChatLauncherStyle(
            size: ShellUiConfig.headerToggleSize * 1.5,
            iconSize: 30,
            icon: Icons.chat,
            foregroundColor: ShellUiConfig.headerToggleFor(brightness),
            hoverForegroundColor: ShellUiConfig.headerToggleHoverFor(
              brightness,
            ),
            backgroundColor: ShellUiConfig.headerToggleBackgroundFor(
              brightness,
            ),
            borderWidth: 1,
            animationDuration: const Duration(milliseconds: 180),
            idleShadowBlurRadius: 8,
            hoverShadowBlurRadius: 12,
            shadowOffset: const Offset(0, 3),
            shadowAlpha: 0.12,
          ),
        );
      },
    );
  }
}
