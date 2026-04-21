import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shell/chat_keyboard_scroll_target.dart';

class ArrowKeyScrollWrapper extends StatefulWidget {
  const ArrowKeyScrollWrapper({
    super.key,
    required this.controller,
    required this.child,
    this.lineStep = 120,
    this.onPointerDown,
  });

  final ScrollController controller;
  final Widget child;
  final double lineStep;
  final VoidCallback? onPointerDown;

  @override
  State<ArrowKeyScrollWrapper> createState() => _ArrowKeyScrollWrapperState();
}

class _ArrowKeyScrollWrapperState extends State<ArrowKeyScrollWrapper> {
  late final FocusNode _focusNode;
  Timer? _scrollTimer;

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
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          ChatKeyboardScrollTarget.setChatTarget(false);
          widget.onPointerDown?.call();
          _focusNode.requestFocus();
        },
        child: widget.child,
      ),
    );
  }
}
