import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/markdown.dart';

void main() {
  group('SelectionCopyProjection Tests', () {
    test('Formats plain paragraph', () {
      final doc = MessageMarkup.parse('Hello world');
      final projection = SelectionCopyProjection.fromDocument(doc);

      expect(projection.visibleText, 'Hello world');
      expect(projection.visibleLength, 11);

      // Slice entire text
      expect(projection.copySlice(start: 0, end: 11), 'Hello world');
      // Slice part of text
      expect(projection.copySlice(start: 0, end: 5), 'Hello');
    });

    test('Formats bold and emphasis', () {
      final doc = MessageMarkup.parse('Hello **bold** *emphasis*');
      final projection = SelectionCopyProjection.fromDocument(doc);

      expect(projection.visibleText, 'Hello bold emphasis');
      expect(projection.visibleLength, 19);

      // Slice entire text
      expect(projection.copySlice(start: 0, end: 19), 'Hello **bold** *emphasis*');
      // Slice only bold portion
      expect(projection.copySlice(start: 6, end: 10), '**bold**');
      // Slice crossing boundaries
      expect(projection.copySlice(start: 0, end: 10), 'Hello **bold**');
    });

    test('Formats links', () {
      final doc = MessageMarkup.parse('[T1 grid](https://t1grid.com)');
      final projection = SelectionCopyProjection.fromDocument(doc);

      expect(projection.visibleText, 'T1 grid');
      expect(projection.visibleLength, 7);

      expect(projection.copySlice(start: 0, end: 7), '[T1 grid](https://t1grid.com)');
      expect(projection.copySlice(start: 3, end: 7), 'grid');
    });

    test('Formats blockquotes', () {
      final doc = MessageMarkup.parse('> Quote line 1\n> Quote line 2');
      final projection = SelectionCopyProjection.fromDocument(doc);

      expect(projection.visibleText, 'Quote line 1\nQuote line 2');

      expect(projection.copySlice(start: 0, end: 25), '> Quote line 1\n> Quote line 2');
    });

    test('Formats headers', () {
      final doc = MessageMarkup.parse('# Heading 1\n\n## Heading 2');
      final projection = SelectionCopyProjection.fromDocument(doc);

      expect(projection.visibleText, 'Heading 1\nHeading 2');

      expect(projection.copySlice(start: 0, end: 9), '# Heading 1');
      expect(
        projection.copySlice(
          start: 10,
          end: 19,
          includeLeadingCopyAtStart: true,
        ),
        '## Heading 2',
      );
    });
  });

  group('MarkupSelectionCopyFormatter Tests', () {
    test('replaces plain text selection with formatted markdown', () {
      final doc = MessageMarkup.parse('Click [here](https://example.com) for **details**.');
      final instance = MarkupSelectionInstance(
        document: doc,
        selectedRange: const SelectedContentRange(startOffset: 6, endOffset: 17),
        selectedPlainText: 'here for details',
      );

      final result = MarkupSelectionCopyFormatter.formatCopy(
        globalPlainText: 'Page title\nClick here for details.',
        instances: [instance],
      );

      expect(result, 'Page title\nClick [here](https://example.com) for **details**.');
    });
  });
}
