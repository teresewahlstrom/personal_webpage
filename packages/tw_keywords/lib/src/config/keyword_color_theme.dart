import 'package:flutter/material.dart';

enum KeywordTextColorToken {
  cyan,
  magenta,
  slate,
  charcoal,
}

final class KeywordTextPalette {
  const KeywordTextPalette({
    required this.cyan,
    required this.magenta,
    required this.slate,
    required this.charcoal,
  });

  final Color cyan;
  final Color magenta;
  final Color slate;
  final Color charcoal;

  Color forToken(KeywordTextColorToken token) {
    return switch (token) {
      KeywordTextColorToken.cyan => cyan,
      KeywordTextColorToken.magenta => magenta,
      KeywordTextColorToken.slate => slate,
      KeywordTextColorToken.charcoal => charcoal,
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
    charcoal: Color(0xFF3A3F47),
  ),
);

const KeywordSkinData keywordDarkSkin = KeywordSkinData(
  // Intentionally identical for now; split is in place for future divergence.
  textColors: KeywordTextPalette(
    cyan: Color(0xFF43ADCF),
    magenta: Color(0xFFE12D80),
    slate: Color(0xFF555B68),
    charcoal: Color(0xFF3A3F47),
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
