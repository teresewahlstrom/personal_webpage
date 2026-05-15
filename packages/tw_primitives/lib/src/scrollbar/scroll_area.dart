import 'package:flutter/material.dart';

import 'tw_scrollbar.dart';

/// Composes a scrollable content area with the Tw scrollbar treatment.
class TwScrollArea extends StatelessWidget {
  const TwScrollArea({
    super.key,
    required this.controller,
    required this.child,
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
    this.thumbVisibility = true,
    this.interactive = true,
    this.trackVisibility = false,
    this.fadeDuration = TwScrollbarDefaults.thumbFadeDuration,
    this.timeToFade = TwScrollbarDefaults.thumbFadeOutDelay,
  });

  final ScrollController controller;
  final Widget child;
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
  final bool thumbVisibility;
  final bool interactive;
  final bool trackVisibility;
  final Duration fadeDuration;
  final Duration timeToFade;

  @override
  Widget build(BuildContext context) {
    final scrollbar = TwScrollbar(
      controller: controller,
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
      thumbVisibility: thumbVisibility,
      interactive: interactive,
      trackVisibility: trackVisibility,
      fadeDuration: fadeDuration,
      timeToFade: timeToFade,
      child: child,
    );

    final area = track == null && overlayChildren.isEmpty
        ? scrollbar
        : Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              if (track != null) track!,
              scrollbar,
              ...overlayChildren,
            ],
          );

    if (!hideSystemScrollbars) {
      return area;
    }

    return ScrollConfiguration(
      behavior: const TwNoScrollbarBehavior(),
      child: area,
    );
  }
}
