import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/pages/landing_page.dart';
import 'package:tw_primitives/markdown.dart';

void main() {
  testWidgets(
    'project card header is not selectable while markdown body remains selectable',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LandingPage())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Capability Architecture'));
      await tester.pumpAndSettle();

      final Finder titleSelectionContainer = find.ancestor(
        of: find.text('Capability Architecture'),
        matching: find.byType(SelectionContainer),
      );
      final RichText titleRichText = tester.widget<RichText>(
        find.descendant(
          of: titleSelectionContainer.first,
          matching: find.byType(RichText),
        ).first,
      );
      final RichText bodyRichText = tester.widget<RichText>(
        find.descendant(
          of: find.byType(MarkupView).first,
          matching: find.byType(RichText),
        ).first,
      );

      expect(titleRichText.selectionRegistrar, isNull);
      expect(bodyRichText.selectionRegistrar, isNotNull);
    },
  );

  testWidgets('expanded project card keeps bottom markdown overflow padding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LandingPage())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Capability Architecture'));
    await tester.pumpAndSettle();

    final Padding expandedPadding = tester.widget<Padding>(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Padding &&
            widget.padding == const EdgeInsets.only(top: 12, bottom: 4),
      ),
    );

    expect(expandedPadding.padding, const EdgeInsets.only(top: 12, bottom: 4));
  });
}
