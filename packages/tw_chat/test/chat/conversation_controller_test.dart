import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/controllers/conversation_controller.dart';
import 'package:tw_chat/src/controllers/reply_client.dart';

void main() {
  test('controller starts with intro bot message', () {
    final controller = TwinConversationController(
      introText: 'intro',
      replyClient: const FixedTwinReplyClient(replyText: 'fixed'),
    );

    expect(controller.messages.length, 1);
    expect(controller.messages.first.text, 'intro');
    expect(controller.messages.first.isPending, isFalse);

    controller.dispose();
  });

  test('controller emits fixed response after pending placeholder', () async {
    final controller = TwinConversationController(
      introText: 'intro',
      replyClient: const FixedTwinReplyClient(
        replyText: 'fixed',
        replyDelay: Duration(milliseconds: 5),
      ),
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
    final controller = TwinConversationController(
      introText: 'intro',
      replyClient: const FixedTwinReplyClient(
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
      final controller = TwinConversationController(
        introText: 'intro',
        replyClient: _ThrowingTwinReplyClient(),
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
}

class _ThrowingTwinReplyClient extends TwinReplyClient {
  @override
  Future<String> fetchReply({
    required String sessionId,
    required String message,
  }) {
    throw Exception('backend down');
  }
}
