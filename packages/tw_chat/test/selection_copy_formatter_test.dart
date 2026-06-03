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

  test('plain text anchoring does not truncate copied tail', () {
    const raw = 'Start **bold text** and more text.';
    const selectedPlainText = 'Start bold text';

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
        'message-1': SelectedContentRange(startOffset: 0, endOffset: 34),
      },
      selectedPlainTextByMessage: const <String, String>{
        'message-1': selectedPlainText,
      },
    );

    expect(copied, contains('Start **bold text** and more text.'));
    expect(copied, endsWith('Start **bold text** and more text.'));
  });

  test('tiny nonzero start offset is treated as full message copy', () {
    const raw = '## Prototype Mode\nEventually this will be a real AI chat.';
    const selectedPlainText = 'rototype Mode\nEventually this will be a real AI chat.';

    final copied = formatChatSelectionCopy(
      messages: <ChatMessage>[
        ChatMessage(
          id: 'message-1',
          role: ChatRole.bot,
          text: raw,
          createdAt: DateTime(2026, 6, 3, 16, 47),
        ),
      ],
      selectedRanges: const <String, SelectedContentRange>{
        'message-1': SelectedContentRange(startOffset: 2, endOffset: 54),
      },
      selectedPlainTextByMessage: const <String, String>{
        'message-1': selectedPlainText,
      },
    );

    expect(copied, startsWith('---\nTwin'));
    expect(copied, contains('## Prototype Mode'));
  });
}
