import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide ScrollbarPainter;
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:super_editor/src/infrastructure/flutter/scrollbar.dart'
    show
        RawScrollbarWithCustomPhysics,
        RawScrollbarWithCustomPhysicsState,
        ScrollbarPainter;

import 'skin.dart';

class ChatScrollbar {
  const ChatScrollbar._();

  static const visibilityOverflowThreshold = 0.5;
  static const hoverActivationInset = 12.0;
  static Color thumbColor(BuildContext context) =>
      ChatSkin.dataOf(context).colors.scrollbarThumb;
  static Color thumbInactiveColor(BuildContext context) =>
      ChatSkin.dataOf(context).colors.scrollbarThumbInactive;
  static Color trackColor(BuildContext context) =>
      ChatSkin.dataOf(context).colors.scrollbarTrack;
  static const inputTrackBorder = Border();
  static const thumbFadeDuration = Duration(milliseconds: 220);
  static const thumbFadeOutDelay = Duration(milliseconds: 700);

  static Widget buildTrack({
    required BuildContext context,
    required double thickness,
    required double crossAxisInset,
    double topInset = 0,
    double bottomInset = 0,
  }) {
    final tokens = ChatSkin.tokens;
    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.only(
          top: topInset,
          bottom: bottomInset,
          right: crossAxisInset + tokens.scrollbarTrackLeftShift,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: thickness,
            decoration: BoxDecoration(
              color: trackColor(context),
              borderRadius: tokens.scrollbarTrackRadius,
              border: inputTrackBorder,
            ),
          ),
        ),
      ),
    );
  }
}

class ChatNoScrollbarBehavior extends MaterialScrollBehavior {
  const ChatNoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class ChatFadingScrollbar extends StatelessWidget {
  const ChatFadingScrollbar({
    super.key,
    required this.controller,
    required this.child,
    required this.thickness,
    required this.minThumbLength,
    required this.crossAxisMargin,
    required this.mainAxisMargin,
    required this.radius,
    this.padding,
    this.thumbVisibility = true,
    this.interactive = true,
    this.trackVisibility = false,
  });

  final ScrollController controller;
  final Widget child;
  final double thickness;
  final double minThumbLength;
  final double crossAxisMargin;
  final double mainAxisMargin;
  final Radius radius;
  final EdgeInsetsGeometry? padding;
  final bool thumbVisibility;
  final bool interactive;
  final bool trackVisibility;

  @override
  Widget build(BuildContext context) {
    return _ChatScrollbar(
      controller: controller,
      thumbVisibility: thumbVisibility,
      interactive: interactive,
      trackVisibility: trackVisibility,
      thickness: thickness,
      minThumbLength: minThumbLength,
      crossAxisMargin: crossAxisMargin,
      mainAxisMargin: mainAxisMargin,
      padding: padding?.resolve(Directionality.of(context)),
      radius: radius,
      child: child,
    );
  }
}

class _ChatScrollbar extends RawScrollbarWithCustomPhysics {
  const _ChatScrollbar({
    required super.controller,
    required super.child,
    required super.thumbVisibility,
    required super.interactive,
    required super.trackVisibility,
    required double thickness,
    required double minThumbLength,
    required double crossAxisMargin,
    required double mainAxisMargin,
    required Radius radius,
    required EdgeInsets? padding,
  }) : super(
         physics: const ClampingScrollPhysics(),
         thickness: thickness,
         minThumbLength: minThumbLength,
         minOverscrollLength: minThumbLength,
         crossAxisMargin: crossAxisMargin,
         mainAxisMargin: mainAxisMargin,
         padding: padding,
         radius: radius,
         thumbColor: Colors.transparent,
         trackColor: Colors.transparent,
         trackBorderColor: Colors.transparent,
         fadeDuration: ChatScrollbar.thumbFadeDuration,
         timeToFade: ChatScrollbar.thumbFadeOutDelay,
        );

  @override
  _ChatScrollbarState createState() => _ChatScrollbarState();
}

class _ChatScrollbarState
    extends RawScrollbarWithCustomPhysicsState<_ChatScrollbar> {
  Timer? _thumbFadeTimer;
  late final AnimationController _thumbOpacityController;
  late final ScrollbarPainter _activeScrollbarPainter;
  ScrollController? _listenedController;
  bool _isScrollbarHovered = false;
  bool _isScrollbarPressed = false;
  bool _isUserScrollActive = false;

  bool get _isScrollbarActive =>
      _isScrollbarHovered || _isScrollbarPressed || _isUserScrollActive;

  ScrollController? get _controller => widget.controller;
  double get _scrollbarThickness => widget.thickness!;
  bool get _showsThumb => widget.thumbVisibility ?? false;
  bool get _showsTrack => widget.trackVisibility ?? false;

  @override
  bool get showScrollbar => _showsThumb;

  @override
  bool get enableGestures => widget.interactive ?? true;

  @override
  void initState() {
    super.initState();
    _thumbOpacityController = AnimationController(
      vsync: this,
      duration: ChatScrollbar.thumbFadeDuration,
      value: 0,
    );
    _thumbOpacityController.addListener(updateScrollbarPainter);
    _activeScrollbarPainter = ScrollbarPainter(
      color: Colors.transparent,
      fadeoutOpacityAnimation: _thumbOpacityController,
      trackColor: Colors.transparent,
      trackBorderColor: Colors.transparent,
      thickness: _scrollbarThickness,
      radius: widget.radius,
      mainAxisMargin: widget.mainAxisMargin,
      crossAxisMargin: widget.crossAxisMargin,
      minLength: widget.minThumbLength,
      minOverscrollLength: widget.minThumbLength,
      padding: widget.padding ?? EdgeInsets.zero,
      ignorePointer: true,
    );
    _attachControllerListener(_controller);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncActiveScrollbarPainterFromController();
    });
  }

  @override
  void updateScrollbarPainter() {
    final inactiveThumbColor = _showsThumb
        ? ChatScrollbar.thumbInactiveColor(context)
        : Colors.transparent;
    final activeThumbColor = _showsThumb
        ? ChatScrollbar.thumbColor(context)
        : Colors.transparent;
    scrollbarPainter
      ..color = inactiveThumbColor
      ..trackColor = _showsTrack
          ? ChatScrollbar.trackColor(context)
          : Colors.transparent
      ..trackBorderColor = Colors.transparent
      ..textDirection = Directionality.of(context)
      ..thickness = _scrollbarThickness
      ..radius = widget.radius
      ..crossAxisMargin = widget.crossAxisMargin
      ..mainAxisMargin = widget.mainAxisMargin
      ..minLength = widget.minThumbLength
      ..minOverscrollLength = widget.minThumbLength
      ..padding = widget.padding ?? EdgeInsets.zero
      ..ignorePointer = !enableGestures;
    _activeScrollbarPainter
      ..color = activeThumbColor
      ..trackColor = Colors.transparent
      ..trackBorderColor = Colors.transparent
      ..textDirection = Directionality.of(context)
      ..thickness = _scrollbarThickness
      ..radius = widget.radius
      ..crossAxisMargin = widget.crossAxisMargin
      ..mainAxisMargin = widget.mainAxisMargin
      ..minLength = widget.minThumbLength
      ..minOverscrollLength = widget.minThumbLength
      ..padding = widget.padding ?? EdgeInsets.zero
      ..ignorePointer = true;
  }

  @override
  void didUpdateWidget(covariant _ChatScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachControllerListener();
      _attachControllerListener(_controller);
      _syncActiveScrollbarPainterFromController();
    }
  }

  @override
  void handleHover(PointerHoverEvent event) {
    super.handleHover(event);
    final isHovered = isPointerOverScrollbar(
      event.position,
      event.kind,
      forHover: true,
    );
    _setScrollbarInteraction(isHovered: isHovered);
  }

  @override
  void handleHoverExit(PointerExitEvent event) {
    super.handleHoverExit(event);
    _setScrollbarInteraction(isHovered: false);
  }

  @override
  void handleThumbPressStart(Offset localPosition) {
    super.handleThumbPressStart(localPosition);
    _setScrollbarInteraction(isPressed: true);
  }

  @override
  void handleThumbPressEnd(Offset localPosition, Velocity velocity) {
    super.handleThumbPressEnd(localPosition, velocity);
    _setScrollbarInteraction(isPressed: false);
  }

  @override
  void dispose() {
    _thumbFadeTimer?.cancel();
    _thumbOpacityController.removeListener(updateScrollbarPainter);
    _detachControllerListener();
    _activeScrollbarPainter.dispose();
    _thumbOpacityController.dispose();
    super.dispose();
  }

  void _setScrollbarInteraction({
    bool? isHovered,
    bool? isPressed,
  }) {
    final wasActive = _isScrollbarActive;
    final nextHovered = isHovered ?? _isScrollbarHovered;
    final nextPressed = isPressed ?? _isScrollbarPressed;
    if (nextHovered == _isScrollbarHovered &&
        nextPressed == _isScrollbarPressed) {
      return;
    }
    setState(() {
      _isScrollbarHovered = nextHovered;
      _isScrollbarPressed = nextPressed;
    });
    if (wasActive != _isScrollbarActive) {
      _syncThumbOpacityAnimation();
    }
  }

  void _setUserScrollActive() {
    _thumbFadeTimer?.cancel();
    if (!_isUserScrollActive) {
      setState(() {
        _isUserScrollActive = true;
      });
    }
    _syncThumbOpacityAnimation();
  }

  void _scheduleUserScrollFadeOut() {
    _thumbFadeTimer?.cancel();
    _thumbFadeTimer = Timer(ChatScrollbar.thumbFadeOutDelay, () {
      if (!mounted || !_isUserScrollActive) {
        return;
      }
      setState(() {
        _isUserScrollActive = false;
      });
      _syncThumbOpacityAnimation();
    });
  }

  bool _isUserDrivenScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      return notification.direction != ScrollDirection.idle;
    }
    if (notification is ScrollStartNotification) {
      return notification.dragDetails != null;
    }
    if (notification is ScrollUpdateNotification) {
      return notification.dragDetails != null;
    }
    if (notification is OverscrollNotification) {
      return notification.dragDetails != null;
    }
    return false;
  }

  bool _isUserScrollEndNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      return notification.direction == ScrollDirection.idle;
    }
    return notification is ScrollEndNotification;
  }

  void _syncThumbOpacityAnimation() {
    _thumbOpacityController.animateTo(
      _isScrollbarActive ? 1 : 0,
      duration: ChatScrollbar.thumbFadeDuration,
    );
  }

  void _attachControllerListener(ScrollController? controller) {
    if (_listenedController == controller) {
      return;
    }
    _detachControllerListener();
    controller?.addListener(_syncActiveScrollbarPainterFromController);
    _listenedController = controller;
  }

  void _detachControllerListener() {
    _listenedController?.removeListener(_syncActiveScrollbarPainterFromController);
    _listenedController = null;
  }

  void _syncActiveScrollbarPainterFromController() {
    final controller = _controller;
    if (!mounted || controller == null || !controller.hasClients) {
      return;
    }
    final position = controller.position;
    _activeScrollbarPainter.update(position, position.axisDirection);
  }

  bool _handleActivePainterMetricsNotification(
    ScrollMetricsNotification notification,
  ) {
    _activeScrollbarPainter.update(
      notification.metrics,
      notification.metrics.axisDirection,
    );
    return false;
  }

  bool _handleChatScrollNotification(ScrollNotification notification) {
    if (_isUserDrivenScrollNotification(notification)) {
      _setUserScrollActive();
    } else if (_isUserScrollActive &&
        _isUserScrollEndNotification(notification)) {
      _scheduleUserScrollFadeOut();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _handleActivePainterMetricsNotification,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleChatScrollNotification,
        child: CustomPaint(
          foregroundPainter: _activeScrollbarPainter,
          child: super.build(context),
        ),
      ),
    );
  }
}
