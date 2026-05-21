import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/models/message.dart';
import 'package:tw_chat/src/widgets/message_bubble.dart';
import 'package:tw_chat/src/widgets/message_list_area.dart';
import 'package:tw_chat/src/widgets/section_coordinator.dart';

void main() {
  ChatMessage message({
    required String id,
    required ChatRole role,
    required String text,
    required DateTime createdAt,
  }) {
    return ChatMessage(id: id, role: role, text: text, createdAt: createdAt);
  }

  String longText(String label, int paragraphs) {
    return List<String>.generate(
      paragraphs,
      (index) =>
          '$label paragraph ${index + 1} carries enough words to wrap over multiple lines and keep the transcript tall enough to scroll.',
    ).join('\n\n');
  }

  List<ChatMessage> buildMessages({bool withNewBot = false}) {
    final messages = <ChatMessage>[
      message(
        id: 'bot-0',
        role: ChatRole.bot,
        text: longText('Intro', 4),
        createdAt: DateTime(2026, 4, 16, 12, 0),
      ),
      message(
        id: 'user-1',
        role: ChatRole.user,
        text: longText('Question', 3),
        createdAt: DateTime(2026, 4, 16, 12, 1),
      ),
      message(
        id: 'bot-2',
        role: ChatRole.bot,
        text: longText('Earlier answer', 5),
        createdAt: DateTime(2026, 4, 16, 12, 2),
      ),
      message(
        id: 'user-3',
        role: ChatRole.user,
        text: longText('Follow-up', 3),
        createdAt: DateTime(2026, 4, 16, 12, 3),
      ),
      message(
        id: 'bot-4',
        role: ChatRole.bot,
        text: longText('Latest existing bot', 8),
        createdAt: DateTime(2026, 4, 16, 12, 4),
      ),
      message(
        id: 'user-5',
        role: ChatRole.user,
        text: longText('Most recent user', 4),
        createdAt: DateTime(2026, 4, 16, 12, 5),
      ),
    ];

    if (withNewBot) {
      messages.add(
        message(
          id: 'bot-6',
          role: ChatRole.bot,
          text: longText('Newest bot', 10),
          createdAt: DateTime(2026, 4, 16, 12, 6),
        ),
      );
    }

    return messages;
  }

  Future<void> pumpTranscript(
    WidgetTester tester, {
    required SectionCoordinator coordinator,
    required List<ChatMessage> messages,
  }) async {
    final selectionNotifiers = <String, SelectionListenerNotifier>{};

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
                    chatScroll: coordinator.chatScroll,
                    chatFocusNode: coordinator.chatFocusNode,
                    chatSelectionAreaKey: coordinator.chatSelectionAreaKey,
                    messageBubbleKeys: coordinator.messageBubbleKeys,
                    showChatScrollbarTrack: coordinator.showChatScrollbarTrack,
                    isMessageTruncated: coordinator.isMessageTruncated,
                    onToggleTruncation: coordinator.toggleMessageTruncation,
                    onChatSelectionChanged:
                        coordinator.handleChatSelectionChanged,
                    selectionNotifierForMessage: (messageId) =>
                        selectionNotifiers.putIfAbsent(
                          messageId,
                          SelectionListenerNotifier.new,
                        ),
                    onCopySelectionRequested: () => '',
                    onRequestChatKeyboardTarget: () {},
                    onChatPointerInteractionStart:
                        coordinator.handleChatPointerInteractionStart,
                    onChatPointerInteractionEnd:
                        coordinator.handleChatPointerInteractionEnd,
                    hasActiveChatSelection: () =>
                        coordinator.isChatSelectionActive,
                    onClearChatSelection: coordinator.clearChatSelection,
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

    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();
  }

  testWidgets('initialize reveals the latest completed bot message', (
    tester,
  ) async {
    final messages = buildMessages();
    var mounted = true;
    final coordinator = SectionCoordinator(
      isMounted: () => mounted,
      onSetChatKeyboardScrollTarget: () {},
    );

    addTearDown(() {
      mounted = false;
      coordinator.dispose();
    });

    coordinator.initialize(messages: messages);
    await pumpTranscript(tester, coordinator: coordinator, messages: messages);

    final viewportRect = tester.getRect(find.byType(SingleChildScrollView));
    final latestBotRect = tester.getRect(find.byType(ChatMessageBubble).at(4));
    final lastBubbleRect = tester.getRect(find.byType(ChatMessageBubble).last);

    expect(latestBotRect.top, lessThanOrEqualTo(viewportRect.top + 16));
    expect(lastBubbleRect.bottom, greaterThan(viewportRect.bottom));
  });

  testWidgets(
    'new bot messages away from bottom mark unread and jump to latest',
    (tester) async {
      final initialMessages = buildMessages();
      var mounted = true;
      final coordinator = SectionCoordinator(
        isMounted: () => mounted,
        onSetChatKeyboardScrollTarget: () {},
      );

      addTearDown(() {
        mounted = false;
        coordinator.dispose();
      });

      coordinator.initialize(messages: initialMessages);
      await pumpTranscript(
        tester,
        coordinator: coordinator,
        messages: initialMessages,
      );

      final updatedMessages = buildMessages(withNewBot: true);
      coordinator.handleWidgetUpdate(
        messages: updatedMessages,
        becameVisible: false,
        isVisible: true,
      );
      await pumpTranscript(
        tester,
        coordinator: coordinator,
        messages: updatedMessages,
      );

      expect(coordinator.hasUnseenLatestBotMessage, isTrue);

      coordinator.jumpToLatest();
      await tester.pump();
      await tester.pumpAndSettle();

      final viewportRect = tester.getRect(find.byType(SingleChildScrollView));
      final newestBotRect = tester.getRect(find.byType(ChatMessageBubble).last);

      expect(coordinator.hasUnseenLatestBotMessage, isFalse);
      expect(newestBotRect.top, lessThanOrEqualTo(viewportRect.top + 16));
      expect(newestBotRect.bottom, greaterThan(viewportRect.bottom));
    },
  );
}
