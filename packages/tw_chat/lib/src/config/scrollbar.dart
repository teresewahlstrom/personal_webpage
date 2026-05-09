import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:super_editor/src/infrastructure/flutter/scrollbar.dart'
    show RawScrollbarWithCustomPhysics, RawScrollbarWithCustomPhysicsState;

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
  bool _isScrollbarHovered = false;
  bool _isScrollbarPressed = false;
  bool _isUserScrollActive = false;

  bool get _isScrollbarActive =>
      _isScrollbarHovered || _isScrollbarPressed || _isUserScrollActive;

  double get _scrollbarThickness => widget.thickness!;
  Color get _thumbColor => _isScrollbarActive
      ? ChatScrollbar.thumbColor(context)
      : ChatScrollbar.thumbInactiveColor(context);
  bool get _showsThumb => widget.thumbVisibility ?? false;
  bool get _showsTrack => widget.trackVisibility ?? false;

  @override
  bool get showScrollbar => _showsThumb;

  @override
  bool get enableGestures => widget.interactive ?? true;

  @override
  void updateScrollbarPainter() {
    scrollbarPainter
      ..color = _showsThumb ? _thumbColor : Colors.transparent
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

  void _setScrollbarInteraction({
    bool? isHovered,
    bool? isPressed,
  }) {
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
    _thumbFadeTimer = Timer(ChatScrollbar.thumbFadeOutDelay, () {
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
    return NotificationListener<ScrollNotification>(
      onNotification: _handleChatScrollNotification,
      child: super.build(context),
    );
  }
}
