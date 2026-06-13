import 'package:flutter/material.dart';
import '../theme/text_styles/router.dart';

class TwMarkdownLayoutTokens {
  const TwMarkdownLayoutTokens._({
    required this.twH2ToBodySpacing,
  });

  static TwMarkdownLayoutTokens forBrightness(Brightness brightness) {
    final textTokens = TwTextStyleTokens.forBrightness(brightness);
    return TwMarkdownLayoutTokens._(
      twH2ToBodySpacing:
          textTokens.twBodyBaseFontSize * 0.75 +
          (textTokens.twBodyBaseFontSize * textTokens.twH2Scale) * -0.14,
    );
  }

  final double twH2ToBodySpacing;
}

extension TwMarkdownLayoutTokensBuildContextExtension on BuildContext {
  TwMarkdownLayoutTokens get twMarkdownLayoutTokens =>
      TwMarkdownLayoutTokens.forBrightness(Theme.of(this).brightness);
}
