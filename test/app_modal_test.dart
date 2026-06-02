import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/config/app_ui_config.dart';
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

    final Dialog dialog = tester.widget<Dialog>(find.byType(Dialog));
    final RoundedRectangleBorder shape =
        dialog.shape! as RoundedRectangleBorder;
    final TwColors tw = TwColors.forBrightness(Brightness.light);
    final AppLineStyle frameBorder = AppLineStyle(
      color: tw.lineSubtle,
      width: AppLineTheme.subtleWidth,
    );

    expect(dialog.backgroundColor, tw.modalBackground);
    expect(shape.borderRadius, BorderRadius.zero);
    expect(shape.side.color, frameBorder.color);
    expect(shape.side.width, frameBorder.width);
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
      of: find.byType(Dialog),
      matching: find.byWidgetPredicate(
        (Widget widget) => widget is Padding && widget.padding == customPadding,
      ),
    );

    expect(modalContentPadding, findsOneWidget);
  });
}
