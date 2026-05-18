import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/composer.dart';

void main() {
  testWidgets('applies skin colors and widths to the composer shell', (
    tester,
  ) async {
    const skin = TwComposerSkin(
      fillColor: Color(0xFF112233),
      outlineColor: Color(0xFF445566),
      accentColor: Color(0xFF778899),
      outlineWidth: 3.0,
      cornerStrokeWidth: 2.5,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TwComposer(
            skin: skin,
            textField: const SizedBox(height: 40, child: Text('field')),
            inputShellKey: const ValueKey('input-shell'),
            minInputHeight: 40,
            maxInputHeight: 100,
            sendButtonMinWidth: 50,
            sendButtonHeight: 40,
            sendButtonIcon: Icons.send_rounded,
            sendButtonTooltip: 'Send message',
            onSendPressed: _noop,
            shellRadius: 8,
            cornerRadius: 4,
            cornerSegmentLength: 10,
            sendButtonRadius: 6,
            sendIconSize: 20,
          ),
        ),
      ),
    );

    final shell = tester.widget<Container>(
      find.byKey(const ValueKey('input-shell')),
    );
    final decoration = shell.decoration! as BoxDecoration;
    final border = decoration.border! as Border;
    final accents =
        tester.widget<CustomPaint>(find.byType(CustomPaint)).foregroundPainter!
            as TwComposerCornerAccentPainter;
    final icon = tester.widget<Icon>(find.byIcon(Icons.send_rounded));

    expect(decoration.color, skin.fillColor);
    expect(border.top.color, skin.outlineColor);
    expect(border.top.width, skin.outlineWidth);
    expect(accents.color, skin.accentColor);
    expect(accents.strokeWidth, skin.cornerStrokeWidth);
    expect(icon.color, skin.accentColor);
  });

  testWidgets('invokes the send callback when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TwComposer(
            skin: const TwComposerSkin(
              fillColor: Colors.white,
              outlineColor: Colors.black,
              accentColor: Colors.blue,
              outlineWidth: 1,
              cornerStrokeWidth: 2,
            ),
            textField: const SizedBox(height: 40),
            minInputHeight: 40,
            maxInputHeight: 100,
            sendButtonMinWidth: 50,
            sendButtonHeight: 40,
            sendButtonIcon: Icons.send_rounded,
            sendButtonTooltip: 'Send message',
            onSendPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}

void _noop() {}
