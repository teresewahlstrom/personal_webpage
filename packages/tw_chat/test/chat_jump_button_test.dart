import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/theme.dart';

import 'package:tw_chat/src/widgets/chat_jump_button.dart';

void main() {
  Future<void> pumpButton(
    WidgetTester tester, {
    required bool showNewMessage,
    required VoidCallback onJumpToLatest,
    required VoidCallback onJumpToBottom,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Center(
            child: ChatJumpButton(
              showNewMessage: showNewMessage,
              onJumpToLatest: onJumpToLatest,
              onJumpToBottom: onJumpToBottom,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows circle button for jump to bottom', (tester) async {
    var latestPressed = 0;
    var bottomPressed = 0;

    await pumpButton(
      tester,
      showNewMessage: false,
      onJumpToLatest: () => latestPressed++,
      onJumpToBottom: () => bottomPressed++,
    );

    expect(find.text('new message'), findsNothing);
    expect(find.byIcon(Icons.south_rounded), findsOneWidget);

    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is GestureDetector && widget.child is TwLinkPill,
      ),
    );
    await tester.pump();

    expect(latestPressed, 0);
    expect(bottomPressed, 1);
  });

  testWidgets('shows pill button for new bot message', (tester) async {
    var latestPressed = 0;
    var bottomPressed = 0;

    await pumpButton(
      tester,
      showNewMessage: true,
      onJumpToLatest: () => latestPressed++,
      onJumpToBottom: () => bottomPressed++,
    );

    expect(find.text('new message'), findsOneWidget);
    expect(find.byIcon(Icons.south_rounded), findsOneWidget);

    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is GestureDetector && widget.child is TwLinkPill,
      ),
    );
    await tester.pump();

    expect(latestPressed, 1);
    expect(bottomPressed, 0);
  });
}
