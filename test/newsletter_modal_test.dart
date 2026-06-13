import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/modals/newsletter/newsletter_modal.dart';

void main() {
  testWidgets(
    'newsletter embed scales down and stays centered on narrow widths',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 700,
              child: NewsletterModalContent(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final frameFinder = find.byKey(
        const ValueKey<String>('newsletter-embed-frame'),
      );
      final stubFinder = find.byKey(
        const ValueKey<String>('newsletter-embed-stub'),
      );

      expect(frameFinder, findsOneWidget);
      expect(stubFinder, findsOneWidget);

      final hostRect = tester.getRect(find.byType(NewsletterModalContent));
      final frameRect = tester.getRect(frameFinder);

      expect(frameRect.width, lessThan(540));
      expect(frameRect.center.dx, closeTo(hostRect.center.dx, 0.1));
    },
  );
}
