import 'package:flutter/material.dart';

import '../content/prototype_content.dart';
import '../controllers/chat_keyboard_scroll_target_controller.dart';
import '../controllers/conversation_controller.dart';
import '../controllers/reply_client.dart';
import '../controllers/reply_client_factory.dart';
import '../config/skin.dart';
import 'chat_dock.dart';

class ChatOverlay extends StatefulWidget {
  const ChatOverlay({
    super.key,
    required this.backendUrl,
    required this.useBackend,
    required this.backendDisabledReply,
    required this.keyboardScrollTargetController,
    this.chatSkinMode = ChatSkinMode.light,
    this.onChatInteractionClaimed,
    this.minimizedBottomOffset = 25,
    this.minimizedRightInset = 0,
    this.launcherStyle = const ChatLauncherStyle(),
    this.introText = prototypeIntroText,
    this.requestTimeout = const Duration(seconds: 30),
  });

  final String backendUrl;
  final bool useBackend;
  final String backendDisabledReply;
  final ChatKeyboardScrollTargetController keyboardScrollTargetController;
  final ChatSkinMode chatSkinMode;
  final VoidCallback? onChatInteractionClaimed;
  final double minimizedBottomOffset;
  final double minimizedRightInset;
  final ChatLauncherStyle launcherStyle;
  final String introText;
  final Duration requestTimeout;

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay> {
  late final ConversationController _conversationController;

  @override
  void initState() {
    super.initState();
    final ReplyClient replyClient = ChatReplyClientFactory.create(
      backendUrl: Uri.parse(widget.backendUrl),
      useBackend: widget.useBackend,
      backendDisabledReply: widget.backendDisabledReply,
      timeout: widget.requestTimeout,
    );

    _conversationController = ConversationController(
      introText: widget.introText,
      replyClient: replyClient,
      ownsReplyClient: true,
    );
  }

  @override
  void dispose() {
    _conversationController.dispose();
    super.dispose();
  }

  void _claimChatInteraction() {
    widget.onChatInteractionClaimed?.call();
    widget.keyboardScrollTargetController.setChatTarget(true);
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedBuilder(
      animation: _conversationController,
      builder: (BuildContext context, Widget? child) {
        return ChatDock(
          messages: _conversationController.messages,
          onSend: _conversationController.sendMessage,
          onStop: _conversationController.stopPendingReply,
          isChatKeyboardScrollTarget:
              widget.keyboardScrollTargetController.isChatTargetListenable,
          onSetChatKeyboardScrollTarget: _claimChatInteraction,
          onSetPageKeyboardScrollTarget: () =>
              widget.keyboardScrollTargetController.setChatTarget(false),
          keyboardHeight: keyboardHeight,
          minimizedBottomOffset: widget.minimizedBottomOffset,
          minimizedRightInset: widget.minimizedRightInset,
          skinMode: widget.chatSkinMode,
          launcherStyle: widget.launcherStyle,
        );
      },
    );
  }
}