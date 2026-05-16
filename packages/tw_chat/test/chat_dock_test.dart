import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/config/skin.dart';
import 'package:tw_chat/src/widgets/chat_dock.dart';

void main() {
  testWidgets('chat app bar title renders in a pill matching chat controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ChatSkinScope(
        mode: ChatSkinMode.light,
        child: MaterialApp(
          home: Material(
            child: ChatAppBar(
              onDisplayStateToggle: _noop,
              displayStateToggleIcon: Icons.close,
              displayStateToggleTooltip: 'Close chat',
              tokens: ChatSkin.tokens,
            ),
          ),
        ),
      ),
    );

    final pill = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('chat-app-bar-title-pill')),
    );
    final decoration = pill.decoration as ShapeDecoration;
    final shape = decoration.shape as StadiumBorder;

    expect(find.text('Chat with Twin'), findsOneWidget);
    expect(shape.side.color, const Color(0xFFE1E4F2));
    expect(shape.side.width, 1.0);
  });
}

void _noop() {}
