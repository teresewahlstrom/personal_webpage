class ChatRuntimeConfig {
  const ChatRuntimeConfig({
    this.minimumPendingReplyDuration = const Duration(milliseconds: 700),
  });

  static const defaults = ChatRuntimeConfig();

  final Duration minimumPendingReplyDuration;
}
