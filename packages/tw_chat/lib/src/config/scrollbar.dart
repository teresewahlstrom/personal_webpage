import 'dart:async';

import 'package:flutter/material.dart';
import 'package:super_editor/super_text_field.dart';

import 'composer_layout.dart';
import 'skin.dart';

class ChatScrollbar {
  const ChatScrollbar._();

  static const visibilityOverflowThreshold = 0.5;
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

/// A fading scrollbar that wraps a scrollable [child].
///
/// When [physics] is provided, [RawScrollbarWithCustomPhysics] is used so the
/// scrollbar thumb remains draggable even when the underlying [Scrollable] uses
/// [NeverScrollableScrollPhysics] (as is the case with [SuperTextField]).
/// When [physics] is `null`, the standard [RawScrollbar] is used.
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
    this.physics,
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

  /// Optional scroll physics to use for the scrollbar.
  ///
  /// When non-null, [RawScrollbarWithCustomPhysics] is used so the scrollbar
  /// thumb can still be dragged even if the underlying [Scrollable] uses
  /// [NeverScrollableScrollPhysics].  Pass
  /// `ScrollConfiguration.of(context).getScrollPhysics(context)` here when
  /// wrapping a [SuperTextField].
  final ScrollPhysics? physics;

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
      context,
      _isScrollbarActive,
    );
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: targetThumbColor),
        duration: ChatScrollbar.thumbFadeDuration,
        builder: (context, animatedThumbColor, child) {
          final thumbColor = animatedThumbColor ?? targetThumbColor;
          final physics = widget.physics;
          if (physics != null) {
            return RawScrollbarWithCustomPhysics(
              controller: widget.controller,
              physics: physics,
              thumbVisibility: widget.thumbVisibility,
              interactive: widget.interactive,
              trackVisibility: widget.trackVisibility,
              thickness: widget.thickness,
              minThumbLength: widget.minThumbLength,
              crossAxisMargin: widget.crossAxisMargin,
              mainAxisMargin: widget.mainAxisMargin,
              padding: widget.padding,
              radius: widget.radius,
              thumbColor: thumbColor,
              child: child!,
            );
          }
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
            thumbColor: thumbColor,
            child: child!,
          );
        },
        child: widget.child,
      ),
    );
  }
}
