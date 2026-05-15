import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:tw_primitives/src/scrollbar/raw_scrollbar_with_custom_physics.dart';

class TwScrollbarDefaults {
  const TwScrollbarDefaults._();

  static const visibilityOverflowThreshold = 0.5;
  static const thumbFadeDuration = Duration(milliseconds: 220);
  static const thumbFadeOutDelay = Duration(milliseconds: 700);
  static const thickness = 7.0;
  static const minThumbLength = 15.0;
  static const crossAxisMargin = 1.0;
  static const mainAxisMargin = 0.0;
  static const radius = Radius.circular(100);
  static const thumbColor = Color(0x397199FF);
  static const thumbInactiveColor = Color(0xFF283143);
  static const trackColor = Colors.transparent;
  static const trackBorder = Border();
}

class TwNoScrollbarBehavior extends MaterialScrollBehavior {
  const TwNoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class TwScrollbarTrack extends StatelessWidget {
  const TwScrollbarTrack({
    super.key,
    required this.color,
    this.thickness = TwScrollbarDefaults.thickness,
    this.crossAxisInset = 0,
    this.topInset = 0,
    this.bottomInset = 0,
    this.rightShift = 0,
    this.borderRadius,
    this.border = TwScrollbarDefaults.trackBorder,
  });

  final Color color;
  final double thickness;
  final double crossAxisInset;
  final double topInset;
  final double bottomInset;
  final double rightShift;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder border;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.only(
          top: topInset,
          bottom: bottomInset,
          right: crossAxisInset + rightShift,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: thickness,
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius,
              border: border,
            ),
          ),
        ),
      ),
    );
  }
}

class TwScrollbar extends StatelessWidget {
  const TwScrollbar({
    super.key,
    required this.controller,
    required this.child,
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
    this.thumbVisibility = true,
    this.interactive = true,
    this.trackVisibility = false,
    this.fadeDuration = TwScrollbarDefaults.thumbFadeDuration,
    this.timeToFade = TwScrollbarDefaults.thumbFadeOutDelay,
  });

  final ScrollController controller;
  final Widget child;
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
  final bool thumbVisibility;
  final bool interactive;
  final bool trackVisibility;
  final Duration fadeDuration;
  final Duration timeToFade;

  @override
  Widget build(BuildContext context) {
    return _TwRawScrollbar(
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
      physics: physics,
      thumbColor: thumbColor,
      thumbInactiveColor: thumbInactiveColor,
      activeTrackColor: trackColor,
      fadeDuration: fadeDuration,
      timeToFade: timeToFade,
      child: child,
    );
  }
}

class _TwRawScrollbar extends RawScrollbarWithCustomPhysics {
  const _TwRawScrollbar({
    required super.controller,
    required super.child,
    required super.thumbVisibility,
    required super.interactive,
    required super.trackVisibility,
    required super.thickness,
    required super.minThumbLength,
    required super.crossAxisMargin,
    required super.mainAxisMargin,
    required super.padding,
    required super.radius,
    required super.physics,
    required this.thumbInactiveColor,
    required this.activeTrackColor,
    required super.fadeDuration,
    required super.timeToFade,
    super.thumbColor,
  }) : super(
         minOverscrollLength: minThumbLength,
         trackColor: Colors.transparent,
         trackBorderColor: Colors.transparent,
       );

  final Color thumbInactiveColor;
  final Color activeTrackColor;

  @override
  _TwRawScrollbarState createState() => _TwRawScrollbarState();
}

class _TwRawScrollbarState
    extends RawScrollbarWithCustomPhysicsState<_TwRawScrollbar> {
  Timer? _thumbFadeTimer;
  bool _isScrollbarHovered = false;
  bool _isScrollbarPressed = false;
  bool _isUserScrollActive = false;

  bool get _isScrollbarActive =>
      _isScrollbarHovered || _isScrollbarPressed || _isUserScrollActive;

  bool get _showsThumb => widget.thumbVisibility ?? false;
  bool get _showsTrack => widget.trackVisibility ?? false;

  @override
  bool get showScrollbar => _showsThumb;

  @override
  bool get enableGestures => widget.interactive ?? true;

  @override
  void updateScrollbarPainter() {
    scrollbarPainter
      ..color = _showsThumb
          ? (_isScrollbarActive
                ? widget.thumbColor ?? TwScrollbarDefaults.thumbColor
                : widget.thumbInactiveColor)
          : Colors.transparent
      ..trackColor = _showsTrack ? widget.activeTrackColor : Colors.transparent
      ..trackBorderColor = Colors.transparent
      ..textDirection = Directionality.of(context)
      ..thickness = widget.thickness ?? TwScrollbarDefaults.thickness
      ..radius = widget.radius
      ..crossAxisMargin = widget.crossAxisMargin
      ..mainAxisMargin = widget.mainAxisMargin
      ..minLength = widget.minThumbLength
      ..minOverscrollLength = widget.minThumbLength
      ..padding = widget.padding ?? EdgeInsets.zero
      ..ignorePointer = !enableGestures;
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
    super.dispose();
  }

  void _setScrollbarInteraction({bool? isHovered, bool? isPressed}) {
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
  }

  void _setUserScrollActive() {
    _thumbFadeTimer?.cancel();
    if (!_isUserScrollActive) {
      setState(() {
        _isUserScrollActive = true;
      });
    }
  }

  void _scheduleUserScrollFadeOut() {
    _thumbFadeTimer?.cancel();
    _thumbFadeTimer = Timer(widget.timeToFade, () {
      if (!mounted || !_isUserScrollActive) {
        return;
      }
      setState(() {
        _isUserScrollActive = false;
      });
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

  bool _handleScrollNotification(ScrollNotification notification) {
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
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: super.build(context),
    );
  }
}
