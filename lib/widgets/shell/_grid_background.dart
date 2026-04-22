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
  const _GridPainter({required this.gridLineStyle});

  final AppLineStyle gridLineStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = gridLineStyle.createPaint();

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
      oldDelegate.gridLineStyle.color != gridLineStyle.color ||
      oldDelegate.gridLineStyle.width != gridLineStyle.width;
}
