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
      expect(
        projection.copySlice(start: 0, end: 19),
        'Hello **bold** *emphasis*',
      );
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

      expect(
        projection.copySlice(start: 0, end: 7),
        '[T1 grid](https://t1grid.com)',
      );
      expect(projection.copySlice(start: 3, end: 7), 'grid');
    });

    test('Formats blockquotes', () {
      final doc = MessageMarkup.parse('> Quote line 1\n> Quote line 2');
      final projection = SelectionCopyProjection.fromDocument(doc);

      expect(projection.visibleText, 'Quote line 1\nQuote line 2');

      expect(
        projection.copySlice(start: 0, end: 25),
        '> Quote line 1\n> Quote line 2',
      );
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

    test('Keeps one blank line above headings after paragraph text', () {
      final doc = MessageMarkup.parse('Paragraph text.\n## Heading');
      final projection = SelectionCopyProjection.fromDocument(doc);

      expect(
        projection.copySlice(start: 0, end: projection.visibleLength),
        'Paragraph text.\n\n## Heading',
      );
    });

    test('Preserves escaped literal markdown characters', () {
      final doc = MessageMarkup.parse(
        '- Escaped markdown: \\*literal asterisks\\*',
      );
      final projection = SelectionCopyProjection.fromDocument(doc);

      expect(
        projection.copySlice(start: 0, end: projection.visibleLength),
        '- Escaped markdown: \\*literal asterisks\\*',
      );
    });

    test('Uses 4-space indentation for nested unordered list items', () {
      final doc = MessageMarkup.parse('- Parent\n    - Child');
      final projection = SelectionCopyProjection.fromDocument(doc);

      expect(
        projection.copySlice(start: 0, end: projection.visibleLength),
        '- Parent\n    - Child',
      );
    });

    test('Omits horizontal rule from copied markdown', () {
      final doc = MessageMarkup.parse('Before\n\n---\n\nAfter');
      final projection = SelectionCopyProjection.fromDocument(doc);

      expect(projection.visibleText, 'Before\nAfter');
      expect(
        projection.copySlice(start: 0, end: projection.visibleLength),
        'Before\n\nAfter',
      );
    });
  });

  group('MarkupSelectionCopyFormatter Tests', () {
    test('replaces plain text selection with formatted markdown', () {
      final doc = MessageMarkup.parse(
        'Click [here](https://example.com) for **details**.',
      );
      final instance = MarkupSelectionInstance(
        document: doc,
        selectedRange: const SelectedContentRange(
          startOffset: 6,
          endOffset: 17,
        ),
        selectedPlainText: 'here for details',
      );

      final result = MarkupSelectionCopyFormatter.formatCopy(
        globalPlainText: 'Page title\nClick here for details.',
        instances: [instance],
      );

      expect(
        result,
        'Page title\nClick [here](https://example.com) for **details**.',
      );
    });

    test('keeps title before body when selected plain text includes both', () {
      final doc = MessageMarkup.parse('Body paragraph.');
      final instance = MarkupSelectionInstance(
        document: doc,
        selectedRange: const SelectedContentRange(
          startOffset: 0,
          endOffset: 15,
        ),
        selectedPlainText: 'Card Title\nBody paragraph.',
        title: 'Card Title',
      );

      final result = MarkupSelectionCopyFormatter.formatCopy(
        globalPlainText: 'Card Title\nBody paragraph.',
        instances: [instance],
      );

      expect(result, '## Card Title\nBody paragraph.');
    });

    test('adds a blank line before promoted title in multi-card copy', () {
      final doc = MessageMarkup.parse('Body paragraph.');
      final instance = MarkupSelectionInstance(
        document: doc,
        selectedRange: const SelectedContentRange(
          startOffset: 0,
          endOffset: 15,
        ),
        selectedPlainText: 'Body paragraph.',
        title: 'Second Card',
      );

      final result = MarkupSelectionCopyFormatter.formatCopy(
        globalPlainText: 'First card ending.\nSecond Card\nBody paragraph.',
        instances: [instance],
      );

      expect(result, 'First card ending.\n\n## Second Card\nBody paragraph.');
    });

    test('adds a blank line before promoted title selected with body', () {
      final doc = MessageMarkup.parse('Body paragraph.');
      final instance = MarkupSelectionInstance(
        document: doc,
        selectedRange: const SelectedContentRange(
          startOffset: 0,
          endOffset: 15,
        ),
        selectedPlainText: 'Second Card\nBody paragraph.',
        title: 'Second Card',
      );

      final result = MarkupSelectionCopyFormatter.formatCopy(
        globalPlainText: 'First card ending.\nSecond Card\nBody paragraph.',
        instances: [instance],
      );

      expect(result, 'First card ending.\n\n## Second Card\nBody paragraph.');
    });

    test(
      'adds a line break after promoted title when global text lacks one',
      () {
        final doc = MessageMarkup.parse('Body paragraph.');
        final instance = MarkupSelectionInstance(
          document: doc,
          selectedRange: const SelectedContentRange(
            startOffset: 0,
            endOffset: 15,
          ),
          selectedPlainText: 'Body paragraph.',
          title: 'Card Title',
        );

        final result = MarkupSelectionCopyFormatter.formatCopy(
          globalPlainText: 'Card TitleBody paragraph.',
          instances: [instance],
        );

        expect(result, '## Card Title\nBody paragraph.');
      },
    );

    test('promotes registered plain heading lines', () {
      final result = formatPlainHeadingCopy(
        globalPlainText: 'First card ending.\nSecond Card\nBody paragraph.',
        headings: const <String>['Second Card'],
      );

      expect(result, 'First card ending.\n\n## Second Card\nBody paragraph.');
    });

    test('does not promote registered heading text inside paragraphs', () {
      final result = formatPlainHeadingCopy(
        globalPlainText:
            'Second Card\nA paragraph that mentions Second Card inline.',
        headings: const <String>['Second Card'],
      );

      expect(
        result,
        '## Second Card\nA paragraph that mentions Second Card inline.',
      );
    });
  });
}
