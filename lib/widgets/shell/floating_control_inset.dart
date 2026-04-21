class FloatingControlInset {
  const FloatingControlInset._();

  static double forViewportWidth(double viewportWidth) {
    if (viewportWidth <= 420) {
      return 10;
    }
    if (viewportWidth <= 640) {
      return 12;
    }
    if (viewportWidth <= 960) {
      return 16;
    }
    return 25;
  }
}
