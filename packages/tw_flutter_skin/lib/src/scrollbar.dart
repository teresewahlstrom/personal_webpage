import 'dart:async';

import 'package:flutter/material.dart';

/// A [ScrollBehavior] that suppresses the platform's built-in scrollbar,
/// useful when a custom scrollbar overlay is provided instead.
class NoScrollbarBehavior extends MaterialScrollBehavior {
  const NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

/// A scrollbar whose thumb smoothly fades between an active and an inactive
/// colour as the user scrolls and then stops.
///
/// Wrap any [Scrollable] descendant with this widget and supply the
/// [ScrollController] that drives it.  The thumb becomes [thumbActiveColor]
/// while scrolling and transitions to [thumbInactiveColor] after
/// [fadeOutDelay] has elapsed, using [fadeDuration] for the animation.
class FadingScrollbar extends StatefulWidget {
  const FadingScrollbar({
    super.key,
    this.controller,
    required this.child,
    required this.thickness,
    required this.minThumbLength,
    required this.crossAxisMargin,
    required this.mainAxisMargin,
    required this.radius,
    required this.thumbActiveColor,
    required this.thumbInactiveColor,
    this.padding,
    this.thumbVisibility = true,
    this.interactive = true,
    this.trackVisibility = false,
    this.fadeDuration = const Duration(milliseconds: 220),
    this.fadeOutDelay = const Duration(milliseconds: 700),
  });

  /// The [ScrollController] used to drive the scrollbar thumb position.
  ///
  /// When `null`, the nearest [PrimaryScrollController] is used, or the
  /// scrollbar auto-attaches to the first [Scrollable] descendant.
  final ScrollController? controller;

  final Widget child;

  final double thickness;
  final double minThumbLength;
  final double crossAxisMargin;
  final double mainAxisMargin;
  final Radius radius;

  /// Thumb colour while the user is actively scrolling.
  final Color thumbActiveColor;

  /// Thumb colour when the scrollbar is idle (not scrolling).
  final Color thumbInactiveColor;

  final EdgeInsetsGeometry? padding;

  /// Whether the thumb is always rendered, even when not scrolling.
  final bool thumbVisibility;

  /// Whether the user can drag the scrollbar thumb.
  final bool interactive;

  final bool trackVisibility;

  /// Duration of the active↔inactive colour transition.
  final Duration fadeDuration;

  /// How long after scrolling stops before the fade-to-inactive begins.
  final Duration fadeOutDelay;

  @override
  State<FadingScrollbar> createState() => _FadingScrollbarState();
}

class _FadingScrollbarState extends State<FadingScrollbar> {
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
    _thumbFadeTimer = Timer(widget.fadeOutDelay, () {
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
    final targetThumbColor =
        _isScrollbarActive ? widget.thumbActiveColor : widget.thumbInactiveColor;
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: targetThumbColor),
        duration: widget.fadeDuration,
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
