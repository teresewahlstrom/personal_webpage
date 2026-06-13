import 'package:flutter/material.dart';
import 'markup_view_style.dart';

class BlockQuoteRailPainter extends CustomPainter {
  const BlockQuoteRailPainter({
    required this.color,
    required this.railThickness,
    required this.capLength,
    required this.railInset,
  });

  final Color color;
  final double railThickness;
  final double capLength;
  final double railInset;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0 || color.a == 0.0) {
      return;
    }

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = railThickness
      ..strokeCap = StrokeCap.square;

    const double verticalOvershoot = MarkupViewStyle.blockquoteRailVerticalOverhang;
    final double railX = railInset + railThickness / 2;
    final double topY = -verticalOvershoot;
    final double bottomY = size.height + verticalOvershoot;
    final double maxCapLength = (size.width - railX).clamp(
      0.0,
      double.infinity,
    );
    final double boundedCapLength = capLength.clamp(0.0, maxCapLength);

    canvas.drawLine(Offset(railX, topY), Offset(railX, bottomY), paint);
    canvas.drawLine(
      Offset(railX, topY),
      Offset(railX + boundedCapLength, topY),
      paint,
    );
    canvas.drawLine(
      Offset(railX, bottomY),
      Offset(railX + boundedCapLength, bottomY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant BlockQuoteRailPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.railThickness != railThickness ||
        oldDelegate.capLength != capLength ||
        oldDelegate.railInset != railInset;
  }
}
