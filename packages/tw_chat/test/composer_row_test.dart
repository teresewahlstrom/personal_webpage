import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_chat/src/config/skin.dart';
import 'package:tw_chat/src/widgets/composer_row.dart';
import 'package:tw_primitives/text_field.dart'
    show TwReadyTextController, TwReadyTextField;

void main() {
  testWidgets(
    'composer text field is not clipped so selection handles can extend outside the shell',
    (tester) async {
      final controller = TwReadyTextController(text: 'Hello world');
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        ChatSkinScope(
          mode: ChatSkinMode.light,
          child: MaterialApp(
            home: Material(
              child: ChatComposerRow(
                controller: controller,
                inputFocusNode: focusNode,
                minInputHeight: 40,
                maxInputHeight: 132,
                sendButtonMinWidth: 50,
                isAwaitingResponse: false,
                onSubmit: () {},
                onStop: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TwReadyTextField), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byType(TwReadyTextField),
          matching: find.byType(ClipRRect),
        ),
        findsNothing,
      );
    },
  );
}
