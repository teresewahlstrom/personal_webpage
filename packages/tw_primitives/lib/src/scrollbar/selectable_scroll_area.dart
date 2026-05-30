import 'package:flutter/cupertino.dart'
    show cupertinoTextSelectionHandleControls;
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
        contextMenuBuilder: resolvedContextMenuBuilder,
        focusNode: widget.interactionFocusNode,
        magnifierConfiguration: widget.magnifierConfiguration,
        onSelectionChanged: _handleSelectionChanged,
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

  bool _usesHorizontalDesktopToolbar(TargetPlatform platform) {
    return switch (platform) {
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => true,
      TargetPlatform.android ||
      TargetPlatform.fuchsia ||
      TargetPlatform.iOS => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (buttonItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final platform = Theme.of(context).platform;
    if (!_usesHorizontalDesktopToolbar(platform)) {
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
        delegate: _TwHorizontalSelectionToolbarLayoutDelegate(
          anchor: anchors.primaryAnchor - localAdjustment,
          gap: _toolbarGap,
        ),
        child: Material(
          borderRadius: const BorderRadius.all(Radius.circular(7)),
          clipBehavior: Clip.antiAlias,
          elevation: 1,
          type: MaterialType.card,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, buttonItem) in buttonItems.indexed) ...[
                _TwSelectionContextMenuButton(buttonItem: buttonItem),
                if (index < buttonItems.length - 1)
                  const SizedBox(
                    height: 24,
                    child: VerticalDivider(width: 1, thickness: 1),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TwSelectionContextMenuButton extends StatelessWidget {
  const _TwSelectionContextMenuButton({required this.buttonItem});

  final ContextMenuButtonItem buttonItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor = theme.colorScheme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
    return TextButton(
      style: TextButton.styleFrom(
        enabledMouseCursor: SystemMouseCursors.basic,
        disabledMouseCursor: SystemMouseCursors.basic,
        foregroundColor: foregroundColor,
        minimumSize: const Size(kMinInteractiveDimension, 36),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 1),
        shape: const RoundedRectangleBorder(),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
      onPressed: buttonItem.onPressed,
      child: Text(
        AdaptiveTextSelectionToolbar.getButtonLabel(context, buttonItem),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }
}

class _TwHorizontalSelectionToolbarLayoutDelegate
    extends SingleChildLayoutDelegate {
  const _TwHorizontalSelectionToolbarLayoutDelegate({
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
    final double x = (anchor.dx - childSize.width / 2)
        .clamp(0.0, (size.width - childSize.width).clamp(0.0, size.width))
        .toDouble();
    final double y = (anchor.dy - childSize.height - gap)
        .clamp(0.0, (size.height - childSize.height).clamp(0.0, size.height))
        .toDouble();
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_TwHorizontalSelectionToolbarLayoutDelegate oldDelegate) {
    return anchor != oldDelegate.anchor || gap != oldDelegate.gap;
  }
}
