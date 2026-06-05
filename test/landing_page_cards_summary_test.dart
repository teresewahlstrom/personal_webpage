import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/pages/landing_page.dart';
import 'package:personal_webpage/widgets/shell/page_scaffold.dart';

void main() {
  testWidgets(
    'landing cards keep summary visible while deep dive only appears expanded',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PageScaffold(
            showFooter: false,
            showThemeToggle: false,
            child: LandingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder cardTitle = find.text('Cross-Functional Leader');
      final Finder summaryText = find.textContaining(
        'The hardest problems in technical organizations do not sit inside a single function.',
        findRichText: true,
      );
      final Finder deepDiveText = find.textContaining(
        'structured investigation, technical curiosity, and evidence-driven analysis',
        findRichText: true,
      );

      expect(cardTitle, findsOneWidget);
      expect(summaryText, findsOneWidget);
      expect(deepDiveText, findsNothing);

      await tester.tap(summaryText);
      await tester.pumpAndSettle();
      expect(deepDiveText, findsNothing);

      await tester.tap(cardTitle);
      await tester.pumpAndSettle();
      expect(summaryText, findsOneWidget);
      expect(deepDiveText, findsOneWidget);
    },
  );
}
