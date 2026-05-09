import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

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

class ChatFadingScrollbar extends StatefulWidget {
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
  State<ChatFadingScrollbar> createState() => _ChatFadingScrollbarState();
}

class _ChatFadingScrollbarState extends State<ChatFadingScrollbar>
    with SingleTickerProviderStateMixin {
  Timer? _thumbFadeTimer;
  late final AnimationController _activeThumbOpacityController;
  late final ScrollbarPainter _inactiveScrollbarPainter;
  late final ScrollbarPainter _activeScrollbarPainter;
  bool _isScrollbarHovered = false;
  bool _isScrollbarPressed = false;
  bool _isUserScrollActive = false;

  bool get _isScrollbarActive =>
      _isScrollbarHovered || _isScrollbarPressed || _isUserScrollActive;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerScrollChange);
    _activeThumbOpacityController = AnimationController(
      vsync: this,
      duration: ChatScrollbar.thumbFadeDuration,
      value: 0,
    );
    _inactiveScrollbarPainter = ScrollbarPainter(
      color: Colors.transparent,
      fadeoutOpacityAnimation: const AlwaysStoppedAnimation(1.0),
      textDirection: TextDirection.ltr,
      thickness: widget.thickness,
      padding: widget.padding ?? EdgeInsets.zero,
      mainAxisMargin: widget.mainAxisMargin,
      crossAxisMargin: widget.crossAxisMargin,
      radius: widget.radius,
      minLength: widget.minThumbLength,
      minOverscrollLength: widget.minThumbLength,
      ignorePointer: true,
    );
    _activeScrollbarPainter = ScrollbarPainter(
      color: Colors.transparent,
      fadeoutOpacityAnimation: _activeThumbOpacityController,
      trackColor: Colors.transparent,
      trackBorderColor: Colors.transparent,
      textDirection: TextDirection.ltr,
      thickness: widget.thickness,
      padding: widget.padding ?? EdgeInsets.zero,
      mainAxisMargin: widget.mainAxisMargin,
      crossAxisMargin: widget.crossAxisMargin,
      radius: widget.radius,
      minLength: widget.minThumbLength,
      minOverscrollLength: widget.minThumbLength,
      ignorePointer: true,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncPainterMetricsFromController();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerScrollChange);
    _thumbFadeTimer?.cancel();
    _activeThumbOpacityController.dispose();
    _inactiveScrollbarPainter.dispose();
    _activeScrollbarPainter.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatFadingScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.thickness != widget.thickness) {
      _inactiveScrollbarPainter.thickness = widget.thickness;
      _activeScrollbarPainter.thickness = widget.thickness;
    }
    if (oldWidget.padding != widget.padding) {
      final padding = widget.padding ?? EdgeInsets.zero;
      _inactiveScrollbarPainter.padding = padding;
      _activeScrollbarPainter.padding = padding;
    }
    if (oldWidget.mainAxisMargin != widget.mainAxisMargin) {
      _inactiveScrollbarPainter.mainAxisMargin = widget.mainAxisMargin;
      _activeScrollbarPainter.mainAxisMargin = widget.mainAxisMargin;
    }
    if (oldWidget.crossAxisMargin != widget.crossAxisMargin) {
      _inactiveScrollbarPainter.crossAxisMargin = widget.crossAxisMargin;
      _activeScrollbarPainter.crossAxisMargin = widget.crossAxisMargin;
    }
    if (oldWidget.radius != widget.radius) {
      _inactiveScrollbarPainter.radius = widget.radius;
      _activeScrollbarPainter.radius = widget.radius;
    }
    if (oldWidget.minThumbLength != widget.minThumbLength) {
      _inactiveScrollbarPainter.minLength = widget.minThumbLength;
      _inactiveScrollbarPainter.minOverscrollLength = widget.minThumbLength;
      _activeScrollbarPainter.minLength = widget.minThumbLength;
      _activeScrollbarPainter.minOverscrollLength = widget.minThumbLength;
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerScrollChange);
      widget.controller.addListener(_handleControllerScrollChange);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _syncPainterMetricsFromController();
      });
    }
  }

  void _handleControllerScrollChange() {
    _syncPainterMetricsFromController();
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
    _activeThumbOpacityController.value = 1;
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

  bool _isWithinScrollbarRegion(Offset localPosition, Size size) {
    final padding =
        widget.padding?.resolve(Directionality.of(context)) ?? EdgeInsets.zero;
    final verticalStart = padding.top;
    final verticalEnd = size.height - padding.bottom;
    if (localPosition.dy < verticalStart || localPosition.dy >= verticalEnd) {
      return false;
    }

    final interactionExtent =
        widget.thickness +
        widget.crossAxisMargin +
        ChatScrollbar.hoverActivationInset;
    final direction = Directionality.of(context);
    if (direction == TextDirection.rtl) {
      return localPosition.dx < interactionExtent + padding.left;
    }
    return localPosition.dx > size.width - padding.right - interactionExtent;
  }

  void _updateHover(Offset localPosition, Size size) {
    _setScrollbarInteraction(
      isHovered: _isWithinScrollbarRegion(localPosition, size),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    _updatePainterMetrics(notification.metrics, notification.metrics.axisDirection);
    if (_isUserDrivenScrollNotification(notification)) {
      _setUserScrollActive();
    } else if (_isUserScrollActive &&
        _isUserScrollEndNotification(notification)) {
      _scheduleUserScrollFadeOut();
    }
    return false;
  }

  bool _handleScrollMetricsNotification(ScrollMetricsNotification notification) {
    _updatePainterMetrics(notification.metrics, notification.metrics.axisDirection);
    return false;
  }

  void _syncThumbOpacityAnimation() {
    if (_isScrollbarActive) {
      _activeThumbOpacityController.value = 1;
      return;
    }
    _activeThumbOpacityController.animateTo(
      0,
      duration: ChatScrollbar.thumbFadeDuration,
    );
  }

  void _syncPainterMetricsFromController() {
    if (!widget.controller.hasClients) {
      return;
    }
    final position = widget.controller.position;
    _updatePainterMetrics(position, position.axisDirection);
  }

  void _updatePainterMetrics(ScrollMetrics metrics, AxisDirection axisDirection) {
    _inactiveScrollbarPainter.update(metrics, axisDirection);
    _activeScrollbarPainter.update(metrics, axisDirection);
  }

  void _syncPainterTheme(BuildContext context) {
    final textDirection = Directionality.of(context);
    final inactiveThumbColor = widget.thumbVisibility
        ? ChatScrollbar.thumbInactiveColor(context)
        : Colors.transparent;
    final activeThumbColor = widget.thumbVisibility
        ? ChatScrollbar.thumbColor(context)
        : Colors.transparent;
    final inactiveTrackColor = widget.trackVisibility
        ? ChatScrollbar.trackColor(context)
        : Colors.transparent;
    _inactiveScrollbarPainter
      ..color = inactiveThumbColor
      ..trackColor = inactiveTrackColor
      ..trackBorderColor = Colors.transparent
      ..textDirection = textDirection;
    _activeScrollbarPainter
      ..color = activeThumbColor
      ..textDirection = textDirection;
  }

  @override
  Widget build(BuildContext context) {
    _syncPainterTheme(context);
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _handleScrollMetricsNotification,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                final isInteracting = _isWithinScrollbarRegion(
                  event.localPosition,
                  size,
                );
                _setScrollbarInteraction(
                  isHovered: isInteracting,
                  isPressed: isInteracting,
                );
              },
              onPointerUp: (event) {
                _setScrollbarInteraction(
                  isHovered: _isWithinScrollbarRegion(event.localPosition, size),
                  isPressed: false,
                );
              },
              onPointerCancel: (_) {
                _setScrollbarInteraction(isHovered: false, isPressed: false);
              },
              child: MouseRegion(
                onHover: (event) => _updateHover(event.localPosition, size),
                onExit: (_) => _setScrollbarInteraction(isHovered: false),
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    RawScrollbar(
                      controller: widget.controller,
                      thumbVisibility: widget.thumbVisibility,
                      interactive: widget.interactive,
                      trackVisibility: false,
                      thickness: widget.thickness,
                      minThumbLength: widget.minThumbLength,
                      crossAxisMargin: widget.crossAxisMargin,
                      mainAxisMargin: widget.mainAxisMargin,
                      padding: widget.padding,
                      radius: widget.radius,
                      thumbColor: Colors.transparent,
                      child: widget.child,
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          foregroundPainter: _inactiveScrollbarPainter,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          foregroundPainter: _activeScrollbarPainter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
