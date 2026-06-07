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
    return Container(
      color: backgroundColor,
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

    canvas.save();
    canvas.clipRect(bounds);

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
        v % 5 == 0 ? majorPaint : minorPaint,
      );
    }

    canvas.restore();
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
