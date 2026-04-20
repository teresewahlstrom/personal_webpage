import 'package:flutter/material.dart';

import '../../config/app_ui_config.dart';

class GridBackground extends StatelessWidget {
  const GridBackground({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFFF8F9F7),
    this.gridLineColor = const Color(0xFFE1E4F2),
  });

  final Widget child;
  final Color backgroundColor;
  final Color gridLineColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GridPainter(gridLineColor: gridLineColor),
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
  const _GridPainter({required this.gridLineColor});

  final Color gridLineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = gridLineColor
      ..strokeWidth = 1;

    final double xStart = (size.width / 2) % ShellUiConfig.gridSpacing;
    for (double x = xStart; x <= size.width; x += ShellUiConfig.gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double x = xStart - ShellUiConfig.gridSpacing;
        x >= 0;
        x -= ShellUiConfig.gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    for (double y = ShellUiConfig.gridYStart;
        y <= size.height;
        y += ShellUiConfig.gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    for (double y = ShellUiConfig.gridYStart - ShellUiConfig.gridSpacing;
        y >= 0;
        y -= ShellUiConfig.gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.gridLineColor != gridLineColor;
}
