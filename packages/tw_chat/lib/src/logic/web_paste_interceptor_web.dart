import 'dart:js_interop';

import 'package:web/web.dart' as web;

typedef ChatPasteIsFocused = bool Function();
typedef ChatPasteTextInserter = void Function(String text);

class ChatWebPasteInterceptor {
  ChatWebPasteInterceptor({
    required this.isFocused,
    required this.onPasteText,
  });

  final ChatPasteIsFocused isFocused;
  final ChatPasteTextInserter onPasteText;
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
    if (!isFocused()) {
      return;
    }

    if (!event.isA<web.ClipboardEvent>()) {
      return;
    }

    final pasteEvent = event as web.ClipboardEvent;
    final clipboardData = pasteEvent.clipboardData;
    if (clipboardData == null) {
      return;
    }

    final text = clipboardData.getData('text/plain');
    if (text.isEmpty) {
      return;
    }

    event.preventDefault();
    onPasteText(text);
  }
}
