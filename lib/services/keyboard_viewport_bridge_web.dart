// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import 'keyboard_viewport_bridge.dart';

KeyboardViewportBridge createKeyboardViewportBridge() {
  return _WebKeyboardViewportBridge();
}

class _WebKeyboardViewportBridge implements KeyboardViewportBridge {
  KeyboardViewportChangeCallback? _onChange;
  StreamSubscription<html.Event>? _viewportResizeSubscription;
  StreamSubscription<html.Event>? _viewportScrollSubscription;
  StreamSubscription<html.Event>? _windowResizeSubscription;

  @override
  double get estimatedBottomInset {
    final html.VisualViewport? visualViewport = html.window.visualViewport;
    if (visualViewport == null) {
      return 0;
    }

    final num? windowInnerHeight = html.window.innerHeight;
    if (windowInnerHeight == null) {
      return 0;
    }

    final num? visualViewportHeight = visualViewport.height;
    final num? visualViewportOffsetTop = visualViewport.offsetTop;
    if (visualViewportHeight == null || visualViewportOffsetTop == null) {
      return 0;
    }

    final double rawInset =
        windowInnerHeight.toDouble() -
        visualViewportHeight.toDouble() -
        visualViewportOffsetTop.toDouble();
    if (rawInset.isNaN || !rawInset.isFinite) {
      return 0;
    }

    return rawInset < 0 ? 0 : rawInset;
  }

  @override
  void start(KeyboardViewportChangeCallback onChange) {
    _onChange = onChange;

    final html.VisualViewport? visualViewport = html.window.visualViewport;
    if (visualViewport != null) {
      _viewportResizeSubscription = visualViewport.onResize.listen((_) {
        _onChange?.call();
      });
      _viewportScrollSubscription = visualViewport.onScroll.listen((_) {
        _onChange?.call();
      });
    }

    _windowResizeSubscription = html.window.onResize.listen((_) {
      _onChange?.call();
    });
  }

  @override
  void stop() {
    _viewportResizeSubscription?.cancel();
    _viewportResizeSubscription = null;

    _viewportScrollSubscription?.cancel();
    _viewportScrollSubscription = null;

    _windowResizeSubscription?.cancel();
    _windowResizeSubscription = null;

    _onChange = null;
  }
}
