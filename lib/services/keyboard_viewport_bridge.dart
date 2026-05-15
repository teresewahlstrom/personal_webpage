typedef KeyboardViewportChangeCallback = void Function();

abstract class KeyboardViewportBridge {
  double get estimatedBottomInset;

  void start(KeyboardViewportChangeCallback onChange);

  void stop();
}
