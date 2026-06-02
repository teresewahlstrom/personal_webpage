import 'package:flutter/material.dart';

EdgeInsets resolveScrollAreaContentPadding({
  required EdgeInsetsGeometry? contentPadding,
  required Axis scrollDirection,
  required TextDirection textDirection,
  required double scrollbarColumnWidth,
}) {
  final EdgeInsets basePadding =
      contentPadding?.resolve(textDirection) ?? EdgeInsets.zero;
  if (scrollbarColumnWidth <= 0) {
    return basePadding;
  }

  return switch (scrollDirection) {
    Axis.horizontal => EdgeInsets.fromLTRB(
      basePadding.left,
      basePadding.top,
      basePadding.right,
      basePadding.bottom + scrollbarColumnWidth,
    ),
    _ => textDirection == TextDirection.rtl
        ? EdgeInsets.fromLTRB(
            basePadding.left + scrollbarColumnWidth,
            basePadding.top,
            basePadding.right,
            basePadding.bottom,
          )
        : EdgeInsets.fromLTRB(
            basePadding.left,
            basePadding.top,
            basePadding.right + scrollbarColumnWidth,
            basePadding.bottom,
          ),
  };
}

double resolveScrollbarColumnWidth({
  required double? scrollbarColumnWidth,
  required double thickness,
  required double crossAxisMargin,
}) {
  return (scrollbarColumnWidth ?? (thickness + (crossAxisMargin * 2)))
      .clamp(0.0, double.infinity)
      .toDouble();
}
