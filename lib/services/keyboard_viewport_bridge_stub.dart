import 'keyboard_viewport_bridge.dart';

KeyboardViewportBridge createKeyboardViewportBridge() {
  return _NoopKeyboardViewportBridge();
}

class _NoopKeyboardViewportBridge implements KeyboardViewportBridge {
  @override
  double get estimatedBottomInset => 0;

  @override
  double? get layoutViewportHeight => null;

  @override
  double? get visualViewportOffsetTop => null;

  @override
  void start(KeyboardViewportChangeCallback onChange) {}

  @override
  void stop() {}
}
