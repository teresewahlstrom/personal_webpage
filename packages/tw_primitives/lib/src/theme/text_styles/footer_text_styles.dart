import 'package:flutter/material.dart';

import 'body_text_style.dart';

final class TwFooterTextStyles {
  static const double baseFontSize = 16.0;

  static TextStyle bodyForContext({
    required BuildContext context,
    required Color color,
  }) {
    final TextStyle baseStyle = TwBodyTextStyle.bodyForContext(
      context: context,
      color: color,
    );
    final double resolvedTextScale = TwBodyTextStyle.resolveTextScale(
      MediaQuery.textScalerOf(context).scale(baseFontSize) / baseFontSize,
    );
    return baseStyle.copyWith(
      fontSize: TwBodyTextStyle.scaledFontSize(baseFontSize, resolvedTextScale),
    );
  }

  static TextStyle linkForContext({
    required BuildContext context,
    required Color color,
  }) {
    return bodyForContext(context: context, color: color);
  }
}