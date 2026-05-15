import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/controllers/conversation_controller.dart';
import 'package:tw_chat/src/controllers/reply_client.dart';

void main() {
  test('controller starts with intro bot message', () {
    final controller = ConversationController(
      introText: 'intro',
      replyClient: const FixedReplyClient(replyText: 'fixed'),
      minimumPendingReplyDuration: Duration.zero,
    );

    expect(controller.messages.length, 1);
    expect(controller.messages.first.text, 'intro');
    expect(controller.messages.first.isPending, isFalse);

    controller.dispose();
  });

  test('controller emits fixed response after pending placeholder', () async {
    final controller = ConversationController(
      introText: 'intro',
      replyClient: const FixedReplyClient(
        replyText: 'fixed',
        replyDelay: Duration(milliseconds: 5),
      ),
      minimumPendingReplyDuration: Duration.zero,
    );

    controller.sendMessage('hello');

    expect(controller.messages.length, 3);
    expect(controller.messages[1].text, 'hello');
    expect(controller.messages[2].isPending, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(controller.messages.length, 3);
    expect(controller.messages[2].isPending, isFalse);
    expect(controller.messages[2].text, 'fixed');

    controller.dispose();
  });

  test('stopPendingReply removes pending bot messages', () {
    final controller = ConversationController(
      introText: 'intro',
      replyClient: const FixedReplyClient(
        replyText: 'fixed',
        replyDelay: Duration(seconds: 5),
      ),
    );

    controller.sendMessage('hello');
    expect(controller.messages.any((m) => m.isPending), isTrue);

    controller.stopPendingReply();

    expect(controller.messages.any((m) => m.isPending), isFalse);
    expect(controller.messages.length, 2);

    controller.dispose();
  });

  test(
    'controller shows backend error message when reply client fails',
    () async {
      final controller = ConversationController(
        introText: 'intro',
        replyClient: _ThrowingReplyClient(),
        minimumPendingReplyDuration: Duration.zero,
      );

      controller.sendMessage('hello');
      await Future<void>.delayed(Duration.zero);

      expect(controller.messages.length, 3);
      expect(controller.messages.last.isPending, isFalse);
      expect(
        controller.messages.last.text,
        'I cannot respond right now. Please try again.',
      );

      controller.dispose();
    },
  );

  test('controller keeps immediate replies pending briefly', () async {
    final controller = ConversationController(
      introText: 'intro',
      replyClient: const FixedReplyClient(replyText: 'fixed'),
      minimumPendingReplyDuration: const Duration(milliseconds: 40),
    );

    controller.sendMessage('hello');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(controller.messages.length, 3);
    expect(controller.messages.last.isPending, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(controller.messages.last.isPending, isFalse);
    expect(controller.messages.last.text, 'fixed');

    controller.dispose();
  });
}

class _ThrowingReplyClient extends ReplyClient {
  @override
  Future<String> fetchReply({
    required String sessionId,
    required String message,
  }) {
    throw Exception('backend down');
  }
}
