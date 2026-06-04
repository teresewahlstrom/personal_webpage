import 'package:flutter/material.dart'
    hide SelectionListener, SelectionListenerNotifier;
import 'package:flutter/rendering.dart'
    show SelectedContentRange, SelectionStatus;
import '../../../../scrollbar.dart'
    show TwSelectableRegionState, SelectionListenerNotifier;
import '../markup_ast.dart';
import 'selection_copy_projection.dart';

class MarkupSelectionInstance {
  const MarkupSelectionInstance({
    required this.document,
    required this.selectedRange,
    required this.selectedPlainText,
    this.title,
  });

  final MarkupDocument document;
  final SelectedContentRange? selectedRange;
  final String selectedPlainText;
  final String? title;
}

class MarkupSelectionCopyFormatter {
  /// Replaces substrings in [globalPlainText] that correspond to selections inside
  /// registered [MarkupDocument]s with their formatted Markdown representations.
  static String formatCopy({
    required String globalPlainText,
    required List<MarkupSelectionInstance> instances,
  }) {
    final edits = <_CopyEdit>[];
    for (final instance in instances) {
      if (instance.selectedRange == null ||
          instance.selectedPlainText.isEmpty) {
        continue;
      }

      final projection = SelectionCopyProjection.fromDocument(
        instance.document,
      );
      if (projection.isEmpty) {
        continue;
      }

      final start = instance.selectedRange!.startOffset
          .clamp(0, projection.visibleLength)
          .toInt();
      final end = instance.selectedRange!.endOffset
          .clamp(0, projection.visibleLength)
          .toInt();
      if (end <= start) {
        continue;
      }

      final startPos = projection.findVisibleTextRange(
        instance.selectedPlainText,
        preferredStart: start,
      );
      final finalStart = startPos?.$1 ?? start;
      final finalEnd = startPos?.$2 ?? end;
      final includeLeadingCopyAtStart = startPos != null
          ? projection.shouldIncludeLeadingCopyAtStart(
              start: finalStart,
              selectedText: instance.selectedPlainText,
            )
          : false;

      var markdownSlice = projection.copySlice(
        start: finalStart,
        end: finalEnd,
        includeLeadingCopyAtStart: includeLeadingCopyAtStart,
      );

      final targetText = instance.selectedPlainText;
      final titleText = instance.title;
      final bool targetIncludesTitle =
          titleText != null && targetText.startsWith(titleText);
      if (targetIncludesTitle) {
        final targetIndex = globalPlainText.indexOf(targetText);
        markdownSlice =
            '${_leadingBlankLineBeforeTitle(globalPlainText, targetIndex)}## $titleText\n$markdownSlice';
      }

      final targetIndex = globalPlainText.indexOf(targetText);
      if (targetIndex != -1) {
        edits.add(
          _CopyEdit(
            start: targetIndex,
            end: targetIndex + targetText.length,
            replacement: markdownSlice,
          ),
        );
      }

      if (titleText != null && !targetIncludesTitle) {
        final titleIndex = targetIndex == -1
            ? globalPlainText.indexOf(titleText)
            : globalPlainText.lastIndexOf(titleText, targetIndex);
        if (titleIndex != -1) {
          final titleEnd = titleIndex + titleText.length;
          final needsTrailingLineBreak =
              titleEnd >= globalPlainText.length ||
              globalPlainText[titleEnd] != '\n';
          edits.add(
            _CopyEdit(
              start: titleIndex,
              end: titleIndex + titleText.length,
              replacement: needsTrailingLineBreak
                  ? '${_leadingBlankLineBeforeTitle(globalPlainText, titleIndex)}## $titleText\n'
                  : '${_leadingBlankLineBeforeTitle(globalPlainText, titleIndex)}## $titleText',
            ),
          );
        }
      }
    }

    if (edits.isEmpty) {
      return globalPlainText;
    }

    edits.sort((left, right) => right.start.compareTo(left.start));

    var result = globalPlainText;
    for (final edit in edits) {
      result = result.replaceRange(edit.start, edit.end, edit.replacement);
    }
    return result;
  }
}

String _leadingBlankLineBeforeTitle(String globalPlainText, int titleIndex) {
  if (titleIndex <= 1 || titleIndex > globalPlainText.length) {
    return '';
  }
  if (globalPlainText[titleIndex - 1] != '\n') {
    return '';
  }
  return globalPlainText[titleIndex - 2] == '\n' ? '' : '\n';
}

class _CopyEdit {
  const _CopyEdit({
    required this.start,
    required this.end,
    required this.replacement,
  });

  final int start;
  final int end;
  final String replacement;
}

class MarkupSelectionCopyHelper {
  final Map<Object, MarkupDocument> documents = {};
  final Map<Object, String> _titles = {};
  final Set<GlobalKey<TwSelectableRegionState>> selectionKeys = {};
  final Map<Object, SelectionListenerNotifier> _notifiers = {};

  SelectionListenerNotifier notifierFor(Object key) {
    return _notifiers.putIfAbsent(key, () => SelectionListenerNotifier());
  }

  void registerDocument(Object key, MarkupDocument doc, {String? title}) {
    documents[key] = doc;
    if (title != null) {
      _titles[key] = title;
    }
  }

  void unregisterDocument(Object key) {
    documents.remove(key);
    _titles.remove(key);
    final notifier = _notifiers.remove(key);
    notifier?.dispose();
  }

  void registerSelectionKey(GlobalKey<TwSelectableRegionState> selectionKey) {
    selectionKeys.add(selectionKey);
  }

  void unregisterSelectionKey(GlobalKey<TwSelectableRegionState> selectionKey) {
    selectionKeys.remove(selectionKey);
  }

  /// Formats the global copied plain text by injecting Markdown formatting
  /// for any selected MarkupDocuments.
  String resolveCopyText({required String globalPlainText}) {
    final instances = <MarkupSelectionInstance>[];
    for (final entry in documents.entries) {
      final notifier = _notifiers[entry.key];
      if (notifier == null || !notifier.registered) {
        continue;
      }
      final selection = notifier.selection;
      if (selection.status == SelectionStatus.none || selection.range == null) {
        continue;
      }
      instances.add(
        MarkupSelectionInstance(
          document: entry.value,
          selectedRange: selection.range,
          selectedPlainText: selection.plainText,
          title: _titles[entry.key],
        ),
      );
    }
    return MarkupSelectionCopyFormatter.formatCopy(
      globalPlainText: globalPlainText,
      instances: instances,
    );
  }

  void dispose() {
    for (final notifier in _notifiers.values) {
      notifier.dispose();
    }
    _notifiers.clear();
    documents.clear();
    _titles.clear();
    selectionKeys.clear();
  }
}

class MarkupSelectionRegistry extends InheritedWidget {
  const MarkupSelectionRegistry({
    super.key,
    required this.copyHelper,
    required super.child,
  });

  final MarkupSelectionCopyHelper copyHelper;

  static MarkupSelectionRegistry? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MarkupSelectionRegistry>();
  }

  @override
  bool updateShouldNotify(MarkupSelectionRegistry oldWidget) {
    return copyHelper != oldWidget.copyHelper;
  }
}
