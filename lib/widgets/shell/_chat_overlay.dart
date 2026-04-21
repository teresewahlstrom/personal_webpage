import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart';
import 'package:tw_chat/content.dart';

import '../../config/app_ui_config.dart';
import '../../services/http_twin_reply_client.dart';

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
  final ValueNotifier<bool> _isChatKeyboardScrollTarget = ValueNotifier<bool>(
    false,
  );

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
    _isChatKeyboardScrollTarget.dispose();
    super.dispose();
  }

  void _setChatKeyboardScrollTarget(bool value) {
    if (_isChatKeyboardScrollTarget.value == value) {
      return;
    }
    _isChatKeyboardScrollTarget.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _conversationController,
      builder: (BuildContext context, Widget? child) {
        return TwinChatDock(
          messages: _conversationController.messages,
          onSend: _conversationController.sendMessage,
          onStop: _conversationController.stopPendingReply,
          isChatKeyboardScrollTarget: _isChatKeyboardScrollTarget,
          onSetChatKeyboardScrollTarget: () =>
              _setChatKeyboardScrollTarget(true),
          onSetPageKeyboardScrollTarget: () =>
              _setChatKeyboardScrollTarget(false),
          skinMode: widget.chatSkinMode,
        );
      },
    );
  }
}
