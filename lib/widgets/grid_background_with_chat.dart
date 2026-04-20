import 'package:flutter/material.dart';

/// A reusable widget that combines a grid background with content.
/// 
/// Use this widget to display content over a grid background pattern.
/// The grid and content are properly layered with IgnorePointer on the grid
/// to allow interaction with content beneath.
class GridBackgroundWithChat extends StatelessWidget {
  const GridBackgroundWithChat({
    super.key,
    required this.child,
    this.gridColor = const Color(0xFFF8F9F7),
    this.gridLineColor = const Color(0xFFE1E4F2),
  });

  /// The main content to display on top of the grid background.
  final Widget child;

  /// Background color of the grid.
  final Color gridColor;

  /// Color of the grid lines.
  final Color gridLineColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: gridColor,
      child: Stack(
        children: <Widget>[
          // Grid background
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GridPainter(gridLineColor: gridLineColor),
              ),
            ),
          ),
          // Main content
          child,
        ],
      ),
    );
  }
}

/// Custom painter that renders a grid pattern.
class _GridPainter extends CustomPainter {
  const _GridPainter({required this.gridLineColor});

  final Color gridLineColor;

  static const double _spacing = 25;
  static const double _yStart = 15;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = gridLineColor
      ..strokeWidth = 1;

    final double xStart = (size.width / 2) % _spacing;
    for (double x = xStart; x <= size.width; x += _spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double x = xStart - _spacing; x >= 0; x -= _spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    for (double y = _yStart; y <= size.height; y += _spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    for (double y = _yStart - _spacing; y >= 0; y -= _spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.gridLineColor != gridLineColor;
}
