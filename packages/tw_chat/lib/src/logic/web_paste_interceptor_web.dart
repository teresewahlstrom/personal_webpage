import 'dart:js_interop';

import 'package:web/web.dart' as web;

typedef ChatPasteTextCallback = void Function(String text);

/// Intercepts browser `paste` events and routes the clipboard text to a
/// Dart callback without triggering the `clipboard-read` permission prompt.
///
/// Browsers expose clipboard content through [web.ClipboardEvent.clipboardData]
/// on the synchronous `paste` event. Reading from there does **not** require
/// the `clipboard-read` permission that [web.Clipboard.readText] would ask for.
class ChatWebPasteInterceptor {
  ChatWebPasteInterceptor(this._onPasteText);

  final ChatPasteTextCallback _onPasteText;
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
      // Some browsers (e.g., certain mobile browsers) fire a paste event
      // without clipboardData. Fall through to let the default behavior run.
      return;
    }

    final text = clipboardData.getData('text/plain');
    if (text.isEmpty) {
      return;
    }

    // Prevent the browser from inserting the pasted text into any underlying
    // HTML input element (e.g., Flutter's hidden textarea).
    pasteEvent.preventDefault();

    _onPasteText(text);
  }
}
