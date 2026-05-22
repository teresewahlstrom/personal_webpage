import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tw_primitives/markdown.dart';

void main() {
  testWidgets('top-level ordered lists have extra space above', (tester) async {
    const baseStyle = TextStyle(fontSize: 20, height: 1);

    await tester.pumpWidget(
      _MarkupTestApp(
        document: MessageMarkup.parse('Before\n\n1. One'),
        baseStyle: baseStyle,
      ),
    );

    final beforeRect = tester.getRect(_richTextWithPlainText('Before').first);
    final itemRect = tester.getRect(_richTextWithPlainText('One').first);

    expect(itemRect.top - beforeRect.bottom, closeTo(12.6, 0.5));
  });

  testWidgets('headers keep a little more space below', (tester) async {
    const baseStyle = TextStyle(fontSize: 20, height: 1);

    await tester.pumpWidget(
      _MarkupTestApp(
        document: MessageMarkup.parse('# Heading\n\nAfter'),
        baseStyle: baseStyle,
      ),
    );

    final headingRect = tester.getRect(_richTextWithPlainText('Heading').first);
    final afterRect = tester.getRect(_richTextWithPlainText('After').first);

    expect(afterRect.top - headingRect.bottom, closeTo(11.4, 0.5));
  });

  testWidgets('blockquotes keep tighter spacing above', (tester) async {
    const baseStyle = TextStyle(fontSize: 20, height: 1);

    await tester.pumpWidget(
      _MarkupTestApp(
        document: MessageMarkup.parse('Before\n\n> Quote'),
        baseStyle: baseStyle,
      ),
    );

    final beforeRect = tester.getRect(_richTextWithPlainText('Before').first);
    final quoteRect = tester.getRect(_richTextWithPlainText('Quote').first);

    expect(quoteRect.top - beforeRect.bottom, closeTo(27.0, 0.5));
  });

  testWidgets('paragraphs keep less space after a top-level list', (tester) async {
    const baseStyle = TextStyle(fontSize: 20, height: 1);

    await tester.pumpWidget(
      _MarkupTestApp(
        document: MessageMarkup.parse('1. One\n\nAfter'),
        baseStyle: baseStyle,
      ),
    );

    final itemRect = tester.getRect(_richTextWithPlainText('One').first);
    final afterRect = tester.getRect(_richTextWithPlainText('After').first);

    expect(afterRect.top - itemRect.bottom, closeTo(24.0, 0.5));
  });

  testWidgets('unordered list marker uses the reduced SVG size', (tester) async {
    const baseStyle = TextStyle(fontSize: 20, height: 1);

    await tester.pumpWidget(
      _MarkupTestApp(
        document: MessageMarkup.parse('* One'),
        baseStyle: baseStyle,
      ),
    );

    final SvgPicture marker = tester.widget<SvgPicture>(find.byType(SvgPicture));

    expect(marker.width, 14.0);
    expect(marker.height, 14.0);
  });

  test('strikethrough thickness is scaled down to half the source stroke', () {
    const theme = MarkupTheme(
      baseStyle: TextStyle(fontSize: 14),
      strongStyle: TextStyle(fontWeight: FontWeight.bold),
      emphasisStyle: TextStyle(fontStyle: FontStyle.italic),
      strikethroughStyle: TextStyle(
        decoration: TextDecoration.lineThrough,
        decorationThickness: 4.0,
      ),
      underlineStyle: TextStyle(decoration: TextDecoration.underline),
      linkStyle: TextStyle(color: Colors.blue),
      blockquoteStyle: TextStyle(fontStyle: FontStyle.italic),
      headingStyleResolver: _headingStyle,
    );

    final span = const MarkupInline(
      text: 'gone',
      isStrikethrough: true,
    ).toTextSpan(theme: theme, gestureRecognizerFactory: (_) => null);

    expect(span.style?.decorationThickness, 2.0);
  });
}

class _MarkupTestApp extends StatelessWidget {
  const _MarkupTestApp({required this.document, required this.baseStyle});

  final MarkupDocument document;
  final TextStyle baseStyle;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            child: MarkupView(
              document: document,
              theme: _theme(baseStyle),
              gestureRecognizerFactory: (_) => null,
            ),
          ),
        ),
      ),
    );
  }
}

MarkupTheme _theme(TextStyle baseStyle) {
  return MarkupTheme(
    baseStyle: baseStyle,
    strongStyle: const TextStyle(fontWeight: FontWeight.bold),
    emphasisStyle: const TextStyle(fontStyle: FontStyle.italic),
    strikethroughStyle: const TextStyle(decoration: TextDecoration.lineThrough),
    underlineStyle: const TextStyle(decoration: TextDecoration.underline),
    linkStyle: const TextStyle(color: Colors.blue),
    blockquoteStyle: baseStyle.copyWith(fontStyle: FontStyle.italic),
    headingStyleResolver: (int level) => baseStyle.copyWith(
      fontSize: level == 1 ? 30 : 24,
      fontWeight: FontWeight.bold,
      height: 1,
    ),
  );
}

TextStyle _headingStyle(int level) {
  return TextStyle(fontSize: level == 1 ? 30 : 24);
}

Finder _richTextWithPlainText(String text) {
  return find.byWidgetPredicate(
    (Widget widget) => widget is RichText && widget.text.toPlainText() == text,
  );
}
