import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/config/config.dart';
import 'package:tw_chat/src/models/message.dart';
import 'package:tw_chat/src/widgets/message_bubble.dart';
import 'package:tw_chat/src/widgets/message_list_area.dart';

void main() {
  testWidgets(
    'overflowing transcript keeps the leading gap on the first bubble and the configured trailing edge gap',
    (tester) async {
      final chatScroll = ScrollController();
      final chatFocusNode = FocusNode();
      final selectionAreaKey = GlobalKey<SelectionAreaState>();
      final messageBubbleKeys = <String, GlobalKey<State>>{};
      final selectionNotifiers = <String, SelectionListenerNotifier>{};
      final messages = List<ChatMessage>.generate(
        12,
        (index) => ChatMessage(
          id: 'message-$index',
          role: index.isEven ? ChatRole.bot : ChatRole.user,
          text:
              'Message $index carries enough text to wrap across multiple lines in the viewport and force the transcript to overflow naturally.',
          createdAt: DateTime(2026, 4, 16, 12, index),
        ),
      );

      for (final message in messages) {
        messageBubbleKeys[message.id] = GlobalKey<State>();
      }

      addTearDown(() {
        chatScroll.dispose();
        chatFocusNode.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: SizedBox(
              width: 360,
              height: 280,
              child: Column(
                children: [
                  Expanded(
                    child: ChatMessageListArea(
                      messages: messages,
                      availableWidth: 360,
                      chatScroll: chatScroll,
                      chatFocusNode: chatFocusNode,
                      chatSelectionAreaKey: selectionAreaKey,
                      messageBubbleKeys: messageBubbleKeys,
                      showChatScrollbarTrack: false,
                      isMessageTruncated: (_) => false,
                      onToggleTruncation: (_) {},
                      onChatSelectionChanged: (_) {},
                      selectionNotifierForMessage: (messageId) =>
                          selectionNotifiers.putIfAbsent(
                            messageId,
                            SelectionListenerNotifier.new,
                          ),
                      onCopySelectionRequested: () => '',
                      onRequestChatKeyboardTarget: () {},
                      onChatPointerInteractionStart: () {},
                      onChatPointerInteractionEnd: () {},
                      hasActiveChatSelection: () => false,
                      onClearChatSelection: () {},
                      jumpToLatestButton: null,
                      scrollbarTopInset: 0,
                      scrollbarBottomInset: 0,
                      contentBottomInset: 0,
                      buildScrollbarTrack:
                          ({
                            required double thickness,
                            required double crossAxisInset,
                            required double topInset,
                            required double bottomInset,
                          }) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(chatScroll.position.maxScrollExtent, greaterThan(0));
      final tokens = ChatSkin.dataForBrightness(Brightness.light).tokens;

      final initialViewportRect = tester.getRect(
        find.byType(SingleChildScrollView),
      );
      final initialFirstBubbleRect = tester.getRect(
        find.byType(ChatMessageBubble).first,
      );

      expect(initialFirstBubbleRect.top, closeTo(initialViewportRect.top, 0.1));

      chatScroll.jumpTo(chatScroll.position.maxScrollExtent);
      await tester.pumpAndSettle();

      final viewportRect = tester.getRect(find.byType(SingleChildScrollView));
      final lastBubbleRect = tester.getRect(
        find.byType(ChatMessageBubble).last,
      );

      expect(
        viewportRect.bottom - lastBubbleRect.bottom,
        closeTo(tokens.chatListTrailingGap, 0.1),
      );
    },
  );
}
