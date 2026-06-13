import 'package:flutter/material.dart';
import 'package:tw_primitives/src/text_field/infrastructure/blinking_caret.dart';
import 'package:tw_primitives/src/text_field/infrastructure/touch_controls.dart';
import 'package:super_text_layout/super_text_layout.dart';

/// An iOS-style text selection handle.
///
/// On iOS, drag handles are drawn differently depending on
/// whether the handle appears in the [HandleType.upstream]
/// position (the left side in left-to-right text), or in the
/// [HandleType.downstream] position (the right side in
/// right-to-left text). The upstream handle displays a vertical
/// caret with a circle on top of the caret. The downstream handle
/// displays a vertical caret with a circle on the bottom of the caret.
///
/// The collapsed handle looks like a standard text caret.
///
/// [IOSSelectionHandle] doesn't handle any gestures. The responsibility
/// of user interaction is left to the client for the following reasons:
///   * the touch area should be larger than the painted area because
///     the handle is very thin
///   * handle drag gestures may need to co-exist with other gestures
///     related to text interaction
class IOSSelectionHandle extends StatelessWidget {
  static const double defaultOutlineWidth = 0.5;

  const IOSSelectionHandle.upstream({
    super.key,
    required this.color,
    required this.caretHeight,
    this.outlineColor,
    this.caretWidth = 2,
    this.ballRadius = 4,
    this.handleType = HandleType.upstream,
  });

  const IOSSelectionHandle.downstream({
    super.key,
    required this.color,
    required this.caretHeight,
    this.outlineColor,
    this.caretWidth = 2,
    this.ballRadius = 4,
    this.handleType = HandleType.downstream,
  });

  /// The color of the caret and ball in the handle.
  final Color color;

  /// The color of the outline around the caret and ball.
  final Color? outlineColor;

  /// The height of the caret, excluding the ball.
  final double caretHeight;

  /// The width of the caret, excluding the ball.
  final double caretWidth;

  /// The radius of the ball that's displayed above or
  /// below the caret.
  final double ballRadius;

  /// The type of handle, e.g., upstream, downstream, collapsed.
  final HandleType handleType;

  @override
  Widget build(BuildContext context) {
    switch (handleType) {
      case HandleType.upstream:
      case HandleType.downstream:
        return _buildExpandedHandle();
      default:
        throw Exception("Bad handle type: $handleType");
    }
  }

  Widget _buildExpandedHandle() {
    final ballDiameter = ballRadius * 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show the ball on the top for an upstream handle
        if (handleType == HandleType.upstream)
          Container(
            width: ballDiameter,
            height: ballDiameter,
            decoration: BoxDecoration(
              color: color,
              border: _outlineBorder,
              shape: BoxShape.circle,
            ),
          ),
        Container(
          width: caretWidth,
          height: caretHeight,
          decoration: BoxDecoration(
            color: color,
            border: _outlineBorder,
          ),
        ),
        // Show the ball on the bottom for a downstream handle
        if (handleType == HandleType.downstream)
          Container(
            width: ballDiameter,
            height: ballDiameter,
            decoration: BoxDecoration(
              color: color,
              border: _outlineBorder,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Border? get _outlineBorder => outlineColor == null
      ? null
      : Border.all(
          color: outlineColor!,
          width: defaultOutlineWidth,
        );
}

/// An iOS-style caret/collapsed selection handle.
class IOSCollapsedHandle extends StatelessWidget {
  const IOSCollapsedHandle({
    super.key,
    this.controller,
    required this.color,
    required this.caretHeight,
    this.outlineColor,
    this.caretWidth = 2,
  });

  /// The controller for the handle/caret's blinking behavior.
  final BlinkController? controller;

  /// The color of the caret and ball in the handle.
  final Color color;

  /// The color of the outline around the caret handle.
  final Color? outlineColor;

  /// The height of the caret, excluding the ball.
  final double caretHeight;

  /// The width of the caret, excluding the ball.
  final double caretWidth;

  @override
  Widget build(BuildContext context) {
    final caret = BlinkingCaret(
      controller: controller,
      caretOffset: Offset.zero,
      caretHeight: caretHeight,
      width: caretWidth,
      color: color,
      borderRadius: BorderRadius.zero,
      isTextEmpty: false,
      showCaret: true,
    );

    if (outlineColor == null) {
      return caret;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: outlineColor!,
          width: IOSSelectionHandle.defaultOutlineWidth,
        ),
      ),
      child: caret,
    );
  }
}
