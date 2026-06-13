import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SelectedContent;
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/widgets/shell/page_scaffold.dart';
import 'package:tw_primitives/markdown.dart';

void main() {
  testWidgets('Test page selection copy with expanded cards', (WidgetTester tester) async {
    final doc1 = MessageMarkup.parse('Paragraph 1 in card 1.\n\nParagraph 2 in card 1.');
    final doc2 = MessageMarkup.parse('Paragraph 1 in card 2.\n\nParagraph 2 in card 2.');

    await tester.pumpWidget(
      MaterialApp(
        home: PageScaffold(
          child: Builder(
            builder: (context) {
              final selectionRegistrar = SelectionContainer.maybeOf(context);
              return Column(
                children: [
                  const Text('Card Title 1'),
                  RichText(
                    text: const TextSpan(text: '\n'),
                    selectionRegistrar: selectionRegistrar,
                    selectionColor: Colors.transparent,
                  ),
                  MarkupView(
                    title: 'Card Title 1',
                    document: doc1,
                    theme: const MarkupTheme(
                      baseStyle: TextStyle(),
                      strongStyle: TextStyle(),
                      emphasisStyle: TextStyle(),
                      strikethroughStyle: TextStyle(),
                      underlineStyle: TextStyle(),
                      linkStyle: TextStyle(),
                      blockquoteStyle: TextStyle(),
                      transparentSelectionSpacer: TextStyle(),
                      headingStyleResolver: _headingStyleResolver,
                    ),
                    gestureRecognizerFactory: (_) => null,
                    selectable: true,
                  ),
                  RichText(
                    text: const TextSpan(text: '\n\n'),
                    selectionRegistrar: selectionRegistrar,
                    selectionColor: Colors.transparent,
                  ),
                  const Text('Card Title 2'),
                  RichText(
                    text: const TextSpan(text: '\n'),
                    selectionRegistrar: selectionRegistrar,
                    selectionColor: Colors.transparent,
                  ),
                  MarkupView(
                    title: 'Card Title 2',
                    document: doc2,
                    theme: const MarkupTheme(
                      baseStyle: TextStyle(),
                      strongStyle: TextStyle(),
                      emphasisStyle: TextStyle(),
                      strikethroughStyle: TextStyle(),
                      underlineStyle: TextStyle(),
                      linkStyle: TextStyle(),
                      blockquoteStyle: TextStyle(),
                      transparentSelectionSpacer: TextStyle(),
                      headingStyleResolver: _headingStyleResolver,
                    ),
                    gestureRecognizerFactory: (_) => null,
                    selectable: true,
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find the page selection area key state
    final selectableRegionFinder = find.byType(Actions);
    expect(selectableRegionFinder, findsWidgets);

    // Let's print the elements to see the selection state
    final dynamic pageScaffoldState = tester.state(find.byType(PageScaffold));
    final helper = pageScaffoldState.pageCopyHelper;

    // Simulate select all on the page selection area key
    pageScaffoldState.pageSelectionAreaKey.currentState!.selectAll(SelectionChangedCause.keyboard);
    await tester.pumpAndSettle();

    final SelectedContent? selectedContent = pageScaffoldState.lastSelectedContent;
    expect(selectedContent, isNotNull);
    // ignore: avoid_print
    print('GLOBAL PLAIN TEXT: [${selectedContent!.plainText}]');

    for (final entry in helper.documents.entries) {
      final notifier = helper.notifierFor(entry.key);
      // ignore: avoid_print
      print('Notifier registered: ${notifier.registered}, selection: ${notifier.selection.plainText}');
    }

    final resolved = helper.resolveCopyText(globalPlainText: selectedContent.plainText);
    // ignore: avoid_print
    print('RESOLVED COPY TEXT: [$resolved]');

    expect(resolved.indexOf('## Card Title 1'), lessThan(resolved.indexOf('Paragraph 1 in card 1.')));
    expect(resolved.indexOf('## Card Title 2'), lessThan(resolved.indexOf('Paragraph 1 in card 2.')));
  });
}

TextStyle _headingStyleResolver(int level) => const TextStyle();
