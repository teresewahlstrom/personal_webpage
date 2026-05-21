import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/pages/landing_page.dart';
import 'package:tw_keywords/tw_keywords.dart';

void main() {
  test('web index advertises the site as Terese Wahlström personal website', () {
    final String indexHtml = File('web/index.html').readAsStringSync();

    expect(
      indexHtml,
      contains('<title>T1 grid — Terese Wahlström personal website</title>'),
    );
    expect(
      indexHtml,
      contains(
        'Personal website of Terese Wahlström — mechanical engineer working across AI-assisted workflows, knowledge systems, additive manufacturing, and engineering tooling.',
      ),
    );
    expect(indexHtml, contains('property="og:title"'));
    expect(indexHtml, contains('application/ld+json'));
    expect(indexHtml, contains('"@type": "Person"'));
    expect(
      indexHtml,
      contains(
        'name="viewport"\n      content="width=device-width, initial-scale=1.0, viewport-fit=cover"',
      ),
    );
    expect(indexHtml, isNot(contains('overflow: hidden;')));
    expect(indexHtml, isNot(contains('position: fixed;')));
  });

  testWidgets('landing page hero emphasizes broader engineering identity', (
    WidgetTester tester,
  ) async {
    const SubjectKeywordData subject = SubjectKeywordData(
      id: 'terese',
      name: 'Terese Wahlström',
      role: 'Mechanical Engineer',
      keywords: <KeywordNode>[
        KeywordNode(
          'AI-assisted workflows',
          KeywordTextColorToken.cyan,
          FontWeight.w700,
          0.08,
          tier: 'hero',
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LandingPage(subject: subject)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Terese Wahlström'), findsOneWidget);
    expect(
      find.text(
        'Mechanical engineer working across AI-assisted workflows, knowledge systems, additive manufacturing, and engineering tooling.',
      ),
      findsOneWidget,
    );
  });
}
