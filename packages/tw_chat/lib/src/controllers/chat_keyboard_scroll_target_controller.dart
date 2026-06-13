import 'package:flutter/foundation.dart';

class ChatKeyboardScrollTargetController {
  ChatKeyboardScrollTargetController({bool initialIsChatTarget = false})
    : _isChatTarget = ValueNotifier<bool>(initialIsChatTarget);

  final ValueNotifier<bool> _isChatTarget;

  ValueListenable<bool> get isChatTargetListenable => _isChatTarget;

  bool get isChatTarget => _isChatTarget.value;

  void setChatTarget(bool value) {
    if (_isChatTarget.value == value) {
      return;
    }
    _isChatTarget.value = value;
  }

  void dispose() {
    _isChatTarget.dispose();
  }
}