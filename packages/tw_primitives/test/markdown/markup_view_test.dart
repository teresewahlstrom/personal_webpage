import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/markdown.dart';
import 'package:tw_primitives/theme.dart';

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

  testWidgets('link pill text does not keep underline decoration', (
    tester,
  ) async {
    await tester.pumpWidget(
      _MarkupTestApp(
        document: MessageMarkup.parse('[Twin](https://example.com)'),
        baseStyle: const TextStyle(fontSize: 20, height: 1),
        linkPillStyle: const TwLinkPillStyle(
          fillColor: Colors.white,
          borderColor: Colors.black,
          textStyle: TextStyle(fontSize: 13),
        ),
      ),
    );

    expect(
      tester.widget<Text>(find.text('Twin')).style?.decoration,
      TextDecoration.none,
    );
    expect(
      tester
          .widget<MouseRegion>(
            find.ancestor(
              of: find.text('Twin'),
              matching: find.byType(MouseRegion),
            ),
          )
          .cursor,
      SystemMouseCursors.click,
    );
  });

  testWidgets(
    'chrome-free selectable path does not inject copy-break RichText between paragraphs',
    (tester) async {
      await tester.pumpWidget(
        _MarkupTestApp(
          document: MessageMarkup.parse('Before\n\nAfter'),
          baseStyle: const TextStyle(fontSize: 20, height: 1),
          chromeVisible: false,
        ),
      );

      expect(_newlineRichText(), findsNothing);
    },
  );

  testWidgets(
    'chrome-free selectable path does not inject copy-break RichText between list items',
    (tester) async {
      await tester.pumpWidget(
        _MarkupTestApp(
          document: MessageMarkup.parse('1. One\n2. Two'),
          baseStyle: const TextStyle(fontSize: 20, height: 1),
          chromeVisible: false,
        ),
      );

      expect(_newlineRichText(), findsNothing);
    },
  );

  testWidgets('chrome-free selectable nested lists preserve nested alignment', (
    tester,
  ) async {
    await tester.pumpWidget(
      _MarkupTestApp(
        document: MessageMarkup.parse(
          '1. Parent\n    - Child one\n    - Child two\n2. Next',
        ),
        baseStyle: const TextStyle(fontSize: 20, height: 1),
        chromeVisible: false,
      ),
    );

    final parentRect = tester.getRect(_richTextWithPlainText('Parent').first);
    final childRect = tester.getRect(_richTextWithPlainText('Child one').first);
    final nextRect = tester.getRect(_richTextWithPlainText('Next').first);

    expect(childRect.left, greaterThan(parentRect.left));
    expect(nextRect.left, closeTo(parentRect.left, 0.5));
    expect(nextRect.top, greaterThan(childRect.bottom));
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
  const _MarkupTestApp({
    required this.document,
    required this.baseStyle,
    this.chromeVisible = true,
    this.linkPillStyle,
  });

  final MarkupDocument document;
  final TextStyle baseStyle;
  final bool chromeVisible;
  final TwLinkPillStyle? linkPillStyle;

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
              theme: _theme(baseStyle, linkPillStyle: linkPillStyle),
              gestureRecognizerFactory: (_) => null,
              chromeVisible: chromeVisible,
            ),
          ),
        ),
      ),
    );
  }
}

MarkupTheme _theme(TextStyle baseStyle, {TwLinkPillStyle? linkPillStyle}) {
  return MarkupTheme(
    baseStyle: baseStyle,
    strongStyle: const TextStyle(fontWeight: FontWeight.bold),
    emphasisStyle: const TextStyle(fontStyle: FontStyle.italic),
    strikethroughStyle: const TextStyle(decoration: TextDecoration.lineThrough),
    underlineStyle: const TextStyle(decoration: TextDecoration.underline),
    linkStyle: const TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),
    linkPillStyle: linkPillStyle,
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

Finder _newlineRichText() {
  return find.byWidgetPredicate(
    (Widget widget) => widget is RichText && widget.text.toPlainText() == '\n',
  );
}
