import 'package:flutter_test/flutter_test.dart';

import 'package:tw_primitives/markdown.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String plainText(String raw) => MessageMarkup.toPlainText(raw);

  List<MarkupBlock> blocks(String raw) => MessageMarkup.parse(raw).blocks;

  MarkupParagraphBlock paragraph(String raw) {
    final result = blocks(raw);
    expect(result, hasLength(1));
    expect(result.first, isA<MarkupParagraphBlock>());
    return result.first as MarkupParagraphBlock;
  }

  // ---------------------------------------------------------------------------
  // Inline tokenizer
  // ---------------------------------------------------------------------------

  group('inline tokenizer', () {
    test('plain text passes through unchanged', () {
      final inlines = paragraph('Hello world').inlines;
      expect(inlines, hasLength(1));
      expect(inlines.first.text, 'Hello world');
      expect(inlines.first.isStrong, isFalse);
    });

    test('**bold** is parsed as strong', () {
      final inlines = paragraph('before **bold** after').inlines;
      final bold = inlines.firstWhere((i) => i.isStrong);
      expect(bold.text, 'bold');
    });

    test('__bold__ is parsed as strong', () {
      final inlines = paragraph('__bold__').inlines;
      expect(inlines.first.isStrong, isTrue);
      expect(inlines.first.text, 'bold');
    });

    test('*italic* is parsed as emphasis', () {
      final inlines = paragraph('*italic*').inlines;
      expect(inlines.first.isEmphasis, isTrue);
      expect(inlines.first.text, 'italic');
    });

    test('_italic_ is parsed as emphasis', () {
      final inlines = paragraph('_italic_').inlines;
      expect(inlines.first.isEmphasis, isTrue);
      expect(inlines.first.text, 'italic');
    });

    test('~~strikethrough~~ is parsed', () {
      final inlines = paragraph('~~strike~~').inlines;
      expect(inlines.first.isStrikethrough, isTrue);
      expect(inlines.first.text, 'strike');
    });

    test('<u>underline</u> tag is parsed', () {
      final inlines = paragraph('<u>underline</u>').inlines;
      expect(inlines.first.isUnderline, isTrue);
      expect(inlines.first.text, 'underline');
    });

    test('[label](url) markdown link is parsed', () {
      final inlines = paragraph('[Click here](https://example.com)').inlines;
      expect(inlines.first.text, 'Click here');
      expect(inlines.first.href, 'https://example.com');
    });

    test('bare https URL is auto-linked', () {
      final inlines = paragraph('Visit https://example.com today').inlines;
      final link = inlines.firstWhere((i) => i.href != null);
      expect(link.href, 'https://example.com');
    });

    test('bare http URL is auto-linked', () {
      final inlines = paragraph('http://example.com').inlines;
      expect(inlines.first.href, 'http://example.com');
    });

    test('escaped asterisk is treated as literal', () {
      final inlines = paragraph(r'\*literal\*').inlines;
      expect(inlines.first.text, '*literal*');
      expect(inlines.first.isEmphasis, isFalse);
    });

    test('escaped backslash is treated as literal', () {
      final inlines = paragraph(r'\\').inlines;
      expect(inlines.first.text, r'\');
    });

    test('unclosed bold delimiter is not parsed as strong', () {
      final inlines = paragraph('**unclosed').inlines;
      expect(inlines.every((i) => !i.isStrong), isTrue);
    });

    test('empty bold delimiters produce no token', () {
      final inlines = paragraph('****').inlines;
      expect(inlines.every((i) => !i.isStrong), isTrue);
    });

    test('empty markdown link label falls back to autolink parsing', () {
      final inlines = paragraph('[](https://example.com)').inlines;

      expect(inlines.any((i) => i.href == 'https://example.com'), isTrue);
      expect(inlines.first.text, '[](');
      expect(inlines.last.text, ')');
    });

    test('link with empty href is not parsed as link', () {
      final inlines = paragraph('[label]()').inlines;
      expect(inlines.every((i) => i.href == null), isTrue);
    });

    test('combined bold-italic: bold wraps emphasis token', () {
      // **bold** followed by *italic* — both parsed in the same paragraph
      final inlines = paragraph('**bold** and *italic*').inlines;
      expect(inlines.any((i) => i.isStrong && i.text == 'bold'), isTrue);
      expect(inlines.any((i) => i.isEmphasis && i.text == 'italic'), isTrue);
    });

    test('plain text toPlainText round-trips unchanged', () {
      const raw = 'Hello world';
      expect(plainText(raw), raw);
    });

    test('inline markup is stripped in toPlainText', () {
      expect(plainText('**bold** and *italic*'), 'bold and italic');
    });

    test('link label is used in toPlainText, href appended when different', () {
      final text = plainText('[Click here](https://example.com)');
      expect(text, contains('Click here'));
      expect(text, contains('https://example.com'));
    });

    test('link label equals href: href not duplicated in toPlainText', () {
      const url = 'https://example.com';
      final text = plainText('[$url]($url)');
      expect(url.allMatches(text).length, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // Block parser
  // ---------------------------------------------------------------------------

  group('block parser — paragraphs', () {
    test('single line produces one paragraph', () {
      expect(blocks('Hello'), hasLength(1));
      expect(blocks('Hello').first, isA<MarkupParagraphBlock>());
    });

    test('blank line separates two paragraphs', () {
      final result = blocks('First\n\nSecond');
      expect(result, hasLength(2));
      expect(result.every((b) => b is MarkupParagraphBlock), isTrue);
    });

    test('consecutive non-blank lines collapse into one paragraph', () {
      // Default parser does NOT preserve soft line breaks
      final result = blocks('Line one\nLine two');
      expect(result, hasLength(1));
    });
  });

  group('block parser — headings', () {
    test('# H1 produces heading level 1', () {
      final result = blocks('# Heading');
      expect(result, hasLength(1));
      final heading = result.first as MarkupHeadingBlock;
      expect(heading.level, 1);
      expect(heading.inlines.first.text, 'Heading');
    });

    test('## H2 produces heading level 2', () {
      final heading = blocks('## Sub').first as MarkupHeadingBlock;
      expect(heading.level, 2);
    });

    test('### beyond max level is treated as paragraph', () {
      // _maxHeadingLevel is 2; ### should not produce a heading
      final result = blocks('### Too deep');
      expect(result.first, isA<MarkupParagraphBlock>());
    });

    test('heading is stripped to plain text in toPlainText', () {
      expect(plainText('# Title'), 'Title');
    });
  });

  group('block parser — horizontal rule', () {
    test('--- is treated as literal paragraph text', () {
      final result = blocks('---');
      expect(result, hasLength(1));
      expect(result.first, isA<MarkupParagraphBlock>());
    });

    test('horizontal rule plain text keeps the marker', () {
      expect(plainText('---').trim(), '---');
    });
  });

  group('block parser — unordered lists', () {
    test('- items produce a list block', () {
      final result = blocks('- Alpha\n- Beta\n- Gamma');
      expect(result, hasLength(1));
      final list = result.first as MarkupListBlock;
      expect(list.ordered, isFalse);
      expect(list.items, hasLength(3));
    });

    test('list item text is correct', () {
      final list = blocks('- Foo\n- Bar').first as MarkupListBlock;
      final item0Para = list.items[0].blocks.first as MarkupParagraphBlock;
      final item1Para = list.items[1].blocks.first as MarkupParagraphBlock;
      expect(item0Para.inlines.first.text, 'Foo');
      expect(item1Para.inlines.first.text, 'Bar');
    });

    test('nested list is parsed inside parent item', () {
      const raw = '- Parent\n    - Child';
        final list = blocks(raw).first as MarkupListBlock;
      final nestedList = list.items.first.blocks
          .whereType<MarkupListBlock>()
          .first;
      final childPara =
          nestedList.items.first.blocks.first as MarkupParagraphBlock;
      expect(childPara.inlines.first.text, 'Child');
    });

    test('unordered list toPlainText contains item text', () {
      final text = plainText('- Alpha\n- Beta');
      expect(text, contains('Alpha'));
      expect(text, contains('Beta'));
    });
  });

  group('block parser — ordered lists', () {
    test('1. items produce an ordered list block', () {
      final list = blocks('1. One\n2. Two').first as MarkupListBlock;
      expect(list.ordered, isTrue);
      expect(list.items, hasLength(2));
    });

    test('ordered list startingIndex is preserved', () {
      final list = blocks('3. Three\n4. Four').first as MarkupListBlock;
      expect(list.startingIndex, 3);
    });
  });

  group('block parser — blockquotes', () {
    test('> prefix produces a blockquote block', () {
      final result = blocks('> A quote');
      expect(result, hasLength(1));
      expect(result.first, isA<MarkupBlockquoteBlock>());
    });

    test('blockquote content is parsed as nested blocks', () {
      final bq = blocks('> **Bold** quote').first as MarkupBlockquoteBlock;
      final para = bq.blocks.first as MarkupParagraphBlock;
      expect(para.inlines.first.isStrong, isTrue);
    });

    test('blank line between quote lines stays in same blockquote', () {
      // Two consecutive > lines with blank > line between
      final result = blocks('> First\n>\n> Second');
      expect(result, hasLength(1));
      expect(result.first, isA<MarkupBlockquoteBlock>());
    });

    test('blockquote toPlainText contains quoted text', () {
      expect(plainText('> A quote'), contains('A quote'));
    });
  });

  group('block parser — mixed content', () {
    test('paragraph followed by list', () {
      final result = blocks('Intro\n\n- Item');
      expect(result[0], isA<MarkupParagraphBlock>());
      expect(result[1], isA<MarkupListBlock>());
    });

    test('heading followed by paragraph', () {
      final result = blocks('# Title\n\nBody text');
      expect(result[0], isA<MarkupHeadingBlock>());
      expect(result[1], isA<MarkupParagraphBlock>());
    });

    test('toPlainText joins blocks with double newlines', () {
      final text = plainText('First\n\nSecond');
      expect(text, contains('First'));
      expect(text, contains('Second'));
    });
  });
}
