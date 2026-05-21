import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:tw_primitives/markdown.dart';

import '../models/message.dart';

String formatChatSelectionCopy({
  required List<ChatMessage> messages,
  required Map<String, SelectedContentRange> selectedRanges,
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

    final start = math
        .min(range.startOffset, range.endOffset)
        .clamp(0, projection.visibleLength);
    final end = math
        .max(range.startOffset, range.endOffset)
        .clamp(0, projection.visibleLength);
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
    buffer.write(projection.copySlice(start: start, end: end));
    wroteAny = true;
  }

  return buffer.toString();
}

class _SelectionCopyProjection {
  _SelectionCopyProjection(this._segments)
    : visibleLength = _segments.fold<int>(
        0,
        (total, segment) => total + segment.visibleLength,
      );

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
        separator: MarkupDocument.blockSeparator,
      ),
    );
  }

  final List<_SelectionCopySegment> _segments;
  final int visibleLength;

  bool get isEmpty => visibleLength == 0;

  String copySlice({required int start, required int end}) {
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

      if (localStart == 0) {
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

  _SelectionCopySegment prependLeadingCopy(String prefix) {
    if (prefix.isEmpty) {
      return this;
    }
    return _SelectionCopySegment(
      visibleText: visibleText,
      leadingCopy: '$prefix$leadingCopy',
      trailingCopy: trailingCopy,
    );
  }

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
  required String separator,
}) {
  final segments = <_SelectionCopySegment>[];

  for (final block in blocks) {
    final blockSegments = _buildBlockSegments(block);
    if (blockSegments.isEmpty) {
      continue;
    }
    if (segments.isNotEmpty) {
      blockSegments[0] = blockSegments[0].prependLeadingCopy(separator);
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
    segments[0] = segments[0].prependLeadingCopy(prefix);
    return segments;
  }
  if (block is MarkupBlockQuoteBlock) {
    return _prefixCopyLines(
      _buildJoinedBlockSegments(
        block.blocks,
        separator: MarkupDocument.blockSeparator,
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

    segments.add(
      _SelectionCopySegment(
        visibleText: marker,
        leadingCopy: entry.$1 > 0 ? '\n' : '',
      ),
    );

    final itemSegments = _prefixCopyLines(
      _buildJoinedBlockSegments(entry.$2.blocks, separator: '\n'),
      firstLinePrefix: '',
      continuationPrefix: ' ' * marker.length,
    );
    segments.addAll(itemSegments);
  }

  return segments;
}

List<_SelectionCopySegment> _buildInlineSegments(
  List<MarkupInline> inlines,
) {
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
