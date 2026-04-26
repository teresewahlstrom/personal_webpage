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

  test('composer keeps native selection controls on mobile web', () {
    expect(
      composerSelectionControlsForPlatform(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
      isNull,
    );
    expect(
      composerSelectionControlsForPlatform(
        isWeb: true,
        platform: TargetPlatform.iOS,
      ),
      isNull,
    );
    expect(
      composerSelectionControlsForPlatform(
        isWeb: false,
        platform: TargetPlatform.iOS,
      ),
      same(cupertinoTextSelectionControls),
    );
    expect(
      composerSelectionControlsForPlatform(
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      same(materialTextSelectionControls),
    );
  });

  test('composer defers context menu to the browser on mobile web', () {
    expect(
      composerContextMenuBuilderForPlatform(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
      isNull,
    );
    expect(
      composerContextMenuBuilderForPlatform(
        isWeb: true,
        platform: TargetPlatform.iOS,
      ),
      isNull,
    );
    expect(
      composerContextMenuBuilderForPlatform(
        isWeb: true,
        platform: TargetPlatform.windows,
      ),
      isNotNull,
    );
    expect(
      composerContextMenuBuilderForPlatform(
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      isNotNull,
    );
    expect(
      composerContextMenuBuilderForPlatform(
        isWeb: false,
        platform: TargetPlatform.iOS,
      ),
      isNotNull,
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

  test('composer disables custom input scrollbar on mobile web', () {
    expect(
      usesComposerInputScrollbarForPlatform(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
      isFalse,
    );
    expect(
      usesComposerInputScrollbarForPlatform(
        isWeb: true,
        platform: TargetPlatform.iOS,
      ),
      isFalse,
    );
    expect(
      usesComposerInputScrollbarForPlatform(
        isWeb: true,
        platform: TargetPlatform.windows,
      ),
      isTrue,
    );
    expect(
      usesComposerInputScrollbarForPlatform(
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      isTrue,
    );
  });

  test('composer scrollbar padding extends mobile web thumb travel fully', () {
    expect(
      composerScrollbarPadding(
        isMobileWebTextInputPlatform: false,
        composerInputTextInsetTop: 6.3,
        composerInputTextInsetTopBottom: 6.3,
      ),
      const EdgeInsets.only(bottom: -6.3),
    );
    expect(
      composerScrollbarPadding(
        isMobileWebTextInputPlatform: true,
        composerInputTextInsetTop: 6.3,
        composerInputTextInsetTopBottom: 6.3,
      ),
      const EdgeInsets.only(bottom: -12.6),
    );
  });
}
