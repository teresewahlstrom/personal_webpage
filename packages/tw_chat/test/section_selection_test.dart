import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_chat/src/config/skin.dart';
import 'package:tw_chat/src/models/message.dart';
import 'package:tw_chat/src/widgets/section.dart';
import 'package:tw_primitives/scrollbar.dart' as tw_scrollbar;

void main() {
  testWidgets('chat selection is cleared when isChatKeyboardScrollTarget becomes false', (
    tester,
  ) async {
    final isChatKeyboardScrollTarget = ValueNotifier<bool>(true);
    addTearDown(isChatKeyboardScrollTarget.dispose);

    final messages = <ChatMessage>[
      ChatMessage(
        id: 'msg-1',
        role: ChatRole.bot,
        text: 'This is some selectable message text within the chat window.',
        createdAt: DateTime(2026, 5, 21, 12),
      ),
    ];

    await tester.pumpWidget(
      ChatSkinScope(
        mode: ChatSkinMode.light,
        child: MaterialApp(
          home: Material(
            child: SizedBox(
              width: 560,
              height: 560,
              child: ChatSection(
                messages: messages,
                onSend: _noopSend,
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

    // Verify selection region is active
    final selectionAreaFinder = find.byType(tw_scrollbar.TwSelectableRegion);
    expect(selectionAreaFinder, findsOneWidget);

    final selectionAreaKey = tester.widget<tw_scrollbar.TwSelectableRegion>(selectionAreaFinder).key
        as GlobalKey<tw_scrollbar.TwSelectableRegionState>?;

    expect(selectionAreaKey, isNotNull);

    // Make selection active by calling selectAll
    selectionAreaKey!.currentState!.selectAll(SelectionChangedCause.keyboard);
    await tester.pump();

    // Find the message bubble's SelectionListener and retrieve its notifier
    final listenerFinder = find.byType(tw_scrollbar.SelectionListener).first;
    expect(listenerFinder, findsOneWidget);
    final selectionListener = tester.widget<tw_scrollbar.SelectionListener>(listenerFinder);
    final notifier = selectionListener.selectionNotifier;

    // Verify a selection exists in the message bubble notifier
    expect(notifier.selection.status, isNot(SelectionStatus.none));

    // Simulate page claiming scroll target (setting isChatKeyboardScrollTarget to false)
    isChatKeyboardScrollTarget.value = false;
    await tester.pump();

    // Verify selection is cleared!
    expect(notifier.selection.status, SelectionStatus.none);
  });
}

void _noop() {}
void _noopSend(String _) {}
