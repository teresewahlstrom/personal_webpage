import 'package:attributed_text/attributed_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/src/text_field/tw_textfield/infrastructure/attributed_text_editing_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttributedTextEditingController', () {
    test('pasted CRLF blank rows are normalized to LF', () async {
      final controller = AttributedTextEditingController(
        text: AttributedText(),
        selection: const TextSelection.collapsed(offset: 0),
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.getData') {
            return <String, dynamic>{'text': 'a\r\n\r\nb'};
          }
          return null;
        },
      );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });

      await controller.pasteClipboard();

      expect(controller.text.toPlainText(), 'a\n\nb');
      expect(controller.selection, const TextSelection.collapsed(offset: 4));
    });

    test('pasteClipboard sets and clearHasJustPastedFlag clears hasJustPasted flag', () async {
      final controller = AttributedTextEditingController(
        text: AttributedText(),
        selection: const TextSelection.collapsed(offset: 0),
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.getData') {
            return <String, dynamic>{'text': 'hello'};
          }
          return null;
        },
      );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });

      expect(controller.hasJustPasted, isFalse);

      await controller.pasteClipboard();

      expect(controller.hasJustPasted, isTrue);

      controller.clearHasJustPastedFlag();

      expect(controller.hasJustPasted, isFalse);
    });
  });
}
