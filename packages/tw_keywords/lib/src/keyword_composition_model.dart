import 'package:flutter/material.dart';

import 'config/keyword_color_theme.dart';

/// A single keyword cell with visual and semantic metadata.
///
/// [em] = font size as a fraction of container width — expresses visual
/// importance, independent of text length. This enables robust scaling and
/// reuse across different keyword sets.
final class KeywordNode {
  final String text;
  final KeywordTextColorToken colorToken;
  final FontWeight weight;
  final double em;

  /// Semantic tier: `hero` (leading), `core` (primary), `support` (secondary).
  final String tier;

  /// Optional semantic group: `engineering`, `business`, `human`, `future`.
  final String? group;

  /// Optional alignment bias for future advanced layouts.
  /// `left`, `center`, `right`, or null for default.
  final String? alignmentBias;

  /// Optional lock group id.
  ///
  /// Keywords with the same `lockGroup` are placed together as one unit in
  /// the cloud layout (for intentional pairings like title/subtitle stacks).
  final String? lockGroup;

  /// Optional order within a lock group. Lower values appear first.
  final int? lockOrder;

  /// Optional lock axis for grouped words: `vertical` or `horizontal`.
  final String? lockAxis;

  /// Optional alignment inside a vertical lock group: `left`, `center`, `right`.
  final String? lockAlign;

  /// Optional explicit gap between grouped words, expressed as em-of-width.
  final double? lockGapEm;

  const KeywordNode(
    this.text,
    this.colorToken,
    this.weight,
    this.em, {
    required this.tier,
    this.group,
    this.alignmentBias,
    this.lockGroup,
    this.lockOrder,
    this.lockAxis,
    this.lockAlign,
    this.lockGapEm,
  });
}
