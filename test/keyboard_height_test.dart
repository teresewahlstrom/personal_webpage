import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/services/keyboard_height.dart';

void main() {
  test(
    'estimateViewportConsumedBottomInset is zero when Flutter viewport keeps full height',
    () {
      expect(
        estimateViewportConsumedBottomInset(
          viewportHeight: 780,
          layoutViewportHeight: 780,
          visualViewportOffsetTop: 0,
        ),
        0,
      );
    },
  );

  test(
    'estimateViewportConsumedBottomInset matches the bottom space already removed from the Flutter viewport',
    () {
      expect(
        estimateViewportConsumedBottomInset(
          viewportHeight: 500,
          layoutViewportHeight: 780,
          visualViewportOffsetTop: 0,
        ),
        280,
      );
    },
  );

  test(
    'estimateViewportConsumedBottomInset excludes viewport top shifts from the bottom overlap',
    () {
      expect(
        estimateViewportConsumedBottomInset(
          viewportHeight: 640,
          layoutViewportHeight: 780,
          visualViewportOffsetTop: 40,
        ),
        100,
      );
    },
  );
}
