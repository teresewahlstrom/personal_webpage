import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/src/text_field/tw_textfield/tw_textfield.dart';

void main() {
  group('defaultTextInputSourceForPlatform', () {
    test('uses IME on mobile platforms', () {
      expect(
        defaultTextInputSourceForPlatform(
          TargetPlatform.android,
          useImeOnWebTouchDevice: false,
        ),
        TextInputSource.ime,
      );
      expect(
        defaultTextInputSourceForPlatform(
          TargetPlatform.iOS,
          useImeOnWebTouchDevice: false,
        ),
        TextInputSource.ime,
      );
    });

    test('keeps keyboard input on non-touch desktop platforms', () {
      expect(
        defaultTextInputSourceForPlatform(
          TargetPlatform.macOS,
          useImeOnWebTouchDevice: false,
        ),
        TextInputSource.keyboard,
      );
      expect(
        defaultTextInputSourceForPlatform(
          TargetPlatform.windows,
          useImeOnWebTouchDevice: false,
        ),
        TextInputSource.keyboard,
      );
    });

    test('prefers IME for touch-capable web browsers', () {
      expect(
        defaultTextInputSourceForPlatform(
          TargetPlatform.windows,
          useImeOnWebTouchDevice: true,
        ),
        TextInputSource.ime,
      );
    });
  });
}
