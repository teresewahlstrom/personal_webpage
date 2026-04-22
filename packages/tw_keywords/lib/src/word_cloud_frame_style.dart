import 'package:flutter/material.dart';

final class WordCloudFrameStyle {
  const WordCloudFrameStyle({
    required this.backgroundColor,
    required this.borderSide,
    this.padding = const EdgeInsets.all(0),
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  });

  final Color backgroundColor;
  final BorderSide borderSide;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
}
