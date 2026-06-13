import 'package:flutter/material.dart';

import '../colors/router.dart';

typedef TwFeatureCardBuilder =
    Widget Function(BuildContext context, TwFeatureCardBuildState state);

const double _kFeatureCardRadius = 18.0;
const double _kFeatureCardRestScale = 1.0;
const double _kFeatureCardHoverScale = 1.015;
const double _kFeatureCardRestImageScale = 1.0;
const double _kFeatureCardHoverImageScale = 1.05;
const Duration _kFeatureCardAnimationDuration = Duration(milliseconds: 200);
const Curve _kFeatureCardAnimationCurve = Curves.easeOutCubic;
const EdgeInsets _kFeatureCardCompactPadding = EdgeInsets.symmetric(
  horizontal: 6.0,
  vertical: 8.0,
);
const EdgeInsets _kFeatureCardRegularPadding = EdgeInsets.symmetric(
  horizontal: 10.0,
  vertical: 12.0,
);

class TwFeatureCardBuildState {
  const TwFeatureCardBuildState({required this.isHovered});

  final bool isHovered;

  Duration get animationDuration => _kFeatureCardAnimationDuration;
  Curve get animationCurve => _kFeatureCardAnimationCurve;
  double get imageScale =>
      isHovered ? _kFeatureCardHoverImageScale : _kFeatureCardRestImageScale;
}

class TwFeatureCardSurface extends StatefulWidget {
  const TwFeatureCardSurface({
    super.key,
    required this.builder,
    this.onTap,
    this.isCompact = false,
  });

  final TwFeatureCardBuilder builder;
  final VoidCallback? onTap;
  final bool isCompact;

  @override
  State<TwFeatureCardSurface> createState() => _TwFeatureCardSurfaceState();
}

class _TwFeatureCardSurfaceState extends State<TwFeatureCardSurface> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.twColors;
    final isDark = context.twIsDark;
    final scale = _isHovered ? _kFeatureCardHoverScale : _kFeatureCardRestScale;
    final padding = widget.isCompact
        ? _kFeatureCardCompactPadding
        : _kFeatureCardRegularPadding;

    return MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: widget.onTap == null
            ? HitTestBehavior.deferToChild
            : HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: scale,
          duration: _kFeatureCardAnimationDuration,
          curve: _kFeatureCardAnimationCurve,
          child: AnimatedContainer(
            duration: _kFeatureCardAnimationDuration,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_kFeatureCardRadius),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  colors.capabilityCardBgStart,
                  colors.capabilityCardBgMid,
                  colors.capabilityCardBgEnd,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: _featureCardShadows(
                colors: colors,
                isDark: isDark,
                isHovered: _isHovered,
              ),
            ),
            child: CustomPaint(
              foregroundPainter: _TwFeatureCardBevelPainter(
                radius: _kFeatureCardRadius,
                colors: colors,
                isDark: isDark,
              ),
              child: Padding(
                padding: padding,
                child: widget.builder(
                  context,
                  TwFeatureCardBuildState(isHovered: _isHovered),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<BoxShadow> _featureCardShadows({
  required TwColors colors,
  required bool isDark,
  required bool isHovered,
}) {
  final shadowColor = colors.capabilityCardShadowColor;
  final shadowHoverColor = colors.capabilityCardShadowHoverColor;
  final activeColor = colors.capabilityCardActive;

  if (isDark) {
    return isHovered
        ? [
            BoxShadow(
              color: shadowHoverColor.withValues(alpha: 0.45),
              blurRadius: 20.0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: activeColor.withValues(alpha: 0.20),
              blurRadius: 8.0,
              offset: const Offset(0, 3),
            ),
          ]
        : [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.35),
              blurRadius: 12.0,
              offset: const Offset(0, 4),
            ),
          ];
  }

  return isHovered
      ? [
          BoxShadow(
            color: shadowHoverColor.withValues(alpha: 0.22),
            blurRadius: 26,
            spreadRadius: 0,
            offset: const Offset(-8, 15),
          ),
          BoxShadow(
            color: shadowHoverColor.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(-2.5, 5),
          ),
        ]
      : [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.18),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(-6, 11),
          ),
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.12),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(-2, 4),
          ),
        ];
}

class _TwFeatureCardBevelPainter extends CustomPainter {
  const _TwFeatureCardBevelPainter({
    required this.radius,
    required this.colors,
    required this.isDark,
  });

  final double radius;
  final TwColors colors;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;

    final outerRect = fullRect.deflate(0.75);
    final outerRRect = RRect.fromRectAndRadius(
      outerRect,
      Radius.circular(radius),
    );

    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: isDark
            ? [
                colors.capabilityCardBevelHighlight.withValues(alpha: 0.188),
                colors.capabilityCardBevelHighlight.withValues(alpha: 0.082),
                colors.capabilityCardBevelShadow.withValues(alpha: 0.376),
                colors.capabilityCardBevelShadow.withValues(alpha: 0.564),
              ]
            : [
                colors.capabilityCardBevelHighlight.withValues(alpha: 0.85),
                colors.capabilityCardBevelHighlight.withValues(alpha: 0.0),
                colors.capabilityCardBevelShadow.withValues(alpha: 0.0),
                colors.capabilityCardBevelShadow.withValues(alpha: 0.12),
              ],
        stops: isDark
            ? const [0.0, 0.36, 0.72, 1.0]
            : const [0.0, 0.35, 0.65, 1.0],
      ).createShader(fullRect);

    canvas.drawRRect(outerRRect, outerPaint);

    final innerRect = fullRect.deflate(2.1);
    final innerRRect = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(radius - 1.6),
    );

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: isDark
            ? [
                colors.capabilityCardBevelHighlight.withValues(alpha: 0.094),
                colors.capabilityCardBevelHighlight.withValues(alpha: 0.031),
                colors.capabilityCardBevelShadow.withValues(alpha: 0.125),
                colors.capabilityCardBevelShadow.withValues(alpha: 0.250),
              ]
            : [
                colors.capabilityCardBevelHighlight.withValues(alpha: 0.25),
                colors.capabilityCardBevelHighlight.withValues(alpha: 0.0),
                colors.capabilityCardBevelShadow.withValues(alpha: 0.0),
                colors.capabilityCardBevelShadow.withValues(alpha: 0.05),
              ],
        stops: isDark
            ? const [0.0, 0.42, 0.74, 1.0]
            : const [0.0, 0.35, 0.65, 1.0],
      ).createShader(fullRect);

    canvas.drawRRect(innerRRect, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _TwFeatureCardBevelPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.colors != colors ||
        oldDelegate.isDark != isDark;
  }
}
