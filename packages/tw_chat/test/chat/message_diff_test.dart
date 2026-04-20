import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/logic/message_diff.dart';
import 'package:tw_chat/src/models/message.dart';

void main() {
  ChatMessage message({
    required String id,
    required ChatRole role,
    required String text,
    DateTime? createdAt,
    bool isPending = false,
  }) {
    return ChatMessage(
      id: id,
      role: role,
      text: text,
      createdAt: createdAt ?? DateTime(2026, 4, 15, 16, 55),
      isPending: isPending,
    );
  }

  test('counts new visible bot messages', () {
    final summary = ChatMessageDiff.summarize(
      previousMessages: [message(id: 'm0', role: ChatRole.bot, text: 'intro')],
      currentMessages: [
        message(id: 'm0', role: ChatRole.bot, text: 'intro'),
        message(id: 'm1', role: ChatRole.user, text: 'question'),
        message(id: 'm2', role: ChatRole.bot, text: 'answer'),
      ],
    );

    expect(summary.visibleIncomingMessages, 1);
    expect(summary.resolvedPendingBotId, isNull);
    expect(summary.hasNewContent, isTrue);
  });

  test('counts resolved pending bot messages and captures first id', () {
    final summary = ChatMessageDiff.summarize(
      previousMessages: [
        message(id: 'm0', role: ChatRole.bot, text: 'intro'),
        message(id: 'm1', role: ChatRole.user, text: 'question'),
        message(id: 'm2', role: ChatRole.bot, text: '...', isPending: true),
      ],
      currentMessages: [
        message(id: 'm0', role: ChatRole.bot, text: 'intro'),
        message(id: 'm1', role: ChatRole.user, text: 'question'),
        message(id: 'm2', role: ChatRole.bot, text: 'answer'),
      ],
    );

    expect(summary.visibleIncomingMessages, 1);
    expect(summary.resolvedPendingBotId, 'm2');
    expect(summary.hasNewContent, isTrue);
  });
}
