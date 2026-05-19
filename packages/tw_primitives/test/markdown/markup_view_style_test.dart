import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/src/markdown/markup_view.dart';

void main() {
  test('default markup spacing gives more room above lists and below headings', () {
    const ChatMarkupViewStyle style = ChatMarkupViewStyle();

    expect(style.listTopSpacingAdjustment, -0.15);
    expect(style.headingBottomSpacingFactors, const <double>[-0.1, -0.3]);
  });
}
