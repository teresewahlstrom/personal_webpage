// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

void clearBrowserTextInputFocus() {
  final html.Element? activeElement = html.document.activeElement;
  if (!_isEditableElement(activeElement)) {
    return;
  }
  activeElement?.blur();
}

bool _isEditableElement(html.Element? element) {
  if (element == null || element == html.document.body) {
    return false;
  }

  final String tagName = element.tagName.toLowerCase();
  return tagName == 'input' ||
      tagName == 'textarea' ||
      element.isContentEditable == true;
}
