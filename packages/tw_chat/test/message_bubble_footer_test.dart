import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_chat/src/config/skin.dart';
import 'package:tw_chat/src/widgets/message_bubble.dart';

void main() {
  test('collapsed footer dash layout ends on a full dash', () {
    final segments = bubbleFooterDashSegmentsForWidth(95);

    expect(segments, hasLength(5));
    expect(segments.first.start, 0.0);
    expect(segments.last.end, moreOrLessEquals(95.0));

    for (final ({double start, double end}) segment in segments) {
      expect(
        segment.end - segment.start,
        moreOrLessEquals(bubbleFooterDashWidth),
      );
    }
  });

  test('collapsed footer line overlap is only a slight upward nudge', () {
    expect(
      bubbleFooterCollapsedLineTranslationFactor,
      moreOrLessEquals(-0.35),
    );
  });

  test('markdown strikethrough thickness is reduced to the lighter target', () {
    final TextStyle style = ChatSkin.textStyles.markdownStrikethroughStyle(
      const TextStyle(color: Colors.black),
      ChatSkin.tokens,
    );

    expect(style.decorationThickness, moreOrLessEquals(2.5));
  });
}
