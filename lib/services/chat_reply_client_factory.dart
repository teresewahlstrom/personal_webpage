import 'package:tw_chat/chat.dart';

import '../config/app_ui_config.dart';
import 'http_twin_reply_client.dart';

final class ChatReplyClientFactory {
  const ChatReplyClientFactory._();

  static ReplyClient create({required String backendUrl}) {
    if (!AppRuntimeConfig.useChatBackend) {
      return const FixedReplyClient(
        replyText: AppRuntimeConfig.backendDisabledReply,
      );
    }

    return HttpReplyClient(baseUri: Uri.parse(backendUrl));
  }
}
