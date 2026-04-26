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

  test('composer disables selection handles on iOS mobile web', () {
    // iOS mobile web: the Cupertino handle's tap is intercepted during
    // pointer-down so toggleToolbar() is a no-op; return null to remove the
    // broken handle.  The contextMenuBuilder still provides the toolbar on
    // long-press.
    expect(
      composerSelectionControlsForPlatform(
        isWeb: true,
        platform: TargetPlatform.iOS,
      ),
      isNull,
    );
  });

  test('composer uses Flutter selection controls on non-iOS-web platforms', () {
    expect(
      composerSelectionControlsForPlatform(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
      same(materialTextSelectionControls),
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

  test('composer uses Flutter context menu on all platforms including mobile web', () {
    expect(
      composerContextMenuBuilderForPlatform(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
      isNotNull,
    );
    expect(
      composerContextMenuBuilderForPlatform(
        isWeb: true,
        platform: TargetPlatform.iOS,
      ),
      isNotNull,
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
        platform: TargetPlatform.iOS,
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
    expect(
      shouldClipComposerInputForPlatform(
        isWeb: false,
        platform: TargetPlatform.iOS,
      ),
      isTrue,
    );
  });

  test('composer disables custom input scrollbar on mobile web', () {
    expect(
      shouldUseComposerInputScrollbarForPlatform(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
      isFalse,
    );
    expect(
      shouldUseComposerInputScrollbarForPlatform(
        isWeb: true,
        platform: TargetPlatform.iOS,
      ),
      isFalse,
    );
    expect(
      shouldUseComposerInputScrollbarForPlatform(
        isWeb: true,
        platform: TargetPlatform.windows,
      ),
      isTrue,
    );
    expect(
      shouldUseComposerInputScrollbarForPlatform(
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
