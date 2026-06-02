import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/widgets/app_modal.dart';
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
}
