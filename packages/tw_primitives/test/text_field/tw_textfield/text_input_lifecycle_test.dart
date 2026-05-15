import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/src/text_field/tw_textfield/infrastructure/text_input_lifecycle.dart';
import 'package:tw_primitives/src/text_field/tw_textfield/input_method_engine/_ime_text_editing_controller.dart';

void main() {
  group('shouldClearTextInputForLifecycleState', () {
    test('clears text input when the app is leaving the foreground', () {
      expect(
        shouldClearTextInputForLifecycleState(AppLifecycleState.inactive),
        isTrue,
      );
      expect(
        shouldClearTextInputForLifecycleState(AppLifecycleState.hidden),
        isTrue,
      );
      expect(
        shouldClearTextInputForLifecycleState(AppLifecycleState.paused),
        isTrue,
      );
    });

    test('does not clear text input for resumed or detached states', () {
      expect(
        shouldClearTextInputForLifecycleState(AppLifecycleState.resumed),
        isFalse,
      );
      expect(
        shouldClearTextInputForLifecycleState(AppLifecycleState.detached),
        isFalse,
      );
    });
  });

  testWidgets('background cleanup unfocuses without touching overlay state', (
    tester,
  ) async {
    final focusNode = FocusNode();
    final controller = ImeAttributedTextEditingController();
    int stateUpdates = 0;
    int overlayRemovals = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Focus(focusNode: focusNode, child: const SizedBox()),
      ),
    );

    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
    expect(controller.isAttachedToIme, isFalse);

    clearTextInputForBackgroundTransition(
      focusNode: focusNode,
      textEditingController: controller,
      isMounted: () => true,
      runStateUpdate: (stateChange) {
        stateUpdates += 1;
        stateChange();
      },
      removeEditingOverlayControls: () {
        overlayRemovals += 1;
      },
    );

    expect(focusNode.hasFocus, isFalse);
    expect(stateUpdates, 0);
    expect(overlayRemovals, 0);

    focusNode.dispose();
    controller.dispose();
  });

  testWidgets('background cleanup detaches IME and clears editing state', (
    tester,
  ) async {
    final focusNode = FocusNode();
    final controller = ImeAttributedTextEditingController()
      ..selection = const TextSelection.collapsed(offset: 0)
      ..composingRegion = const TextRange(start: 0, end: 0);
    int stateUpdates = 0;
    int overlayRemovals = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Focus(focusNode: focusNode, child: const SizedBox()),
      ),
    );
    focusNode.requestFocus();
    await tester.pump();

    controller.attachToIme(viewId: tester.view.viewId);
    expect(controller.isAttachedToIme, isTrue);

    clearTextInputForBackgroundTransition(
      focusNode: focusNode,
      textEditingController: controller,
      isMounted: () => true,
      runStateUpdate: (stateChange) {
        stateUpdates += 1;
        stateChange();
      },
      removeEditingOverlayControls: () {
        overlayRemovals += 1;
      },
    );

    expect(focusNode.hasFocus, isFalse);
    expect(controller.isAttachedToIme, isFalse);
    expect(controller.selection, const TextSelection.collapsed(offset: -1));
    expect(controller.composingRegion, TextRange.empty);
    expect(stateUpdates, 1);
    expect(overlayRemovals, 1);

    focusNode.dispose();
    controller.dispose();
  });
}
