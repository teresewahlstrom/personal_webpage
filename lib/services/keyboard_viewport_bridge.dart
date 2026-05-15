typedef KeyboardViewportChangeCallback = void Function();

abstract class KeyboardViewportBridge {
  double get estimatedBottomInset;

  bool get canTrackTextInputFocus;

  bool get isTextInputFocused;

  void clearTextInputFocus();

  void start(KeyboardViewportChangeCallback onChange);

  void stop();
}
