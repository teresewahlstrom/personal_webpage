import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/config/skin_light.dart';

void main() {
  test('top shadow decoration paints an opaque shell background beneath the gradient', () {
    final colors = chatLightSkin.colors;
    final decoration = chatLightSkin.tokens.shellTopShadowDecoration(colors);

    expect(decoration.color, colors.shellBackgroundStart);
    expect(decoration.gradient, isNotNull);
  });
}
