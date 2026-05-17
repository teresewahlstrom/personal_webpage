import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/config/app_ui_config.dart';
import 'package:personal_webpage/widgets/app_modal.dart';

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
    final AppLineStyle frameBorder = ModalUiConfig.frameBorderFor(
      Brightness.light,
    );

    expect(
      dialog.backgroundColor,
      ModalUiConfig.frameFillFor(Brightness.light),
    );
    expect(shape.borderRadius, BorderRadius.zero);
    expect(shape.side.color, frameBorder.color);
    expect(shape.side.width, frameBorder.width);
  });
}
