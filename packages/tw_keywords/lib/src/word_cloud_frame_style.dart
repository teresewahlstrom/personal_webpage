import 'package:flutter/material.dart';

final class WordCloudFrameStyle {
  const WordCloudFrameStyle({
    required this.backgroundColor,
    required this.borderColor,
    this.padding = const EdgeInsets.all(0),
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.borderWidth = 1,
  });

  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final double borderWidth;
}
