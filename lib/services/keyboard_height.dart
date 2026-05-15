import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'keyboard_viewport_bridge.dart';
import 'keyboard_viewport_bridge_stub.dart'
    if (dart.library.html) 'keyboard_viewport_bridge_web.dart';

class KeyboardHeight extends InheritedNotifier<ValueNotifier<double>> {
  const KeyboardHeight({
    super.key,
    required ValueNotifier<double> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static double of(BuildContext context) {
    final KeyboardHeight? inherited =
        context.dependOnInheritedWidgetOfExactType<KeyboardHeight>();
    final ValueNotifier<double>? notifier = inherited?.notifier;
    if (notifier == null) {
      return MediaQuery.of(context).viewInsets.bottom;
    }
    return notifier.value;
  }
}

class KeyboardHeightObserver extends StatefulWidget {
  const KeyboardHeightObserver({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<KeyboardHeightObserver> createState() =>
      _KeyboardHeightObserverState();
}

class _KeyboardHeightObserverState extends State<KeyboardHeightObserver>
    with WidgetsBindingObserver {
  final ValueNotifier<double> _keyboardHeight = ValueNotifier<double>(0);
  final KeyboardViewportBridge _viewportBridge = createKeyboardViewportBridge();

  bool _isQueued = false;
  bool _isDisposed = false;
  bool _hadPrimaryFocusBeforePause = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewportBridge.start(_scheduleUpdate);
    _scheduleUpdate();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _viewportBridge.stop();
    WidgetsBinding.instance.removeObserver(this);
    _keyboardHeight.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _scheduleUpdate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _hadPrimaryFocusBeforePause =
          FocusManager.instance.primaryFocus != null;
      return;
    }

    if (state == AppLifecycleState.resumed) {
      if (_hadPrimaryFocusBeforePause) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
      _scheduleStabilizationBurst();
    }
  }

  void _scheduleStabilizationBurst() {
    _scheduleUpdate();
    for (final int delayMs in <int>[16, 80, 180]) {
      Future<void>.delayed(Duration(milliseconds: delayMs), _scheduleUpdate);
    }
  }

  void _scheduleUpdate() {
    if (_isDisposed || _isQueued) {
      return;
    }
    _isQueued = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _isQueued = false;
      if (_isDisposed) {
        return;
      }
      _recomputeKeyboardHeight();
    });
  }

  void _recomputeKeyboardHeight() {
    final view = View.of(context);
    final double screenHeight = view.physicalSize.height / view.devicePixelRatio;

    final double flutterInset = math.max(
      0,
      view.viewInsets.bottom / view.devicePixelRatio,
    );
    final double webInset = math.max(0, _viewportBridge.estimatedBottomInset);

    final double clampedFlutterInset = _clampInset(flutterInset, screenHeight);
    final double clampedWebInset = _clampInset(webInset, screenHeight);
    final double nextValue = math.max(clampedFlutterInset, clampedWebInset);

    if ((nextValue - _keyboardHeight.value).abs() > 0.5) {
      _keyboardHeight.value = nextValue;
    }
  }

  double _clampInset(double inset, double screenHeight) {
    final double maxAllowed = screenHeight * 0.6;
    return inset.clamp(0, maxAllowed);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardHeight(
      notifier: _keyboardHeight,
      child: widget.child,
    );
  }
}
