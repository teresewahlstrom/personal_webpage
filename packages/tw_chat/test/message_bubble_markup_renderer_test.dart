import 'package:flutter/material.dart' hide GestureRecognizerFactory;
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/config/config.dart';
import 'package:tw_chat/src/logic/message_markup.dart';
import 'package:tw_chat/src/widgets/message_bubble_markup_renderer.dart';

void main() {
  testWidgets('horizontal rules keep tighter spacing above and below', (
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

    final beforeRect = tester.getRect(
      find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText() == 'Before',
      ),
    );
    final afterRect = tester.getRect(
      find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText() == 'After',
      ),
    );

    final tokens = ChatSkin.tokens;
    final fontSize = style.fontSize ?? 12.0;
    final expectedPerSideSpacing =
        fontSize *
        (tokens.markupBlockBaseSpacingFactor +
            tokens.markupBlockQuoteExtraSpacing) *
        (2 / 3);
    final expectedVerticalGap =
        expectedPerSideSpacing * 2 + tokens.markupBlockquoteRailWidth;

    expect(
      afterRect.top - beforeRect.bottom,
      closeTo(expectedVerticalGap, 0.5),
    );
  });
}
