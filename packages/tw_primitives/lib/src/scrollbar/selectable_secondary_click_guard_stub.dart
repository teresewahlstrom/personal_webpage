import 'dart:ui';

typedef SelectableSecondaryClickGuardPredicate = bool Function();
typedef SelectableSecondaryClickGuardBoundsResolver = Rect? Function();

class TwSelectableSecondaryClickGuard {
  TwSelectableSecondaryClickGuard({
    required SelectableSecondaryClickGuardPredicate shouldGuard,
    required SelectableSecondaryClickGuardBoundsResolver boundsResolver,
  });

  void attach() {}

  void detach() {}
}