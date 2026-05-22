class MarkupViewStyle {
  const MarkupViewStyle();

  final double blockquoteRailWidth = 0.4;
  final double blockBaseSpacingFactor = 0.75;
  final double blockquoteExtraSpacing = 1.2;
  final double listTopSpacingAdjustment = -0.12;
  final double nestedListTopSpacingAdjustment = -0.59;
  final double nestedListBottomSpacingAdjustment = -0.55;
  final double blockquoteTopSpacingAdjustment = -0.6;
  final double listBottomSpacingAdjustment = 0.45;
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
