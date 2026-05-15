import 'keyboard_viewport_bridge.dart';

KeyboardViewportBridge createKeyboardViewportBridge() {
  return _NoopKeyboardViewportBridge();
}

class _NoopKeyboardViewportBridge implements KeyboardViewportBridge {
  @override
  double get estimatedBottomInset => 0;

  @override
  bool get canTrackTextInputFocus => false;

  @override
  bool get isTextInputFocused => false;

  @override
  void clearTextInputFocus() {}

  @override
  void start(KeyboardViewportChangeCallback onChange) {}

  @override
  void stop() {}
}
