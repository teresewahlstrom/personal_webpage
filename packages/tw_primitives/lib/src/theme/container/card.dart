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
    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    final lifts = HSLColor.fromColor(context.twColors.pageBodyText);
    final lifted = lifts.withLightness((lifts.lightness * 1.10).clamp(0.0, 1.0));
    final strongStyle = baseStyle.copyWith(
      fontWeight: tokens.twStrongFontWeight,
      color: lifted.toColor(),
    );
    final h2 = strongStyle.copyWith(
      fontSize: baseStyle.fontSize! * tokens.twCardH2Scale,
      fontWeight: tokens.twH2FontWeight,
      height: 1.2,
      letterSpacing: tokens.twH2LetterSpacing,
      wordSpacing: tokens.twH2WordSpacing,
    );
    final TextStyle cardTitleStyle = TwTextStyles.of(context).cardTitleFrom(h2);

    final border = widget.border ?? Border.all(
      color: context.twColors.lineSubtle,
      width: 1.0,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Listener(
                behavior: HitTestBehavior.translucent,
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
            SizeTransition(
              sizeFactor: _heightAnimation,
              child: AnimatedBuilder(
                animation: _heightAnimation,
                builder: (BuildContext context, Widget? child) {
                  final bool fullyExpanded = _heightAnimation.value >= 1.0;
                  if (_heightAnimation.status == AnimationStatus.dismissed) {
                    return SelectionContainer.disabled(child: const SizedBox.shrink());
                  }
                  return Padding(
                    padding: widget.contentPadding,
                    child: widget.childBuilder(context, fullyExpanded),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
