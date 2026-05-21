import 'dart:js_interop';
import 'dart:ui';

import 'package:web/web.dart' as web;

typedef ChatSelectionGuardPredicate = bool Function();
typedef ChatSelectionGuardBoundsResolver = Rect? Function();

class ChatWebSecondaryClickSelectionGuard {
  ChatWebSecondaryClickSelectionGuard({
    required ChatSelectionGuardPredicate shouldGuard,
    required ChatSelectionGuardBoundsResolver boundsResolver,
  }) : _shouldGuard = shouldGuard,
       _boundsResolver = boundsResolver;

  final ChatSelectionGuardPredicate _shouldGuard;
  final ChatSelectionGuardBoundsResolver _boundsResolver;
  JSFunction? _pointerDownListener;
  JSBoolean? _captureOptions;

  void attach() {
    if (_pointerDownListener != null) {
      return;
    }
    _pointerDownListener = _handlePointerDown.toJS;
    final captureOptions = true.toJS;
    _captureOptions = captureOptions;
    web.document.addEventListener(
      'pointerdown',
      _pointerDownListener,
      captureOptions,
    );
  }

  void detach() {
    final listener = _pointerDownListener;
    final captureOptions = _captureOptions;
    if (listener == null || captureOptions == null) {
      return;
    }
    web.document.removeEventListener(
      'pointerdown',
      listener,
      captureOptions,
    );
    _pointerDownListener = null;
    _captureOptions = null;
  }

  void _handlePointerDown(web.Event event) {
    if (!_shouldGuard() || !event.isA<web.PointerEvent>()) {
      return;
    }

    final pointerEvent = event as web.PointerEvent;
    if (pointerEvent.button != 2) {
      return;
    }

    final bounds = _boundsResolver();
    if (bounds == null ||
        !bounds.contains(
          Offset(
            pointerEvent.clientX.toDouble(),
            pointerEvent.clientY.toDouble(),
          ),
        )) {
      return;
    }

    // Let the browser context menu open, but keep Flutter's SelectableRegion
    // from treating the secondary click as a new selection gesture.
    event.stopImmediatePropagation();
  }
}
