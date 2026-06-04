// Canonical markdown-related tokens for decoration thickness and biases.
// These values are used by the markdown rendering pipeline for underline
// and strikethrough geometry. They were previously in
// `markdown_tokens.dart` but are kept here to centralize markup view
// styling.
// Note: these values were previously top-level constants. They are now
// provided as static members of `MarkupViewStyle` to keep markup-related
// styling grouped together.

class MarkupViewStyle {
  const MarkupViewStyle();

  // Canonical markdown-related tokens for decoration thickness and biases.
  // These are exposed as static constants so callers can access them as
  // `MarkupViewStyle.twMarkdownUnderlineThickness` without polluting the
  // top-level namespace.
  static const double underlineThickness = 1.75;
  static const double decorationThicknessBias = 0.15;
  static const double strikethroughLightThicknessBias = 0.9;
  static const double strikethroughDarkThicknessBias = 4.0;

  // Backwards-compatible non-bias names used by other markdown builders.
  static const double strikethroughLightThickness =
      strikethroughLightThicknessBias;
  static const double strikethroughDarkThickness =
      strikethroughDarkThicknessBias;

  // Presentation/layout tokens used by the markup view renderer.
  static const double unorderedListMarkerSizeFactor = 0.30;
  static const double unorderedListMarkerVerticalOffsetFactor = 0.60;
  static const double blockquoteRailVerticalOverhang = 3.0;
  static const double blockquoteInnerVerticalPadding = 2.0;

  final double blockquoteRailWidth = 0.4;
  final double blockBaseSpacingFactor = 0.75;
  final double blockquoteExtraSpacing = 1.2;
  final double listTopSpacingAdjustment = -0.12;
  final double nestedListTopSpacingAdjustment = -0.59;
  final double nestedListBottomSpacingAdjustment = -0.55;
  final double blockquoteTopSpacingAdjustment = 0.0;
  final double listBottomSpacingAdjustment = 1.05;
  final List<double> headingBottomSpacingFactors = const <double>[-0.12, -0.14];
  final List<double> headingTopSpacingFactors = const <double>[1.0, 1.0];
  final double listItemBaseSpacingFactor = 0.26;
  final double topLevelListItemSpacingAdjustment = 0.52;
  final double listMarkerGapFactor = 0.3333333333;
  final double topLevelListMarkerSlotFactor = 2.0;
  final double nestedListMarkerSlotFactor = 1.75;
  final double blockquoteIndentFactor = 0.4;
  final double blockquoteCapLength = 12.0;
  final double blockquoteRailInset = 5.0;

  double headingBottomSpacingFactorForLevel(int level) {
    return _factorByLevel(headingBottomSpacingFactors, level);
  }

  double headingTopSpacingFactorForLevel(int level) {
    return _factorByLevel(headingTopSpacingFactors, level);
  }

  double _factorByLevel(List<double> factors, int level) {
    final int index = level.clamp(1, factors.length).toInt() - 1;
    return factors[index];
  }
}

const MarkupViewStyle kMarkupViewStyle = MarkupViewStyle();
