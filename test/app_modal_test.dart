import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/widgets/app_modal.dart';
import 'package:tw_primitives/scrollbar.dart' show TwScrollArea;
import 'package:tw_primitives/theme.dart';

void main() {
  testWidgets('showAppModal uses the shared square themed frame', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: () {
                  showAppModal(
                    context: context,
                    headerTitle: 'Subscribe',
                    builder: (_, _) => const Text('Modal body'),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final TwPanelContainer panel = tester.widget<TwPanelContainer>(
      find.byType(TwPanelContainer),
    );
    expect(panel, isNotNull);
    expect(find.byKey(const ValueKey('chat-app-bar-title-pill')), findsNothing);

    final BuildContext titleContext = tester.element(find.text('Subscribe'));
    final Text titleText = tester.widget<Text>(find.text('Subscribe'));
    final TextStyle expectedTitleStyle = TwTextStyles.of(titleContext).h1From(
      TwTextStyles.of(titleContext).bodyForContext(
        context: titleContext,
        color: titleContext.twColors.pageBodyText,
      ),
    );
    expect(titleText.style?.fontSize, expectedTitleStyle.fontSize);
    expect(titleText.style?.fontWeight, expectedTitleStyle.fontWeight);
    final Positioned topShadow = tester.widget<Positioned>(
      find.ancestor(
        of: find.byKey(const ValueKey('tw-panel-top-shadow')),
        matching: find.byType(Positioned),
      ),
    );
    expect(topShadow.height, 56.0);
    final Positioned actionBounds = tester.widget<Positioned>(
      find.byKey(const ValueKey('chat-app-bar-action-bounds')),
    );
    expect(actionBounds.height, 48.0);
    expect(actionBounds.bottom, isNull);

    final decoratedBoxes = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(TwPanelContainer),
        matching: find.byType(DecoratedBox),
      ),
    );

    final bgBox = decoratedBoxes.firstWhere(
      (box) =>
          box.decoration is BoxDecoration &&
          (box.decoration as BoxDecoration).color != null,
    );
    final bgDecoration = bgBox.decoration as BoxDecoration;

    final borderBox = decoratedBoxes.firstWhere(
      (box) =>
          box.decoration is BoxDecoration &&
          (box.decoration as BoxDecoration).border != null,
    );
    final borderDecoration = borderBox.decoration as BoxDecoration;

    final tw = TwColors.forBrightness(Brightness.light);

    expect(bgDecoration.color, tw.shellBackground);
    expect(bgDecoration.borderRadius, BorderRadius.zero);
    expect(borderDecoration.border!.top.color, tw.shellOuterBorder);
    expect(borderDecoration.border!.top.width, 1.0);
  });

  testWidgets('showAppModal respects custom content padding override', (
    WidgetTester tester,
  ) async {
    const EdgeInsets customPadding = EdgeInsets.fromLTRB(10, 11, 12, 13);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: () {
                  showAppModal(
                    context: context,
                    contentPadding: customPadding,
                    builder: (_, _) => const Text('Modal body'),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final Finder modalContentPadding = find.descendant(
      of: find.byType(TwPanelContainer),
      matching: find.byWidgetPredicate(
        (Widget widget) =>
            widget is TwPanelScope && widget.containerPadding == customPadding,
      ),
    );

    expect(modalContentPadding, findsOneWidget);
  });

  testWidgets('showAppModal supports custom headers with expanded top shadow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: () {
                  showAppModal(
                    context: context,
                    header: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('TERESE AS:'),
                        Text('Product R&D Engineer'),
                      ],
                    ),
                    builder: (_, _) => const Text('Modal body'),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('TERESE AS:'), findsOneWidget);
    expect(find.text('Product R&D Engineer'), findsOneWidget);
    final Positioned topShadow = tester.widget<Positioned>(
      find.ancestor(
        of: find.byKey(const ValueKey('tw-panel-top-shadow')),
        matching: find.byType(Positioned),
      ),
    );
    expect(topShadow.height, 84.0);
    final Positioned actionBounds = tester.widget<Positioned>(
      find.byKey(const ValueKey('chat-app-bar-action-bounds')),
    );
    expect(actionBounds.height, 48.0);
    expect(actionBounds.bottom, isNull);
  });

  testWidgets('panel scrollbar can reach above header-padded content', (
    WidgetTester tester,
  ) async {
    const double headerInset = 64.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SizedBox(
            width: 320,
            height: 420,
            child: TwPanelContainer(
              onClose: () {},
              title: TwPanelTitle(label: 'Privacy & Cookies'),
              body: const TwPanelScrollArea(
                overlapHeaderTopInset: headerInset,
                child: SizedBox(height: 900, child: Text('Long body')),
              ),
            ),
          ),
        ),
      ),
    );

    final TwScrollArea scrollArea = tester.widget<TwScrollArea>(
      find.byType(TwScrollArea),
    );
    final Positioned topShadow = tester.widget<Positioned>(
      find.ancestor(
        of: find.byKey(const ValueKey('tw-panel-top-shadow')),
        matching: find.byType(Positioned),
      ),
    );

    expect(scrollArea.padding?.resolve(TextDirection.ltr).top, headerInset);
    expect(scrollArea.scrollbarInsets.resolve(TextDirection.ltr).top, 36.0);
    expect(topShadow.right, 12.0);
  });
}
