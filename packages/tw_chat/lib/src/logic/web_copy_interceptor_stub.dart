typedef ChatCopyTextResolver = String Function();
typedef ChatCopyGuard = bool Function();

class ChatWebCopyInterceptor {
  ChatWebCopyInterceptor(
    ChatCopyTextResolver resolveCopyText, {
    required ChatCopyGuard shouldInterceptCopy,
  });

  void attach() {}

  void detach() {}
}