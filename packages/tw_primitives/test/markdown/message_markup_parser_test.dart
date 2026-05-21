import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/markdown.dart';
import 'package:tw_primitives/src/markdown/markup_parser.dart';

void main() {
  test('single newline stays in one paragraph by default', () {
    final document = MessageMarkup.parse('Alpha\nBeta');

    expect(document.blocks, hasLength(1));
    expect(document.blocks.single, isA<MarkupParagraphBlock>());
    expect(document.toPlainText(), 'Alpha Beta');
  });

  test('blank lines still split paragraphs', () {
    final document = MessageMarkup.parse('Alpha\n\nBeta');

    expect(document.blocks, hasLength(2));
    expect(document.blocks[0], isA<MarkupParagraphBlock>());
    expect(document.blocks[1], isA<MarkupParagraphBlock>());
    expect(document.toPlainText(), 'Alpha\n\nBeta');
  });

  test('preserveSoftLineBreaks keeps newline within the same paragraph', () {
    final document = MarkupParser.fromLines(
      const <String>['Alpha', 'Beta'],
      preserveSoftLineBreaks: true,
    ).parse();

    expect(document.blocks, hasLength(1));
    expect(document.blocks.single, isA<MarkupParagraphBlock>());
    expect(document.toPlainText(), 'Alpha\nBeta');
  });
}