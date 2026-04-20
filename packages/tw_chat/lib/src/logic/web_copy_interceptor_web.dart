import 'dart:js_interop';

import 'package:web/web.dart' as web;

typedef ChatCopyTextResolver = String Function();

class ChatWebCopyInterceptor {
  ChatWebCopyInterceptor(this._resolveCopyText);

  final ChatCopyTextResolver _resolveCopyText;
  JSFunction? _copyListener;

  void attach() {
    if (_copyListener != null) {
      return;
    }
    _copyListener = _handleCopy.toJS;
    web.document.addEventListener('copy', _copyListener);
  }

  void detach() {
    if (_copyListener == null) {
      return;
    }
    web.document.removeEventListener('copy', _copyListener);
    _copyListener = null;
  }

  void _handleCopy(web.Event event) {
    final copyText = _resolveCopyText();
    if (copyText.trim().isEmpty) {
      return;
    }

    if (!event.isA<web.ClipboardEvent>()) {
      return;
    }

    final copyEvent = event as web.ClipboardEvent;
    copyEvent.preventDefault();
    copyEvent.clipboardData?.setData('text/plain', copyText);
  }
}
