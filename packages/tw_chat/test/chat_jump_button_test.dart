import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_chat/src/config/config.dart';
import 'package:tw_primitives/theme.dart';

import 'package:tw_chat/src/widgets/chat_jump_button.dart';

void main() {
  Future<void> pumpButton(
    WidgetTester tester, {
    required bool showNewMessage,
    required VoidCallback onJumpToLatest,
    required VoidCallback onJumpToBottom,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Center(
            child: ChatJumpButton(
              showNewMessage: showNewMessage,
              onJumpToLatest: onJumpToLatest,
              onJumpToBottom: onJumpToBottom,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows circle button for jump to bottom', (tester) async {
    var latestPressed = 0;
    var bottomPressed = 0;

    await pumpButton(
      tester,
      showNewMessage: false,
      onJumpToLatest: () => latestPressed++,
      onJumpToBottom: () => bottomPressed++,
    );

    expect(find.text('new message'), findsNothing);
    expect(find.byIcon(Icons.south_rounded), findsOneWidget);
    expect(_arrowIcon(tester).size, _expectedArrowSize(tester));
    expect(_pillHasClickCursor(tester), isTrue);
    expect(_inkWellRect(tester), _pillRect(tester));

    await tester.tap(find.byType(TwLinkPill));
    await tester.pump();

    expect(latestPressed, 0);
    expect(bottomPressed, 1);
  });

  testWidgets('shows pill button for new bot message', (tester) async {
    var latestPressed = 0;
    var bottomPressed = 0;

    await pumpButton(
      tester,
      showNewMessage: true,
      onJumpToLatest: () => latestPressed++,
      onJumpToBottom: () => bottomPressed++,
    );

    expect(find.text('new message'), findsOneWidget);
    expect(find.byIcon(Icons.south_rounded), findsOneWidget);
    expect(_arrowIcon(tester).size, _expectedArrowSize(tester));
    expect(
      _newMessageText(tester).style?.fontSize,
      _bodyTextStyle(tester).fontSize,
    );
    expect(_newMessageText(tester).style?.fontWeight, isNot(FontWeight.w700));
    expect(
      _newMessagePill(tester).style?.padding,
      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    );
    expect(_pillHasClickCursor(tester), isTrue);

    await tester.tap(find.byType(TwLinkPill));
    await tester.pump();

    expect(latestPressed, 1);
    expect(bottomPressed, 0);
  });
}

Icon _arrowIcon(WidgetTester tester) {
  return tester.widget<Icon>(find.byIcon(Icons.south_rounded));
}

Text _newMessageText(WidgetTester tester) {
  return tester.widget<Text>(find.text('new message'));
}

TwLinkPill _newMessagePill(WidgetTester tester) {
  return tester.widget<TwLinkPill>(find.byType(TwLinkPill));
}

TextStyle _bodyTextStyle(WidgetTester tester) {
  final context = tester.element(find.byType(ChatJumpButton));
  return ChatBubbleRules.textStyle(
    context,
    MediaQuery.textScalerOf(context).scale(1.0),
  );
}

double _expectedArrowSize(WidgetTester tester) {
  final context = tester.element(find.byType(ChatJumpButton));
  final tokens = ChatSkin.dataOf(context).tokens;
  return tokens.jumpToLatestButtonFixedSize *
      tokens.jumpToLatestButtonIconRatio;
}

bool _pillHasClickCursor(WidgetTester tester) {
  final mouseRegions = tester.widgetList<MouseRegion>(
    find.descendant(
      of: find.byType(TwLinkPill),
      matching: find.byType(MouseRegion),
    ),
  );
  return mouseRegions.any(
    (region) => region.cursor == SystemMouseCursors.click,
  );
}

Rect _pillRect(WidgetTester tester) {
  return tester.getRect(
    find.descendant(
      of: find.byType(TwLinkPill),
      matching: find.byType(DecoratedBox),
    ),
  );
}

Rect _inkWellRect(WidgetTester tester) {
  return tester.getRect(
    find.descendant(
      of: find.byType(TwLinkPill),
      matching: find.byType(InkWell),
    ),
  );
}
