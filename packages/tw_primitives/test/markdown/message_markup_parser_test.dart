import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/markdown.dart';
import 'package:tw_primitives/src/markdown/markup_parser.dart';

void main() {
  test('single newline stays in one paragraph and preserves line break', () {
    final document = MessageMarkup.parse('Alpha\nBeta');

    expect(document.blocks, hasLength(1));
    expect(document.blocks.single, isA<MarkupParagraphBlock>());
    expect(document.toPlainText(), 'Alpha\nBeta');
  });

  test('blank lines still split paragraphs', () {
    final document = MessageMarkup.parse('Alpha\n\nBeta');

    expect(document.blocks, hasLength(2));
    expect(document.blocks[0], isA<MarkupParagraphBlock>());
    expect(document.blocks[1], isA<MarkupParagraphBlock>());
    expect(document.toPlainText(), 'Alpha\n\nBeta');
  });

  test('preserveSoftLineBreaks can fold newline within the same paragraph', () {
    final document = MarkupParser.fromLines(const <String>[
      'Alpha',
      'Beta',
    ], preserveSoftLineBreaks: false).parse();

    expect(document.blocks, hasLength(1));
    expect(document.blocks.single, isA<MarkupParagraphBlock>());
    expect(document.toPlainText(), 'Alpha Beta');
  });

  group('horizontal rule', () {
    test('--- produces a horizontal rule block', () {
      final document = MessageMarkup.parse('---');

      expect(document.blocks, hasLength(1));
      expect(document.blocks.single, isA<MarkupHorizontalRuleBlock>());
    });

    test('three or more dashes produce a horizontal rule block', () {
      final document = MessageMarkup.parse('-----');

      expect(document.blocks, hasLength(1));
      expect(document.blocks.single, isA<MarkupHorizontalRuleBlock>());
    });

    test('horizontal rule is omitted from plain text', () {
      final document = MessageMarkup.parse('Before\n\n---\n\nAfter');

      expect(document.toPlainText(), 'Before\n\nAfter');
    });

    test('horizontal rule without blank lines still separates paragraphs', () {
      final document = MessageMarkup.parse('Before\n---\nAfter');

      expect(document.blocks, hasLength(3));
      expect(document.blocks[0], isA<MarkupParagraphBlock>());
      expect(document.blocks[1], isA<MarkupHorizontalRuleBlock>());
      expect(document.blocks[2], isA<MarkupParagraphBlock>());
    });
  });
}
