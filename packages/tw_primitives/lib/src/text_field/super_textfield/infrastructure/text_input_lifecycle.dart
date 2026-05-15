import 'package:flutter/widgets.dart';
import 'package:tw_primitives/src/text_field/infrastructure/platforms/web/browser_text_input_stub.dart'
    if (dart.library.html) 'package:tw_primitives/src/text_field/infrastructure/platforms/web/browser_text_input_web.dart';

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
