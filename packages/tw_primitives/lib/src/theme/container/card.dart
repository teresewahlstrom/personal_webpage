import 'package:flutter/gestures.dart' show kPrimaryButton, kTouchSlop;
import 'package:flutter/material.dart';
import '../colors/router.dart';
import '../text_styles/router.dart';

class TwExpandableCard extends StatefulWidget {
  const TwExpandableCard({
    super.key,
    required this.title,
    required this.childBuilder,
    required this.isExpanded,
    required this.onTap,
    this.border,
    this.backgroundColor,
    this.headerPadding = const EdgeInsets.fromLTRB(15, 7, 7, 7),
    this.contentPadding = const EdgeInsets.fromLTRB(15, 0, 15, 15),
  });

  final String title;
  final Widget Function(BuildContext context, bool isExpanded) childBuilder;
  final bool isExpanded;
  final VoidCallback onTap;
  final BoxBorder? border;
  final Color? backgroundColor;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry contentPadding;

  @override
  State<TwExpandableCard> createState() => _TwExpandableCardState();
}

class _TwExpandableCardState extends State<TwExpandableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  bool _isHovered = false;
  int? _headerPointer;
  Offset? _headerPointerDownPosition;
  bool _headerTapEligible = false;

  final GlobalKey _headerKey = GlobalKey();
  ScrollPosition? _scrollPosition;
  double _floatOffset = 0.0;
  bool _isFloating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _heightAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.addListener(_onScroll);
    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  bool _lastFullyExpanded = false;
  Widget? _cachedChild;

  @override
  void didUpdateWidget(TwExpandableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
    // Invalidate the child cache when the widget configuration changes,
    // so we pick up theme changes, new documents, etc., but we preserve
    // the cache during internal state changes (hover, scroll).
    _cachedChild = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateScrollListener();
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _animationController.removeListener(_onScroll);
    _animationController.dispose();
    super.dispose();
  }

  ScrollPosition? _findScrollPosition() {
    try {
      final ScrollableState? scrollable = Scrollable.maybeOf(context);
      return scrollable?.position;
    } catch (_) {
      return null;
    }
  }

  void _updateScrollListener() {
    final ScrollPosition? newPosition = _findScrollPosition();
    if (newPosition != _scrollPosition) {
      _scrollPosition?.removeListener(_onScroll);
      _scrollPosition = newPosition;
      _scrollPosition?.addListener(_onScroll);
      if (newPosition != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _onScroll();
        });
      }
    }
  }

  void _onScroll() {
    final bool isClosed = !widget.isExpanded && _heightAnimation.isDismissed;
    if (isClosed) {
      if (_floatOffset != 0.0 || _isFloating) {
        setState(() {
          _floatOffset = 0.0;
          _isFloating = false;
        });
      }
      return;
    }
    try {
      final RenderBox? cardBox = context.findRenderObject() as RenderBox?;
      final RenderBox? scrollableBox =
          Scrollable.maybeOf(context)?.context.findRenderObject() as RenderBox?;
      if (cardBox != null &&
          scrollableBox != null &&
          cardBox.hasSize &&
          scrollableBox.hasSize) {
        final double cardTopInScrollable =
            cardBox.localToGlobal(Offset.zero, ancestor: scrollableBox).dy;
        final RenderBox? headerBox =
            _headerKey.currentContext?.findRenderObject() as RenderBox?;
        final double headerHeight = headerBox?.size.height ?? 0.0;
        final double cardHeight = cardBox.size.height;
        final double maxFloatOffset = cardHeight - headerHeight;

        final double newOffset =
            (-cardTopInScrollable).clamp(0.0, maxFloatOffset);
        final bool newIsFloating =
            cardTopInScrollable < 0 && newOffset < maxFloatOffset;

        if (newOffset != _floatOffset || newIsFloating != _isFloating) {
          setState(() {
            _floatOffset = newOffset;
            _isFloating = newIsFloating;
          });
        }
      }
    } catch (_) {
      // Safely ignore if render bounds are accessed during disposal/inactive state
    }
  }

  void _clearHeaderPointerTracking() {
    _headerPointer = null;
    _headerPointerDownPosition = null;
    _headerTapEligible = false;
  }

  void _handleCardTap() {
    widget.onTap();
  }

  void _handleHeaderPointerDown(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton) {
      _clearHeaderPointerTracking();
      return;
    }
    _headerPointer = event.pointer;
    _headerPointerDownPosition = event.position;
    _headerTapEligible = true;
  }

  void _handleHeaderPointerMove(PointerMoveEvent event) {
    if (!_headerTapEligible ||
        event.pointer != _headerPointer ||
        _headerPointerDownPosition == null) {
      return;
    }
    if ((event.position - _headerPointerDownPosition!).distance > kTouchSlop) {
      _headerTapEligible = false;
    }
  }

  void _handleHeaderPointerUp(PointerUpEvent event) {
    final bool shouldToggle =
        _headerTapEligible && event.pointer == _headerPointer;
    _clearHeaderPointerTracking();
    if (shouldToggle) {
      _handleCardTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateScrollListener();

    final Color cardFill = widget.backgroundColor ?? Color.lerp(
      context.twColors.pageBackground,
      context.twColors.lineSubtle,
      context.twColors.cardFillAlpha,
    )!;

    final baseIconColor =
        TwTextStyles.of(context).bodyForContext(
          context: context,
          color: context.twColors.pageBodyText,
        ).color ??
        Theme.of(context).textTheme.bodyMedium?.color ??
        context.twColors.pageBodyText;
    final Color iconColor = _isHovered ? context.twColors.linkTextHover : baseIconColor;

    final tokens = TwTextStyleTokens.forBrightness(Theme.of(context).brightness);
    final baseStyle = TwTextStyles.of(context).bodyForContextless(
      color: context.twColors.pageBodyText,
      textScale: MediaQuery.textScalerOf(context).scale(tokens.twBodyBaseFontSize) / tokens.twBodyBaseFontSize,
    );
    final h2 = TwTextStyles.of(context).h2From(baseStyle);
    final TextStyle cardTitleStyle = TwTextStyles.of(context).cardTitleFrom(h2);


    final border = widget.border ?? Border.all(
      color: context.twColors.lineSubtle,
      width: 1.0,
    );

    Widget buildHeader({Key? key}) {
      return DefaultSelectionStyle(
        mouseCursor: SystemMouseCursors.click,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Listener(
            key: key,
            behavior: HitTestBehavior.opaque,
            onPointerDown: _handleHeaderPointerDown,
            onPointerMove: _handleHeaderPointerMove,
            onPointerUp: _handleHeaderPointerUp,
            onPointerCancel: (_) => _clearHeaderPointerTracking(),
            child: Padding(
              padding: widget.headerPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Opacity(
                      opacity: context.twColors.cardMarkdownOpacity,
                      child: Text(widget.title, style: cardTitleStyle),
                    ),
                  ),
                  RotationTransition(
                    turns: Tween<double>(
                      begin: 0,
                      end: 0.5,
                    ).animate(_heightAnimation),
                    child: Icon(Icons.expand_more, color: iconColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final Widget header = buildHeader(key: _headerKey);

    final bool isClosed = !widget.isExpanded && _heightAnimation.isDismissed;
    if (isClosed) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cardFill,
            border: border,
            borderRadius: BorderRadius.zero,
          ),
          child: header,
        ),
      );
    }

    final Widget cardChild = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        header,
        SizeTransition(
          sizeFactor: _heightAnimation,
          child: AnimatedBuilder(
            animation: _heightAnimation,
            builder: (BuildContext context, Widget? child) {
              final bool fullyExpanded = _heightAnimation.value >= 1.0;
              if (_heightAnimation.status == AnimationStatus.dismissed) {
                return SelectionContainer.disabled(child: const SizedBox.shrink());
              }
              if (_cachedChild == null || _lastFullyExpanded != fullyExpanded) {
                _lastFullyExpanded = fullyExpanded;
                _cachedChild = widget.childBuilder(context, fullyExpanded);
              }
              return Padding(
                padding: widget.contentPadding,
                child: _cachedChild!,
              );
            },
          ),
        ),
      ],
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardFill,
          border: border,
          borderRadius: BorderRadius.zero,
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            // 1. Content and placeholder
            cardChild,

            if (_isFloating) ...<Widget>[
              // 2. Floating Top Shadow / Gradient
              Positioned(
                top: _floatOffset,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _heightAnimation,
                  builder: (context, child) {
                    double headerHeight = 44.0;
                    try {
                      final RenderBox? headerBox = _headerKey.currentContext?.findRenderObject() as RenderBox?;
                      if (headerBox != null && headerBox.hasSize) {
                        headerHeight = headerBox.size.height;
                      }
                    } catch (_) {}
                    final double floatOpacity = (_floatOffset / 16.0).clamp(0.0, 1.0);
                    final double alphaFactor = _heightAnimation.value * floatOpacity;
                    return IgnorePointer(
                      child: Container(
                        height: headerHeight + 13.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              cardFill.withValues(alpha: alphaFactor),
                              cardFill.withValues(alpha: 0.92 * alphaFactor),
                              cardFill.withValues(alpha: 0.8 * alphaFactor),
                              cardFill.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.16, 0.75, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 3. Floating Header
              Positioned(
                top: _floatOffset,
                left: 0,
                right: 0,
                child: SelectionContainer.disabled(
                  child: buildHeader(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
