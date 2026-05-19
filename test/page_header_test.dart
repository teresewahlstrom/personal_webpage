import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_webpage/widgets/shell/_page_header.dart';

void main() {
  testWidgets(
    'page header leaves the logo as a plain image without interactive wrappers',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageHeader(),
          ),
        ),
      );

      final Finder imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final Image image = tester.widget<Image>(imageFinder);
      expect(image.image, isA<AssetImage>());
      expect((image.image as AssetImage).assetName, 'assets/images/logo.png');
      expect(image.frameBuilder, isNull);
      expect(image.gaplessPlayback, isFalse);

      expect(
        find.ancestor(of: imageFinder, matching: find.byType(Tooltip)),
        findsNothing,
      );
      expect(
        find.ancestor(of: imageFinder, matching: find.byType(GestureDetector)),
        findsNothing,
      );
      expect(
        find.ancestor(of: imageFinder, matching: find.byType(MouseRegion)),
        findsNothing,
      );
      expect(
        find.ancestor(
          of: imageFinder,
          matching: find.byType(SelectionContainer),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(PageHeader),
          matching: find.byType(RepaintBoundary),
        ),
        findsNothing,
      );
    },
  );
}
