import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart';
import 'package:tw_chat/content.dart';

import '../../services/chat_reply_client_factory.dart';
import '../../services/keyboard_height.dart';
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

  @override
  void initState() {
    super.initState();
    final ReplyClient replyClient = ChatReplyClientFactory.create(
      backendUrl: widget.twinBackendUrl,
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

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Size viewport = MediaQuery.of(context).size;
    final double floatingInset = FloatingControlInset.forViewportWidth(
      viewport.width,
    );
    final double keyboardHeight = KeyboardHeight.of(context);
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
          keyboardHeight: keyboardHeight,
          minimizedBottomOffset: floatingInset,
          minimizedRightInset: floatingInset,
          skinMode: widget.chatSkinMode,
          launcherStyle: buildChatLauncherStyle(brightness),
        );
      },
    );
  }
}
