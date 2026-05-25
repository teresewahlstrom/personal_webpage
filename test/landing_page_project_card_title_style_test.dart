import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/config/app_ui_config.dart';
import 'package:personal_webpage/pages/landing_page.dart';
import 'package:tw_keywords/tw_keywords.dart';

void main() {
  testWidgets('project card titles use the H2 page text style', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LandingPage(
          subject: const SubjectKeywordData(
            id: 'test',
            name: 'Test',
            keywords: <KeywordNode>[],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder titleFinder = find.text('Capability Architect');
    expect(titleFinder, findsOneWidget);

    final Text titleText = tester.widget<Text>(titleFinder);
    final BuildContext context = tester.element(titleFinder);
    final TextStyle expectedStyle = PageTextStyles.h2(context);

    expect(titleText.style?.fontFamily, expectedStyle.fontFamily);
    expect(titleText.style?.fontWeight, expectedStyle.fontWeight);
    expect(titleText.style?.fontSize, expectedStyle.fontSize);
    expect(titleText.style?.height, expectedStyle.height);
    expect(titleText.style?.color, expectedStyle.color);
  });
}
