import 'package:web/web.dart' as web;

void clearBrowserTextInputFocus() {
  final web.Element? activeElement = web.document.activeElement;
  if (!_isEditableElement(activeElement)) {
    return;
  }
  (activeElement as web.HTMLElement).blur();
}

bool _isEditableElement(web.Element? element) {
  if (element == null || element == web.document.body) {
    return false;
  }

  final String tagName = element.tagName.toLowerCase();
  return tagName == 'input' ||
      tagName == 'textarea' ||
      (element is web.HTMLElement && element.isContentEditable);
}
