import 'package:flutter/cupertino.dart'
    show cupertinoTextSelectionHandleControls;
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show RenderBox, ScrollDirection, SelectedContent;
import 'package:flutter/scheduler.dart' show Ticker;

import '../selection/tw_selectable_region.dart';
import '../selection/tw_selection_toolbar.dart';
import 'selectable_secondary_click_guard.dart';
import 'scroll_area.dart';
import 'tw_scrollbar.dart';

/// Composes a Tw scroll area with an inner SelectableRegion.
///
/// The internal scroll view is excluded from the parent selection system so
/// only the explicit selectable content participates in selection.
class TwSelectableScrollArea extends StatefulWidget {
  const TwSelectableScrollArea._({
    super.key,
    this.controller,
    required this.child,
    this.selectionControls,
    this.selectionKey,
    this.interactionFocusNode,
    this.canRequestFocus = true,
    this.contextMenuBuilder,
    this.magnifierConfiguration = TextMagnifierConfiguration.disabled,
    this.onSelectionChanged,
    this.actions,
    this.clearSelectionOnDesktopTap = true,
    this.onDesktopTap,
    this.onPointerDown,
    this.onPointerUp,
    this.onPointerCancel,
    this.enableDesktopKeyboardScroll = true,
    this.keyboardScrollLineStep = 120,
    this.isKeyboardScrollBlocked,
    this.enableWebSecondaryClickGuard = true,
    this.scrollDirection = Axis.vertical,
    this.primary = false,
    this.activationPulse,
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

  factory TwSelectableScrollArea.scrollView({
    Key? key,
    ScrollController? controller,
    required Widget child,
    TextSelectionControls? selectionControls,
    GlobalKey<TwSelectableRegionState>? selectionKey,
    FocusNode? interactionFocusNode,
    bool canRequestFocus = true,
    TwSelectableRegionContextMenuBuilder? contextMenuBuilder,
    TextMagnifierConfiguration magnifierConfiguration =
        TextMagnifierConfiguration.disabled,
    ValueChanged<SelectedContent?>? onSelectionChanged,
    Map<Type, Action<Intent>>? actions,
    bool clearSelectionOnDesktopTap = true,
    VoidCallback? onDesktopTap,
    VoidCallback? onPointerDown,
    VoidCallback? onPointerUp,
    VoidCallback? onPointerCancel,
    bool enableDesktopKeyboardScroll = true,
    double keyboardScrollLineStep = 120,
    ValueListenable<bool>? isKeyboardScrollBlocked,
    bool enableWebSecondaryClickGuard = true,
    Axis scrollDirection = Axis.vertical,
    bool primary = false,
    ValueListenable<Object?>? activationPulse,
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
    return TwSelectableScrollArea._(
      key: key,
      controller: controller,
      selectionControls: selectionControls,
      selectionKey: selectionKey,
      interactionFocusNode: interactionFocusNode,
      canRequestFocus: canRequestFocus,
      contextMenuBuilder: contextMenuBuilder,
      magnifierConfiguration: magnifierConfiguration,
      onSelectionChanged: onSelectionChanged,
      actions: actions,
      clearSelectionOnDesktopTap: clearSelectionOnDesktopTap,
      onDesktopTap: onDesktopTap,
      onPointerDown: onPointerDown,
      onPointerUp: onPointerUp,
      onPointerCancel: onPointerCancel,
      enableDesktopKeyboardScroll: enableDesktopKeyboardScroll,
      keyboardScrollLineStep: keyboardScrollLineStep,
      isKeyboardScrollBlocked: isKeyboardScrollBlocked,
      enableWebSecondaryClickGuard: enableWebSecondaryClickGuard,
      scrollDirection: scrollDirection,
      primary: primary,
      activationPulse: activationPulse,
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

  final ScrollController? controller;
  final Widget child;
  final TextSelectionControls? selectionControls;
  final GlobalKey<TwSelectableRegionState>? selectionKey;
  final FocusNode? interactionFocusNode;
  final bool canRequestFocus;
  final TwSelectableRegionContextMenuBuilder? contextMenuBuilder;
  final TextMagnifierConfiguration magnifierConfiguration;
  final ValueChanged<SelectedContent?>? onSelectionChanged;
  final Map<Type, Action<Intent>>? actions;
  final bool clearSelectionOnDesktopTap;
  final VoidCallback? onDesktopTap;
  final VoidCallback? onPointerDown;
  final VoidCallback? onPointerUp;
  final VoidCallback? onPointerCancel;
  final bool enableDesktopKeyboardScroll;
  final double keyboardScrollLineStep;
  final ValueListenable<bool>? isKeyboardScrollBlocked;
  final bool enableWebSecondaryClickGuard;
  final Axis scrollDirection;
  final bool primary;
  final ValueListenable<Object?>? activationPulse;
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
  State<TwSelectableScrollArea> createState() => _TwSelectableScrollAreaState();
}

class _TwSelectableScrollAreaState extends State<TwSelectableScrollArea>
    with SingleTickerProviderStateMixin {
  static const double _selectionAutoScrollBoundary = 56;
  static const double _selectionAutoScrollMaxSpeed = 720;

  late final TwSelectableSecondaryClickGuard _secondaryClickGuard;
  ScrollController? _ownedController;
  late final Ticker _selectionAutoScrollTicker;
  final GlobalKey<TwSelectableRegionState> _internalSelectionKey =
      GlobalKey<TwSelectableRegionState>();
  bool _hasSelection = false;
  Offset? _selectionDragGlobalPosition;
  Duration? _lastSelectionAutoScrollTick;

  GlobalKey<TwSelectableRegionState> get _effectiveSelectionKey =>
      widget.selectionKey ?? _internalSelectionKey;

  ScrollController get _effectiveScrollController =>
      widget.controller ?? (_ownedController ??= ScrollController());

  @override
  void initState() {
    super.initState();
    _selectionAutoScrollTicker = createTicker(_handleSelectionAutoScrollTick);
    _secondaryClickGuard = TwSelectableSecondaryClickGuard(
      shouldGuard: () => widget.enableWebSecondaryClickGuard && _hasSelection,
      boundsResolver: _resolveGlobalBounds,
    )..attach();
  }

  @override
  void didUpdateWidget(covariant TwSelectableScrollArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == null && widget.controller != null) {
      _ownedController?.dispose();
      _ownedController = null;
    }
  }

  @override
  void dispose() {
    _stopSelectionAutoScroll();
    _selectionAutoScrollTicker.dispose();
    _ownedController?.dispose();
    _secondaryClickGuard.detach();
    super.dispose();
  }

  Rect? _resolveGlobalBounds() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }
    final topLeft = renderObject.localToGlobal(Offset.zero);
    return topLeft & renderObject.size;
  }

  Rect? _resolveSelectionOverlayBounds() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }

    final padding =
        widget.padding?.resolve(Directionality.of(context)) ?? EdgeInsets.zero;
    final size = renderObject.size;
    final localBounds = Rect.fromLTRB(
      padding.left.clamp(0.0, size.width).toDouble(),
      padding.top.clamp(0.0, size.height).toDouble(),
      (size.width - padding.right).clamp(0.0, size.width).toDouble(),
      (size.height - padding.bottom).clamp(0.0, size.height).toDouble(),
    );
    if (localBounds.isEmpty) {
      return null;
    }
    return Rect.fromPoints(
      renderObject.localToGlobal(localBounds.topLeft),
      renderObject.localToGlobal(localBounds.bottomRight),
    );
  }

  void _handleSelectionChanged(SelectedContent? selectedContent) {
    final hasSelection = selectedContent?.plainText.isNotEmpty ?? false;
    if (_hasSelection != hasSelection) {
      setState(() {
        _hasSelection = hasSelection;
      });
    }
    widget.onSelectionChanged?.call(selectedContent);
  }

  void _handleDesktopTap() {
    if (widget.clearSelectionOnDesktopTap) {
      _effectiveSelectionKey.currentState?.clearSelection();
    }
    widget.onDesktopTap?.call();
  }

  void _handleSelectionDragUpdate(Offset globalPosition) {
    _selectionDragGlobalPosition = globalPosition;
    if (_selectionAutoScrollTicker.isTicking) {
      return;
    }
    _handleSelectionAutoScrollTick(Duration.zero);
    if (!_selectionAutoScrollTicker.isTicking) {
      _lastSelectionAutoScrollTick = null;
      _selectionAutoScrollTicker.start();
    }
  }

  void _stopSelectionAutoScroll() {
    _selectionDragGlobalPosition = null;
    _lastSelectionAutoScrollTick = null;
    if (_selectionAutoScrollTicker.isTicking) {
      _selectionAutoScrollTicker.stop();
    }
  }

  void _handleSelectionAutoScrollTick(Duration elapsed) {
    final Offset? dragPosition = _selectionDragGlobalPosition;
    final Rect? bounds = _resolveSelectionOverlayBounds();
    final controller = _effectiveScrollController;
    if (dragPosition == null ||
        bounds == null ||
        !controller.hasClients ||
        widget.scrollDirection != Axis.vertical) {
      _stopSelectionAutoScroll();
      return;
    }

    final position = controller.position;
    final double distanceAbove =
        bounds.top + _selectionAutoScrollBoundary - dragPosition.dy;
    final double distanceBelow =
        dragPosition.dy - (bounds.bottom - _selectionAutoScrollBoundary);
    final double direction;
    final double distance;
    if (distanceAbove > 0 && position.pixels > position.minScrollExtent) {
      direction = -1;
      distance = distanceAbove;
    } else if (distanceBelow > 0 &&
        position.pixels < position.maxScrollExtent) {
      direction = 1;
      distance = distanceBelow;
    } else {
      if (_selectionAutoScrollTicker.isTicking) {
        _selectionAutoScrollTicker.stop();
      }
      _lastSelectionAutoScrollTick = null;
      return;
    }

    final Duration? previousTick = _lastSelectionAutoScrollTick;
    _lastSelectionAutoScrollTick = elapsed;
    final double seconds = previousTick == null
        ? 1 / 60
        : (elapsed - previousTick).inMicroseconds /
              Duration.microsecondsPerSecond;
    final double speedPercent = (distance / _selectionAutoScrollBoundary)
        .clamp(0.0, 1.0)
        .toDouble();
    final double delta =
        direction * _selectionAutoScrollMaxSpeed * speedPercent * seconds;
    if (delta == 0) {
      return;
    }

    final double nextOffset = (position.pixels + delta)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (nextOffset == position.pixels) {
      _stopSelectionAutoScroll();
      return;
    }
    controller.jumpTo(nextOffset);
    _effectiveSelectionKey.currentState?.markViewportScrollInProgress();
    _effectiveSelectionKey.currentState?.refreshSelectionForViewportChange();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final selectionState = _effectiveSelectionKey.currentState;
    if (selectionState == null) {
      return false;
    }

    if (notification is ScrollStartNotification ||
        notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      selectionState.markViewportScrollInProgress();
      selectionState.refreshSelectionForViewportChange();
    } else if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.idle) {
        selectionState.markViewportScrollSettled();
      } else {
        selectionState.markViewportScrollInProgress();
        selectionState.refreshSelectionForViewportChange();
      }
    } else if (notification is ScrollEndNotification) {
      selectionState.markViewportScrollSettled();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;
    final TextSelectionControls resolvedSelectionControls =
        widget.selectionControls ??
        (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
            ? cupertinoTextSelectionHandleControls
            : materialTextSelectionHandleControls);
    final TwSelectableRegionContextMenuBuilder resolvedContextMenuBuilder =
        widget.contextMenuBuilder ??
        (BuildContext context, TwSelectableRegionState selectableRegionState) {
          return _TwSelectionContextMenu(
            anchors: selectableRegionState.contextMenuAnchors,
            buttonItems: selectableRegionState.contextMenuButtonItems,
          );
        };

    Widget result = TwScrollArea.scrollView(
      controller: _effectiveScrollController,
      scrollDirection: widget.scrollDirection,
      primary: widget.primary,
      activationPulse: widget.activationPulse,
      track: widget.track,
      overlayChildren: widget.overlayChildren,
      hideSystemScrollbars: widget.hideSystemScrollbars,
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
      excludeScrollViewFromSelection: true,
      enableDesktopKeyboardScroll: widget.enableDesktopKeyboardScroll,
      keyboardScrollLineStep: widget.keyboardScrollLineStep,
      isKeyboardScrollBlocked: widget.isKeyboardScrollBlocked,
      onDesktopTap: _handleDesktopTap,
      thumbVisibility: widget.thumbVisibility,
      interactive: widget.interactive,
      trackVisibility: widget.trackVisibility,
      fadeDuration: widget.fadeDuration,
      timeToFade: widget.timeToFade,
      child: TwSelectableRegion(
        key: _effectiveSelectionKey,
        contextMenuBuilder: resolvedContextMenuBuilder,
        focusNode: widget.interactionFocusNode,
        magnifierConfiguration: widget.magnifierConfiguration,
        onSelectionChanged: _handleSelectionChanged,
        onSelectionDragUpdate: _handleSelectionDragUpdate,
        onSelectionDragEnd: _stopSelectionAutoScroll,
        selectionOverlayBoundsResolver: _resolveSelectionOverlayBounds,
        selectionControls: resolvedSelectionControls,
        child: widget.child,
      ),
    );

    result = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: result,
    );

    if (widget.actions != null && widget.actions!.isNotEmpty) {
      result = Actions(actions: widget.actions!, child: result);
    }

    if (widget.onPointerDown != null ||
        widget.onPointerUp != null ||
        widget.onPointerCancel != null) {
      result = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: widget.onPointerDown == null
            ? null
            : (_) => widget.onPointerDown!(),
        onPointerUp: widget.onPointerUp == null
            ? null
            : (_) => widget.onPointerUp!(),
        onPointerCancel: widget.onPointerCancel == null
            ? null
            : (_) => widget.onPointerCancel!(),
        child: result,
      );
    }

    return result;
  }
}

class _TwSelectionContextMenu extends StatelessWidget {
  const _TwSelectionContextMenu({
    required this.anchors,
    required this.buttonItems,
  });

  static const double _screenPadding = 8;
  static const double _toolbarGap = 8;

  final TextSelectionToolbarAnchors anchors;
  final List<ContextMenuButtonItem> buttonItems;

  @override
  Widget build(BuildContext context) {
    if (buttonItems.isEmpty) {
      return const SizedBox.shrink();
    }

    VoidCallback? onCopyPressed;
    VoidCallback? onSelectAllPressed;
    for (final buttonItem in buttonItems) {
      switch (buttonItem.type) {
        case ContextMenuButtonType.copy:
          onCopyPressed = buttonItem.onPressed;
        case ContextMenuButtonType.selectAll:
          onSelectAllPressed = buttonItem.onPressed;
        case ContextMenuButtonType.cut:
        case ContextMenuButtonType.paste:
        case ContextMenuButtonType.delete:
        case ContextMenuButtonType.lookUp:
        case ContextMenuButtonType.searchWeb:
        case ContextMenuButtonType.share:
        case ContextMenuButtonType.liveTextInput:
        case ContextMenuButtonType.custom:
          break;
      }
    }

    if (onCopyPressed == null && onSelectAllPressed == null) {
      return AdaptiveTextSelectionToolbar.buttonItems(
        anchors: anchors,
        buttonItems: buttonItems,
      );
    }

    final double paddingAbove =
        MediaQuery.paddingOf(context).top + _screenPadding;
    final localAdjustment = Offset(_screenPadding, paddingAbove);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _screenPadding,
        paddingAbove,
        _screenPadding,
        _screenPadding,
      ),
      child: CustomSingleChildLayout(
        delegate: _TwSelectionToolbarLayoutDelegate(
          anchor: anchors.primaryAnchor - localAdjustment,
          gap: _toolbarGap,
        ),
        child: TwSelectionFloatingToolbar(
          onCopyPressed: onCopyPressed,
          onSelectAllPressed: onSelectAllPressed,
        ),
      ),
    );
  }
}

class _TwSelectionToolbarLayoutDelegate extends SingleChildLayoutDelegate {
  const _TwSelectionToolbarLayoutDelegate({
    required this.anchor,
    required this.gap,
  });

  final Offset anchor;
  final double gap;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double maxX = (size.width - childSize.width).clamp(0.0, size.width);
    final double maxY = (size.height - childSize.height).clamp(
      0.0,
      size.height,
    );
    final double x = (anchor.dx - childSize.width / 2)
        .clamp(0.0, maxX)
        .toDouble();
    final double yAbove = anchor.dy - childSize.height - gap;
    final double yBelow = anchor.dy + gap;
    final double y = (yAbove >= 0.0 ? yAbove : yBelow)
        .clamp(0.0, maxY)
        .toDouble();
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_TwSelectionToolbarLayoutDelegate oldDelegate) {
    return anchor != oldDelegate.anchor || gap != oldDelegate.gap;
  }
}
