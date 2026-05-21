import 'markup_model.dart';
import 'markup_tokenizer.dart';

class MarkupParser {
  static const int _maxHeadingLevel = 2;

  MarkupParser(String raw)
    : _lines = raw.replaceAll('\r\n', '\n').split('\n'),
      preserveSoftLineBreaks = false;

  MarkupParser.fromLines(
    this._lines, {
    this.preserveSoftLineBreaks = false,
  });

  final List<String> _lines;
  final bool preserveSoftLineBreaks;

  MarkupDocument parse() {
    return MarkupDocument(_parseBlocks(start: 0, baseIndent: 0).blocks);
  }

  _BlockParseResult _parseBlocks({
    required int start,
    required int baseIndent,
  }) {
    final blocks = <MarkupBlock>[];
    var index = start;

    while (index < _lines.length) {
      final line = _trimTrailingWhitespace(_lines[index]);

      if (_isBlank(line)) {
        index += 1;
        continue;
      }

      if (_leadingSpaces(line) < baseIndent) {
        break;
      }

      final blockQuoteContent = _stripBlockQuotePrefix(
        line,
        baseIndent: baseIndent,
      );
      if (blockQuoteContent != null) {
        final result = _parseBlockQuote(start: index, baseIndent: baseIndent);
        blocks.add(result.block);
        index = result.nextIndex;
        continue;
      }

      final headingMatch = _matchHeading(line, baseIndent: baseIndent);
      if (headingMatch != null) {
        blocks.add(
          MarkupHeadingBlock(
            level: headingMatch.level,
            inlines: MarkupInlineTokenizer(headingMatch.text).tokenize(),
          ),
        );
        index += 1;
        continue;
      }

      final listMarker = _matchListMarker(line, minimumIndent: baseIndent);
      if (listMarker != null) {
        final result = _parseListBlock(
          start: index,
          baseIndent: baseIndent,
          firstMarker: listMarker,
        );
        blocks.add(result.block);
        index = result.nextIndex;
        continue;
      }

      final result = _parseParagraph(start: index, baseIndent: baseIndent);
      blocks.add(result.block);
      index = result.nextIndex;
    }

    return _BlockParseResult(blocks: blocks, nextIndex: index);
  }

  _ParagraphParseResult _parseParagraph({
    required int start,
    required int baseIndent,
  }) {
    final paragraphLines = <String>[];
    var index = start;

    while (index < _lines.length) {
      final line = _trimTrailingWhitespace(_lines[index]);
      if (_isBlank(line)) {
        break;
      }
      if (_leadingSpaces(line) < baseIndent) {
        break;
      }
      if (index > start && _startsNewBlock(line, baseIndent: baseIndent)) {
        break;
      }

      final content = line.substring(baseIndent);
      paragraphLines.add(
        preserveSoftLineBreaks ? content.trimRight() : content.trim(),
      );
      index += 1;
    }

    final paragraphText = preserveSoftLineBreaks
        ? paragraphLines.join('\n')
        : paragraphLines.join(' ');

    return _ParagraphParseResult(
      block: MarkupParagraphBlock(MarkupInlineTokenizer(paragraphText).tokenize()),
      nextIndex: index,
    );
  }

  _ListParseResult _parseListBlock({
    required int start,
    required int baseIndent,
    required _ListMarker firstMarker,
  }) {
    final items = <MarkupListItem>[];
    var index = start;
    final ordered = firstMarker.ordered;
    final listIndent = firstMarker.indent;
    final startingIndex = firstMarker.index ?? 1;

    while (index < _lines.length) {
      while (index < _lines.length &&
          _isBlank(_trimTrailingWhitespace(_lines[index]))) {
        index += 1;
      }
      if (index >= _lines.length) {
        break;
      }

      final marker = _matchListMarker(
        _trimTrailingWhitespace(_lines[index]),
        minimumIndent: baseIndent,
      );
      if (marker == null ||
          marker.indent != listIndent ||
          marker.ordered != ordered) {
        break;
      }

      final itemResult = _parseListItem(start: index, marker: marker);
      items.add(itemResult.item);
      index = itemResult.nextIndex;
    }

    return _ListParseResult(
      block: MarkupListBlock(
        ordered: ordered,
        startingIndex: startingIndex,
        items: List<MarkupListItem>.unmodifiable(items),
      ),
      nextIndex: index,
    );
  }

  _ListItemParseResult _parseListItem({
    required int start,
    required _ListMarker marker,
  }) {
    final itemLines = <String>[];
    if (marker.content.isNotEmpty) {
      itemLines.add(marker.content);
    }

    var index = start + 1;
    final contentIndent = marker.indent + marker.markerWidth;

    while (index < _lines.length) {
      final line = _trimTrailingWhitespace(_lines[index]);
      if (_isBlank(line)) {
        final nextNonBlank = _findNextNonBlank(index + 1);
        if (nextNonBlank == null) {
          index += 1;
          break;
        }

        final nextLine = _trimTrailingWhitespace(_lines[nextNonBlank]);
        final nextMarker = _matchListMarker(nextLine, minimumIndent: 0);
        if (nextMarker != null && nextMarker.indent == marker.indent) {
          break;
        }
        if (_leadingSpaces(nextLine) > marker.indent) {
          itemLines.add('');
          index += 1;
          continue;
        }
        break;
      }

      final lineIndent = _leadingSpaces(line);
      final nextMarker = _matchListMarker(line, minimumIndent: 0);
      if (nextMarker != null && nextMarker.indent == marker.indent) {
        break;
      }
      if (lineIndent <= marker.indent) {
        break;
      }

      itemLines.add(_dedentListContentLine(line, contentIndent: contentIndent));
      index += 1;
    }

    final blocks = MarkupParser.fromLines(
      itemLines,
      preserveSoftLineBreaks: true,
    )._parseBlocks(start: 0, baseIndent: 0).blocks;

    return _ListItemParseResult(
      item: MarkupListItem(List<MarkupBlock>.unmodifiable(blocks)),
      nextIndex: index,
    );
  }

  _BlockQuoteParseResult _parseBlockQuote({
    required int start,
    required int baseIndent,
  }) {
    final quoteLines = <String>[];
    var index = start;

    while (index < _lines.length) {
      final line = _trimTrailingWhitespace(_lines[index]);
      final stripped = _stripBlockQuotePrefix(line, baseIndent: baseIndent);
      if (stripped == null) {
        break;
      }
      quoteLines.add(stripped);
      index += 1;
    }

    final blocks = MarkupParser.fromLines(
      quoteLines,
    )._parseBlocks(start: 0, baseIndent: 0).blocks;

    return _BlockQuoteParseResult(
      block: MarkupBlockQuoteBlock(List<MarkupBlock>.unmodifiable(blocks)),
      nextIndex: index,
    );
  }

  bool _startsNewBlock(String line, {required int baseIndent}) {
    return _stripBlockQuotePrefix(line, baseIndent: baseIndent) != null ||
        _matchHeading(line, baseIndent: baseIndent) != null ||
        _matchListMarker(line, minimumIndent: baseIndent) != null;
  }

  _HeadingMatch? _matchHeading(String line, {required int baseIndent}) {
    if (_leadingSpaces(line) < baseIndent) {
      return null;
    }
    final match = RegExp(
      r'^\s{0,3}(#{1,2})\s+(.+?)\s*$',
    ).firstMatch(line.substring(baseIndent));
    if (match == null) {
      return null;
    }
    return _HeadingMatch(
      level: match.group(1)!.length.clamp(1, _maxHeadingLevel).toInt(),
      text: match.group(2)!.trim(),
    );
  }

  _ListMarker? _matchListMarker(String line, {required int minimumIndent}) {
    final match = RegExp(
      r'^(\s*)(?:(\d+)\.\s+(.*)|([-+*•])\s+(.*))$',
    ).firstMatch(line);
    if (match == null) {
      return null;
    }

    final indent = match.group(1)!.length;
    if (indent < minimumIndent) {
      return null;
    }

    final ordered = match.group(2) != null;
    final markerWidth = ordered
        ? '${match.group(2)}. '.length
        : '${match.group(4)} '.length;

    return _ListMarker(
      ordered: ordered,
      indent: indent,
      markerWidth: markerWidth,
      index: ordered ? int.parse(match.group(2)!) : null,
      content: ordered ? match.group(3)!.trim() : match.group(5)!.trim(),
    );
  }

  String? _stripBlockQuotePrefix(String line, {required int baseIndent}) {
    if (_leadingSpaces(line) < baseIndent) {
      return null;
    }
    final match = RegExp(
      r'^\s{0,3}>\s?(.*)$',
    ).firstMatch(line.substring(baseIndent));
    if (match == null) {
      return null;
    }
    return match.group(1)!;
  }

  int? _findNextNonBlank(int start) {
    for (var index = start; index < _lines.length; index += 1) {
      if (!_isBlank(_trimTrailingWhitespace(_lines[index]))) {
        return index;
      }
    }
    return null;
  }

  int _leadingSpaces(String line) {
    var count = 0;
    while (count < line.length && line.codeUnitAt(count) == 0x20) {
      count += 1;
    }
    return count;
  }

  bool _isBlank(String line) {
    return line.trim().isEmpty;
  }

  String _dedentListContentLine(String line, {required int contentIndent}) {
    final leading = _leadingSpaces(line);
    final trimCount = leading >= contentIndent ? contentIndent : leading;
    return line.substring(trimCount);
  }

  String _trimTrailingWhitespace(String line) {
    return line.replaceFirst(RegExp(r'\s+$'), '');
  }
}

class _BlockParseResult {
  const _BlockParseResult({required this.blocks, required this.nextIndex});

  final List<MarkupBlock> blocks;
  final int nextIndex;
}

class _ParagraphParseResult {
  const _ParagraphParseResult({required this.block, required this.nextIndex});

  final MarkupParagraphBlock block;
  final int nextIndex;
}

class _ListParseResult {
  const _ListParseResult({required this.block, required this.nextIndex});

  final MarkupListBlock block;
  final int nextIndex;
}

class _ListItemParseResult {
  const _ListItemParseResult({required this.item, required this.nextIndex});

  final MarkupListItem item;
  final int nextIndex;
}

class _BlockQuoteParseResult {
  const _BlockQuoteParseResult({required this.block, required this.nextIndex});

  final MarkupBlockQuoteBlock block;
  final int nextIndex;
}

class _HeadingMatch {
  const _HeadingMatch({required this.level, required this.text});

  final int level;
  final String text;
}

class _ListMarker {
  const _ListMarker({
    required this.ordered,
    required this.indent,
    required this.markerWidth,
    required this.content,
    this.index,
  });

  final bool ordered;
  final int indent;
  final int markerWidth;
  final int? index;
  final String content;
}
