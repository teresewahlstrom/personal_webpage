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
    expect(shape.side.color, const Color(0xFFFFFFFF));
    expect(shape.side.width, 1.0);
  });

  testWidgets('chat app bar toggle icon is vertically centered in hit area', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ChatSkinScope(
        mode: ChatSkinMode.light,
        child: MaterialApp(
          home: Material(
            child: ChatAppBar(
              onDisplayStateToggle: _noop,
              displayStateToggleIcon: Icons.expand_more_rounded,
              displayStateToggleTooltip: 'Minimize chat',
              tokens: ChatSkin.tokens,
            ),
          ),
        ),
      ),
    );

    final Rect hitAreaRect = tester.getRect(find.byTooltip('Minimize chat'));
    final Rect actionBoundsRect = tester.getRect(
      find.byKey(const ValueKey('chat-app-bar-action-bounds')),
    );
    final Rect actionContainerRect = tester.getRect(
      find.byKey(const ValueKey('chat-app-bar-action-container')),
    );
    final Rect iconRect = tester.getRect(
      find.byIcon(Icons.expand_more_rounded),
    );

    expect(
      actionContainerRect.height,
      closeTo(
        actionBoundsRect.height * ChatSkin.tokens.appBarActionHeightFactor,
        0.5,
      ),
    );
    expect(hitAreaRect.height, closeTo(actionContainerRect.height, 0.5));
    expect(hitAreaRect.top, closeTo(actionBoundsRect.top, 0.5));
    expect(iconRect.center.dy, closeTo(hitAreaRect.center.dy, 0.5));
  });
}

void _noop() {}
