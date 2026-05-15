import 'package:flutter/material.dart';

import 'tw_scrollbar.dart';

/// Composes a scrollable content area with the Tw scrollbar treatment.
class TwScrollArea extends StatefulWidget {
  const TwScrollArea({
    super.key,
    required ScrollController controller,
    required Widget child,
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
  }) : _controller = controller,
       _child = child,
      _scrollDirection = scrollDirection,
      _primary = primary;

  final ScrollController? _controller;
  final Widget _child;
    final Axis? _scrollDirection;
    final bool _primary;
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
  State<TwScrollArea> createState() => _TwScrollAreaState();
}

class _TwScrollAreaState extends State<TwScrollArea> {
  ScrollController? _ownedController;

  ScrollController get _effectiveController {
    return widget._controller ?? (_ownedController ??= ScrollController());
  }

  @override
  void didUpdateWidget(covariant TwScrollArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._controller == null && widget._controller != null) {
      _ownedController?.dispose();
      _ownedController = null;
    }
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _effectiveController;
    final child = widget._scrollDirection == null
      ? widget._child
      : _buildScrollView(controller);

    final scrollbar = TwScrollbar(
      controller: controller,
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
    final scrollView = SingleChildScrollView(
      controller: usePrimary ? null : controller,
      primary: usePrimary,
      scrollDirection: widget._scrollDirection!,
      physics: widget.physics,
      child: widget._child,
    );
    if (!usePrimary) {
      return scrollView;
    }
    return PrimaryScrollController(controller: controller, child: scrollView);
  }
}
