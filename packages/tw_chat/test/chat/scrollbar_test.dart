import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/config/config.dart';

void main() {
  Future<void> pumpScrollbar(
    WidgetTester tester, {
    required ScrollController controller,
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 240,
              child: ChatFadingScrollbar(
                controller: controller,
                thickness: 6,
                minThumbLength: 18,
                crossAxisMargin: 0,
                mainAxisMargin: 0,
                radius: const Radius.circular(8),
                thumbVisibility: true,
                child: ListView.builder(
                  controller: controller,
                  itemCount: 40,
                  itemExtent: 32,
                  itemBuilder: (_, index) => Text('Item $index'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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

  testWidgets(
    'scrollbar stays inactive during programmatic scrolling and activates on hover',
    (tester) async {
      final controller = ScrollController();

      await pumpScrollbar(tester, controller: controller);

      final scrollbarFinder = find.byType(RawScrollbar);
      final scrollbarElement = tester.element(find.byType(ChatFadingScrollbar));
      final scrollbarRect = tester.getRect(find.byType(ChatFadingScrollbar));
      final inactiveColor = ChatScrollbar.thumbInactiveColor(scrollbarElement);
      final activeColor = ChatScrollbar.thumbColor(scrollbarElement);

      expect(
        tester.widget<RawScrollbar>(scrollbarFinder).thumbColor,
        inactiveColor,
      );

      controller.jumpTo(120);
      await tester.pump();
      await tester.pump(ChatScrollbar.thumbFadeDuration);

      expect(
        tester.widget<RawScrollbar>(scrollbarFinder).thumbColor,
        inactiveColor,
      );

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(
        location: Offset(scrollbarRect.left + 4, scrollbarRect.center.dy),
      );
      await tester.pump();

      await gesture.moveTo(
        Offset(scrollbarRect.right - 1, scrollbarRect.center.dy),
      );
      await tester.pump();
      await tester.pump(ChatScrollbar.thumbFadeDuration);

      expect(
        tester.widget<RawScrollbar>(scrollbarFinder).thumbColor,
        activeColor,
      );

      await gesture.moveTo(
        Offset(scrollbarRect.left + 4, scrollbarRect.center.dy),
      );
      await tester.pump();
      await tester.pump(ChatScrollbar.thumbFadeDuration);

      expect(
        tester.widget<RawScrollbar>(scrollbarFinder).thumbColor,
        inactiveColor,
      );
    },
  );
}
