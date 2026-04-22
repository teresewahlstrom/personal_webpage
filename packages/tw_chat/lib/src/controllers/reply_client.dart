import 'dart:async';

abstract class ReplyClient {
  const ReplyClient();

  Future<String> fetchReply({
    required String sessionId,
    required String message,
  });

  void dispose() {}
}

class FixedReplyClient extends ReplyClient {
  const FixedReplyClient({
    required this.replyText,
    this.replyDelay = Duration.zero,
  });

  final String replyText;
  final Duration replyDelay;

  @override
  Future<String> fetchReply({
    required String sessionId,
    required String message,
  }) async {
    if (replyDelay > Duration.zero) {
      await Future<void>.delayed(replyDelay);
    }
    return replyText;
  }
}

class ReplyException implements Exception {
  const ReplyException(this.message);

  final String message;

  @override
  String toString() => message;
}
