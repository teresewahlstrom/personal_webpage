import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/src/text_field/tw_textfield/infrastructure/text_input_lifecycle.dart';

void main() {
  group('shouldClearTextInputForLifecycleState', () {
    test('clears text input when the app is leaving the foreground', () {
      expect(
        shouldClearTextInputForLifecycleState(AppLifecycleState.inactive),
        isTrue,
      );
      expect(
        shouldClearTextInputForLifecycleState(AppLifecycleState.hidden),
        isTrue,
      );
      expect(
        shouldClearTextInputForLifecycleState(AppLifecycleState.paused),
        isTrue,
      );
    });

    test('does not clear text input for resumed or detached states', () {
      expect(
        shouldClearTextInputForLifecycleState(AppLifecycleState.resumed),
        isFalse,
      );
      expect(
        shouldClearTextInputForLifecycleState(AppLifecycleState.detached),
        isFalse,
      );
    });
  });

  test(
    'resetTextInputEditingStateForBackgroundTransition clears IME state',
    () {
      final calls = <String>[];
      TextSelection? selection;
      TextRange? composingRegion;

      resetTextInputEditingStateForBackgroundTransition(
        detachFromIme: () {
          calls.add('detach');
        },
        setSelection: (value) {
          calls.add('selection');
          selection = value;
        },
        setComposingRegion: (value) {
          calls.add('composing');
          composingRegion = value;
        },
        removeEditingOverlayControls: () {
          calls.add('overlay');
        },
      );

      expect(calls, <String>['detach', 'selection', 'composing', 'overlay']);
      expect(selection, const TextSelection.collapsed(offset: -1));
      expect(composingRegion, TextRange.empty);
    },
  );
}
