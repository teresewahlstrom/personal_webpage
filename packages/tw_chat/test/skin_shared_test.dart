import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/config/skin_light.dart';

void main() {
  test(
    'top shadow decoration paints an opaque shell background beneath the gradient',
    () {
      final colors = chatLightSkin.colors;
      final decoration = chatLightSkin.tokens.shellTopShadowDecoration(colors);

      expect(decoration.color, colors.shellBackgroundStart);
      expect(decoration.gradient, isNotNull);
    },
  );

  test(
    'bubble text style uses the updated larger size and tighter line height',
    () {
      final style = chatLightSkin.tokens.bubbleTextStyle(
        1.0,
        chatLightSkin.colors,
      );

      expect(style.fontSize, 15);
      expect(style.height, 1.4);
    },
  );

  test(
    'bubble viewport right padding trims one sixth of the previous gutter',
    () {
      expect(
        chatLightSkin.tokens.bubbleViewportPadding.right,
        closeTo(20.75 * 5 / 6, 0.001),
      );
    },
  );
}
