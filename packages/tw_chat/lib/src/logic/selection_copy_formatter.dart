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

    final projection = SelectionCopyProjection.fromDocument(MessageMarkup.parse(message.text));
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
