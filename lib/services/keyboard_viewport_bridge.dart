typedef KeyboardViewportChangeCallback = void Function();

abstract class KeyboardViewportBridge {
  double get estimatedBottomInset;
  double? get layoutViewportHeight;
  double? get visualViewportOffsetTop;

  void start(KeyboardViewportChangeCallback onChange);

  void stop();
}
