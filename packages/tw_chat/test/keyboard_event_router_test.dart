import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/logic/keyboard_event_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  KeyDownEvent keyDown({
    required LogicalKeyboardKey logical,
    required PhysicalKeyboardKey physical,
    String? character,
  }) {
    return KeyDownEvent(
      timeStamp: Duration.zero,
      logicalKey: logical,
      physicalKey: physical,
      character: character,
    );
  }

  test('returns null when chat is not visible', () {
    final command = ChatKeyboardEventRouter.resolve(
      event: keyDown(
        logical: LogicalKeyboardKey.arrowDown,
        physical: PhysicalKeyboardKey.arrowDown,
      ),
      chatHasClients: true,
      isVisible: false,
      isChatKeyboardScrollTarget: true,
      inputHasPrimaryFocus: false,
      isChatSelectionActive: false,
    );

    expect(command, isNull);
  });

  test('returns null when keyboard target is page', () {
    final command = ChatKeyboardEventRouter.resolve(
      event: keyDown(
        logical: LogicalKeyboardKey.arrowDown,
        physical: PhysicalKeyboardKey.arrowDown,
      ),
      chatHasClients: true,
      isVisible: true,
      isChatKeyboardScrollTarget: false,
      inputHasPrimaryFocus: false,
      isChatSelectionActive: false,
    );

    expect(command, isNull);
  });

  test('returns scroll command for arrow down', () {
    final command = ChatKeyboardEventRouter.resolve(
      event: keyDown(
        logical: LogicalKeyboardKey.arrowDown,
        physical: PhysicalKeyboardKey.arrowDown,
      ),
      chatHasClients: true,
      isVisible: true,
      isChatKeyboardScrollTarget: true,
      inputHasPrimaryFocus: false,
      isChatSelectionActive: false,
    );

    expect(command, isA<ScrollChatByCommand>());
    expect((command as ScrollChatByCommand).delta, 72.0);
  });

  test('returns typed-character redirect command', () {
    final command = ChatKeyboardEventRouter.resolve(
      event: keyDown(
        logical: LogicalKeyboardKey.keyA,
        physical: PhysicalKeyboardKey.keyA,
        character: 'a',
      ),
      chatHasClients: true,
      isVisible: true,
      isChatKeyboardScrollTarget: true,
      inputHasPrimaryFocus: false,
      isChatSelectionActive: false,
    );

    expect(command, isA<RedirectCharacterToInputCommand>());
    final redirect = command as RedirectCharacterToInputCommand;
    expect(redirect.character, 'a');
    expect(redirect.transferFocusOnly, isFalse);
  });

  test('returns focus-only redirect for combining mark', () {
    final command = ChatKeyboardEventRouter.resolve(
      event: keyDown(
        logical: LogicalKeyboardKey.quote,
        physical: PhysicalKeyboardKey.quote,
        character: '\u0301',
      ),
      chatHasClients: true,
      isVisible: true,
      isChatKeyboardScrollTarget: true,
      inputHasPrimaryFocus: false,
      isChatSelectionActive: false,
    );

    expect(command, isA<RedirectCharacterToInputCommand>());
    expect(
      (command as RedirectCharacterToInputCommand).transferFocusOnly,
      isTrue,
    );
  });

  test('does not redirect typed characters when input already focused', () {
    final command = ChatKeyboardEventRouter.resolve(
      event: keyDown(
        logical: LogicalKeyboardKey.keyA,
        physical: PhysicalKeyboardKey.keyA,
        character: 'a',
      ),
      chatHasClients: true,
      isVisible: true,
      isChatKeyboardScrollTarget: true,
      inputHasPrimaryFocus: true,
      isChatSelectionActive: false,
    );

    expect(command, isNull);
  });
}
