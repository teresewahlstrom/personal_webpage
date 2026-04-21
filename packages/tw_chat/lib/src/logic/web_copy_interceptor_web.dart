import 'dart:async';
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
    final clipboardData = copyEvent.clipboardData;
    if (clipboardData != null) {
      copyEvent.preventDefault();
      clipboardData.setData('text/plain', copyText);
      return;
    }

    // Some mobile browsers fire a copy event without clipboardData.
    // Try asynchronous clipboard write and allow default copy to proceed.
    try {
      unawaited(web.window.navigator.clipboard.writeText(copyText).toDart);
    } catch (_) {
      // Keep the default browser copy behavior as a fallback.
    }
  }
}
