import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tw_scrollbar.dart';

/// Composes a scrollable content area with the Tw scrollbar treatment.
class TwScrollArea extends StatefulWidget {
  const TwScrollArea({
    super.key,
    required ScrollController controller,
    required Widget child,
    this.activationPulse,
    this.track,
    this.overlayChildren = const <Widget>[],
    this.hideSystemScrollbars = true,
    this.thumbColor = TwScrollbarDefaults.thumbColor,
    this.thumbInactiveColor = TwScrollbarDefaults.thumbInactiveColor,
    this.trackColor = TwScrollbarDefaults.trackColor,
    this.thickness = TwScrollbarDefaults.thickness,
    this.minThumbLength = TwScrollbarDefaults.minThumbLength,
    this.crossAxisMargin = TwScrollbarDefaults.crossAxisMargin,
    this.mainAxisMargin = TwScrollbarDefaults.mainAxisMargin,
    this.radius = TwScrollbarDefaults.radius,
    this.padding,
    this.physics = const ClampingScrollPhysics(),
    this.excludeScrollViewFromSelection = false,
    this.enableDesktopKeyboardScroll = false,
    this.keyboardScrollLineStep = 120,
    this.isKeyboardScrollBlocked,
    this.onDesktopTap,
    this.thumbVisibility = true,
    this.interactive = true,
    this.trackVisibility = false,
    this.fadeDuration = TwScrollbarDefaults.thumbFadeDuration,
    this.timeToFade = TwScrollbarDefaults.thumbFadeOutDelay,
  }) : _controller = controller,
       _child = child,
      _scrollDirection = null,
      _primary = false;

  factory TwScrollArea.scrollView({
    Key? key,
    ScrollController? controller,
    required Widget child,
    Axis scrollDirection = Axis.vertical,
    bool primary = false,
    ValueListenable<Object?>? activationPulse,
    Widget? track,
    List<Widget> overlayChildren = const <Widget>[],
    bool hideSystemScrollbars = true,
    Color thumbColor = TwScrollbarDefaults.thumbColor,
    Color thumbInactiveColor = TwScrollbarDefaults.thumbInactiveColor,
    Color trackColor = TwScrollbarDefaults.trackColor,
    double thickness = TwScrollbarDefaults.thickness,
    double minThumbLength = TwScrollbarDefaults.minThumbLength,
    double crossAxisMargin = TwScrollbarDefaults.crossAxisMargin,
    double mainAxisMargin = TwScrollbarDefaults.mainAxisMargin,
    Radius radius = TwScrollbarDefaults.radius,
    EdgeInsetsGeometry? padding,
    ScrollPhysics physics = const ClampingScrollPhysics(),
    bool excludeScrollViewFromSelection = false,
    bool enableDesktopKeyboardScroll = true,
    double keyboardScrollLineStep = 120,
    ValueListenable<bool>? isKeyboardScrollBlocked,
    VoidCallback? onDesktopTap,
    bool thumbVisibility = true,
    bool interactive = true,
    bool trackVisibility = false,
    Duration fadeDuration = TwScrollbarDefaults.thumbFadeDuration,
    Duration timeToFade = TwScrollbarDefaults.thumbFadeOutDelay,
  }) {
    return TwScrollArea._scrollView(
      key: key,
      controller: controller,
      scrollDirection: scrollDirection,
      primary: primary,
      activationPulse: activationPulse,
      track: track,
      overlayChildren: overlayChildren,
      hideSystemScrollbars: hideSystemScrollbars,
      thumbColor: thumbColor,
      thumbInactiveColor: thumbInactiveColor,
      trackColor: trackColor,
      thickness: thickness,
      minThumbLength: minThumbLength,
      crossAxisMargin: crossAxisMargin,
      mainAxisMargin: mainAxisMargin,
      radius: radius,
      padding: padding,
      physics: physics,
      excludeScrollViewFromSelection: excludeScrollViewFromSelection,
      enableDesktopKeyboardScroll: enableDesktopKeyboardScroll,
      keyboardScrollLineStep: keyboardScrollLineStep,
      isKeyboardScrollBlocked: isKeyboardScrollBlocked,
      onDesktopTap: onDesktopTap,
      thumbVisibility: thumbVisibility,
      interactive: interactive,
      trackVisibility: trackVisibility,
      fadeDuration: fadeDuration,
      timeToFade: timeToFade,
      child: child,
    );
  }

  const TwScrollArea._scrollView({
    super.key,
    ScrollController? controller,
    required Widget child,
    required Axis scrollDirection,
    required bool primary,
    this.activationPulse,
    this.track,
    this.overlayChildren = const <Widget>[],
    this.hideSystemScrollbars = true,
    this.thumbColor = TwScrollbarDefaults.thumbColor,
    this.thumbInactiveColor = TwScrollbarDefaults.thumbInactiveColor,
    this.trackColor = TwScrollbarDefaults.trackColor,
    this.thickness = TwScrollbarDefaults.thickness,
    this.minThumbLength = TwScrollbarDefaults.minThumbLength,
    this.crossAxisMargin = TwScrollbarDefaults.crossAxisMargin,
    this.mainAxisMargin = TwScrollbarDefaults.mainAxisMargin,
    this.radius = TwScrollbarDefaults.radius,
    this.padding,
    this.physics = const ClampingScrollPhysics(),
    this.excludeScrollViewFromSelection = false,
    this.enableDesktopKeyboardScroll = false,
    this.keyboardScrollLineStep = 120,
    this.isKeyboardScrollBlocked,
    this.onDesktopTap,
    this.thumbVisibility = true,
    this.interactive = true,
    this.trackVisibility = false,
    this.fadeDuration = TwScrollbarDefaults.thumbFadeDuration,
    this.timeToFade = TwScrollbarDefaults.thumbFadeOutDelay,
  }) : _controller = controller,
       _child = child,
      _scrollDirection = scrollDirection,
      _primary = primary;

  final ScrollController? _controller;
  final Widget _child;
  final Axis? _scrollDirection;
  final bool _primary;
  final ValueListenable<Object?>? activationPulse;
  final Widget? track;
  final List<Widget> overlayChildren;
  final bool hideSystemScrollbars;

  final Color thumbColor;
  final Color thumbInactiveColor;
  final Color trackColor;
  final double thickness;
  final double minThumbLength;
  final double crossAxisMargin;
  final double mainAxisMargin;
  final Radius radius;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics physics;
  final bool excludeScrollViewFromSelection;
  final bool enableDesktopKeyboardScroll;
  final double keyboardScrollLineStep;
  final ValueListenable<bool>? isKeyboardScrollBlocked;
  final VoidCallback? onDesktopTap;
  final bool thumbVisibility;
  final bool interactive;
  final bool trackVisibility;
  final Duration fadeDuration;
  final Duration timeToFade;

  @override
  State<TwScrollArea> createState() => _TwScrollAreaState();
}

class _TwScrollAreaState extends State<TwScrollArea> {
  ScrollController? _ownedController;
  FocusNode? _keyboardScrollFocusNode;
  Timer? _keyboardScrollTimer;

  ScrollController get _effectiveController {
    return widget._controller ?? (_ownedController ??= ScrollController());
  }

  @override
  void initState() {
    super.initState();
    _configureKeyboardScrollFocusNode();
  }

  @override
  void didUpdateWidget(covariant TwScrollArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._controller == null && widget._controller != null) {
      _ownedController?.dispose();
      _ownedController = null;
    }
    if (oldWidget.enableDesktopKeyboardScroll !=
            widget.enableDesktopKeyboardScroll ||
        oldWidget._controller != widget._controller ||
        oldWidget.isKeyboardScrollBlocked != widget.isKeyboardScrollBlocked) {
      _disposeKeyboardScrollFocusNode();
      _configureKeyboardScrollFocusNode();
    }
  }

  @override
  void dispose() {
    _disposeKeyboardScrollFocusNode();
    _ownedController?.dispose();
    super.dispose();
  }

  void _configureKeyboardScrollFocusNode() {
    if (!widget.enableDesktopKeyboardScroll) {
      return;
    }
    _keyboardScrollFocusNode = FocusNode(debugLabel: 'tw-scroll-area');
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

    final controller = _effectiveController;
    if (!controller.hasClients) {
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
    final controller = _effectiveController;
    Widget child = widget._scrollDirection == null
        ? widget._child
        : _buildScrollView(controller);

    if (widget.enableDesktopKeyboardScroll || widget.onDesktopTap != null) {
      child = GestureDetector(
        behavior: HitTestBehavior.translucent,
        supportedDevices: const <PointerDeviceKind>{PointerDeviceKind.mouse},
        onTap: () {
          _keyboardScrollFocusNode?.requestFocus();
          widget.onDesktopTap?.call();
        },
        child: child,
      );
    }

    if (_keyboardScrollFocusNode != null) {
      child = KeyboardListener(
        focusNode: _keyboardScrollFocusNode!,
        autofocus: false,
        onKeyEvent: (_) {
          // KeyboardListener is used here for focus ownership only.
          // Actual scroll handling is timer-driven in _handleKeyboardScrollTick.
        },
        child: child,
      );
    }

    final scrollbar = TwScrollbar(
      controller: controller,
      activationPulse: widget.activationPulse,
      thumbColor: widget.thumbColor,
      thumbInactiveColor: widget.thumbInactiveColor,
      trackColor: widget.trackColor,
      thickness: widget.thickness,
      minThumbLength: widget.minThumbLength,
      crossAxisMargin: widget.crossAxisMargin,
      mainAxisMargin: widget.mainAxisMargin,
      radius: widget.radius,
      padding: widget.padding,
      physics: widget.physics,
      thumbVisibility: widget.thumbVisibility,
      interactive: widget.interactive,
      trackVisibility: widget.trackVisibility,
      fadeDuration: widget.fadeDuration,
      timeToFade: widget.timeToFade,
      child: child,
    );

    final area = widget.track == null && widget.overlayChildren.isEmpty
        ? scrollbar
        : Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              if (widget.track != null) widget.track!,
              scrollbar,
              ...widget.overlayChildren,
            ],
          );

    if (!widget.hideSystemScrollbars) {
      return area;
    }

    return ScrollConfiguration(
      behavior: const TwNoScrollbarBehavior(),
      child: area,
    );
  }

  Widget _buildScrollView(
    ScrollController controller,
  ) {
    final usePrimary =
        widget._scrollDirection == Axis.vertical && widget._primary;
    Widget scrollView = SingleChildScrollView(
      controller: usePrimary ? null : controller,
      primary: usePrimary,
      scrollDirection: widget._scrollDirection!,
      physics: widget.physics,
      child: widget._child,
    );
    if (widget.excludeScrollViewFromSelection) {
      scrollView = SelectionContainer.disabled(child: scrollView);
    }
    if (!usePrimary) {
      return scrollView;
    }
    return PrimaryScrollController(controller: controller, child: scrollView);
  }
}
