import '../models/message.dart';

class ChatMessageDiff {
  const ChatMessageDiff({
    required this.addedMessages,
    required this.visibleIncomingMessages,
    required this.resolvedPendingBotId,
  });

  final int addedMessages;
  final int visibleIncomingMessages;
  final String? resolvedPendingBotId;

  bool get hasNewContent => addedMessages > 0 || visibleIncomingMessages > 0;

  static ChatMessageDiff summarize({
    required List<ChatMessage> previousMessages,
    required List<ChatMessage> currentMessages,
  }) {
    final previousMessagesById = <String, ChatMessage>{
      for (final message in previousMessages) message.id: message,
    };

    var visibleIncomingMessages = 0;
    String? resolvedPendingBotId;

    for (final currentMessage in currentMessages) {
      final previousMessage = previousMessagesById[currentMessage.id];

      if (previousMessage == null) {
        if (currentMessage.role == ChatRole.bot && !currentMessage.isPending) {
          visibleIncomingMessages += 1;
        }
        continue;
      }

      final resolvedPendingBot =
          previousMessage.role == ChatRole.bot &&
          previousMessage.isPending &&
          currentMessage.role == ChatRole.bot &&
          !currentMessage.isPending;
      if (resolvedPendingBot) {
        visibleIncomingMessages += 1;
        resolvedPendingBotId ??= currentMessage.id;
      }
    }

    return ChatMessageDiff(
      addedMessages: currentMessages.length - previousMessages.length,
      visibleIncomingMessages: visibleIncomingMessages,
      resolvedPendingBotId: resolvedPendingBotId,
    );
  }
}
