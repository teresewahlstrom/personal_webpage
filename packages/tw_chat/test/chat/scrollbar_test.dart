import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/config/config.dart';

void main() {
  testWidgets('scrollbar thumb colors follow the light skin tokens', (
    tester,
  ) async {
    late Color activeColor;
    late Color inactiveColor;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            activeColor = ChatScrollbar.thumbColorForState(context, true);
            inactiveColor = ChatScrollbar.thumbColorForState(context, false);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final colors = ChatSkin.dataForBrightness(Brightness.light).colors;
    expect(activeColor, colors.scrollbarThumb);
    expect(inactiveColor, colors.scrollbarThumbInactive);
  });

  testWidgets('scrollbar thumb colors follow the dark skin tokens', (
    tester,
  ) async {
    late Color activeColor;
    late Color inactiveColor;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Builder(
          builder: (context) {
            activeColor = ChatScrollbar.thumbColorForState(context, true);
            inactiveColor = ChatScrollbar.thumbColorForState(context, false);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final colors = ChatSkin.dataForBrightness(Brightness.dark).colors;
    expect(activeColor, colors.scrollbarThumb);
    expect(inactiveColor, colors.scrollbarThumbInactive);
  });
}
