import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:tw_primitives/markdown.dart';

import '../models/message.dart';

String formatChatSelectionCopy({
  required List<ChatMessage> messages,
  required Map<String, SelectedContentRange> selectedRanges,
  Map<String, String> selectedPlainTextByMessage = const <String, String>{},
  Set<String> fullCopyMessageIds = const <String>{},
}) {
  final buffer = StringBuffer();
  var wroteAny = false;

  for (final entry in messages.indexed) {
    final message = entry.$2;
    final range = selectedRanges[message.id];
    if (range == null) {
      continue;
    }

    final projection = _SelectionCopyProjection.fromRawMessage(message.text);
    if (projection.isEmpty) {
      continue;
    }

    final bool copyWholeMessage = fullCopyMessageIds.contains(message.id);
    final int fallbackStart = copyWholeMessage
        ? 0
        : math
              .min(range.startOffset, range.endOffset)
              .clamp(0, projection.visibleLength)
              .toInt();
    final int fallbackEnd = copyWholeMessage
        ? projection.visibleLength
        : math
              .max(range.startOffset, range.endOffset)
              .clamp(0, projection.visibleLength)
              .toInt();
    final selectedPlainText = selectedPlainTextByMessage[message.id] ?? '';
    final bool rangeCoversWholeMessage =
        fallbackStart == 0 && fallbackEnd == projection.visibleLength;
    final bool rangeLengthMatchesSelectedText =
        selectedPlainText.length == (fallbackEnd - fallbackStart);
    final bool shouldAnchorToSelectedText =
        !copyWholeMessage &&
        selectedPlainText.isNotEmpty &&
        (!rangeCoversWholeMessage || !rangeLengthMatchesSelectedText);
    final matchedRange = !shouldAnchorToSelectedText
        ? null
        : projection.findVisibleTextRange(
            selectedPlainText,
            preferredStart: fallbackStart,
          );
    final int start = matchedRange?.$1 ?? fallbackStart;
    final int end = matchedRange?.$2 ?? fallbackEnd;
    final bool includeLeadingCopyAtStart = matchedRange != null
        ? projection.shouldIncludeLeadingCopyAtStart(
            start: start,
            selectedText: selectedPlainText,
          )
        : false;
    if (end <= start) {
      continue;
    }

    if (wroteAny || start == 0) {
      buffer.write(
        _buildSelectionCopyMessageHeader(
          message,
          isFirstMessage: entry.$1 == 0,
        ),
      );
    }
    buffer.write(
      projection.copySlice(
        start: start,
        end: end,
        includeLeadingCopyAtStart: includeLeadingCopyAtStart,
      ),
    );
    wroteAny = true;
  }

  return buffer.toString();
}

class _SelectionCopyProjection {
  _SelectionCopyProjection(this._segments)
    : visibleLength = _segments.fold<int>(
        0,
        (total, segment) => total + segment.visibleLength,
      ),
      visibleText = _segments.map((segment) => segment.visibleText).join();

  factory _SelectionCopyProjection.fromRawMessage(String raw) {
    // Copy selection offsets come from the visible rendered markup tree, so the
    // projection starts from the parsed document and preserves visible text
    // length exactly. Transcript-only affordances such as list markers, quote
    // prefixes, separators, and link URLs are carried in leading/trailing copy
    // fields so they appear in copied output without shifting visible offsets.
    final document = MessageMarkup.parse(raw);
    return _SelectionCopyProjection(
      _buildJoinedBlockSegments(
        document.blocks,
        visibleSeparator: '\n',
        copySeparator: MarkupDocument.blockSeparator,
      ),
    );
  }

  final List<_SelectionCopySegment> _segments;
  final int visibleLength;
  final String visibleText;

  bool get isEmpty => visibleLength == 0;

  (int, int)? findVisibleTextRange(
    String selectedText, {
    required int preferredStart,
  }) {
    if (selectedText.isEmpty) {
      return null;
    }

    int? bestStart;
    var searchStart = 0;
    while (searchStart <= visibleText.length - selectedText.length) {
      final matchIndex = visibleText.indexOf(selectedText, searchStart);
      if (matchIndex == -1) {
        break;
      }
      if (bestStart == null ||
          (matchIndex - preferredStart).abs() <
              (bestStart - preferredStart).abs()) {
        bestStart = matchIndex;
      }
      searchStart = matchIndex + 1;
    }

    if (bestStart == null) {
      return _findVisibleTextRangeSkippingSeparators(
        selectedText,
        preferredStart: preferredStart,
      );
    }
    return (bestStart, bestStart + selectedText.length);
  }

  (int, int)? _findVisibleTextRangeSkippingSeparators(
    String selectedText, {
    required int preferredStart,
  }) {
    int? bestStart;
    int? bestEnd;

    for (var candidateStart = 0;
        candidateStart < visibleText.length;
        candidateStart += 1) {
      var visibleIndex = candidateStart;
      var selectedIndex = 0;

      while (visibleIndex < visibleText.length &&
          selectedIndex < selectedText.length) {
        if (visibleText[visibleIndex] == '\n') {
          visibleIndex += 1;
          continue;
        }
        if (visibleText[visibleIndex] != selectedText[selectedIndex]) {
          break;
        }
        visibleIndex += 1;
        selectedIndex += 1;
      }

      if (selectedIndex != selectedText.length) {
        continue;
      }

      if (bestStart == null ||
          (candidateStart - preferredStart).abs() <
              (bestStart - preferredStart).abs()) {
        bestStart = candidateStart;
        bestEnd = visibleIndex;
      }
    }

    if (bestStart == null || bestEnd == null) {
      return null;
    }
    return (bestStart, bestEnd);
  }

  bool shouldIncludeLeadingCopyAtStart({
    required int start,
    required String selectedText,
  }) {
    if (selectedText.isEmpty || start < 0 || start >= visibleText.length) {
      return false;
    }

    if (start > 0 && visibleText[start - 1] != '\n') {
      return false;
    }

    final firstSelectedLine = selectedText.split('\n').first;
    final lineEnd = visibleText.indexOf('\n', start);
    final visibleLineEnd = lineEnd == -1 ? visibleText.length : lineEnd;
    return start + firstSelectedLine.length >= visibleLineEnd;
  }

  String copySlice({
    required int start,
    required int end,
    bool includeLeadingCopyAtStart = false,
  }) {
    final buffer = StringBuffer();
    var visibleOffset = 0;

    for (final segment in _segments) {
      final segmentStart = visibleOffset;
      final segmentEnd = segmentStart + segment.visibleLength;
      visibleOffset = segmentEnd;

      if (end <= segmentStart) {
        break;
      }
      if (start >= segmentEnd) {
        continue;
      }

      final localStart = math.max(0, start - segmentStart);
      final localEnd = math.min(segment.visibleLength, end - segmentStart);
      if (localEnd <= localStart) {
        continue;
      }

      if (localStart == 0 &&
          (segmentStart == 0 ||
              buffer.isNotEmpty ||
              (includeLeadingCopyAtStart && segmentStart == start))) {
        buffer.write(segment.leadingCopy);
      }
      buffer.write(segment.visibleText.substring(localStart, localEnd));
      if (localStart == 0 && localEnd == segment.visibleLength) {
        buffer.write(segment.trailingCopy);
      }
    }

    return buffer.toString();
  }
}

class _SelectionCopySegment {
  const _SelectionCopySegment({
    required this.visibleText,
    this.leadingCopy = '',
    this.trailingCopy = '',
  });

  final String visibleText;
  final String leadingCopy;
  final String trailingCopy;

  int get visibleLength => visibleText.length;

  _SelectionCopySegment copyWith({
    String? visibleText,
    String? leadingCopy,
    String? trailingCopy,
  }) {
    return _SelectionCopySegment(
      visibleText: visibleText ?? this.visibleText,
      leadingCopy: leadingCopy ?? this.leadingCopy,
      trailingCopy: trailingCopy ?? this.trailingCopy,
    );
  }
}

class _LinePrefixState {
  const _LinePrefixState({
    required this.atLineStart,
    required this.pendingPrefix,
  });

  final bool atLineStart;
  final String pendingPrefix;
}

List<_SelectionCopySegment> _buildJoinedBlockSegments(
  List<MarkupBlock> blocks, {
  required String visibleSeparator,
  required String copySeparator,
}) {
  final segments = <_SelectionCopySegment>[];

  for (final block in blocks) {
    final blockSegments = _buildBlockSegments(block);
    if (blockSegments.isEmpty) {
      continue;
    }
    if (segments.isNotEmpty) {
      segments.add(
        _buildVisibleSeparatorSegment(
          visibleSeparator: visibleSeparator,
          copySeparator: copySeparator,
        ),
      );
    }
    segments.addAll(blockSegments);
  }

  return segments;
}

List<_SelectionCopySegment> _buildBlockSegments(MarkupBlock block) {
  // Visible text maps 1:1 to selection offsets. Structural transcript chrome is
  // injected only through copy prefixes/suffixes so selection math stays tied
  // to what the user actually highlighted on screen.
  if (block is MarkupParagraphBlock) {
    return _buildInlineSegments(block.inlines);
  }
  if (block is MarkupHeadingBlock) {
    final segments = _buildInlineSegments(block.inlines);
    final prefix = _markdownHeadingPrefix(block.level);
    if (prefix.isEmpty || segments.isEmpty) {
      return segments;
    }
    segments[0] = segments[0].copyWith(
      leadingCopy: '$prefix${segments[0].leadingCopy}',
    );
    return segments;
  }
  if (block is MarkupBlockquoteBlock) {
    return _prefixCopyLines(
      _buildJoinedBlockSegments(
        block.blocks,
        visibleSeparator: '\n',
        copySeparator: MarkupDocument.blockSeparator,
      ),
      firstLinePrefix: '> ',
      continuationPrefix: '> ',
    );
  }
  if (block is MarkupListBlock) {
    return _buildListSegments(block);
  }

  return _splitVisibleText(block.toPlainText());
}

List<_SelectionCopySegment> _buildListSegments(MarkupListBlock block) {
  final segments = <_SelectionCopySegment>[];

  for (final entry in block.items.indexed) {
    final marker = block.ordered ? '${block.startingIndex + entry.$1}. ' : '- ';
    if (entry.$1 > 0) {
      segments.add(const _SelectionCopySegment(visibleText: '\n'));
    }

    if (block.ordered) {
      segments.add(_SelectionCopySegment(visibleText: marker));
    }

    final itemSegments = _prefixCopyLines(
      _buildJoinedBlockSegments(
        entry.$2.blocks,
        visibleSeparator: '\n',
        copySeparator: '\n',
      ),
      firstLinePrefix: block.ordered ? '' : marker,
      continuationPrefix: ' ' * marker.length,
    );
    segments.addAll(itemSegments);
  }

  return segments;
}

_SelectionCopySegment _buildVisibleSeparatorSegment({
  required String visibleSeparator,
  required String copySeparator,
}) {
  assert(copySeparator.startsWith(visibleSeparator));
  return _SelectionCopySegment(
    visibleText: visibleSeparator,
    trailingCopy: copySeparator.substring(visibleSeparator.length),
  );
}

List<_SelectionCopySegment> _buildInlineSegments(List<MarkupInline> inlines) {
  final segments = <_SelectionCopySegment>[];

  for (final inline in inlines) {
    segments.addAll(
      _splitVisibleText(
        inline.text,
        leadingCopy: _inlineLeadingMarkdown(inline),
        trailingCopy: _inlineTrailingMarkdown(inline),
      ),
    );
  }

  return segments;
}

String _markdownHeadingPrefix(int level) {
  return switch (level) {
    1 => '# ',
    2 => '## ',
    _ => '',
  };
}

String _inlineLeadingMarkdown(MarkupInline inline) {
  final buffer = StringBuffer();
  if (inline.isStrong) {
    buffer.write('**');
  }
  if (inline.isEmphasis) {
    buffer.write('*');
  }
  if (inline.isStrikethrough) {
    buffer.write('~~');
  }
  if (inline.isUnderline) {
    buffer.write('<u>');
  }
  if (_shouldWriteMarkdownLink(inline)) {
    buffer.write('[');
  }
  return buffer.toString();
}

String _inlineTrailingMarkdown(MarkupInline inline) {
  final buffer = StringBuffer();
  if (_shouldWriteMarkdownLink(inline)) {
    buffer.write('](${inline.href})');
  }
  if (inline.isUnderline) {
    buffer.write('</u>');
  }
  if (inline.isStrikethrough) {
    buffer.write('~~');
  }
  if (inline.isEmphasis) {
    buffer.write('*');
  }
  if (inline.isStrong) {
    buffer.write('**');
  }
  return buffer.toString();
}

bool _shouldWriteMarkdownLink(MarkupInline inline) {
  final href = inline.href;
  return href != null && href.isNotEmpty && href != inline.text;
}

List<_SelectionCopySegment> _splitVisibleText(
  String text, {
  String leadingCopy = '',
  String trailingCopy = '',
}) {
  if (text.isEmpty) {
    return const <_SelectionCopySegment>[];
  }

  final segments = <_SelectionCopySegment>[];
  final buffer = StringBuffer();
  var isFirstSegment = true;

  void flushBuffer() {
    if (buffer.isEmpty) {
      return;
    }
    segments.add(
      _SelectionCopySegment(
        visibleText: buffer.toString(),
        leadingCopy: isFirstSegment ? leadingCopy : '',
      ),
    );
    buffer.clear();
    isFirstSegment = false;
  }

  for (var index = 0; index < text.length; index += 1) {
    final character = text[index];
    if (character == '\n') {
      flushBuffer();
      segments.add(
        _SelectionCopySegment(
          visibleText: '\n',
          leadingCopy: isFirstSegment ? leadingCopy : '',
        ),
      );
      isFirstSegment = false;
      continue;
    }
    buffer.write(character);
  }

  flushBuffer();
  if (segments.isEmpty) {
    return const <_SelectionCopySegment>[];
  }

  final lastSegment = segments.last;
  segments[segments.length - 1] = lastSegment.copyWith(
    trailingCopy: '${lastSegment.trailingCopy}$trailingCopy',
  );
  return segments;
}

List<_SelectionCopySegment> _prefixCopyLines(
  List<_SelectionCopySegment> segments, {
  required String firstLinePrefix,
  required String continuationPrefix,
}) {
  if (segments.isEmpty) {
    return const <_SelectionCopySegment>[];
  }

  final prefixedSegments = <_SelectionCopySegment>[];
  var state = _LinePrefixState(
    atLineStart: true,
    pendingPrefix: firstLinePrefix,
  );

  for (final segment in segments) {
    final leadingCopyResult = _consumeCopyOnlyText(
      segment.leadingCopy,
      state: state,
      continuationPrefix: continuationPrefix,
    );
    var leadingCopy = leadingCopyResult.$1;
    state = leadingCopyResult.$2;

    if (state.atLineStart) {
      leadingCopy = '$leadingCopy${state.pendingPrefix}';
      state = _LinePrefixState(
        atLineStart: false,
        pendingPrefix: state.pendingPrefix,
      );
    }

    if (segment.visibleText == '\n') {
      state = _LinePrefixState(
        atLineStart: true,
        pendingPrefix: continuationPrefix,
      );
    }

    final trailingCopyResult = _consumeCopyOnlyText(
      segment.trailingCopy,
      state: state,
      continuationPrefix: continuationPrefix,
    );

    prefixedSegments.add(
      segment.copyWith(
        leadingCopy: leadingCopy,
        trailingCopy: trailingCopyResult.$1,
      ),
    );
    state = trailingCopyResult.$2;
  }

  return prefixedSegments;
}

(String, _LinePrefixState) _consumeCopyOnlyText(
  String text, {
  required _LinePrefixState state,
  required String continuationPrefix,
}) {
  if (text.isEmpty) {
    return (text, state);
  }

  final buffer = StringBuffer();
  var nextState = state;

  for (var index = 0; index < text.length; index += 1) {
    final character = text[index];
    if (nextState.atLineStart) {
      buffer.write(nextState.pendingPrefix);
      nextState = _LinePrefixState(
        atLineStart: false,
        pendingPrefix: nextState.pendingPrefix,
      );
    }
    buffer.write(character);
    if (character == '\n') {
      nextState = _LinePrefixState(
        atLineStart: true,
        pendingPrefix: continuationPrefix,
      );
    }
  }

  return (buffer.toString(), nextState);
}

String _buildSelectionCopyMessageHeader(
  ChatMessage message, {
  required bool isFirstMessage,
}) {
  final transcriptPrefix = isFirstMessage ? '---\n' : '\n\n---\n';
  return '$transcriptPrefix${_roleLabel(message.role)} (${_formattedTimestamp(message.createdAt)})\n\n';
}

String _roleLabel(ChatRole role) {
  return switch (role) {
    ChatRole.user => 'You',
    ChatRole.bot => 'Twin',
  };
}

String _formattedTimestamp(DateTime value) {
  const monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final monthName = monthNames[value.month - 1];
  return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}, ${_ordinalDay(value.day)} of $monthName ${value.year}';
}

String _ordinalDay(int day) {
  final remainder = day % 100;
  if (remainder >= 11 && remainder <= 13) {
    return '${day}th';
  }

  return switch (day % 10) {
    1 => '${day}st',
    2 => '${day}nd',
    3 => '${day}rd',
    _ => '${day}th',
  };
}
