import 'dart:async';

abstract class TwinReplyClient {
  const TwinReplyClient();

  Future<String> fetchReply({
    required String sessionId,
    required String message,
  });

  void dispose() {}
}

class FixedTwinReplyClient extends TwinReplyClient {
  const FixedTwinReplyClient({
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

class TwinReplyException implements Exception {
  const TwinReplyException(this.message);

  final String message;

  @override
  String toString() => message;
}
