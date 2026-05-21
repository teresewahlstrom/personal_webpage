import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/config/config.dart';
import 'package:tw_primitives/markdown.dart';
import 'package:tw_chat/src/widgets/message_bubble_markup_renderer.dart';

void main() {
  testWidgets('horizontal rule syntax is rendered as literal text', (
    tester,
  ) async {
    const style = TextStyle(fontSize: 12, height: 1);
    final skin = ChatSkin.dataForBrightness(Brightness.light);
    final theme = buildMarkdownTheme(
      MarkdownThemeConfig(
        baseTextColor: skin.colors.bubbleText,
        linkColor: skin.colors.markupLink,
        isDark: false,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 200,
              child: MessageBubbleMarkupRenderer(
                document: MessageMarkup.parse('Before\n\n---\n\nAfter'),
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
        (theme.baseStyle.fontSize ?? 12.0) *
      0.75;
    expect(ruleRect.top - beforeRect.bottom, closeTo(expectedSpacing, 0.5));
    expect(afterRect.top - ruleRect.bottom, closeTo(expectedSpacing, 0.5));
  });
}
