import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_chat/src/config/skin.dart';
import 'package:tw_chat/src/widgets/composer_row.dart';
import 'package:tw_primitives/composer.dart';
import 'package:tw_primitives/text_field.dart';

void main() {
  testWidgets('composer row is built from the reusable tw_primitives composer', (
    tester,
  ) async {
    final controller = TwReadyTextController();
    final focusNode = FocusNode();
    addTearDown(() {
      controller.dispose();
      focusNode.dispose();
    });

    await tester.pumpWidget(
      ChatSkinScope(
        mode: ChatSkinMode.light,
        child: MaterialApp(
          home: Material(
            child: ChatComposerRow(
              controller: controller,
              inputFocusNode: focusNode,
              minInputHeight: 40,
              maxInputHeight: 100,
              sendButtonMinWidth: 50,
              isAwaitingResponse: false,
              onSubmit: _noop,
              onStop: _noop,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final composer = tester.widget<TwComposer>(find.byType(TwComposer));
    final textField = tester.widget<TwReadyTextField>(find.byType(TwReadyTextField));

    expect(find.byType(TwComposer), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    expect(textField.handleOutlineColor, composer.skin.fillColor);
  });
}

void _noop() {}
