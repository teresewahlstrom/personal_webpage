import 'package:http/http.dart' as http;

import 'http_reply_client.dart';
import 'reply_client.dart';

final class ChatReplyClientFactory {
  const ChatReplyClientFactory._();

  static ReplyClient create({
    required Uri backendUrl,
    required bool useBackend,
    required String backendDisabledReply,
    Duration timeout = const Duration(seconds: 30),
    http.Client? httpClient,
  }) {
    if (!useBackend) {
      return FixedReplyClient(replyText: backendDisabledReply);
    }

    return HttpReplyClient(
      baseUri: backendUrl,
      httpClient: httpClient,
      timeout: timeout,
    );
  }
}