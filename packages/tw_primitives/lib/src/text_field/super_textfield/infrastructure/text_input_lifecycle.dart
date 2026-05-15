import 'package:flutter/widgets.dart';
import 'package:tw_primitives/src/text_field/infrastructure/flutter/flutter_scheduler.dart';
import 'package:tw_primitives/src/text_field/infrastructure/platforms/web/browser_text_input_stub.dart'
    if (dart.library.html) 'package:tw_primitives/src/text_field/infrastructure/platforms/web/browser_text_input_web.dart';
import 'package:tw_primitives/src/text_field/super_textfield/input_method_engine/_ime_text_editing_controller.dart';

bool shouldClearTextInputForLifecycleState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.resumed:
    case AppLifecycleState.detached:
      return false;
    case AppLifecycleState.inactive:
    case AppLifecycleState.hidden:
    case AppLifecycleState.paused:
      return true;
  }
}

void clearPlatformTextInputFocusForBackgroundTransition() {
  clearBrowserTextInputFocus();
}

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
      textEditingController.detachFromIme();
      textEditingController.selection = const TextSelection.collapsed(
        offset: -1,
      );
      textEditingController.composingRegion = TextRange.empty;
      removeEditingOverlayControls();
    });
  }, debugLabel: 'clear text input for background transition');
}
