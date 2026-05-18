import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/composer.dart';

void main() {
  testWidgets('composer skin drives shell border, accent, and action tap', (
    tester,
  ) async {
    var tapped = false;
    const skin = TwComposerSkin(
      fillColor: Color(0xFF102030),
      outlineColor: Color(0xFF405060),
      accentColor: Color(0xFF708090),
      outlineWidth: 1.5,
      cornerStrokeWidth: 2.5,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TwComposer(
            input: const SizedBox(height: 16),
            skin: skin,
            actionIcon: Icons.send_rounded,
            actionTooltip: 'Send message',
            onActionPressed: () => tapped = true,
            minHeight: 40,
            maxHeight: 80,
            actionMinWidth: 50,
            actionHeight: 44,
            radius: 6,
            cornerRadius: 6,
            cornerSegmentLength: 12,
            actionRadius: 4,
            actionIconSize: 20,
          ),
        ),
      ),
    );

    final shell = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('tw-composer-shell')),
    );
    final decoration = shell.decoration as BoxDecoration;
    final frame = tester.widget<CustomPaint>(
      find.byKey(const ValueKey('tw-composer-frame')),
    );
    final painter = frame.foregroundPainter! as TwComposerCornerPainter;
    final icon = tester.widget<Icon>(find.byIcon(Icons.send_rounded));

    expect(decoration.color, skin.fillColor);
    expect(decoration.border, isA<Border>());
    expect((decoration.border! as Border).top.color, skin.outlineColor);
    expect((decoration.border! as Border).top.width, skin.outlineWidth);
    expect(painter.color, skin.accentColor);
    expect(painter.strokeWidth, skin.cornerStrokeWidth);
    expect(icon.color, skin.accentColor);

    await tester.tap(find.byKey(const ValueKey('tw-composer-action')));

    expect(tapped, isTrue);
  });
}
