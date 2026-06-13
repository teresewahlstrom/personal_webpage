import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import 'scroll_surface_interaction.dart';
import 'scroll_area_layout.dart';
import 'tw_scrollbar.dart';

/// Composes a scrollable content area with the Tw scrollbar treatment.
class TwScrollArea extends StatefulWidget {
  const TwScrollArea({
    super.key,
    required ScrollController this._controller,
    required this._child,
    this.activationPulse,
    this.backgroundTrack,
    this.overlayChildren = const <Widget>[],
    this.hideSystemScrollbars = true,
    this.thumbColor = TwScrollbarDefaults.thumbColor,
    this.thumbInactiveColor = TwScrollbarDefaults.thumbInactiveColor,
    this.scrollbarTrackColor,
    this.thickness = TwScrollbarDefaults.thickness,
    this.minThumbLength = TwScrollbarDefaults.minThumbLength,
    this.crossAxisMargin = TwScrollbarDefaults.crossAxisMargin,
    this.radius = TwScrollbarDefaults.radius,
    this.scrollbarInsets = EdgeInsets.zero,
    this.scrollbarDragPhysics = const ClampingScrollPhysics(),
    this.desktopKeyboardScrollLineStep,
    this.isKeyboardScrollBlocked,
    this.onDesktopTap,
    this.onPointerDown,
    this.onPointerUp,
    this.onPointerCancel,
    this.thumbVisibility = true,
    this.interactive = true,
    this.fadeDuration = TwScrollbarDefaults.thumbFadeDuration,
    this.timeToFade = TwScrollbarDefaults.thumbFadeOutDelay,
  }) : assert(thickness >= 0),
       assert(crossAxisMargin >= 0),
       assert(minThumbLength >= 0),
       assert(
         desktopKeyboardScrollLineStep == null ||
             desktopKeyboardScrollLineStep > 0,
       ),
       contentPhysics = null,
       scrollbarColumnWidth = null,
       padding = null,
       excludeScrollViewFromSelection = false,
       _scrollDirection = null,
       _primary = false;

  factory TwScrollArea.scrollView({
    Key? key,
    ScrollController? controller,
    required Widget child,
    Axis scrollDirection = Axis.vertical,
    bool primary = false,
    ValueListenable<Object?>? activationPulse,
    Widget? backgroundTrack,
    List<Widget> overlayChildren = const <Widget>[],
    bool hideSystemScrollbars = true,
    Color thumbColor = TwScrollbarDefaults.thumbColor,
    Color thumbInactiveColor = TwScrollbarDefaults.thumbInactiveColor,
    Color? scrollbarTrackColor,
    double thickness = TwScrollbarDefaults.thickness,
    double minThumbLength = TwScrollbarDefaults.minThumbLength,
    double crossAxisMargin = TwScrollbarDefaults.crossAxisMargin,
    Radius radius = TwScrollbarDefaults.radius,
    EdgeInsetsGeometry scrollbarInsets = EdgeInsets.zero,
    double? scrollbarColumnWidth,
    EdgeInsetsGeometry? padding,
    ScrollPhysics contentPhysics = const ClampingScrollPhysics(),
    ScrollPhysics scrollbarDragPhysics = const ClampingScrollPhysics(),
    bool excludeScrollViewFromSelection = false,
    double? desktopKeyboardScrollLineStep = 120,
    ValueListenable<bool>? isKeyboardScrollBlocked,
    VoidCallback? onDesktopTap,
    VoidCallback? onPointerDown,
    VoidCallback? onPointerUp,
    VoidCallback? onPointerCancel,
    bool thumbVisibility = true,
    bool interactive = true,
    Duration fadeDuration = TwScrollbarDefaults.thumbFadeDuration,
    Duration timeToFade = TwScrollbarDefaults.thumbFadeOutDelay,
  }) {
    return TwScrollArea._scrollView(
      key: key,
      controller: controller,
      scrollDirection: scrollDirection,
      primary: primary,
      activationPulse: activationPulse,
      backgroundTrack: backgroundTrack,
      overlayChildren: overlayChildren,
      hideSystemScrollbars: hideSystemScrollbars,
      thumbColor: thumbColor,
      thumbInactiveColor: thumbInactiveColor,
      scrollbarTrackColor: scrollbarTrackColor,
      thickness: thickness,
      minThumbLength: minThumbLength,
      crossAxisMargin: crossAxisMargin,
      radius: radius,
      scrollbarInsets: scrollbarInsets,
      scrollbarColumnWidth: scrollbarColumnWidth,
      padding: padding,
      contentPhysics: contentPhysics,
      scrollbarDragPhysics: scrollbarDragPhysics,
      excludeScrollViewFromSelection: excludeScrollViewFromSelection,
      desktopKeyboardScrollLineStep: desktopKeyboardScrollLineStep,
      isKeyboardScrollBlocked: isKeyboardScrollBlocked,
      onDesktopTap: onDesktopTap,
      onPointerDown: onPointerDown,
      onPointerUp: onPointerUp,
      onPointerCancel: onPointerCancel,
      thumbVisibility: thumbVisibility,
      interactive: interactive,
      fadeDuration: fadeDuration,
      timeToFade: timeToFade,
      child: child,
    );
  }

  const TwScrollArea._scrollView({
    super.key,
    this._controller,
    required this._child,
    required Axis this._scrollDirection,
    required this._primary,
    this.activationPulse,
    this.backgroundTrack,
    this.overlayChildren = const <Widget>[],
    this.hideSystemScrollbars = true,
    this.thumbColor = TwScrollbarDefaults.thumbColor,
    this.thumbInactiveColor = TwScrollbarDefaults.thumbInactiveColor,
    this.scrollbarTrackColor,
    this.thickness = TwScrollbarDefaults.thickness,
    this.minThumbLength = TwScrollbarDefaults.minThumbLength,
    this.crossAxisMargin = TwScrollbarDefaults.crossAxisMargin,
    this.radius = TwScrollbarDefaults.radius,
    this.scrollbarInsets = EdgeInsets.zero,
    this.scrollbarColumnWidth,
    this.padding,
    this.contentPhysics = const ClampingScrollPhysics(),
    this.scrollbarDragPhysics = const ClampingScrollPhysics(),
    this.excludeScrollViewFromSelection = false,
    this.desktopKeyboardScrollLineStep = 120,
    this.isKeyboardScrollBlocked,
    this.onDesktopTap,
    this.onPointerDown,
    this.onPointerUp,
    this.onPointerCancel,
    this.thumbVisibility = true,
    this.interactive = true,
    this.fadeDuration = TwScrollbarDefaults.thumbFadeDuration,
    this.timeToFade = TwScrollbarDefaults.thumbFadeOutDelay,
  }) : assert(thickness >= 0),
       assert(crossAxisMargin >= 0),
       assert(minThumbLength >= 0),
       assert(scrollbarColumnWidth == null || scrollbarColumnWidth >= 0),
       assert(
         desktopKeyboardScrollLineStep == null ||
             desktopKeyboardScrollLineStep > 0,
       );

  final ScrollController? _controller;
  final Widget _child;
  final Axis? _scrollDirection;
  final bool _primary;
  final ValueListenable<Object?>? activationPulse;
  final Widget? backgroundTrack;
  final List<Widget> overlayChildren;
  final bool hideSystemScrollbars;

  final Color thumbColor;
  final Color thumbInactiveColor;

  /// Painter track color for the scrollbar.
  ///
  /// `null` keeps the painter track hidden. A non-null [Color] makes the
  /// painter track visible with that color.
  final Color? scrollbarTrackColor;
  final double minThumbLength;
  final double crossAxisMargin;
  final double thickness;
  final Radius radius;
  final EdgeInsetsGeometry scrollbarInsets;

  /// Layout space reserved beside the content for the scrollbar column.
  ///
  /// When `null`, the reserved width is derived automatically from
  /// `thickness + (crossAxisMargin * 2)`. Use `0` to opt into overlay behavior,
  /// where content is not padded away from the scrollbar. Positive values
  /// reserve that explicit amount of space.
  final double? scrollbarColumnWidth;

  /// Caller-owned content breathing room.
  ///
  /// For scroll views, this padding is combined internally with
  /// [scrollbarColumnWidth] so the rendered content padding includes both the
  /// requested breathing room and any reserved scrollbar column.
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? contentPhysics;
  final ScrollPhysics scrollbarDragPhysics;
  final bool excludeScrollViewFromSelection;

  /// Desktop keyboard scroll step.
  ///
  /// `null` disables desktop keyboard scrolling. A positive value enables it
  /// and uses that distance for each line-step scroll.
  final double? desktopKeyboardScrollLineStep;
  final ValueListenable<bool>? isKeyboardScrollBlocked;
  final VoidCallback? onDesktopTap;
  final VoidCallback? onPointerDown;
  final VoidCallback? onPointerUp;
  final VoidCallback? onPointerCancel;
  final bool thumbVisibility;
  final bool interactive;
  final Duration fadeDuration;
  final Duration timeToFade;

  bool get _enableDesktopKeyboardScroll =>
      desktopKeyboardScrollLineStep != null;

  double get _resolvedScrollbarColumnWidth => resolveScrollbarColumnWidth(
    scrollbarColumnWidth: scrollbarColumnWidth,
    thickness: thickness,
    crossAxisMargin: crossAxisMargin,
  );

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
    final Widget scrollChild = widget._scrollDirection == null
        ? widget._child
        : _buildScrollView(controller);

    final Widget child = TwScrollSurfaceInteraction(
      controller: controller,
      enableDesktopKeyboardScroll: widget._enableDesktopKeyboardScroll,
      keyboardScrollLineStep: widget.desktopKeyboardScrollLineStep ?? 120,
      isKeyboardScrollBlocked: widget.isKeyboardScrollBlocked,
      onDesktopTap: widget.onDesktopTap,
      onPointerDown: widget.onPointerDown,
      onPointerUp: widget.onPointerUp,
      onPointerCancel: widget.onPointerCancel,
      child: scrollChild,
    );

    final scrollbar = TwScrollbar(
      controller: controller,
      activationPulse: widget.activationPulse,
      thumbColor: widget.thumbColor,
      thumbInactiveColor: widget.thumbInactiveColor,
      trackColor: widget.scrollbarTrackColor ?? Colors.transparent,
      thickness: widget.thickness,
      minThumbLength: widget.minThumbLength,
      crossAxisMargin: widget.crossAxisMargin,
      mainAxisMargin: TwScrollbarDefaults.mainAxisMargin,
      radius: widget.radius,
      scrollbarInsets: widget.scrollbarInsets,
      physics: widget.scrollbarDragPhysics,
      thumbVisibility: widget.thumbVisibility,
      interactive: widget.interactive,
      trackVisibility: widget.scrollbarTrackColor != null,
      fadeDuration: widget.fadeDuration,
      timeToFade: widget.timeToFade,
      child: child,
    );

    final area =
        widget.backgroundTrack == null && widget.overlayChildren.isEmpty
        ? scrollbar
        : Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              if (widget.backgroundTrack != null) widget.backgroundTrack!,
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

  Widget _buildScrollView(ScrollController controller) {
    final usePrimary =
        widget._scrollDirection == Axis.vertical && widget._primary;
    final TextDirection textDirection = Directionality.of(context);
    final EdgeInsets resolvedContentPadding = resolveScrollAreaContentPadding(
      contentPadding: widget.padding,
      scrollDirection: widget._scrollDirection!,
      textDirection: textDirection,
      scrollbarColumnWidth: widget._resolvedScrollbarColumnWidth,
    );
    final Widget scrollContent = resolvedContentPadding == EdgeInsets.zero
        ? widget._child
        : Padding(padding: resolvedContentPadding, child: widget._child);
    Widget scrollView = SingleChildScrollView(
      controller: usePrimary ? null : controller,
      primary: usePrimary,
      scrollDirection: widget._scrollDirection!,
      physics: widget.contentPhysics ?? const ClampingScrollPhysics(),
      child: scrollContent,
    );
    if (widget.excludeScrollViewFromSelection) {
      scrollView = SelectionContainer.disabled(child: scrollView);
    }
    if (!usePrimary) {
      return scrollView;
    }
    return PrimaryScrollController(controller: controller, child: scrollView);
  }
}
