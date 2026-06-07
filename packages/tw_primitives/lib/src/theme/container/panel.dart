import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SelectedContent;
import '../colors/router.dart';
import '../text_styles/router.dart';
import '../../../scrollbar.dart'
    show TwScrollArea, TwSelectableScrollArea, TwSelectableRegionState;
import 'pill.dart' show TwLinkPill;

/// A shared, canonical title widget matching the Chat title pill visual.
class TwPanelTitle extends StatelessWidget {
  const TwPanelTitle({
    super.key,
    required this.label,
    this.onTap,
    this.clickable,
  });

  final String label;
  final VoidCallback? onTap;
  final bool? clickable;

  @override
  Widget build(BuildContext context) {
    return TwLinkPill(
      key: const ValueKey('chat-app-bar-title-pill'),
      label: label,
      onTap: onTap,
      clickable: clickable,
    );
  }
}

class TwPanelScope extends InheritedWidget {
  const TwPanelScope({
    super.key,
    required this.hasHeader,
    required this.overlapHeader,
    this.containerPadding,
    required this.bottomShadowHeight,
    required this.footerHeight,
    required super.child,
  });

  final bool hasHeader;
  final bool overlapHeader;
  final EdgeInsetsGeometry? containerPadding;
  final double bottomShadowHeight;
  final double footerHeight;

  static TwPanelScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TwPanelScope>();
  }

  @override
  bool updateShouldNotify(TwPanelScope oldWidget) {
    return hasHeader != oldWidget.hasHeader ||
        overlapHeader != oldWidget.overlapHeader ||
        containerPadding != oldWidget.containerPadding ||
        bottomShadowHeight != oldWidget.bottomShadowHeight ||
        footerHeight != oldWidget.footerHeight;
  }
}

/// A highly polished, premium container that unifies the layout and aesthetics
/// of the Chat shell and Modal dialog frames.
class TwPanelContainer extends StatefulWidget {
  const TwPanelContainer({
    super.key,
    required this.body,
    this.title,
    this.onClose,
    this.closeIcon = Icons.close,
    this.closeIconSize,
    this.closeTooltip = 'Close',
    this.isCloseTooltipVisible = true,
    this.footer,
    this.bottomShadowHeight = 0.0,
    this.padding,
    this.borderRadius = BorderRadius.zero,
    this.backgroundColor,
    this.overlapHeader = true,
  });

  final Widget body;
  final Widget? title;
  final VoidCallback? onClose;
  final IconData closeIcon;
  final double? closeIconSize;
  final String closeTooltip;
  final bool isCloseTooltipVisible;
  final Widget? footer;
  final double bottomShadowHeight;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final bool overlapHeader;

  @override
  State<TwPanelContainer> createState() => _TwPanelContainerState();
}

class _TwPanelContainerState extends State<TwPanelContainer> {
  double _footerHeight = 0.0;
  final GlobalKey _footerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureFooter());
  }

  @override
  void didUpdateWidget(TwPanelContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureFooter());
  }

  void _measureFooter() {
    if (!mounted) return;
    if (widget.footer == null) {
      if (_footerHeight != 0.0) {
        setState(() {
          _footerHeight = 0.0;
        });
      }
      return;
    }
    final RenderBox? renderBox =
        _footerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final double newHeight = renderBox.size.height;
      if (newHeight != _footerHeight) {
        setState(() {
          _footerHeight = newHeight;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.twColors;

    // Standardized background, border, and shadow from twColors
    final bg = widget.backgroundColor ?? colors.shellBackground;
    final baseShadow = colors.shellOuterShadow;
    final boostedBase = baseShadow.withValues(
      alpha: (baseShadow.a * 1.35).clamp(0.16, 0.62),
    );
    final accentTint = colors.composerSendIcon.withValues(
      alpha: boostedBase.a * 0.32,
    );
    final shadowColor = Color.alphaBlend(accentTint, boostedBase);
    final shellShadow = BoxShadow(
      color: shadowColor,
      blurRadius: 26,
      offset: const Offset(0, 12),
    );

    final backgroundDecoration = BoxDecoration(
      color: bg,
      borderRadius: widget.borderRadius,
      boxShadow: [shellShadow],
    );

    final foregroundDecoration = BoxDecoration(
      borderRadius: widget.borderRadius,
      border: Border.all(color: colors.shellOuterBorder, width: 1.0),
    );

    // Build the standardized header matching ChatAppBar
    Widget? headerWidget;
    if (widget.title != null || widget.onClose != null) {
      final baseTitleStyle = TwTextStyles.of(
        context,
      ).bodyForContextless(color: colors.bubbleText, textScale: 1.0);
      final titleSmallStyle = TwTextStyles.of(
        context,
      ).smallFrom(baseTitleStyle);
      final finalTitleStyle = TwTextStyles.of(context).adaptBase(
        titleSmallStyle,
        color: colors.bubbleText,
        fontSize: baseTitleStyle.fontSize != null
            ? baseTitleStyle.fontSize! * 0.7
            : null,
      );
      final iconColor = finalTitleStyle.color ?? colors.bubbleText;

      final titlePill = widget.title ?? const SizedBox.shrink();

      Widget? actionWidget;
      if (widget.onClose != null) {
        actionWidget = SizedBox(
          key: const ValueKey('chat-app-bar-action-container'),
          width: 40.0,
          child: Material(
            color: colors.transparent,
            child: TooltipVisibility(
              visible: widget.isCloseTooltipVisible,
              child: Tooltip(
                message: widget.closeTooltip,
                child: Semantics(
                  button: true,
                  label: widget.closeTooltip,
                  child: InkWell(
                    onTap: widget.onClose,
                    child: Center(
                      child: Icon(
                        widget.closeIcon,
                        color: iconColor,
                        size: widget.closeIconSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      headerWidget = SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 8, 8, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 48.0),
                    child: titlePill,
                  ),
                ],
              ),
            ),
            if (actionWidget != null)
              Positioned(
                key: const ValueKey('chat-app-bar-action-bounds'),
                top: 0,
                right: 0,
                bottom: 0,
                width: 40.0,
                child: FractionallySizedBox(
                  alignment: Alignment.topCenter,
                  heightFactor: 0.75,
                  child: actionWidget,
                ),
              ),
          ],
        ),
      );
    }

    // Top shadow gradient definition
    final List<double> topStops = const [0.0, 0.45, 0.82, 1.0];
    final List<int> topAlphas = const [0xFF, 0xED, 0xCD, 0x33];
    final topShadowDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: topAlphas
            .map((a) => colors.shellBackground.withAlpha(a))
            .toList(),
        stops: topStops,
      ),
    );

    // Bottom shadow gradient definition
    final List<double> bottomStops = const [0.0, 0.24, 0.88, 1.0];
    final List<int> bottomAlphas = const [0xFF, 0xEF, 0xD3, 0x4D];
    final bottomShadowDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: bottomAlphas
            .map((a) => colors.shellBackground.withAlpha(a))
            .toList(),
        stops: bottomStops,
      ),
    );

    final bool hasHeader = widget.title != null || widget.onClose != null;
    final Widget scopedBody = TwPanelScope(
      hasHeader: hasHeader,
      overlapHeader: widget.overlapHeader,
      containerPadding: widget.padding,
      bottomShadowHeight: widget.bottomShadowHeight,
      footerHeight: _footerHeight,
      child: widget.body,
    );

    final Widget mainContent;
    if (widget.overlapHeader) {
      mainContent = Stack(
        children: [
          Positioned.fill(child: scopedBody),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 32.0,
            child: IgnorePointer(
              child: DecoratedBox(decoration: topShadowDecoration),
            ),
          ),
          if (headerWidget != null)
            Positioned(top: 0, left: 0, right: 0, child: headerWidget),
          if (widget.bottomShadowHeight > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: widget.bottomShadowHeight,
              child: IgnorePointer(
                child: DecoratedBox(decoration: bottomShadowDecoration),
              ),
            ),
          if (widget.footer != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: NotificationListener<LayoutChangedNotification>(
                onNotification: (notification) {
                  _measureFooter();
                  return false;
                },
                child: SizeChangedLayoutNotifier(
                  child: KeyedSubtree(key: _footerKey, child: widget.footer!),
                ),
              ),
            ),
        ],
      );
    } else {
      mainContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?headerWidget,
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: widget.padding != null
                      ? Padding(padding: widget.padding!, child: scopedBody)
                      : scopedBody,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 32.0,
                  child: IgnorePointer(
                    child: DecoratedBox(decoration: topShadowDecoration),
                  ),
                ),
                if (widget.bottomShadowHeight > 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: widget.bottomShadowHeight,
                    child: IgnorePointer(
                      child: DecoratedBox(decoration: bottomShadowDecoration),
                    ),
                  ),
              ],
            ),
          ),
          ?widget.footer,
        ],
      );
    }

    final Widget decorated = DecoratedBox(
      decoration: backgroundDecoration,
      child: DecoratedBox(
        decoration: foregroundDecoration,
        position: DecorationPosition.foreground,
        child: mainContent,
      ),
    );

    if (widget.borderRadius == BorderRadius.zero) {
      return ClipRect(child: decorated);
    } else {
      return ClipRRect(borderRadius: widget.borderRadius, child: decorated);
    }
  }
}

/// A wrapper around standard Tw scroll areas that consistently enforces
/// chat-grade scrollbar styling, sizing, thickness, and colors.
class TwPanelScrollArea extends StatelessWidget {
  const TwPanelScrollArea({
    super.key,
    required this.child,
    this.controller,
    this.selectable = false,
    this.scrollbarInsets = EdgeInsets.zero,
    this.showTrack = false,
    this.onPointerDown,
    this.onPointerUp,
    this.onPointerCancel,
    this.padding,
    this.contentPhysics = const ClampingScrollPhysics(),
    this.interactionFocusNode,
    this.selectionKey,
    this.onSelectionChanged,
    this.actions,
    this.scrollbarColumnWidth,
    this.overlapHeaderTopInset = 40.0,
  });

  final Widget child;
  final ScrollController? controller;
  final bool selectable;
  final EdgeInsetsGeometry scrollbarInsets;
  final bool showTrack;
  final VoidCallback? onPointerDown;
  final VoidCallback? onPointerUp;
  final VoidCallback? onPointerCancel;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics contentPhysics;
  final double? scrollbarColumnWidth;

  final FocusNode? interactionFocusNode;
  final GlobalKey<TwSelectableRegionState>? selectionKey;
  final ValueChanged<SelectedContent?>? onSelectionChanged;
  final Map<Type, Action<Intent>>? actions;
  final double overlapHeaderTopInset;

  @override
  Widget build(BuildContext context) {
    final colors = context.twColors;
    final thumbColor = colors.scrollbarThumb;
    final thumbInactiveColor = colors.scrollbarThumbInactive;
    final trackColor = showTrack ? colors.scrollbarTrack : null;

    const thickness = 7.0;
    const minThumbLength = 15.0;
    const crossAxisMargin = 0.0;
    final reservedScrollbarSpan =
        scrollbarColumnWidth ?? (thickness + (crossAxisMargin * 2));

    final panelScope = TwPanelScope.maybeOf(context);
    EdgeInsetsGeometry effectivePadding =
        padding ?? const EdgeInsets.fromLTRB(10, 0, 10, 10);
    if (panelScope != null) {
      if (panelScope.overlapHeader && panelScope.containerPadding != null) {
        effectivePadding = panelScope.containerPadding!.add(effectivePadding);
      }
      if (panelScope.hasHeader && panelScope.overlapHeader) {
        final double headerPaddingShift = overlapHeaderTopInset;
        effectivePadding = EdgeInsets.only(
          top: headerPaddingShift,
        ).add(effectivePadding);
      }
      if (panelScope.overlapHeader) {
        final double bottomOffset =
            panelScope.bottomShadowHeight + panelScope.footerHeight;
        if (bottomOffset > 0) {
          effectivePadding = EdgeInsets.only(
            bottom: bottomOffset,
          ).add(effectivePadding);
        }
      }
    }

    EdgeInsetsGeometry effectiveScrollbarInsets = const EdgeInsets.only(
      right: 2.0,
    ).add(scrollbarInsets);
    if (panelScope != null) {
      if (panelScope.hasHeader && panelScope.overlapHeader) {
        final double currentTop = scrollbarInsets
            .resolve(TextDirection.ltr)
            .top;
        final double unifiedHeaderScrollbarInset = overlapHeaderTopInset - 8.0;
        if (currentTop < unifiedHeaderScrollbarInset) {
          effectiveScrollbarInsets = EdgeInsets.only(
            top: unifiedHeaderScrollbarInset - currentTop,
          ).add(effectiveScrollbarInsets);
        }
      }
      if (panelScope.overlapHeader) {
        final double bottomOffset =
            panelScope.bottomShadowHeight + panelScope.footerHeight;
        if (bottomOffset > 0) {
          final double currentBottom = scrollbarInsets
              .resolve(TextDirection.ltr)
              .bottom;
          if (currentBottom < bottomOffset) {
            effectiveScrollbarInsets = EdgeInsets.only(
              bottom: bottomOffset - currentBottom,
            ).add(effectiveScrollbarInsets);
          }
        }
      }
    }

    if (selectable) {
      return TwSelectableScrollArea.scrollView(
        key: key,
        controller: controller,
        selectionKey: selectionKey,
        interactionFocusNode: interactionFocusNode,
        onSelectionChanged: onSelectionChanged,
        onPointerDown: onPointerDown,
        onPointerUp: onPointerUp,
        onPointerCancel: onPointerCancel,
        actions: actions,
        magnifierConfiguration: TextMagnifierConfiguration.disabled,
        thumbColor: thumbColor,
        thumbInactiveColor: thumbInactiveColor,
        scrollbarTrackColor: trackColor,
        thickness: thickness,
        minThumbLength: minThumbLength,
        crossAxisMargin: crossAxisMargin,
        scrollbarColumnWidth: reservedScrollbarSpan,
        scrollbarInsets: effectiveScrollbarInsets,
        radius: const Radius.circular(100),
        thumbVisibility: true,
        interactive: true,
        padding: effectivePadding,
        contentPhysics: contentPhysics,
        child: child,
      );
    } else {
      return TwScrollArea.scrollView(
        key: key,
        controller: controller,
        onPointerDown: onPointerDown,
        onPointerUp: onPointerUp,
        onPointerCancel: onPointerCancel,
        thumbColor: thumbColor,
        thumbInactiveColor: thumbInactiveColor,
        scrollbarTrackColor: trackColor,
        thickness: thickness,
        minThumbLength: minThumbLength,
        crossAxisMargin: crossAxisMargin,
        scrollbarColumnWidth: reservedScrollbarSpan,
        scrollbarInsets: effectiveScrollbarInsets,
        radius: const Radius.circular(100),
        thumbVisibility: true,
        interactive: true,
        padding: effectivePadding,
        contentPhysics: contentPhysics,
        child: child,
      );
    }
  }
}
