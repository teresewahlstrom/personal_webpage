// subject_keyword_data.dart

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
    final List<dynamic> rawKeywords =
        (json['keywords'] as List<dynamic>? ?? <dynamic>[]);
    return SubjectKeywordData(
      id: _readRequiredString(json, 'id'),
      name: _readRequiredString(json, 'name'),
      role: _readOptionalString(json, 'role'),
      theme: _readOptionalString(json, 'theme'),
      bio: _readOptionalString(json, 'bio'),
      keywords: rawKeywords
          .map((dynamic item) =>
              _keywordNodeFromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  static KeywordNode _keywordNodeFromJson(Map<String, dynamic> json) {
    final KeywordTextColorToken colorToken = _parseKeywordTextColorToken(json);
    return KeywordNode(
      _readRequiredString(json, 'text'),
      colorToken,
      _parseFontWeight((json['weight'] as num).toInt()),
      (json['em'] as num).toDouble(),
      group: _readOptionalString(json, 'group'),
      alignmentBias: _readOptionalString(json, 'alignmentBias'),
      lockGroup: _readOptionalString(json, 'lockGroup'),
      lockOrder: (json['lockOrder'] as num?)?.toInt(),
      lockAxis: _readOptionalString(json, 'lockAxis'),
      lockAlign: _readOptionalString(json, 'lockAlign'),
      lockGapEm: (json['lockGapEm'] as num?)?.toDouble(),
    );
  }

  static KeywordTextColorToken _parseKeywordTextColorToken(
      Map<String, dynamic> json) {
    final String? token =
        _readOptionalString(json, 'colorToken')?.trim().toLowerCase();
    if (token != null && token.isNotEmpty) {
      return _tokenFromString(token);
    }

    throw FormatException(
      'Keyword is missing color information: expected "colorToken".',
    );
  }

  static KeywordTextColorToken _tokenFromString(String raw) {
    return switch (raw) {
      'cyan' => KeywordTextColorToken.cyan,
      'magenta' => KeywordTextColorToken.magenta,
      'slate' => KeywordTextColorToken.slate,
      _ => throw FormatException('Unknown colorToken: $raw'),
    };
  }

  static String _readRequiredString(Map<String, dynamic> json, String key) {
    final dynamic value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    throw FormatException('Missing required string field "$key".');
  }

  static String? _readOptionalString(Map<String, dynamic> json, String key) {
    final dynamic value = json[key];
    if (value == null) {
      return null;
    }
    return value.toString();
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
