import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/widgets/composer_row.dart';

void main() {
  test('mobile web text input platforms are limited to Android and iOS', () {
    expect(
      isMobileWebTextInputPlatform(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
      isTrue,
    );
    expect(
      isMobileWebTextInputPlatform(isWeb: true, platform: TargetPlatform.iOS),
      isTrue,
    );
    expect(
      isMobileWebTextInputPlatform(
        isWeb: true,
        platform: TargetPlatform.windows,
      ),
      isFalse,
    );
    expect(
      isMobileWebTextInputPlatform(
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      isFalse,
    );
  });

  test('composer keeps explicit Flutter selection controls on mobile web', () {
    expect(
      composerSelectionControlsForPlatform(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
      same(materialTextSelectionControls),
    );
    expect(
      composerSelectionControlsForPlatform(
        isWeb: true,
        platform: TargetPlatform.iOS,
      ),
      same(cupertinoTextSelectionControls),
    );
  });

  test('composer avoids mobile web clipping around selection handles', () {
    expect(
      shouldClipComposerInputForPlatform(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
      isFalse,
    );
    expect(
      shouldClipComposerInputForPlatform(
        isWeb: true,
        platform: TargetPlatform.windows,
      ),
      isTrue,
    );
  });

  test('composer scrollbar padding extends thumb travel through input padding', () {
    expect(composerScrollbarPadding(6.3), const EdgeInsets.only(bottom: -6.3));
  });
}
