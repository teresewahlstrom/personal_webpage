import 'package:flutter/material.dart';

@immutable
class TwComposerSkin {
  const TwComposerSkin({
    required this.fillColor,
    required this.outlineColor,
    required this.accentColor,
    required this.outlineWidth,
    required this.cornerStrokeWidth,
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
    required this.skin,
    required this.textField,
    required this.minInputHeight,
    required this.maxInputHeight,
    required this.sendButtonMinWidth,
    required this.sendButtonHeight,
    required this.sendButtonIcon,
    required this.sendButtonTooltip,
    required this.onSendPressed,
    this.inputShellKey,
    this.shellRadius = 0.0,
    this.cornerRadius = 0.0,
    this.cornerSegmentLength = 12.0,
    this.sendButtonRadius = 2.0,
    this.sendIconSize = 24.0,
    this.boxShadow = const <BoxShadow>[],
  });

  final TwComposerSkin skin;
  final Widget textField;
  final double minInputHeight;
  final double maxInputHeight;
  final double sendButtonMinWidth;
  final double sendButtonHeight;
  final IconData sendButtonIcon;
  final String sendButtonTooltip;
  final VoidCallback onSendPressed;
  final Key? inputShellKey;
  final double shellRadius;
  final double cornerRadius;
  final double cornerSegmentLength;
  final double sendButtonRadius;
  final double sendIconSize;
  final List<BoxShadow> boxShadow;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: minInputHeight,
        maxHeight: maxInputHeight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: CustomPaint(
              foregroundPainter: TwComposerCornerAccentPainter(
                color: skin.accentColor,
                radius: cornerRadius,
                strokeWidth: skin.cornerStrokeWidth,
                segmentLength: cornerSegmentLength,
              ),
              child: Container(
                key: inputShellKey,
                decoration: BoxDecoration(
                  color: skin.fillColor,
                  borderRadius: BorderRadius.circular(shellRadius),
                  border: Border.all(
                    color: skin.outlineColor,
                    width: skin.outlineWidth,
                  ),
                  boxShadow: boxShadow,
                ),
                constraints: BoxConstraints(
                  minHeight: minInputHeight,
                  maxHeight: maxInputHeight,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(shellRadius),
                  child: textField,
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: sendButtonMinWidth,
              minHeight: sendButtonHeight,
              maxHeight: sendButtonHeight,
            ),
            child: Material(
              color: Colors.transparent,
              child: Tooltip(
                message: sendButtonTooltip,
                child: InkWell(
                  borderRadius: BorderRadius.circular(sendButtonRadius),
                  onTap: onSendPressed,
                  child: Center(
                    child: Icon(
                      sendButtonIcon,
                      size: sendIconSize,
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

class TwComposerCornerAccentPainter extends CustomPainter {
  const TwComposerCornerAccentPainter({
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
  bool shouldRepaint(covariant TwComposerCornerAccentPainter oldDelegate) {
    return color != oldDelegate.color ||
        radius != oldDelegate.radius ||
        strokeWidth != oldDelegate.strokeWidth ||
        segmentLength != oldDelegate.segmentLength;
  }
}
