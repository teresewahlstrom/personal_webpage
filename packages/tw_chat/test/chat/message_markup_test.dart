import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/logic/message_markup.dart';

void main() {
  test(
    'plain text keeps paragraph gaps between blocks and single breaks inside lists',
    () {
      final plainText = ChatMessageMarkup.toPlainText('''**Strengths:**

1. **Process improvement and system design** - identifies friction points
2. **Cross-functional coordination** - builds coalitions
3. **Knowledge infrastructure** - turns knowledge into reusable structures''');

      expect(
        plainText,
        'Strengths:\n\n'
        '1. Process improvement and system design - identifies friction points\n'
        '2. Cross-functional coordination - builds coalitions\n'
        '3. Knowledge infrastructure - turns knowledge into reusable structures',
      );
    },
  );

  test('plain text preserves blank line separation between paragraphs', () {
    final plainText = ChatMessageMarkup.toPlainText('''First paragraph.

Second paragraph.''');

    expect(plainText, 'First paragraph.\n\nSecond paragraph.');
  });

  test(
    'single top-level line breaks create paragraph gaps in rendered output',
    () {
      final document = ChatMessageMarkup.parse('''First paragraph.
Second paragraph.''');

      expect(document.toPlainText(), 'First paragraph.\n\nSecond paragraph.');
      expect(document.blocks.length, 2);

      final span = document.toTextSpan(
        theme: _testTheme(),
        gestureRecognizerFactory: (_) => null,
      );

      expect(span.toPlainText(), 'First paragraph.\n\nSecond paragraph.');
    },
  );

  test('plain text expands markdown links and removes inline markup', () {
    final plainText = ChatMessageMarkup.toPlainText(
      'See [portfolio](https://example.com), *italic*, ~~struck~~, and <u>underlined</u>.',
    );

    expect(
      plainText,
      'See portfolio (https://example.com), italic, struck, and underlined.',
    );
  });

  test('bare urls are autolinked without duplicating plain text', () {
    final document = ChatMessageMarkup.parse(
      'Visit https://example.com/docs and www.example.com.',
    );

    expect(
      document.toPlainText(),
      'Visit https://example.com/docs and www.example.com.',
    );

    final span = document.toTextSpan(
      theme: _testTheme(),
      gestureRecognizerFactory: (_) => null,
    );
    final paragraph = span.children!.single as TextSpan;
    final segments = paragraph.children!.cast<TextSpan>().toList(
      growable: false,
    );

    expect(
      segments.any(
        (segment) =>
            segment.text == 'https://example.com/docs' &&
            segment.style?.decoration == TextDecoration.underline,
      ),
      isTrue,
    );
    expect(
      segments.any(
        (segment) =>
            segment.text == 'www.example.com' &&
            segment.style?.decoration == TextDecoration.underline,
      ),
      isTrue,
    );
  });

  test('plain text preserves escaped markdown markers literally', () {
    final plainText = ChatMessageMarkup.toPlainText(
      r'\*literal asterisks\* and \[not a link](ignored)',
    );

    expect(plainText, '*literal asterisks* and [not a link](ignored)');
  });

  test('plain text preserves blockquotes', () {
    final plainText = ChatMessageMarkup.toPlainText('''> quoted line
>
> still quoted''');

    expect(
      plainText,
      '> quoted line\n'
      '> \n'
      '> still quoted',
    );
  });

  test('plain text preserves nested lists and indented continuation lines', () {
    final plainText = ChatMessageMarkup.toPlainText('''- Parent item
  continuation line
  - Nested one
  - Nested two
- Next item''');

    expect(
      plainText,
      '• Parent item continuation line\n'
      '  • Nested one\n'
      '  • Nested two\n'
      '• Next item',
    );
  });

  test('heading levels render with different sizes', () {
    final document = ChatMessageMarkup.parse('''# Level one

### Level three''');

    final firstHeading = document.blocks[0] as ChatMarkupHeadingBlock;
    final thirdHeading = document.blocks[1] as ChatMarkupHeadingBlock;

    final firstSpan = firstHeading.toTextSpan(
      theme: _testTheme(),
      gestureRecognizerFactory: (_) => null,
    );
    final thirdSpan = thirdHeading.toTextSpan(
      theme: _testTheme(),
      gestureRecognizerFactory: (_) => null,
    );

    expect(firstSpan.style!.fontSize, greaterThan(thirdSpan.style!.fontSize!));
  });

  test('heading markers beyond H3 are parsed as paragraph text', () {
    final document = ChatMessageMarkup.parse('#### Level four');
    expect(document.blocks, hasLength(1));
    expect(document.blocks.single, isA<ChatMarkupParagraphBlock>());
    expect(document.toPlainText(), '#### Level four');
  });

  test('rich text plain output matches transcript body formatting', () {
    final document = ChatMessageMarkup.parse('''# Strengths

1. **Process improvement** - designs better systems
2. [Portfolio](https://example.com)''');

    final span = document.toTextSpan(
      theme: _testTheme(),
      gestureRecognizerFactory: (_) => null,
    );

    expect(
      span.toPlainText(),
      'Strengths\n\n'
      '1. Process improvement - designs better systems\n'
      '2. Portfolio',
    );
  });

  test('rich text applies inline formatting styles beyond bold', () {
    final document = ChatMessageMarkup.parse(
      '*Italic* ~~Strike~~ <u>Underline</u>',
    );

    final span = document.toTextSpan(
      theme: _testTheme(),
      gestureRecognizerFactory: (_) => null,
    );

    final paragraph = span.children!.single as TextSpan;
    final segments = paragraph.children!.cast<TextSpan>().toList(
      growable: false,
    );

    expect(segments[0].text, 'Italic');
    expect(segments[0].style?.fontStyle, FontStyle.italic);

    expect(segments[2].text, 'Strike');
    expect(segments[2].style?.decoration, TextDecoration.lineThrough);

    expect(segments[4].text, 'Underline');
    expect(segments[4].style?.decoration, TextDecoration.underline);
  });
}

ChatMarkupTheme _testTheme() {
  const baseStyle = TextStyle(fontSize: 12, height: 1.5);
  return ChatMarkupTheme(
    baseStyle: baseStyle,
    strongStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    emphasisStyle: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
    strikethroughStyle: const TextStyle(
      fontSize: 12,
      decoration: TextDecoration.lineThrough,
    ),
    underlineStyle: const TextStyle(
      fontSize: 12,
      decoration: TextDecoration.underline,
    ),
    linkStyle: const TextStyle(
      fontSize: 12,
      decoration: TextDecoration.underline,
    ),
    blockquoteStyle: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
    headingStyleResolver: _testHeadingStyle,
  );
}

TextStyle _testHeadingStyle(int level) {
  const baseSize = 12.0;
  const scales = <double>[1.55, 1.36, 1.22];
  final index = level.clamp(1, 3) - 1;
  return TextStyle(
    fontSize: baseSize * scales[index],
    fontWeight: FontWeight.w800,
  );
}
