import 'dart:js_interop';

import 'package:web/web.dart' as web;

typedef OnPasteText = void Function(String text);

/// Intercepts the browser's native `paste` DOM event and reads the plain-text
/// clipboard content via [web.DataTransfer.getData], which does **not** require
/// the clipboard-read browser permission.
///
/// Call [attach] once to start listening and [detach] when the widget is
/// disposed.
class ChatWebPasteInterceptor {
  ChatWebPasteInterceptor({
    required bool Function() shouldHandlePaste,
    required OnPasteText onPasteText,
  })  : _shouldHandlePaste = shouldHandlePaste,
        _onPasteText = onPasteText;

  final bool Function() _shouldHandlePaste;
  final OnPasteText _onPasteText;
  JSFunction? _pasteListener;

  void attach() {
    if (_pasteListener != null) {
      return;
    }
    _pasteListener = _handlePaste.toJS;
    web.document.addEventListener('paste', _pasteListener);
  }

  void detach() {
    if (_pasteListener == null) {
      return;
    }
    web.document.removeEventListener('paste', _pasteListener);
    _pasteListener = null;
  }

  void _handlePaste(web.Event event) {
    if (!event.isA<web.ClipboardEvent>()) {
      return;
    }

    final pasteEvent = event as web.ClipboardEvent;
    final clipboardData = pasteEvent.clipboardData;
    if (clipboardData == null) {
      return;
    }

    final text = clipboardData.getData('text/plain');

    // Always prevent the browser from attempting to insert clipboard content
    // into Flutter's canvas element (which would have no visible effect but
    // could cause unexpected interactions).
    pasteEvent.preventDefault();

    if (!_shouldHandlePaste()) {
      return;
    }

    if (text.isNotEmpty) {
      _onPasteText(text);
    }
  }
}
