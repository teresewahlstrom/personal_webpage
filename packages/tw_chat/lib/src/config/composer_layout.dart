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
  static Color get fillColor => ChatSkin.data.colors.composerFill;
  static Color get borderColor => ChatSkin.data.colors.composerBorder;
  static Color get cursorColor => ChatSkin.data.colors.composerCursor;
  static Color get cornerAccentColor =>
      ChatSkin.data.colors.composerCornerAccent;
  static Color get sendIconColor => ChatSkin.data.colors.composerSendIcon;

  static TextStyle hintStyle(double textScale) {
    final skin = ChatSkin.data;
    return skin.textStyles.composerHintStyle(textScale, skin.colors);
  }

  static ChatComposerMetrics resolveMetrics({
    required double panelHeight,
    required double textScale,
  }) {
    final skin = ChatSkin.data;
    final scale = (!textScale.isFinite || textScale <= 0)
        ? skin.textStyles.minTextScale
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
