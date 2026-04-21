import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart';
import 'package:tw_chat/content.dart';

import '../../config/app_ui_config.dart';
import '../../services/http_twin_reply_client.dart';
import 'chat_keyboard_scroll_target.dart';

class TwinChatOverlay extends StatefulWidget {
  const TwinChatOverlay({
    super.key,
    required this.twinBackendUrl,
    this.chatSkinMode = ChatSkinMode.light,
  });

  final String twinBackendUrl;
  final ChatSkinMode chatSkinMode;

  @override
  State<TwinChatOverlay> createState() => _TwinChatOverlayState();
}

class _TwinChatOverlayState extends State<TwinChatOverlay> {
  late final TwinConversationController _conversationController;

  @override
  void initState() {
    super.initState();
    final TwinReplyClient replyClient = AppRuntimeConfig.useChatBackend
        ? HttpTwinReplyClient(baseUri: Uri.parse(widget.twinBackendUrl))
        : const FixedTwinReplyClient(
            replyText: AppRuntimeConfig.backendDisabledReply,
          );

    _conversationController = TwinConversationController(
      introText: twinPrototypeIntroText,
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
    return AnimatedBuilder(
      animation: _conversationController,
      builder: (BuildContext context, Widget? child) {
        return TwinChatDock(
          messages: _conversationController.messages,
          onSend: _conversationController.sendMessage,
          onStop: _conversationController.stopPendingReply,
          isChatKeyboardScrollTarget: ChatKeyboardScrollTarget.isChatTarget,
          onSetChatKeyboardScrollTarget: () =>
              _setChatKeyboardScrollTarget(true),
          onSetPageKeyboardScrollTarget: () =>
              _setChatKeyboardScrollTarget(false),
          skinMode: widget.chatSkinMode,
          launcherStyle: ChatLauncherStyle(
            size: ShellUiConfig.headerToggleSize * 1.5,
            iconSize: 30,
            icon: Icons.chat,
            foregroundColor: ShellUiConfig.headerToggleFor(brightness),
            hoverForegroundColor: ShellUiConfig.headerToggleHoverFor(brightness),
            backgroundColor: ShellUiConfig.headerToggleBackgroundFor(brightness),
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
