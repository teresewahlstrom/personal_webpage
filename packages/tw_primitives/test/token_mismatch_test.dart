import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/src/theme/text_styles/_light.dart' as light;
import 'package:tw_primitives/src/theme/text_styles/_dark.dart' as dark;
import 'package:tw_primitives/src/theme/text_styles/router.dart' as router;

void main() {
  test('light footer token equals dark canonical footer token', () {
    // Ensure router maps brightness -> token source correctly.
    expect(
      router.TwTextStyleTokens.forBrightness(Brightness.light).twFooterBaseFontSize,
      equals(light.TwTextStyleTokensLight.twFooterBaseFontSize),
    );
    expect(
      router.TwTextStyleTokens.forBrightness(Brightness.dark).twFooterBaseFontSize,
      equals(dark.TwTextStyleTokensDark.twFooterBaseFontSize),
    );
  });
}
