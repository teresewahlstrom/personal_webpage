import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/src/text_field/infrastructure/platforms/android/selection_handles.dart';
import 'package:tw_primitives/src/text_field/infrastructure/platforms/ios/selection_handles.dart';
import 'package:tw_primitives/src/text_field/infrastructure/touch_controls.dart';

void main() {
  testWidgets('android selection handles support a 0.5px outline', (
    tester,
  ) async {
    const fillColor = Color(0xFF112233);
    const outlineColor = Color(0xFF445566);

    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: AndroidSelectionHandle(
            handleType: HandleType.collapsed,
            color: fillColor,
            outlineColor: outlineColor,
          ),
        ),
      ),
    );

    final handle = tester.widget<Container>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.width == 20 &&
            widget.height == 20 &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).color == fillColor,
      ),
    );
    final decoration = handle.decoration! as BoxDecoration;
    final border = decoration.border! as Border;

    expect(border.top.color, outlineColor);
    expect(border.top.width, AndroidSelectionHandle.defaultOutlineWidth);
  });

  testWidgets('ios selection handles support a 0.5px outline', (tester) async {
    const fillColor = Color(0xFF112233);
    const outlineColor = Color(0xFF445566);

    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: IOSSelectionHandle.upstream(
            color: fillColor,
            outlineColor: outlineColor,
            caretHeight: 18,
          ),
        ),
      ),
    );

    final ball = tester.widget<Container>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.width == 8 &&
            widget.height == 8 &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
      ),
    );
    final ballDecoration = ball.decoration! as BoxDecoration;
    final ballBorder = ballDecoration.border! as Border;

    expect(ballBorder.top.color, outlineColor);
    expect(ballBorder.top.width, IOSSelectionHandle.defaultOutlineWidth);

    final caret = tester.widget<Container>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.width == 2 &&
            widget.height == 18 &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).color == fillColor,
      ),
    );
    final caretDecoration = caret.decoration! as BoxDecoration;
    final caretBorder = caretDecoration.border! as Border;

    expect(caretBorder.top.color, outlineColor);
    expect(caretBorder.top.width, IOSSelectionHandle.defaultOutlineWidth);
  });

  testWidgets('ios collapsed handle supports a 0.5px outline', (
    tester,
  ) async {
    const outlineColor = Color(0xFF445566);

    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: IOSCollapsedHandle(
            color: Colors.blue,
            outlineColor: outlineColor,
            caretHeight: 18,
          ),
        ),
      ),
    );

    final decoration = tester.widget<DecoratedBox>(
      find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border != null,
      ),
    ).decoration as BoxDecoration;
    final border = decoration.border! as Border;

    expect(border.top.color, outlineColor);
    expect(border.top.width, IOSSelectionHandle.defaultOutlineWidth);
  });
}
