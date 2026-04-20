import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/subject_keyword_data.dart';

final class SubjectRegistry {
  static const String _indexAssetPath = 'assets/data/subjects/index.json';

  static Map<String, SubjectKeywordData>? _cache;
  static String? _defaultSubjectId;

  static Future<Map<String, SubjectKeywordData>> all() async {
    if (_cache != null) {
      return _cache!;
    }

    final String indexContent = await rootBundle.loadString(_indexAssetPath);
    final Map<String, dynamic> indexJson =
        jsonDecode(indexContent) as Map<String, dynamic>;

    _defaultSubjectId = indexJson['defaultSubjectId'] as String?;
    final List<dynamic> entries =
        (indexJson['subjects'] as List<dynamic>? ?? <dynamic>[]);

    final Map<String, SubjectKeywordData> loaded = <String, SubjectKeywordData>{};

    for (final dynamic entry in entries) {
      final Map<String, dynamic> subjectRef = entry as Map<String, dynamic>;
      final String id = subjectRef['id'] as String;
      final String file = subjectRef['file'] as String;

      final String content = await rootBundle.loadString(file);
      final Map<String, dynamic> json = jsonDecode(content) as Map<String, dynamic>;
      final SubjectKeywordData subject = SubjectKeywordData.fromJson(json);
      loaded[id] = subject;
    }

    _cache = loaded;
    return loaded;
  }

  static Future<SubjectKeywordData?> byId(String id) async {
    final Map<String, SubjectKeywordData> subjects = await all();
    return subjects[id];
  }

  static Future<SubjectKeywordData> defaultSubject() async {
    final Map<String, SubjectKeywordData> subjects = await all();
    if (subjects.isEmpty) {
      throw StateError('No subjects available in assets/data/subjects/index.json');
    }

    final String? preferred = _defaultSubjectId;
    if (preferred != null && subjects.containsKey(preferred)) {
      return subjects[preferred]!;
    }

    return subjects.values.first;
  }

  static Future<List<String>> ids() async {
    final Map<String, SubjectKeywordData> subjects = await all();
    return subjects.keys.toList(growable: false);
  }

  static void clearCache() {
    _cache = null;
    _defaultSubjectId = null;
  }
}
