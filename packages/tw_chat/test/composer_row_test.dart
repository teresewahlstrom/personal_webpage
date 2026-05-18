import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/config/composer_layout.dart';
import 'package:tw_chat/src/config/skin.dart';
import 'package:tw_chat/src/widgets/composer_row.dart';
import 'package:tw_primitives/text_field.dart';

void main() {
  testWidgets('chat composer row applies chat skin to primitive composer shell', (
    tester,
  ) async {
    final controller = TwReadyTextController();
    final focusNode = FocusNode();

    addTearDown(() {
      focusNode.dispose();
      controller.dispose();
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
              maxInputHeight: 120,
              sendButtonMinWidth: 50,
              isAwaitingResponse: false,
              onSubmit: _noop,
              onStop: _noop,
            ),
          ),
        ),
      ),
    );

    final shell = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('tw-composer-shell')),
    );
    final decoration = shell.decoration as BoxDecoration;
    final icon = tester.widget<Icon>(find.byIcon(Icons.send_rounded));

    expect(
      decoration.color,
      ChatComposerLayout.fillColor(
        tester.element(find.byType(ChatComposerRow)),
      ),
    );
    expect(
      (decoration.border! as Border).top.color,
      ChatComposerLayout.borderColor(
        tester.element(find.byType(ChatComposerRow)),
      ),
    );
    expect(
      (decoration.border! as Border).top.width,
      ChatSkin.tokens.composerOutlineStroke,
    );
    expect(
      icon.color,
      ChatComposerLayout.sendIconColor(
        tester.element(find.byType(ChatComposerRow)),
      ),
    );
  });
}

void _noop() {}
