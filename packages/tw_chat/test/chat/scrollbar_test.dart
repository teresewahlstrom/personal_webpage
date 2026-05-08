import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/config/config.dart';

void main() {
  testWidgets('scrollbar thumb colors follow the light composer colors', (
    tester,
  ) async {
    late Color activeColor;
    late Color inactiveColor;
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            capturedContext = context;
            activeColor = ChatScrollbar.thumbColorForState(context, true);
            inactiveColor = ChatScrollbar.thumbColorForState(context, false);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(ChatScrollbar.thumbColor(capturedContext), activeColor);
    expect(ChatScrollbar.thumbInactiveColor(capturedContext), inactiveColor);
    expect(activeColor, ChatComposerLayout.borderColor(capturedContext));
    expect(inactiveColor, ChatComposerLayout.fillColor(capturedContext));
  });

  testWidgets('scrollbar thumb colors follow the dark composer colors', (
    tester,
  ) async {
    late Color activeColor;
    late Color inactiveColor;
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Builder(
          builder: (context) {
            capturedContext = context;
            activeColor = ChatScrollbar.thumbColorForState(context, true);
            inactiveColor = ChatScrollbar.thumbColorForState(context, false);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(ChatScrollbar.thumbColor(capturedContext), activeColor);
    expect(ChatScrollbar.thumbInactiveColor(capturedContext), inactiveColor);
    expect(activeColor, ChatComposerLayout.borderColor(capturedContext));
    expect(inactiveColor, ChatComposerLayout.fillColor(capturedContext));
  });
}
