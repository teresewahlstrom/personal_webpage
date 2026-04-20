import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../logic/selection_copy_formatter.dart';
import '../models/message.dart';

class SelectionCopyHelper {
  final GlobalKey<SelectionAreaState> chatSelectionAreaKey =
      GlobalKey<SelectionAreaState>();

  final Map<String, SelectionListenerNotifier> _messageSelectionNotifiers =
      <String, SelectionListenerNotifier>{};

  bool _isChatSelectionActive = false;
  String _currentSelectedPlainText = '';

  bool get isChatSelectionActive => _isChatSelectionActive;
  String get currentSelectedPlainText => _currentSelectedPlainText;

  SelectionListenerNotifier selectionNotifierForMessage(String messageId) {
    return _messageSelectionNotifiers.putIfAbsent(
      messageId,
      SelectionListenerNotifier.new,
    );
  }

  bool handleChatSelectionChanged(SelectedContent? selectedContent) {
    _currentSelectedPlainText = selectedContent?.plainText ?? '';
    final hasSelection = (selectedContent?.plainText ?? '').trim().isNotEmpty;
    if (_isChatSelectionActive == hasSelection) {
      return false;
    }
    _isChatSelectionActive = hasSelection;
    return true;
  }

  String buildFormattedSelectionCopy(List<ChatMessage> messages) {
    final selectedRanges = <String, SelectedContentRange>{};

    for (final message in messages) {
      final notifier = _messageSelectionNotifiers[message.id];
      if (notifier == null || !notifier.registered) {
        continue;
      }

      final selection = notifier.selection;
      final range = selection.range;
      if (selection.status == SelectionStatus.none || range == null) {
        continue;
      }

      selectedRanges[message.id] = range;
    }

    return formatChatSelectionCopy(
      messages: messages,
      selectedRanges: selectedRanges,
    );
  }

  String resolveSelectionCopyText(List<ChatMessage> messages) {
    final formatted = buildFormattedSelectionCopy(messages);
    if (formatted.trim().isNotEmpty) {
      return formatted;
    }
    return _currentSelectedPlainText;
  }

  void syncActiveMessageIds(Set<String> activeMessageIds) {
    _messageSelectionNotifiers.removeWhere((messageId, notifier) {
      if (activeMessageIds.contains(messageId)) {
        return false;
      }
      notifier.dispose();
      return true;
    });
  }

  void dispose() {
    for (final notifier in _messageSelectionNotifiers.values) {
      notifier.dispose();
    }
  }
}
