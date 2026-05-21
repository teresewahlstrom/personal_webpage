import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_chat/src/composer/chat_composer.dart';
import 'package:tw_chat/src/config/skin.dart';
import 'package:tw_chat/src/models/message.dart';
import 'package:tw_chat/src/widgets/message_bubble.dart';
import 'package:tw_chat/src/widgets/section.dart';

void main() {
  testWidgets('bot bubble aligns with the composer input shell', (
    tester,
  ) async {
    final isChatKeyboardScrollTarget = ValueNotifier<bool>(true);
    addTearDown(isChatKeyboardScrollTarget.dispose);

    await tester.pumpWidget(
      ChatSkinScope(
        mode: ChatSkinMode.light,
        child: MaterialApp(
          home: Material(
            child: SizedBox(
              width: 560,
              height: 560,
              child: ChatSection(
                messages: <ChatMessage>[
                  ChatMessage(
                    id: 'bot-1',
                    role: ChatRole.bot,
                    text: 'Hello from the bot bubble.',
                    createdAt: DateTime(2026, 5, 21, 12),
                  ),
                ],
                onSend: _onSend,
                onStop: _noop,
                isChatKeyboardScrollTarget: isChatKeyboardScrollTarget,
                onSetChatKeyboardScrollTarget: _noop,
                isVisible: true,
                panelWidth: 560,
                panelHeight: 560,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final composerInputShell = find.descendant(
      of: find.byType(ChatComposer),
      matching: find.byType(ClipRRect),
    );
    final botBubbleFrame = find.descendant(
      of: find.byType(ChatMessageBubble),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox &&
            widget.width != null &&
            widget.width!.isFinite &&
            widget.width! > 400,
      ),
    ).first;

    expect(
      tester.getTopLeft(botBubbleFrame).dx,
      closeTo(tester.getTopLeft(composerInputShell).dx, 0.01),
    );
    expect(
      tester.getTopRight(botBubbleFrame).dx,
      closeTo(tester.getTopRight(composerInputShell).dx, 0.01),
    );
  });
}

void _noop() {}

void _onSend(String _) {}
