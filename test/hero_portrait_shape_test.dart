import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/config/app_ui_config.dart';

void main() {
  group('ShellUiConfig hero portrait shape', () {
    test('exposes four per-corner radius tokens', () {
      // All four corner radii must be positive values (non-negative)
      expect(ShellUiConfig.heroPortraitRadiusTopLeft, greaterThan(0));
      expect(ShellUiConfig.heroPortraitRadiusTopRight, greaterThan(0));
      expect(ShellUiConfig.heroPortraitRadiusBottomRight, greaterThan(0));
      expect(ShellUiConfig.heroPortraitRadiusBottomLeft, greaterThan(0));
    });

    test('heroPortraitBorderRadius assembles all four corners correctly', () {
      final BorderRadius br = ShellUiConfig.heroPortraitBorderRadius;
      expect(
        br.topLeft,
        equals(Radius.circular(ShellUiConfig.heroPortraitRadiusTopLeft)),
      );
      expect(
        br.topRight,
        equals(Radius.circular(ShellUiConfig.heroPortraitRadiusTopRight)),
      );
      expect(
        br.bottomRight,
        equals(Radius.circular(ShellUiConfig.heroPortraitRadiusBottomRight)),
      );
      expect(
        br.bottomLeft,
        equals(Radius.circular(ShellUiConfig.heroPortraitRadiusBottomLeft)),
      );
    });

    test('heroPortraitBorderRadius radii stay within portrait size bounds', () {
      // Each corner radius should not exceed half the portrait width/height (60px)
      // so the shape remains a valid rounded rectangle.
      const double maxRadius = 60.0;
      expect(ShellUiConfig.heroPortraitRadiusTopLeft, lessThanOrEqualTo(maxRadius));
      expect(ShellUiConfig.heroPortraitRadiusTopRight, lessThanOrEqualTo(maxRadius));
      expect(ShellUiConfig.heroPortraitRadiusBottomRight, lessThanOrEqualTo(maxRadius));
      expect(ShellUiConfig.heroPortraitRadiusBottomLeft, lessThanOrEqualTo(maxRadius));
    });
  });
}
