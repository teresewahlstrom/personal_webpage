import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TwScrollSurfaceInteraction extends StatefulWidget {
  const TwScrollSurfaceInteraction({
    super.key,
    required this.child,
    this.controller,
    this.enableDesktopKeyboardScroll = false,
    this.keyboardScrollLineStep = 120,
    this.isKeyboardScrollBlocked,
    this.onDesktopTap,
    this.onPointerDown,
    this.onPointerUp,
    this.onPointerCancel,
  });

  final Widget child;
  final ScrollController? controller;
  final bool enableDesktopKeyboardScroll;
  final double keyboardScrollLineStep;
  final ValueListenable<bool>? isKeyboardScrollBlocked;
  final VoidCallback? onDesktopTap;
  final VoidCallback? onPointerDown;
  final VoidCallback? onPointerUp;
  final VoidCallback? onPointerCancel;

  @override
  State<TwScrollSurfaceInteraction> createState() =>
      _TwScrollSurfaceInteractionState();
}

class _TwScrollSurfaceInteractionState extends State<TwScrollSurfaceInteraction> {
  FocusNode? _keyboardScrollFocusNode;
  Timer? _keyboardScrollTimer;

  @override
  void initState() {
    super.initState();
    _configureKeyboardScrollFocusNode();
  }

  @override
  void didUpdateWidget(covariant TwScrollSurfaceInteraction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enableDesktopKeyboardScroll !=
            widget.enableDesktopKeyboardScroll ||
        oldWidget.controller != widget.controller ||
        oldWidget.isKeyboardScrollBlocked != widget.isKeyboardScrollBlocked) {
      _disposeKeyboardScrollFocusNode();
      _configureKeyboardScrollFocusNode();
    }
  }

  @override
  void dispose() {
    _disposeKeyboardScrollFocusNode();
    super.dispose();
  }

  void _configureKeyboardScrollFocusNode() {
    if (!widget.enableDesktopKeyboardScroll) {
      return;
    }
    _keyboardScrollFocusNode = FocusNode(debugLabel: 'tw-scroll-surface');
    _keyboardScrollFocusNode!.addListener(_handleKeyboardScrollFocusChange);
  }

  void _disposeKeyboardScrollFocusNode() {
    _keyboardScrollTimer?.cancel();
    _keyboardScrollTimer = null;
    _keyboardScrollFocusNode?.removeListener(_handleKeyboardScrollFocusChange);
    _keyboardScrollFocusNode?.dispose();
    _keyboardScrollFocusNode = null;
  }

  void _handleKeyboardScrollFocusChange() {
    final focusNode = _keyboardScrollFocusNode;
    if (focusNode == null) {
      return;
    }

    if (focusNode.hasFocus && _keyboardScrollTimer == null) {
      _keyboardScrollTimer = Timer.periodic(
        const Duration(milliseconds: 33),
        (_) => _handleKeyboardScrollTick(),
      );
    } else if (!focusNode.hasFocus) {
      _keyboardScrollTimer?.cancel();
      _keyboardScrollTimer = null;
    }
  }

  void _handleKeyboardScrollTick() {
    if (widget.isKeyboardScrollBlocked?.value ?? false) {
      return;
    }

    final controller = widget.controller;
    if (controller == null || !controller.hasClients) {
      return;
    }

    final Set<LogicalKeyboardKey> pressedKeys =
        HardwareKeyboard.instance.logicalKeysPressed;
    final bool hasModifier =
        pressedKeys.contains(LogicalKeyboardKey.controlLeft) ||
            pressedKeys.contains(LogicalKeyboardKey.controlRight) ||
            pressedKeys.contains(LogicalKeyboardKey.metaLeft) ||
            pressedKeys.contains(LogicalKeyboardKey.metaRight) ||
            pressedKeys.contains(LogicalKeyboardKey.altLeft) ||
            pressedKeys.contains(LogicalKeyboardKey.altRight);
    if (hasModifier) {
      return;
    }

    final ScrollPosition position = controller.position;
    final double pageStep = position.viewportDimension * 0.8;

    double? nextOffset;
    if (pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      nextOffset = position.pixels + widget.keyboardScrollLineStep;
    } else if (pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      nextOffset = position.pixels - widget.keyboardScrollLineStep;
    } else if (pressedKeys.contains(LogicalKeyboardKey.pageDown)) {
      nextOffset = position.pixels + pageStep;
    } else if (pressedKeys.contains(LogicalKeyboardKey.pageUp)) {
      nextOffset = position.pixels - pageStep;
    } else if (pressedKeys.contains(LogicalKeyboardKey.home)) {
      nextOffset = position.minScrollExtent;
    } else if (pressedKeys.contains(LogicalKeyboardKey.end)) {
      nextOffset = position.maxScrollExtent;
    }

    if (nextOffset == null) {
      return;
    }

    final double clamped = nextOffset.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    controller.animateTo(
      clamped,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget result = widget.child;

    if (widget.onPointerDown != null ||
        widget.onPointerUp != null ||
        widget.onPointerCancel != null) {
      result = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown:
            widget.onPointerDown == null ? null : (_) => widget.onPointerDown!(),
        onPointerUp:
            widget.onPointerUp == null ? null : (_) => widget.onPointerUp!(),
        onPointerCancel: widget.onPointerCancel == null
            ? null
            : (_) => widget.onPointerCancel!(),
        child: result,
      );
    }

    if (widget.enableDesktopKeyboardScroll || widget.onDesktopTap != null) {
      result = GestureDetector(
        behavior: HitTestBehavior.translucent,
        supportedDevices: const <PointerDeviceKind>{PointerDeviceKind.mouse},
        onTap: () {
          _keyboardScrollFocusNode?.requestFocus();
          widget.onDesktopTap?.call();
        },
        child: result,
      );
    }

    if (_keyboardScrollFocusNode != null) {
      result = KeyboardListener(
        focusNode: _keyboardScrollFocusNode!,
        autofocus: false,
        onKeyEvent: (_) {
          // KeyboardListener is used here for focus ownership only.
          // Actual scroll handling is timer-driven in _handleKeyboardScrollTick.
        },
        child: result,
      );
    }

    return result;
  }
}