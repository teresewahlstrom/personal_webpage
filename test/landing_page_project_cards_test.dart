import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/pages/landing_page.dart';
import 'package:personal_webpage/widgets/shell/page_scaffold.dart';
import 'package:tw_chat/chat.dart';
import 'package:tw_keywords/tw_keywords.dart';

void main() {
  const SubjectKeywordData subject = SubjectKeywordData(
    id: 'test-subject',
    name: 'Test Subject',
    keywords: <KeywordNode>[
      KeywordNode(
        'AI',
        KeywordTextColorToken.cyan,
        FontWeight.w700,
        0.18,
      ),
    ],
  );

  testWidgets(
    'select all includes the first expanded project card body',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PageScaffold(
            showThemeToggle: false,
            isDarkMode: false,
            isPageLoading: false,
            showFooter: false,
            initialChatSkinMode: ChatSkinMode.light,
            child: const LandingPage(subject: subject),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Deep into AI & Workflows'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('workflow decision support'), findsOneWidget);

      final dynamic selectionRegionState = tester.state(
        find.byType(SelectableRegion),
      );
      final BuildContext selectionActionContext = tester.element(
        find.byType(RichText).first,
      );

      selectionRegionState.selectAll(SelectionChangedCause.keyboard);
      await tester.pump();

      Actions.invoke(selectionActionContext, CopySelectionTextIntent.copy);
      await tester.pump();

      final ClipboardData? clipboardData = await Clipboard.getData(
        Clipboard.kTextPlain,
      );

      expect(clipboardData?.text, contains('workflow decision support'));
    },
  );

  testWidgets(
    'page copy preserves landing page line breaks and expanded project card order',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PageScaffold(
            showThemeToggle: false,
            isDarkMode: false,
            isPageLoading: false,
            showFooter: false,
            initialChatSkinMode: ChatSkinMode.light,
            child: const LandingPage(subject: subject),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Deep into AI & Workflows'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Capability Architect'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final dynamic selectionRegionState = tester.state(
        find.byType(SelectableRegion),
      );
      final BuildContext selectionActionContext = tester.element(
        find.byType(RichText).first,
      );

      selectionRegionState.selectAll(SelectionChangedCause.keyboard);
      await tester.pump();

      Actions.invoke(selectionActionContext, CopySelectionTextIntent.copy);
      await tester.pump();

      final ClipboardData? clipboardData = await Clipboard.getData(
        Clipboard.kTextPlain,
      );
      final String copiedText = clipboardData?.text ?? '';

      expect(
        copiedText,
        startsWith('\nTerese Wahlström\nTurns complexity into clarity.'),
      );
      expect(
        copiedText,
        contains(
          '\nProfessional Story\n\nDeep into AI & Workflows\nTerese applies the same operating model through AI',
        ),
      );
      expect(
        copiedText,
        contains('\nContact, Connect, Follow\nterese@t1grid.com'),
      );

      final int firstCardBodyIndex = copiedText.indexOf(
        'Terese applies the same operating model through AI',
      );
      final int secondCardTitleIndex = copiedText.indexOf('Capability Architect');
      final int secondCardBodyIndex = copiedText.indexOf(
        'In her work, Terese repeatedly encountered environments',
      );

      expect(firstCardBodyIndex, greaterThanOrEqualTo(0));
      expect(secondCardTitleIndex, greaterThan(firstCardBodyIndex));
      expect(secondCardBodyIndex, greaterThan(secondCardTitleIndex));
      expect(
        copiedText.substring(secondCardTitleIndex - 2, secondCardTitleIndex),
        '\n\n',
      );
    },
  );
}
