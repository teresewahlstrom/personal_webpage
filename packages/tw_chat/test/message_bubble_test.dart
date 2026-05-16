import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/logic/message_markup.dart';
import 'package:tw_chat/src/logic/selection_copy_formatter.dart';
import 'package:tw_chat/src/models/message.dart';
import 'package:tw_chat/src/widgets/message_bubble.dart';

void main() {
  testWidgets('collapsed bubble copies the full plain text transcript body', (
    tester,
  ) async {
    final selectionAreaKey = GlobalKey<SelectionAreaState>();
    const rawText =
        '''Line one carries enough words to wrap through the bubble width for truncation.

1. Line two carries enough words to wrap through the bubble width for truncation.
2. Line three carries enough words to wrap through the bubble width for truncation.

Line four carries enough words to wrap through the bubble width for truncation.

> Line five carries enough words to wrap through the bubble width for truncation.
> Line six carries enough words to wrap through the bubble width for truncation.

Line seven carries enough words to wrap through the bubble width for truncation.

Line eight carries enough words to wrap through the bubble width for truncation.''';

    await _pumpTruncatedBubble(
      tester,
      text: rawText,
      selectionAreaKey: selectionAreaKey,
    );
    final selectionActionContext = tester.element(find.byType(RichText).first);

    selectionAreaKey.currentState!.selectableRegion.selectAll(
      SelectionChangedCause.keyboard,
    );
    await tester.pump();

    Actions.invoke(selectionActionContext, CopySelectionTextIntent.copy);
    await tester.pump();

    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);

    expect(clipboardData?.text, ChatMessageMarkup.toPlainText(rawText).trim());
  });

  testWidgets(
    'collapsed bubble uses the structured markdown renderer for lists and blockquotes',
    (tester) async {
      const rawText = '''1. First item
2. Second item

> Quoted line
> Still quoted

Paragraph six carries enough words to wrap through the bubble width for truncation.

Paragraph seven carries enough words to wrap through the bubble width for truncation.

Paragraph eight carries enough words to wrap through the bubble width for truncation.''';

      await _pumpTruncatedBubble(tester, text: rawText);

      final richTexts = tester.widgetList<RichText>(find.byType(RichText));
      final hasStructuredListMarker = richTexts.any((richText) {
        final plainText = richText.text.toPlainText().trim();
        return plainText == '1.' || plainText == '2.';
      });
      final hasBlockQuoteContainer = tester
          .widgetList<Container>(find.byType(Container))
          .any((container) {
            final decoration = container.decoration;
            if (decoration is! BoxDecoration) {
              return false;
            }
            final border = decoration.border;
            if (border is! Border) {
              return false;
            }
            return border.left.width == 2;
          });

      expect(hasStructuredListMarker, isTrue);
      expect(hasBlockQuoteContainer, isTrue);
    },
  );

  testWidgets('collapsed bubble indents nested list items in copied text', (
    tester,
  ) async {
    final selectionAreaKey = GlobalKey<SelectionAreaState>();
    const rawText = '''1. Parent item
2. Second parent
    - Child item
    - Second child''';

    await _pumpTruncatedBubble(
      tester,
      text: rawText,
      selectionAreaKey: selectionAreaKey,
    );

    final selectionActionContext = tester.element(find.byType(RichText).first);

    selectionAreaKey.currentState!.selectableRegion.selectAll(
      SelectionChangedCause.keyboard,
    );
    await tester.pump();

    Actions.invoke(selectionActionContext, CopySelectionTextIntent.copy);
    await tester.pump();

    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);

    expect(
      clipboardData?.text,
      contains('2. Second parent\n   - Child item\n   - Second child'),
    );
  });

  testWidgets('collapsed bubble links remain tappable', (tester) async {
    const rawText = '''[Example](https://example.com)

Line one carries enough words to wrap through the bubble width for truncation.

Line two carries enough words to wrap through the bubble width for truncation.

Line three carries enough words to wrap through the bubble width for truncation.

Line four carries enough words to wrap through the bubble width for truncation.''';

    await _pumpTruncatedBubble(tester, text: rawText);

    final visibleLink = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.selectionRegistrar == null &&
          widget.text.toPlainText().contains('Example'),
    );

    expect(visibleLink, findsOneWidget);
  });

  testWidgets(
    'chat transcript copy stays ordered when the first message is truncated',
    (tester) async {
      final selectionAreaKey = GlobalKey<SelectionAreaState>();
      final messages = <ChatMessage>[
        ChatMessage(
          id: 'bot-1',
          role: ChatRole.bot,
          text: '''# Prototype Mode

I answer from a fixed Terese context and keep in-session chat memory while the local backend is running.

## Markdown Showcase

1. Ordered lists work
2. Nested lists work too
    - Child item
    - Second child item
3. Here is another top-level item after nested list''',
          createdAt: DateTime(2026, 4, 16, 12, 49),
        ),
        ChatMessage(
          id: 'user-1',
          role: ChatRole.user,
          text: 'I cannot respond right now. Please try again.',
          createdAt: DateTime(2026, 4, 16, 12, 50),
        ),
        ChatMessage(
          id: 'user-2',
          role: ChatRole.user,
          text: 'I cannot respond right now. Please try again.',
          createdAt: DateTime(2026, 4, 16, 12, 51),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Center(
              child: SizedBox(
                width: 320,
                child: _TestTranscriptSelectionArea(
                  selectionAreaKey: selectionAreaKey,
                  messages: messages,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final entry in messages.indexed)
                        ChatMessageBubble(
                          key: ValueKey(entry.$2.id),
                          text: entry.$2.text,
                          selectionListenerNotifier:
                              _TestTranscriptSelectionArea.notifierFor(
                                entry.$2.id,
                              ),
                          isUser: entry.$2.role == ChatRole.user,
                          isTypingIndicator: false,
                          isTruncated: entry.$1 == 0,
                          isFirstMessage: entry.$1 == 0,
                          isLastMessage: entry.$1 == messages.length - 1,
                          availableWidth: 320,
                          onToggleTruncation: _noop,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final selectionActionContext = tester.element(
        find.byType(RichText).first,
      );

      selectionAreaKey.currentState!.selectableRegion.selectAll(
        SelectionChangedCause.keyboard,
      );
      await tester.pump();

      Actions.invoke(selectionActionContext, CopySelectionTextIntent.copy);
      await tester.pump();

      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);

      expect(
        clipboardData?.text,
        '---\n'
        'Twin (12:49, 16th of April 2026)\n\n'
        '# Prototype Mode\n\n'
        'I answer from a fixed Terese context and keep in-session chat memory while the local backend is running.\n\n'
        '## Markdown Showcase\n\n'
        '1. Ordered lists work\n'
        '2. Nested lists work too\n'
        '   - Child item\n'
        '   - Second child item\n'
        '3. Here is another top-level item after nested list\n\n'
        '---\n'
        'You (12:50, 16th of April 2026)\n\n'
        '${messages[1].text}\n\n'
        '---\n'
        'You (12:51, 16th of April 2026)\n\n'
        '${messages[2].text}',
      );
    },
  );

  testWidgets('chat transcript copy preserves full multiline blockquotes', (
    tester,
  ) async {
    final selectionAreaKey = GlobalKey<SelectionAreaState>();
    final messages = <ChatMessage>[
      ChatMessage(
        id: 'bot-quote',
        role: ChatRole.bot,
        text: '''Prototype Mode

> Blockquotes render as callouts.
>
> They also keep paragraph spacing.''',
        createdAt: DateTime(2026, 4, 16, 15, 13),
      ),
      ChatMessage(
        id: 'user-1',
        role: ChatRole.user,
        text: 'User message #1',
        createdAt: DateTime(2026, 4, 16, 15, 15),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Center(
            child: SizedBox(
              width: 320,
              child: _TestTranscriptSelectionArea(
                selectionAreaKey: selectionAreaKey,
                messages: messages,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final entry in messages.indexed)
                      ChatMessageBubble(
                        key: ValueKey(entry.$2.id),
                        text: entry.$2.text,
                        selectionListenerNotifier:
                            _TestTranscriptSelectionArea.notifierFor(
                              entry.$2.id,
                            ),
                        isUser: entry.$2.role == ChatRole.user,
                        isTypingIndicator: false,
                        isTruncated: false,
                        isFirstMessage: entry.$1 == 0,
                        isLastMessage: entry.$1 == messages.length - 1,
                        availableWidth: 320,
                        onToggleTruncation: _noop,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final selectionActionContext = tester.element(find.byType(RichText).first);

    selectionAreaKey.currentState!.selectableRegion.selectAll(
      SelectionChangedCause.keyboard,
    );
    await tester.pump();

    Actions.invoke(selectionActionContext, CopySelectionTextIntent.copy);
    await tester.pump();

    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);

    expect(
      clipboardData?.text,
      '---\n'
      'Twin (15:13, 16th of April 2026)\n\n'
      'Prototype Mode\n\n'
      '> Blockquotes render as callouts.\n'
      '> \n'
      '> They also keep paragraph spacing.\n\n'
      '---\n'
      'You (15:15, 16th of April 2026)\n\n'
      'User message #1',
    );
  });

  testWidgets(
    'expanded user bubbles remove the bottom border and let the footer line own that edge',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Center(
              child: SizedBox(
                width: 320,
                child: ChatMessageBubble(
                  text: 'Short user message',
                  selectionListenerNotifier: SelectionListenerNotifier(),
                  isUser: true,
                  isTypingIndicator: false,
                  isTruncated: false,
                  isFirstMessage: true,
                  isLastMessage: true,
                  availableWidth: 320,
                  onToggleTruncation: _noop,
                ),
              ),
            ),
          ),
        ),
      );

      final bubbleContainer = tester.widget<Container>(
        find.byWidgetPredicate((widget) {
          if (widget is! Container) {
            return false;
          }
          final decoration = widget.decoration;
          return decoration is BoxDecoration && decoration.border != null;
        }).first,
      );
      final border = (bubbleContainer.decoration! as BoxDecoration).border! as Border;

      expect(border.top.style, BorderStyle.solid);
      expect(border.left.style, BorderStyle.solid);
      expect(border.right.style, BorderStyle.solid);
      expect(border.bottom.style, BorderStyle.none);
    },
  );
}

Future<void> _pumpTruncatedBubble(
  WidgetTester tester, {
  required String text,
  Key? selectionAreaKey,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Material(
        child: Center(
          child: SizedBox(
            width: 180,
            child: SelectionArea(
              key: selectionAreaKey,
              child: ChatMessageBubble(
                text: text,
                selectionListenerNotifier: SelectionListenerNotifier(),
                isUser: false,
                isTypingIndicator: false,
                isTruncated: true,
                isFirstMessage: true,
                isLastMessage: true,
                availableWidth: 180,
                onToggleTruncation: _noop,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _TestTranscriptSelectionArea extends StatelessWidget {
  const _TestTranscriptSelectionArea({
    required this.selectionAreaKey,
    required this.messages,
    required this.child,
  });

  final GlobalKey<SelectionAreaState> selectionAreaKey;
  final List<ChatMessage> messages;
  final Widget child;

  static final Map<String, SelectionListenerNotifier> _notifiers =
      <String, SelectionListenerNotifier>{};

  static SelectionListenerNotifier notifierFor(String messageId) {
    return _notifiers.putIfAbsent(messageId, SelectionListenerNotifier.new);
  }

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        CopySelectionTextIntent: CallbackAction<CopySelectionTextIntent>(
          onInvoke: (_) {
            final selectedRanges = <String, SelectedContentRange>{};
            for (final message in messages) {
              final notifier = notifierFor(message.id);
              if (!notifier.registered) {
                continue;
              }
              final selection = notifier.selection;
              final range = selection.range;
              if (selection.status == SelectionStatus.none || range == null) {
                continue;
              }
              selectedRanges[message.id] = range;
            }
            Clipboard.setData(
              ClipboardData(
                text: formatChatSelectionCopy(
                  messages: messages,
                  selectedRanges: selectedRanges,
                ),
              ),
            );
            return null;
          },
        ),
      },
      child: SelectionArea(key: selectionAreaKey, child: child),
    );
  }
}

void _noop() {}
