import 'package:flutter/widgets.dart';
import 'package:tw_primitives/src/text_field/infrastructure/flutter/flutter_scheduler.dart';
import 'package:tw_primitives/src/text_field/infrastructure/platforms/web/browser_text_input_stub.dart'
    if (dart.library.html) 'package:tw_primitives/src/text_field/infrastructure/platforms/web/browser_text_input_web.dart';
import 'package:tw_primitives/src/text_field/tw_textfield/input_method_engine/_ime_text_editing_controller.dart';

bool shouldClearTextInputForLifecycleState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.resumed:
    case AppLifecycleState.detached:
    case AppLifecycleState.inactive:
      return false;
    case AppLifecycleState.hidden:
    case AppLifecycleState.paused:
      return true;
  }
}

void clearPlatformTextInputFocusForBackgroundTransition() {
  clearBrowserTextInputFocus();
}

/// Clears platform text-input state before the app leaves the foreground.
///
/// This protects Flutter Web/mobile browsers from resuming with a stale hidden
/// editable element or IME connection after the software keyboard has gone away.
void clearTextInputForBackgroundTransition({
  required FocusNode focusNode,
  required ImeAttributedTextEditingController textEditingController,
  required bool Function() isMounted,
  required void Function(VoidCallback stateChange) runStateUpdate,
  required VoidCallback removeEditingOverlayControls,
}) {
  clearPlatformTextInputFocusForBackgroundTransition();

  if (!focusNode.hasFocus && !textEditingController.isAttachedToIme) {
    return;
  }

  WidgetsBinding.instance.runAsSoonAsPossible(() {
    if (!isMounted()) {
      return;
    }

    focusNode.unfocus();

    if (!textEditingController.isAttachedToIme) {
      return;
    }

    runStateUpdate(() {
      resetTextInputEditingStateForBackgroundTransition(
        detachFromIme: textEditingController.detachFromIme,
        setSelection: (selection) {
          textEditingController.selection = selection;
        },
        setComposingRegion: (composingRegion) {
          textEditingController.composingRegion = composingRegion;
        },
        removeEditingOverlayControls: removeEditingOverlayControls,
      );
    });
  }, debugLabel: 'clear text input for background transition');
}

@visibleForTesting
void resetTextInputEditingStateForBackgroundTransition({
  required VoidCallback detachFromIme,
  required ValueChanged<TextSelection> setSelection,
  required ValueChanged<TextRange> setComposingRegion,
  required VoidCallback removeEditingOverlayControls,
}) {
  detachFromIme();
  setSelection(const TextSelection.collapsed(offset: -1));
  setComposingRegion(TextRange.empty);
  removeEditingOverlayControls();
}
