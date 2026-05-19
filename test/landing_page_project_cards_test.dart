import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/config/app_ui_config.dart';
import 'package:personal_webpage/pages/landing_page.dart';
import 'package:tw_keywords/tw_keywords.dart';

void main() {
  const subject = SubjectKeywordData(
    id: 'test',
    name: 'Test User',
    keywords: <KeywordNode>[
      KeywordNode(
        'AI',
        KeywordTextColorToken.cyan,
        FontWeight.w700,
        0.2,
        tier: 'hero',
      ),
    ],
  );
  const projectTitle = 'Professional Twin with Advanced Retrieval';
  const projectBodySnippet = 'A data-driven professional twin';

  testWidgets('project card title text is reduced by one point', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LandingPage(subject: subject)),
    );
    await tester.pumpAndSettle();

    final Text titleText = tester.widget<Text>(find.text(projectTitle));

    expect(
      titleText.style?.fontSize,
      moreOrLessEquals(
        PageTextStyles.body(tester.element(find.text(projectTitle))).fontSize! -
            1,
      ),
    );
  });

  testWidgets(
    'expanded project card keeps the bottom gap aligned with the side gap',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LandingPage(subject: subject)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(projectTitle));
      await tester.pumpAndSettle();

      final Finder bodyText = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains(projectBodySnippet),
      );
      expect(bodyText, findsWidgets);
      final Iterable<Padding> paddings = tester
          .widgetList<Padding>(
            find.ancestor(
              of: bodyText,
              matching: find.byType(Padding),
            ),
          )
          .where(
            (Padding padding) =>
                padding.padding == const EdgeInsets.fromLTRB(4, 12, 4, 4),
          );

      expect(paddings, isNotEmpty);
    },
  );
}
