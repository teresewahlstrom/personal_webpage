import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tw_keywords/tw_keywords.dart';

final class SubjectRegistry {
  static const String _indexAssetPath = 'assets/data/subjects/index.json';

  static Map<String, SubjectKeywordData>? _cache;
  static final Map<String, SubjectKeywordData> _subjectCache =
      <String, SubjectKeywordData>{};
  static _SubjectIndex? _indexCache;

  /// Returns every subject listed in the asset index.
  static Future<Map<String, SubjectKeywordData>> all() async {
    if (_cache != null) {
      return _cache!;
    }

    final _SubjectIndex index = await _loadIndex();
    final List<MapEntry<String, SubjectKeywordData>> loadedEntries =
        await Future.wait(
          index.subjectRefs.values.map((_SubjectRef ref) async {
            final SubjectKeywordData subject =
                _subjectCache[ref.id] ?? await _loadSubject(ref.file);
            _subjectCache[ref.id] = subject;
            return MapEntry<String, SubjectKeywordData>(ref.id, subject);
          }),
        );

    final Map<String, SubjectKeywordData> loaded =
        Map<String, SubjectKeywordData>.fromEntries(loadedEntries);

    _cache = loaded;
    return loaded;
  }

  /// Returns the subject with the given id, or `null` if no such subject exists.
  static Future<SubjectKeywordData?> byId(String id) async {
    if (_cache != null) {
      return _cache![id];
    }

    final SubjectKeywordData? cached = _subjectCache[id];
    if (cached != null) {
      return cached;
    }

    final _SubjectIndex index = await _loadIndex();
    final _SubjectRef? ref = index.subjectRefs[id];
    if (ref == null) {
      return null;
    }

    final SubjectKeywordData subject = await _loadSubject(ref.file);
    _subjectCache[id] = subject;
    return subject;
  }

  /// Returns the default subject declared by the index, or the first subject.
  static Future<SubjectKeywordData> defaultSubject() async {
    final _SubjectIndex index = await _loadIndex();
    if (index.subjectRefs.isEmpty) {
      throw StateError(
        'No subjects available in assets/data/subjects/index.json',
      );
    }

    final String? preferred = index.defaultSubjectId;
    if (preferred != null) {
      final _SubjectRef? ref = index.subjectRefs[preferred];
      if (ref != null) {
        return _subjectCache[preferred] ??= await _loadSubject(ref.file);
      }
    }

    final _SubjectRef firstRef = index.subjectRefs.values.first;
    return _subjectCache[firstRef.id] ??= await _loadSubject(firstRef.file);
  }

  /// Returns the ids declared in the subject index.
  static Future<List<String>> ids() async {
    final _SubjectIndex index = await _loadIndex();
    return index.subjectRefs.keys.toList(growable: false);
  }

  /// Clears the cached index and subject data.
  static void clearCache() {
    _cache = null;
    _subjectCache.clear();
    _indexCache = null;
  }

  static Future<_SubjectIndex> _loadIndex() async {
    final _SubjectIndex? cachedIndex = _indexCache;
    if (cachedIndex != null) {
      return cachedIndex;
    }

    try {
      final String indexContent = await rootBundle.loadString(_indexAssetPath);
      final dynamic decoded = jsonDecode(indexContent);
      if (decoded is! Map<String, dynamic>) {
        throw FormatException(
          'Expected $_indexAssetPath to contain a JSON object.',
        );
      }

      final String? defaultSubjectId = _readOptionalString(
        decoded,
        'defaultSubjectId',
        _indexAssetPath,
      );
      final List<dynamic> entries = _readRequiredList(
        decoded,
        'subjects',
        _indexAssetPath,
      );

      final Map<String, _SubjectRef> subjectRefs = <String, _SubjectRef>{};
      for (int index = 0; index < entries.length; index++) {
        final dynamic entry = entries[index];
        if (entry is! Map<String, dynamic>) {
          throw FormatException(
            'Expected subjects[$index] in $_indexAssetPath to be a JSON object.',
          );
        }

        final String id = _readRequiredString(
          entry,
          'id',
          'subjects[$index] in $_indexAssetPath',
        );
        final String file = _readRequiredString(
          entry,
          'file',
          'subjects[$index] in $_indexAssetPath',
        );

        if (subjectRefs.containsKey(id)) {
          throw FormatException(
            'Duplicate subject id "$id" in $_indexAssetPath.',
          );
        }

        subjectRefs[id] = _SubjectRef(id: id, file: file);
      }

      final _SubjectIndex index = _SubjectIndex(
        defaultSubjectId: defaultSubjectId,
        subjectRefs: subjectRefs,
      );
      _indexCache = index;
      return index;
    } catch (error, stackTrace) {
      final FormatException wrappedError = FormatException(
        'Failed to load subjects from $_indexAssetPath: $error',
      );
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: wrappedError,
          stack: stackTrace,
          library: 'subject registry',
          context: ErrorDescription('while loading subject index'),
        ),
      );
      Error.throwWithStackTrace(wrappedError, stackTrace);
    }
  }

  static Future<SubjectKeywordData> _loadSubject(String file) async {
    try {
      final String content = await rootBundle.loadString(file);
      final Map<String, dynamic> decoded = _decodeSubjectContent(file, content);
      return SubjectKeywordData.fromJson(decoded);
    } catch (error, stackTrace) {
      final FormatException wrappedError = FormatException(
        'Failed to load subject asset "$file": $error',
      );
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: wrappedError,
          stack: stackTrace,
          library: 'subject registry',
          context: ErrorDescription('while loading a subject'),
        ),
      );
      Error.throwWithStackTrace(wrappedError, stackTrace);
    }
  }

  static Map<String, dynamic> _decodeSubjectContent(
    String file,
    String content,
  ) {
    if (file.toLowerCase().endsWith('.md')) {
      return _subjectJsonFromMarkdown(file, content);
    }

    final dynamic decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Expected $file to contain a JSON object.');
    }

    return decoded;
  }

  static Map<String, dynamic> _subjectJsonFromMarkdown(
    String file,
    String content,
  ) {
    final List<String> lines = content.replaceAll('\r\n', '\n').split('\n');
    if (lines.isEmpty || lines.first.trim() != '---') {
      throw FormatException(
        'Expected $file to start with YAML-style front matter.',
      );
    }

    final int frontMatterEnd = lines.indexWhere(
      (String line) => line.trim() == '---',
      1,
    );
    if (frontMatterEnd == -1) {
      throw FormatException('Expected $file front matter to end with "---".');
    }

    final Map<String, dynamic> subject = <String, dynamic>{};
    for (final String line in lines.sublist(1, frontMatterEnd)) {
      final String trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      final int separator = trimmed.indexOf(':');
      if (separator <= 0) {
        throw FormatException('Expected front matter line "$line" in $file.');
      }

      final String key = trimmed.substring(0, separator).trim();
      final String value = trimmed.substring(separator + 1).trim();
      subject[key] = value;
    }

    final List<String> tableLines = lines
        .skip(frontMatterEnd + 1)
        .where((String line) => line.trim().startsWith('|'))
        .toList(growable: false);
    if (tableLines.length < 2) {
      throw FormatException('Expected $file to contain a keyword table.');
    }

    final List<String> headers = _splitMarkdownTableRow(tableLines.first);
    final List<Map<String, dynamic>> keywords = <Map<String, dynamic>>[];
    for (final String tableLine in tableLines.skip(1)) {
      final List<String> cells = _splitMarkdownTableRow(tableLine);
      if (_isMarkdownSeparatorRow(cells)) {
        continue;
      }
      if (cells.length != headers.length) {
        throw FormatException(
          'Expected keyword row in $file to have ${headers.length} cells.',
        );
      }

      final Map<String, dynamic> keyword = <String, dynamic>{};
      for (int index = 0; index < headers.length; index++) {
        final String key = headers[index];
        final String value = cells[index];
        if (value.isEmpty) {
          continue;
        }

        keyword[key] = switch (key) {
          'weight' || 'lockOrder' => int.parse(value),
          'em' || 'lockGapEm' => double.parse(value),
          _ => value,
        };
      }
      keywords.add(keyword);
    }

    subject['keywords'] = keywords;
    return subject;
  }

  static bool _isMarkdownSeparatorRow(List<String> cells) {
    return cells.every((String cell) => RegExp(r'^:?-{3,}:?$').hasMatch(cell));
  }

  static List<String> _splitMarkdownTableRow(String line) {
    final String trimmed = line.trim();
    final String row = trimmed
        .replaceFirst(RegExp(r'^\|'), '')
        .replaceFirst(RegExp(r'\|$'), '');
    final List<String> cells = <String>[];
    final StringBuffer cell = StringBuffer();

    for (int index = 0; index < row.length; index++) {
      final String character = row[index];
      if (character == '\\' &&
          index + 1 < row.length &&
          row[index + 1] == '|') {
        cell.write('|');
        index++;
      } else if (character == '|') {
        cells.add(cell.toString().trim());
        cell.clear();
      } else {
        cell.write(character);
      }
    }

    cells.add(cell.toString().trim());
    return cells;
  }

  static List<dynamic> _readRequiredList(
    Map<String, dynamic> json,
    String key,
    String source,
  ) {
    final dynamic value = json[key];
    if (value is! List<dynamic>) {
      throw FormatException('Expected "$key" in $source to be a list.');
    }
    return value;
  }

  static String _readRequiredString(
    Map<String, dynamic> json,
    String key,
    String source,
  ) {
    final dynamic value = json[key];
    if (value is! String || value.isEmpty) {
      throw FormatException(
        'Expected "$key" in $source to be a non-empty string.',
      );
    }
    return value;
  }

  static String? _readOptionalString(
    Map<String, dynamic> json,
    String key,
    String source,
  ) {
    final dynamic value = json[key];
    if (value == null) {
      return null;
    }
    if (value is! String || value.isEmpty) {
      throw FormatException(
        'Expected "$key" in $source to be a string or null.',
      );
    }
    return value;
  }
}

final class _SubjectIndex {
  const _SubjectIndex({
    required this.defaultSubjectId,
    required this.subjectRefs,
  });

  final String? defaultSubjectId;
  final Map<String, _SubjectRef> subjectRefs;
}

final class _SubjectRef {
  const _SubjectRef({required this.id, required this.file});

  final String id;
  final String file;
}
