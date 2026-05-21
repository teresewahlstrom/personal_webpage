import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/modals/privacy_cookies_modal.dart';

void main() {
  testWidgets('privacy modal renders markdown content and opens links', (
    WidgetTester tester,
  ) async {
    String? launchedUrl;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrivacyCookiesContent(
            onLaunchUrl: (String url) async {
              launchedUrl = url;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Controller: Terese Wahlstrom (EU resident)'),
      findsOneWidget,
    );
    expect(find.text('Cookies'), findsOneWidget);
    expect(find.text('What We Collect'), findsOneWidget);
    expect(find.text('Brevo'), findsOneWidget);

    await tester.tap(find.text('Brevo'));
    await tester.pump();

    expect(launchedUrl, 'https://www.brevo.com/legal/privacypolicy/');
  });
}
