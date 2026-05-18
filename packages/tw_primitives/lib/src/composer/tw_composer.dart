import 'package:flutter/material.dart';

class TwComposerSkin {
  const TwComposerSkin({
    required this.fillColor,
    required this.outlineColor,
    required this.accentColor,
    this.outlineWidth = 1.0,
    this.cornerStrokeWidth = 2.0,
  });

  final Color fillColor;
  final Color outlineColor;
  final Color accentColor;
  final double outlineWidth;
  final double cornerStrokeWidth;
}

class TwComposer extends StatelessWidget {
  const TwComposer({
    super.key,
    required this.input,
    required this.skin,
    required this.actionIcon,
    required this.actionTooltip,
    required this.onActionPressed,
    required this.minHeight,
    required this.maxHeight,
    required this.actionMinWidth,
    required this.actionHeight,
    this.radius = 0.0,
    this.cornerRadius = 0.0,
    this.cornerSegmentLength = 12.0,
    this.actionRadius = 2.0,
    this.actionIconSize = 25.0,
    this.boxShadow = const <BoxShadow>[],
    this.shellKey,
  });

  final Widget input;
  final TwComposerSkin skin;
  final IconData actionIcon;
  final String actionTooltip;
  final VoidCallback onActionPressed;
  final double minHeight;
  final double maxHeight;
  final double actionMinWidth;
  final double actionHeight;
  final double radius;
  final double cornerRadius;
  final double cornerSegmentLength;
  final double actionRadius;
  final double actionIconSize;
  final List<BoxShadow> boxShadow;
  final Key? shellKey;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: CustomPaint(
              key: const ValueKey('tw-composer-frame'),
              foregroundPainter: TwComposerCornerPainter(
                color: skin.accentColor,
                radius: cornerRadius,
                strokeWidth: skin.cornerStrokeWidth,
                segmentLength: cornerSegmentLength,
              ),
              child: DecoratedBox(
                key: const ValueKey('tw-composer-shell'),
                decoration: BoxDecoration(
                  color: skin.fillColor,
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: skin.outlineColor,
                    width: skin.outlineWidth,
                  ),
                  boxShadow: boxShadow,
                ),
                child: ConstrainedBox(
                  key: shellKey,
                  constraints: BoxConstraints(
                    minHeight: minHeight,
                    maxHeight: maxHeight,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: input,
                  ),
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: actionMinWidth,
              minHeight: actionHeight,
              maxHeight: actionHeight,
            ),
            child: Material(
              color: Colors.transparent,
              child: Tooltip(
                message: actionTooltip,
                child: InkWell(
                  key: const ValueKey('tw-composer-action'),
                  borderRadius: BorderRadius.circular(actionRadius),
                  onTap: onActionPressed,
                  child: Center(
                    child: Icon(
                      actionIcon,
                      size: actionIconSize,
                      color: skin.accentColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TwComposerCornerPainter extends CustomPainter {
  const TwComposerCornerPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.segmentLength,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double segmentLength;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    final left = rect.left;
    final right = rect.right;
    final top = rect.top;
    final bottom = rect.bottom;

    final path = Path()
      ..moveTo(left + radius, top)
      ..lineTo(left + radius + segmentLength, top)
      ..moveTo(left, top + radius)
      ..lineTo(left, top + radius + segmentLength)
      ..moveTo(right - radius - segmentLength, top)
      ..lineTo(right - radius, top)
      ..moveTo(right, top + radius)
      ..lineTo(right, top + radius + segmentLength)
      ..moveTo(left + radius, bottom)
      ..lineTo(left + radius + segmentLength, bottom)
      ..moveTo(left, bottom - radius)
      ..lineTo(left, bottom - radius - segmentLength)
      ..moveTo(right - radius - segmentLength, bottom)
      ..lineTo(right - radius, bottom)
      ..moveTo(right, bottom - radius)
      ..lineTo(right, bottom - radius - segmentLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TwComposerCornerPainter oldDelegate) {
    return color != oldDelegate.color ||
        radius != oldDelegate.radius ||
        strokeWidth != oldDelegate.strokeWidth ||
        segmentLength != oldDelegate.segmentLength;
  }
}
