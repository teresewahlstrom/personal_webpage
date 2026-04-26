import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shell/_chat_keyboard_scroll_target.dart';

class ArrowKeyScrollWrapper extends StatefulWidget {
  const ArrowKeyScrollWrapper({
    super.key,
    required this.controller,
    required this.child,
    this.lineStep = 120,
    this.onTap,
  });

  final ScrollController controller;
  final Widget child;
  final double lineStep;
  final VoidCallback? onTap;

  @override
  State<ArrowKeyScrollWrapper> createState() => _ArrowKeyScrollWrapperState();
}

class _ArrowKeyScrollWrapperState extends State<ArrowKeyScrollWrapper> {
  late final FocusNode _focusNode;
  Timer? _scrollTimer;
  Offset? _touchTapDownPosition;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: "arrow-key-scroll");
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && _scrollTimer == null) {
      _scrollTimer = Timer.periodic(
        const Duration(milliseconds: 250),
        (_) => _handleScroll(),
      );
    } else if (!_focusNode.hasFocus) {
      _scrollTimer?.cancel();
      _scrollTimer = null;
    }
  }

  void _handleScroll() {
    if (ChatKeyboardScrollTarget.isChatTarget.value) {
      return;
    }

    if (!widget.controller.hasClients) {
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

    final ScrollPosition position = widget.controller.position;
    final double pageStep = position.viewportDimension * 0.8;

    double? nextOffset;
    if (pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      nextOffset = position.pixels + widget.lineStep;
    } else if (pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      nextOffset = position.pixels - widget.lineStep;
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

    widget.controller.jumpTo(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (_) {
        // KeyboardListener is used here for focus management only.
        // Actual scroll handling is done in _handleScroll via the timer.
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        // Only participate in the gesture arena for mouse/pointer events.
        // Touch events are deliberately excluded so that the GestureDetector
        // never competes with the text-field caret-handle tap recognizer on
        // touch/mobile devices.  Without this restriction the translucent
        // GestureDetector can win the arena for a tap aimed at the caret
        // handle (which extends into the page-content area in the overlay),
        // preventing the paste / select-all contextual toolbar from appearing.
        // Touch taps are handled separately in the Listener below.
        supportedDevices: const {PointerDeviceKind.mouse},
        onTap: () {
          // Request focus on confirmed mouse tap only, not on every
          // pointer-down. Requesting focus on pointer-down steals it from any
          // active SelectableRegion, which clears text selection even when the
          // user is just starting a drag-scroll.  A confirmed tap (no
          // significant movement) is the right moment to reclaim
          // keyboard-scroll focus and to clear the selection via the optional
          // onTap callback.
          _focusNode.requestFocus();
          widget.onTap?.call();
        },
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            ChatKeyboardScrollTarget.setChatTarget(false);
            // Track touch pointer-down so we can detect a confirmed tap in
            // onPointerUp without entering the gesture arena (which would
            // compete with text-selection caret handles on touch devices).
            if (event.kind == PointerDeviceKind.touch) {
              _touchTapDownPosition = event.localPosition;
            }
          },
          onPointerUp: (event) {
            if (event.kind != PointerDeviceKind.touch) {
              return;
            }
            final downPos = _touchTapDownPosition;
            _touchTapDownPosition = null;
            if (downPos == null) {
              return;
            }
            // Only treat as a tap if the pointer did not travel more than the
            // standard touch-slop threshold (to distinguish taps from
            // drag-scrolls).
            if ((event.localPosition - downPos).distance > kTouchSlop) {
              return;
            }
            // Clear page text selection on a confirmed touch tap.  We
            // deliberately do NOT call _focusNode.requestFocus() here because:
            //   1. Touch/mobile users scroll with swipe gestures, not arrow
            //      keys, so keyboard-scroll focus is not needed.
            //   2. Requesting focus would steal it from the chat text field and
            //      could interfere with text-selection caret handle gestures.
            widget.onTap?.call();
          },
          onPointerCancel: (_) {
            _touchTapDownPosition = null;
          },
          child: widget.child,
        ),
      ),
    );
  }
}
