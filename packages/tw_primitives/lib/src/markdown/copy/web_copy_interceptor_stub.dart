typedef TwCopyTextResolver = String Function();
typedef TwCopyGuard = bool Function();

class TwWebCopyInterceptor {
  TwWebCopyInterceptor(
    TwCopyTextResolver resolveCopyText, {
    required TwCopyGuard shouldInterceptCopy,
  });

  void attach() {}

  void detach() {}
}
