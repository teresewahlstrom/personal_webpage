import 'package:flutter/cupertino.dart' show cupertinoTextSelectionControls;
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show RenderBox, ScrollDirection, SelectedContent;

import '../selection/tw_selectable_region.dart';
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

class _TwSelectableScrollAreaState extends State<TwSelectableScrollArea> {
  late final TwSelectableSecondaryClickGuard _secondaryClickGuard;
  final GlobalKey<TwSelectableRegionState> _internalSelectionKey =
      GlobalKey<TwSelectableRegionState>();
  bool _hasSelection = false;

  GlobalKey<TwSelectableRegionState> get _effectiveSelectionKey =>
      widget.selectionKey ?? _internalSelectionKey;

  @override
  void initState() {
    super.initState();
    _secondaryClickGuard = TwSelectableSecondaryClickGuard(
      shouldGuard: () => widget.enableWebSecondaryClickGuard && _hasSelection,
      boundsResolver: _resolveGlobalBounds,
    )..attach();
  }

  @override
  void dispose() {
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

  void _handleSelectionChanged(SelectedContent? selectedContent) {
    final hasSelection = (selectedContent?.plainText ?? '').trim().isNotEmpty;
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
            ? cupertinoTextSelectionControls
            : materialTextSelectionControls);

    Widget result = TwScrollArea.scrollView(
      controller: widget.controller,
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
        contextMenuBuilder: widget.contextMenuBuilder,
        focusNode: widget.interactionFocusNode,
        magnifierConfiguration: widget.magnifierConfiguration,
        onSelectionChanged: _handleSelectionChanged,
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
