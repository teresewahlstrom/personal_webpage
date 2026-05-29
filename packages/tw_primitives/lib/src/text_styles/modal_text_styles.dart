import 'package:flutter/material.dart';

import 'body_text_style.dart';

final class TwModalTextStyles {
  static const double _headerTitleLineHeight = 1.0;

  static TextStyle headerTitle({required Color color}) {
    return const TextStyle(
      fontFamily: TwBodyTextStyle.fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 24,
      height: _headerTitleLineHeight,
    ).copyWith(color: color);
  }

  static TextStyle closeGlyph({required Color color}) {
    return const TextStyle(fontSize: 28, height: 1).copyWith(color: color);
  }
}