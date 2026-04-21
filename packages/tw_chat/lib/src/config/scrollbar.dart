import 'dart:async';

import 'package:flutter/material.dart';

import 'skin.dart';

class ChatScrollbar {
  const ChatScrollbar._();

  static const visibilityOverflowThreshold = 0.5;
  static Color get thumbColor => ChatSkin.data.colors.scrollbarThumb;
  static Color get thumbInactiveColor =>
      ChatSkin.data.colors.scrollbarThumbInactive;
  static Color get trackColor => ChatSkin.data.colors.scrollbarTrack;
  static const inputTrackBorder = Border();
  static const thumbFadeDuration = Duration(milliseconds: 220);
  static const thumbFadeOutDelay = Duration(milliseconds: 700);

  static Color inactiveThumbColor() {
    return thumbInactiveColor;
  }

  static Color thumbColorForState(bool isActive) {
    return isActive ? thumbColor : inactiveThumbColor();
  }

  static Widget buildTrack({
    required double thickness,
    required double crossAxisInset,
  }) {
    final tokens = ChatSkin.data.tokens;
    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.only(
          right: crossAxisInset + tokens.scrollbarTrackLeftShift,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: thickness,
            decoration: BoxDecoration(
              color: trackColor,
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
  bool _isScrollbarActive = false;

  @override
  void dispose() {
    _thumbFadeTimer?.cancel();
    super.dispose();
  }

  void _setScrollbarActive() {
    _thumbFadeTimer?.cancel();
    if (!_isScrollbarActive) {
      setState(() {
        _isScrollbarActive = true;
      });
    }
  }

  void _scheduleScrollbarFadeOut() {
    _thumbFadeTimer?.cancel();
    _thumbFadeTimer = Timer(ChatScrollbar.thumbFadeOutDelay, () {
      if (!mounted) {
        return;
      }
      if (_isScrollbarActive) {
        setState(() {
          _isScrollbarActive = false;
        });
      }
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification ||
        notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      _setScrollbarActive();
    } else if (notification is ScrollEndNotification) {
      _scheduleScrollbarFadeOut();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final targetThumbColor = ChatScrollbar.thumbColorForState(
      _isScrollbarActive,
    );
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
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
    );
  }
}
