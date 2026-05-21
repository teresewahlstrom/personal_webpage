import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/markdown.dart';

void main() {
  test('parses markdown links with balanced parentheses in href', () {
    final document = MessageMarkup.parse(
      '[Wikipedia](https://en.wikipedia.org/wiki/Function_(mathematics))',
    );

    final paragraph = document.blocks.single as MarkupParagraphBlock;
    final link = paragraph.inlines.single;

    expect(link.text, 'Wikipedia');
    expect(link.href, 'https://en.wikipedia.org/wiki/Function_(mathematics)');
  });

  test('keeps trailing text after markdown links with parentheses in href', () {
    final document = MessageMarkup.parse(
      '[docs](https://example.com/path(a)/more) trailing',
    );

    final paragraph = document.blocks.single as MarkupParagraphBlock;

    expect(paragraph.inlines, hasLength(2));
    expect(paragraph.inlines[0].text, 'docs');
    expect(paragraph.inlines[0].href, 'https://example.com/path(a)/more');
    expect(paragraph.inlines[1].text, ' trailing');
    expect(paragraph.inlines[1].href, isNull);
  });
}
