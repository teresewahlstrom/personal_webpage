import 'package:flutter/foundation.dart';

class ChatKeyboardScrollTarget {
  ChatKeyboardScrollTarget._();

  static final ValueNotifier<bool> isChatTarget = ValueNotifier<bool>(false);

  static void setChatTarget(bool value) {
    if (isChatTarget.value == value) {
      return;
    }
    isChatTarget.value = value;
  }
}
