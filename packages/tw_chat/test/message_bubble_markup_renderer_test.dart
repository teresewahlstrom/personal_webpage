import 'package:flutter/material.dart' hide GestureRecognizerFactory;
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/config/config.dart';
import 'package:tw_primitives/markdown.dart';
import 'package:tw_chat/src/widgets/message_bubble_markup_renderer.dart';

void main() {
  testWidgets('horizontal rule syntax is rendered as literal text', (
    tester,
  ) async {
    const style = TextStyle(fontSize: 12, height: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 200,
              child: MessageBubbleMarkupRenderer(
                document: ChatMessageMarkup.parse('Before\n\n---\n\nAfter'),
                style: style,
                bubbleColor: Colors.white,
                isUserBubble: false,
                truncatedContentHeight: 0,
                isTruncated: false,
                gestureRecognizerFactory: (_) => null,
              ),
            ),
          ),
        ),
      ),
    );

    final beforeFinder = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText() == 'Before',
    );
    final ruleFinder = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText() == '---',
    );
    final afterFinder = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText() == 'After',
    );

    final beforeRect = tester.getRect(beforeFinder.first);
    final ruleRect = tester.getRect(ruleFinder.first);
    final afterRect = tester.getRect(afterFinder.first);

    final expectedSpacing =
        (style.fontSize ?? 12.0) * ChatSkin.tokens.markupBlockBaseSpacingFactor;
    expect(ruleRect.top - beforeRect.bottom, closeTo(expectedSpacing, 0.5));
    expect(afterRect.top - ruleRect.bottom, closeTo(expectedSpacing, 0.5));
  });

  test('H2 heading style uses the computed size without the old -1 offset', () {
    const baseStyle = TextStyle(fontSize: 12, height: 1);
    final skin = ChatSkin.dataForBrightness(Brightness.light);

    final headingStyle = skin.textStyles.markdownHeadingStyle(
      baseStyle,
      2,
      skin.colors,
    );

    expect(headingStyle.fontSize, closeTo(12 * 1.36, 0.001));
  });

  test('strikethrough thickness is balanced by skin mode', () {
    const baseStyle = TextStyle(fontSize: 12, height: 1, color: Colors.black);
    final tokens = ChatSkin.tokens;
    final textStyles = ChatSkin.textStyles;

    final lightStyle = textStyles.markdownStrikethroughStyle(
      baseStyle,
      tokens,
      isDark: false,
    );
    final darkStyle = textStyles.markdownStrikethroughStyle(
      baseStyle,
      tokens,
      isDark: true,
    );

    expect(lightStyle.decorationThickness, closeTo(2.8, 0.001));
    expect(darkStyle.decorationThickness, closeTo(4.2, 0.001));
    expect(_renderedStrikeThickness(lightStyle), closeTo(1.4, 0.001));
    expect(_renderedStrikeThickness(darkStyle), closeTo(2.1, 0.001));
  });
}

double? _renderedStrikeThickness(TextStyle strikeStyle) {
  final theme = ChatMarkupTheme(
    baseStyle: const TextStyle(fontSize: 12),
    strongStyle: const TextStyle(fontWeight: FontWeight.bold),
    emphasisStyle: const TextStyle(fontStyle: FontStyle.italic),
    strikethroughStyle: strikeStyle,
    underlineStyle: const TextStyle(decoration: TextDecoration.underline),
    linkStyle: const TextStyle(color: Colors.blue),
    blockquoteStyle: const TextStyle(fontStyle: FontStyle.italic),
    headingStyleResolver: (int level) => const TextStyle(fontSize: 12),
  );

  final span = const ChatMarkupInline(
    text: 'gone',
    isStrikethrough: true,
  ).toTextSpan(theme: theme, gestureRecognizerFactory: (_) => null);

  return span.style?.decorationThickness;
}
