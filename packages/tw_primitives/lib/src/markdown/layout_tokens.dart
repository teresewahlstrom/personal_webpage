import 'package:flutter/material.dart';

class TwMarkdownLayoutTokens {
  const TwMarkdownLayoutTokens._({
    required this.twH2ToBodySpacing,
  });

  // Layout tokens are intentionally theme-agnostic.
  static const double twBodyBaseFontSize = 17.0;
  static const double twH2Scale = 1.3;
  static const double _twH2ToBodySpacing =
      twBodyBaseFontSize * 0.75 +
      (twBodyBaseFontSize * twH2Scale) * -0.14;

  static const TwMarkdownLayoutTokens instance = TwMarkdownLayoutTokens._(
    twH2ToBodySpacing: _twH2ToBodySpacing,
  );

  final double twH2ToBodySpacing;
}

extension TwMarkdownLayoutTokensBuildContextExtension on BuildContext {
  TwMarkdownLayoutTokens get twMarkdownLayoutTokens => TwMarkdownLayoutTokens.instance;
}
