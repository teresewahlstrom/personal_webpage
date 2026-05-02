//keyword_color_theme.dart

import 'package:flutter/material.dart';

enum KeywordTextColorToken {
  cyan,
  magenta,
  slate,
}

final class KeywordTextPalette {
  const KeywordTextPalette({
    required this.cyan,
    required this.magenta,
    required this.slate,
  });

  final Color cyan;
  final Color magenta;
  final Color slate;

  Color forToken(KeywordTextColorToken token) {
    return switch (token) {
      KeywordTextColorToken.cyan => cyan,
      KeywordTextColorToken.magenta => magenta,
      KeywordTextColorToken.slate => slate,
    };
  }
}

final class KeywordSkinData {
  const KeywordSkinData({required this.textColors});

  final KeywordTextPalette textColors;
}

const KeywordSkinData keywordLightSkin = KeywordSkinData(
  textColors: KeywordTextPalette(
    cyan: Color(0xFF43ADCF),
    magenta: Color(0xFFE12D80),
    slate: Color(0xFF555B68),
  ),
);

const KeywordSkinData keywordDarkSkin = KeywordSkinData(
  // Intentionally identical for now; split is in place for future divergence.
  textColors: KeywordTextPalette(
    cyan: Color(0xFF90E8F8),
    magenta: Color(0xFFE12D80),
    slate: Color(0xFF555B68),
  ),
);

class KeywordSkin {
  KeywordSkin._();

  static KeywordSkinData dataForBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? keywordDarkSkin : keywordLightSkin;
  }

  static Color textColorForToken(
    KeywordTextColorToken token,
    Brightness brightness,
  ) {
    return dataForBrightness(brightness).textColors.forToken(token);
  }
}
