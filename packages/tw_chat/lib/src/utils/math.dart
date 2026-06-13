class ChatMath {
  const ChatMath._();

  static double normalized(double value, double min, double max) {
    if (max <= min) {
      return 1.0;
    }
    return (value.clamp(min, max) - min) / (max - min);
  }

  static double scaleFromOne(double base, double scale, double intensity) {
    return base * (1 + (scale - 1) * intensity);
  }

  static double lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }

  static double lerpClamped(
    double value,
    double minValue,
    double maxValue,
    double minResult,
    double maxResult,
  ) {
    final t = normalized(value, minValue, maxValue);
    return lerp(minResult, maxResult, t);
  }

  static double tapered(
    double base,
    double scale,
    double minScale,
    double maxScale,
    double minFactor,
  ) {
    final n = normalized(scale, minScale, maxScale);
    final factor = 1 - (1 - minFactor) * n;
    return base * factor;
  }
}
