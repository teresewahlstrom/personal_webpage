import 'dart:ui';

typedef ChatSelectionGuardPredicate = bool Function();
typedef ChatSelectionGuardBoundsResolver = Rect? Function();

class ChatWebSecondaryClickSelectionGuard {
  ChatWebSecondaryClickSelectionGuard({
    required ChatSelectionGuardPredicate shouldGuard,
    required ChatSelectionGuardBoundsResolver boundsResolver,
  });

  void attach() {}

  void detach() {}
}
