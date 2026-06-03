import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/logic/selection_copy_formatter.dart';
import 'package:tw_chat/src/models/message.dart';

void main() {
  test('partial copy spanning paragraphs restores markdown separators', () {
    const raw = 'First paragraph tail.\n\nSecond paragraph starts here.';
    const selectedPlainText = 'tail.Second paragraph starts';

    final copied = formatChatSelectionCopy(
      messages: <ChatMessage>[
        ChatMessage(
          id: 'message-1',
          role: ChatRole.bot,
          text: raw,
          createdAt: DateTime(2026, 5, 30, 12),
        ),
      ],
      selectedRanges: const <String, SelectedContentRange>{
        'message-1': SelectedContentRange(startOffset: 16, endOffset: 45),
      },
      selectedPlainTextByMessage: const <String, String>{
        'message-1': selectedPlainText,
      },
    );

    expect(copied, 'tail.\n\nSecond paragraph starts');
  });

  test(
    'partial copy spanning heading and list restores markdown structure',
    () {
      const raw = 'Intro tail.\n\n## Markdown Showcase\n- **Bold**';
      const selectedPlainText = 'tail.Markdown ShowcaseBold';

      final copied = formatChatSelectionCopy(
        messages: <ChatMessage>[
          ChatMessage(
            id: 'message-1',
            role: ChatRole.bot,
            text: raw,
            createdAt: DateTime(2026, 5, 30, 12),
          ),
        ],
        selectedRanges: const <String, SelectedContentRange>{
          'message-1': SelectedContentRange(startOffset: 6, endOffset: 31),
        },
        selectedPlainTextByMessage: const <String, String>{
          'message-1': selectedPlainText,
        },
      );

      expect(copied, 'tail.\n\n## Markdown Showcase\n- **Bold**');
    },
  );
}
