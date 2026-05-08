import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

import 'composer_layout.dart';
import 'skin.dart';

class ChatScrollbar {
  const ChatScrollbar._();

  static const visibilityOverflowThreshold = 0.5;
  static const hoverActivationInset = 12.0;
  static Color thumbColor(BuildContext context) =>
      ChatComposerLayout.borderColor(context);
  static Color thumbInactiveColor(BuildContext context) =>
      ChatComposerLayout.fillColor(context);
  static Color trackColor(BuildContext context) =>
      ChatSkin.dataOf(context).colors.scrollbarTrack;
  static const inputTrackBorder = Border();
  static const thumbFadeDuration = Duration(milliseconds: 220);
  static const thumbFadeOutDelay = Duration(milliseconds: 700);

  static Color inactiveThumbColor(BuildContext context) {
    return thumbInactiveColor(context);
  }

  static Color thumbColorForState(BuildContext context, bool isActive) {
    return isActive ? thumbColor(context) : inactiveThumbColor(context);
  }

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

class _ChatFadingScrollbarState extends State<ChatFadingScrollbar> {
  Timer? _thumbFadeTimer;
  bool _isScrollbarHovered = false;
  bool _isScrollbarPressed = false;
  bool _isUserScrollActive = false;

  bool get _isScrollbarActive =>
      _isScrollbarHovered || _isScrollbarPressed || _isUserScrollActive;

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
    if (_isUserScrollActive) {
      return;
    }
    setState(() {
      _isUserScrollActive = true;
    });
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
    final targetThumbColor = ChatScrollbar.thumbColorForState(
      context,
      _isScrollbarActive,
    );
    return NotificationListener<ScrollNotification>(
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
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: targetThumbColor),
                duration: ChatScrollbar.thumbFadeDuration,
                builder: (context, animatedThumbColor, child) {
                  return RawScrollbar(
                    controller: widget.controller,
                    thumbVisibility: widget.thumbVisibility,
                    interactive: widget.interactive,
                    trackVisibility: widget.trackVisibility,
                    thickness: widget.thickness,
                    minThumbLength: widget.minThumbLength,
                    crossAxisMargin: widget.crossAxisMargin,
                    mainAxisMargin: widget.mainAxisMargin,
                    padding: widget.padding,
                    radius: widget.radius,
                    thumbColor: animatedThumbColor ?? targetThumbColor,
                    child: child!,
                  );
                },
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
