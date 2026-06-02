import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

typedef TwCopyTextResolver = String Function();
typedef TwCopyGuard = bool Function();

class TwWebCopyInterceptor {
  TwWebCopyInterceptor(
    this._resolveCopyText, {
    required TwCopyGuard shouldInterceptCopy,
  }) : _shouldInterceptCopy = shouldInterceptCopy;

  final TwCopyTextResolver _resolveCopyText;
  final TwCopyGuard _shouldInterceptCopy;
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
    if (!_shouldInterceptCopy()) {
      return;
    }

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

    try {
      unawaited(web.window.navigator.clipboard.writeText(copyText).toDart);
    } catch (_) {
      // Keep default browser copy fallback
    }
  }
}
