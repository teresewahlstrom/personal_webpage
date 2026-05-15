import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide ScrollbarPainter;
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_chat/src/config/config.dart';
import 'package:tw_primitives/src/text_field/infrastructure/flutter/scrollbar.dart'
    show ScrollbarPainter;

void main() {
  testWidgets('thumb uses one painter and only the active/inactive colors', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.light),
        home: Material(
          child: SizedBox(
            width: 200,
            height: 180,
            child: Builder(
              builder: (context) => TwScrollbar(
                controller: controller,
                thumbColor: ChatScrollbar.thumbColor(context),
                thumbInactiveColor: ChatScrollbar.thumbInactiveColor(context),
                trackColor: ChatScrollbar.trackColor(context),
                thickness: 6,
                minThumbLength: 24,
                crossAxisMargin: 1,
                mainAxisMargin: 0,
                radius: const Radius.circular(8),
                thumbVisibility: true,
                child: ListView.builder(
                  controller: controller,
                  itemCount: 40,
                  itemBuilder: (context, index) =>
                      SizedBox(height: 32, child: Text('Row $index')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final colors = ChatSkin.dataForBrightness(Brightness.light).colors;
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);

    await mouse.addPointer(location: const Offset(0, 0));
    await mouse.moveTo(
      tester.getTopRight(find.byType(TwScrollbar)) + const Offset(-3, 40),
    );
    await tester.pumpAndSettle();

    List<ScrollbarPainter> findScrollbarPainters() => tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((widget) => widget.foregroundPainter)
        .whereType<ScrollbarPainter>()
        .toList();

    var painters = findScrollbarPainters();
    expect(painters, hasLength(1));
    expect(painters.single.color, colors.scrollbarThumb);

    await mouse.moveTo(tester.getTopLeft(find.byType(TwScrollbar)));
    await tester.pump();

    painters = findScrollbarPainters();
    expect(painters, hasLength(1));
    expect(painters.single.color, colors.scrollbarThumbInactive);
  });
}
