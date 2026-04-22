import 'package:flutter/material.dart';

import 'keyword_composition_model.dart';
import 'config/keyword_color_theme.dart';

/// Complete subject profile with all keywords, semantic metadata, and layout hints.
///
/// Designed to be:
/// - Loadable from JSON or external config
/// - Subject-complete (one instance = full profile for one person/role)
/// - Layout-agnostic (keywords + metadata, rendering handled separately)
final class SubjectKeywordData {
  /// Unique subject identifier (e.g., 'terese', 'alex', 'morgan')
  final String id;

  /// Human-readable name
  final String name;

  /// Role or professional title (optional context)
  final String? role;

  /// All keywords for this subject
  final List<KeywordNode> keywords;

  /// Optional semantic theme/tag
  final String? theme;

  /// Optional narrative/bio (for future use)
  final String? bio;

  const SubjectKeywordData({
    required this.id,
    required this.name,
    required this.keywords,
    this.role,
    this.theme,
    this.bio,
  });

  factory SubjectKeywordData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawKeywords = (json['keywords'] as List<dynamic>? ?? <dynamic>[]);
    return SubjectKeywordData(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String?,
      theme: json['theme'] as String?,
      bio: json['bio'] as String?,
      keywords: rawKeywords
          .map((dynamic item) => _keywordNodeFromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  static KeywordNode _keywordNodeFromJson(Map<String, dynamic> json) {
    final KeywordTextColorToken colorToken =
        _parseKeywordTextColorToken(json);
    return KeywordNode(
      json['text'] as String,
      colorToken,
      _parseFontWeight((json['weight'] as num).toInt()),
      (json['em'] as num).toDouble(),
      tier: json['tier'] as String,
      group: json['group'] as String?,
      alignmentBias: json['alignmentBias'] as String?,
      lockGroup: json['lockGroup'] as String?,
      lockOrder: (json['lockOrder'] as num?)?.toInt(),
      lockAxis: json['lockAxis'] as String?,
      lockAlign: json['lockAlign'] as String?,
      lockGapEm: (json['lockGapEm'] as num?)?.toDouble(),
    );
  }

  static KeywordTextColorToken _parseKeywordTextColorToken(
      Map<String, dynamic> json) {
    final String token = (json['colorToken'] as String).trim().toLowerCase();
    return _tokenFromString(token);
  }

  static KeywordTextColorToken _tokenFromString(String raw) {
    return switch (raw) {
      'cyan' => KeywordTextColorToken.cyan,
      'magenta' => KeywordTextColorToken.magenta,
      'slate' => KeywordTextColorToken.slate,
      'charcoal' => KeywordTextColorToken.charcoal,
      _ => throw FormatException('Unknown colorToken: $raw'),
    };
  }

  static FontWeight _parseFontWeight(int weight) {
    return switch (weight) {
      <= 100 => FontWeight.w100,
      <= 200 => FontWeight.w200,
      <= 300 => FontWeight.w300,
      <= 400 => FontWeight.w400,
      <= 500 => FontWeight.w500,
      <= 600 => FontWeight.w600,
      <= 700 => FontWeight.w700,
      <= 800 => FontWeight.w800,
      _ => FontWeight.w900,
    };
  }
}
