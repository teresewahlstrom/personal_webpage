class ChatRuntimeConfig {
  const ChatRuntimeConfig({
    this.minimumPendingReplyDuration = const Duration(milliseconds: 180),
  });

  static const defaults = ChatRuntimeConfig();

  final Duration minimumPendingReplyDuration;
}
