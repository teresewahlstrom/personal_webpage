typedef ChatCopyTextResolver = String Function();

class ChatWebCopyInterceptor {
  ChatWebCopyInterceptor(ChatCopyTextResolver _);

  void attach() {}

  void detach() {}
}
