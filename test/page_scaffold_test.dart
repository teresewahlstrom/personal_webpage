import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/widgets/shell/_page_footer.dart';
import 'package:personal_webpage/widgets/shell/page_scaffold.dart';
import 'package:tw_chat/chat.dart' show ChatSkinMode;

void main() {
  testWidgets('page scaffold keeps the footer at the viewport bottom', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: PageScaffold(
          showThemeToggle: false,
          isDarkMode: false,
          isPageLoading: false,
          showFooter: true,
          initialChatSkinMode: ChatSkinMode.light,
          child: const SizedBox(height: 120, child: Text('Short page')),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(PageFooter), findsOneWidget);
    expect(
      tester.getRect(find.byType(PageFooter)).bottom,
      moreOrLessEquals(900),
    );
  });
}
