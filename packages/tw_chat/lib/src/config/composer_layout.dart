import 'package:flutter/material.dart';

import '../utils/math.dart';
import 'skin.dart';

class ChatComposerLayout {
  const ChatComposerLayout._();

  /// Lower guardrail for composer input height in compact layouts.
  static const minHeightFloor = 34.0;

  /// Upper guardrail for single-line composer input height before expansion.
  static const minHeightCeiling = 52.0;

  /// Maximum expanded composer input height before internal scrolling.
  static const expandedHeight = 132.0;

  /// Panel heights used to interpolate compactness and control input scaling.
  static const compactPanelHeight = 240.0;
  static const roomyPanelHeight = 520.0;

  /// Baseline width for the send/stop action touch target.
  ///
  /// Width scales up with accessibility text scaling.
  static const sendButtonMinWidthFloor = 50.0;
  static const fillColor = ChatColors.composerFill;
  static const borderColor = ChatColors.composerBorder;
  static const cursorColor = ChatColors.composerCursor;
  static const cornerAccentColor = ChatColors.composerCornerAccent;
  static const sendIconColor = ChatColors.composerSendIcon;

  static TextStyle hintStyle(double textScale) {
    return ChatTextStyles.composerHintStyle(textScale);
  }

  static ChatComposerMetrics resolveMetrics({
    required double panelHeight,
    required double textScale,
  }) {
    final scale = (!textScale.isFinite || textScale <= 0)
        ? ChatTextStyles.minTextScale
        : textScale;
    final compactnessT =
        1.0 -
        ChatMath.normalized(panelHeight, compactPanelHeight, roomyPanelHeight);

    final baseInputHeight = ChatMath.lerp(40.0, 36.0, compactnessT);
    final scaledMinInputHeightCeiling = ChatMath.scaleFromOne(
      minHeightCeiling,
      scale,
      0.9,
    );
    final scaledInputHeight = ChatMath.scaleFromOne(
      baseInputHeight,
      scale,
      0.9,
    ).clamp(minHeightFloor, scaledMinInputHeightCeiling);

    final scaledExpandedHeight = ChatMath.scaleFromOne(
      expandedHeight,
      scale,
      0.8,
    );
    final maxInputHeight = scaledExpandedHeight.clamp(
      scaledInputHeight,
      double.infinity,
    );

    final sendButtonMinWidth = ChatMath.scaleFromOne(
      sendButtonMinWidthFloor,
      scale,
      0.55,
    ).clamp(sendButtonMinWidthFloor, double.infinity);

    return ChatComposerMetrics(
      minInputHeight: scaledInputHeight,
      maxInputHeight: maxInputHeight,
      sendButtonMinWidth: sendButtonMinWidth,
    );
  }
}

class ChatComposerMetrics {
  const ChatComposerMetrics({
    required this.minInputHeight,
    required this.maxInputHeight,
    required this.sendButtonMinWidth,
  });

  final double minInputHeight;
  final double maxInputHeight;
  final double sendButtonMinWidth;
}
