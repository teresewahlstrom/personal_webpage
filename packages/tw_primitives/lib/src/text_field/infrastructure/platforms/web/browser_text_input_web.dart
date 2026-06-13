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
  final String? contentEditableAttr = element
      .getAttribute('contenteditable')
      ?.toLowerCase();
  final bool isContentEditable =
      contentEditableAttr != null && contentEditableAttr != 'false';
  return tagName == 'input' || tagName == 'textarea' || isContentEditable;
}

bool browserReportsTouchInput() {
  final navigator = web.window.navigator;
  final hasTouchPoints = navigator.maxTouchPoints > 0;
  final usesCoarsePrimaryPointer = web.window
      .matchMedia('(pointer: coarse)')
      .matches;
  final hasFinePointer =
      web.window.matchMedia('(pointer: fine)').matches ||
      web.window.matchMedia('(any-pointer: fine)').matches;
  return hasTouchPoints && usesCoarsePrimaryPointer && !hasFinePointer;
}
