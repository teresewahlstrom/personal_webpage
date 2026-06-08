import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../config/app_ui_config.dart';

class GridBackground extends StatelessWidget {
  const GridBackground({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.gridLineStyle,
  });

  final Widget child;
  final Color backgroundColor;
  final AppLineStyle gridLineStyle;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final HSLColor baseHsl = HSLColor.fromColor(backgroundColor);
    final double topSaturation =
        (baseHsl.saturation + 0.10).clamp(0.0, 1.0).toDouble();
    final double topLightness =
        (baseHsl.lightness + 0.06).clamp(0.0, 1.0).toDouble();
    final double bottomLightness =
        (baseHsl.lightness - 0.05).clamp(0.0, 1.0).toDouble();
    final Color gradientTop = isDark
        ? baseHsl
              .withSaturation(topSaturation)
              .withLightness(topLightness)
              .toColor()
        : backgroundColor;
    final Color gradientMiddle = backgroundColor;
    final Color gradientBottom = isDark
        ? baseHsl.withLightness(bottomLightness).toColor()
        : backgroundColor;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            gradientTop,
            gradientMiddle,
            gradientBottom,
          ],
          stops: const <double>[0.0, 0.52, 1.0],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GridPainter(gridLineStyle: gridLineStyle),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({
    required this.gridLineStyle,
  });

  final AppLineStyle gridLineStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;

    // To keep the scale/width of the grid tiles at the bottom of the screen
    // constant when the window is resized vertically, we position the horizon
    // and origin relative to the bottom of the screen (size.height).
    // This locks the vertical perspective geometry to the viewport bottom.
    final double horizonY = size.height - 790.0;

    final double centerX = size.width / 2;
    // Vanishing points are located at a fixed horizontal distance from the center,
    // independent of screen size.
    final double vpDistanceX = 1600.0;

    final Offset vpLeft = Offset(
      centerX - vpDistanceX,
      horizonY,
    );

    final Offset vpRight = Offset(
      centerX + vpDistanceX,
      horizonY,
    );

    // Place the nearest virtual grid intersection far below the viewport.
    // Positioned relative to size.height to keep the distance to the bottom constant.
    final Offset origin = Offset(
      centerX,
      size.height + 1300.0,
    );

    // Constant cell size independent of screen size.
    final double nearCellSize = 135.0;

    final double scaleLeft = _calculatePerspectiveScale(
      origin: origin,
      vanishingPoint: vpLeft,
      desiredNearStep: nearCellSize,
    );

    final double scaleRight = _calculatePerspectiveScale(
      origin: origin,
      vanishingPoint: vpRight,
      desiredNearStep: nearCellSize,
    );

    final Color baseColor = gridLineStyle.color;

    _paintDepthLayer(canvas, size, baseColor);

    final ui.Shader verticalFade = ui.Gradient.linear(
      Offset(0, horizonY),
      Offset(0, size.height),
      <Color>[
        baseColor.withValues(alpha: 0.00),
        baseColor.withValues(alpha: 0.00),
        baseColor.withValues(alpha: 0.65),
        baseColor.withValues(alpha: 0.95),
      ],
      const <double>[
        0.00,
        0.45,
        0.75,
        1.00,
      ],
    );

    final Paint minorPaint = Paint()
      ..shader = verticalFade
      ..strokeWidth = gridLineStyle.width
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final Paint majorPaint = Paint()
      ..shader = verticalFade
      ..strokeWidth = gridLineStyle.width * 1.35
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final ui.Shader glowFade = ui.Gradient.linear(
      Offset(0, horizonY),
      Offset(0, size.height),
      <Color>[
        baseColor.withValues(alpha: 0.0),
        baseColor.withValues(alpha: 0.0),
        baseColor.withValues(alpha: 0.25),
        baseColor.withValues(alpha: 0.55),
      ],
      const <double>[0.0, 0.38, 0.70, 1.0],
    );

    final Paint glowPaint = Paint()
      ..shader = glowFade
      ..strokeWidth = gridLineStyle.width * 4.25
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5)
      ..isAntiAlias = true;

    final ui.Shader radialMask = ui.Gradient.radial(
      Offset(size.width * 0.50, size.height * 0.92),
      size.longestSide * 0.95,
      <Color>[
        baseColor.withValues(alpha: 0.98),
        baseColor.withValues(alpha: 0.82),
        baseColor.withValues(alpha: 0.46),
        baseColor.withValues(alpha: 0.10),
        baseColor.withValues(alpha: 0.0),
      ],
      const <double>[0.0, 0.30, 0.58, 0.84, 1.0],
    );

    canvas.save();
    canvas.clipRect(bounds);
    canvas.saveLayer(bounds, Paint());

    const int lineCount = 75;

    // Family A:
    // Lines follow the rightward grid axis and converge toward vpRight.
    for (int u = 0; u <= lineCount; u++) {
      final Offset start = _projectGridPoint(
        origin: origin,
        vpLeft: vpLeft,
        vpRight: vpRight,
        scaleLeft: scaleLeft,
        scaleRight: scaleRight,
        u: u.toDouble(),
        v: 0,
      );

      final Offset end = _projectGridPoint(
        origin: origin,
        vpLeft: vpLeft,
        vpRight: vpRight,
        scaleLeft: scaleLeft,
        scaleRight: scaleRight,
        u: u.toDouble(),
        v: lineCount.toDouble(),
      );

      canvas.drawLine(
        start,
        end,
        glowPaint,
      );
      canvas.drawLine(
        start,
        end,
        u % 5 == 0 ? majorPaint : minorPaint,
      );
    }

    // Family B:
    // Lines follow the leftward grid axis and converge toward vpLeft.
    for (int v = 0; v <= lineCount; v++) {
      final Offset start = _projectGridPoint(
        origin: origin,
        vpLeft: vpLeft,
        vpRight: vpRight,
        scaleLeft: scaleLeft,
        scaleRight: scaleRight,
        u: 0,
        v: v.toDouble(),
      );

      final Offset end = _projectGridPoint(
        origin: origin,
        vpLeft: vpLeft,
        vpRight: vpRight,
        scaleLeft: scaleLeft,
        scaleRight: scaleRight,
        u: lineCount.toDouble(),
        v: v.toDouble(),
      );

      canvas.drawLine(
        start,
        end,
        glowPaint,
      );
      canvas.drawLine(
        start,
        end,
        v % 5 == 0 ? majorPaint : minorPaint,
      );
    }

    final Paint radialMaskPaint = Paint()
      ..shader = radialMask
      ..blendMode = BlendMode.dstIn;
    canvas.drawRect(bounds, radialMaskPaint);
    canvas.restore();
    canvas.restore();
  }

  void _paintDepthLayer(Canvas canvas, Size size, Color baseColor) {
    final Rect bounds = Offset.zero & size;
    final Offset upperCenter = Offset(size.width * 0.52, size.height * 0.34);
    final Paint atmospherePaint = Paint()
      ..shader = ui.Gradient.radial(
        upperCenter,
        size.shortestSide * 0.68,
        <Color>[
          baseColor.withValues(alpha: 0.050),
          baseColor.withValues(alpha: 0.018),
          baseColor.withValues(alpha: 0.0),
        ],
        const <double>[0.0, 0.48, 1.0],
      );
    canvas.drawRect(bounds, atmospherePaint);

    final Paint structuralPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.075)
      ..style = PaintingStyle.stroke
      ..strokeWidth = gridLineStyle.width * 0.75
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    final Paint structuralGlowPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = gridLineStyle.width * 4.5
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final List<Path> traces = <Path>[
      Path()
        ..moveTo(size.width * 0.12, size.height * 0.26)
        ..lineTo(size.width * 0.38, size.height * 0.20)
        ..lineTo(size.width * 0.62, size.height * 0.28),
      Path()
        ..moveTo(size.width * 0.78, size.height * 0.38)
        ..lineTo(size.width * 0.58, size.height * 0.46)
        ..lineTo(size.width * 0.34, size.height * 0.40),
      Path()
        ..moveTo(size.width * 0.20, size.height * 0.58)
        ..lineTo(size.width * 0.43, size.height * 0.54)
        ..lineTo(size.width * 0.70, size.height * 0.61),
    ];

    for (final Path trace in traces) {
      canvas.drawPath(trace, structuralGlowPaint);
      canvas.drawPath(trace, structuralPaint);
    }

    final Paint particlePaint = Paint()
      ..color = baseColor.withValues(alpha: 0.11)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final List<Offset> particles = <Offset>[
      Offset(size.width * 0.18, size.height * 0.33),
      Offset(size.width * 0.37, size.height * 0.23),
      Offset(size.width * 0.64, size.height * 0.30),
      Offset(size.width * 0.76, size.height * 0.42),
      Offset(size.width * 0.28, size.height * 0.56),
      Offset(size.width * 0.58, size.height * 0.52),
    ];

    for (final Offset particle in particles) {
      canvas.drawCircle(particle, 1.0, particlePaint);
    }
  }

  double _calculatePerspectiveScale({
    required Offset origin,
    required Offset vanishingPoint,
    required double desiredNearStep,
  }) {
    final double distance = (vanishingPoint - origin).distance;

    // Prevent invalid values if layout dimensions are unexpectedly small.
    final double safeStep = desiredNearStep.clamp(1.0, distance * 0.45);

    return safeStep / (distance - safeStep);
  }

  Offset _projectGridPoint({
    required Offset origin,
    required Offset vpLeft,
    required Offset vpRight,
    required double scaleLeft,
    required double scaleRight,
    required double u,
    required double v,
  }) {
    // Homogeneous projective mapping.
    //
    // u and v are logical square-grid coordinates.
    // Equal increments represent equal distances in the virtual plane.
    // Perspective compression occurs naturally after division by w.

    final double w = 1 + u * scaleLeft + v * scaleRight;

    final double x = (
      origin.dx +
      u * scaleLeft * vpLeft.dx +
      v * scaleRight * vpRight.dx
    ) / w;

    final double y = (
      origin.dy +
      u * scaleLeft * vpLeft.dy +
      v * scaleRight * vpRight.dy
    ) / w;

    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.gridLineStyle.color != gridLineStyle.color ||
        oldDelegate.gridLineStyle.width != gridLineStyle.width;
  }
}
