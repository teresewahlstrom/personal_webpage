import 'package:flutter/services.dart';

sealed class ChatKeyboardCommand {
  const ChatKeyboardCommand();
}

class RedirectCharacterToInputCommand extends ChatKeyboardCommand {
  const RedirectCharacterToInputCommand({
    required this.character,
    required this.transferFocusOnly,
  });

  final String character;
  final bool transferFocusOnly;
}

class ScrollChatByCommand extends ChatKeyboardCommand {
  const ScrollChatByCommand(this.delta);

  final double delta;
}

class ChatKeyboardEventRouter {
  const ChatKeyboardEventRouter._();

  static const _scrollStep = 72.0;

  static ChatKeyboardCommand? resolve({
    required KeyEvent event,
    required bool chatHasClients,
    required bool isVisible,
    required bool isChatKeyboardScrollTarget,
    required bool inputHasPrimaryFocus,
    required bool isChatSelectionActive,
  }) {
    if ((event is! KeyDownEvent && event is! KeyRepeatEvent) ||
        !chatHasClients ||
        !isVisible ||
        !isChatKeyboardScrollTarget) {
      return null;
    }

    final key = event.logicalKey;

    final typedCharacter = _typedCharacterToRedirect(
      event: event,
      inputHasPrimaryFocus: inputHasPrimaryFocus,
      isChatSelectionActive: isChatSelectionActive,
    );
    if (typedCharacter != null) {
      return RedirectCharacterToInputCommand(
        character: typedCharacter,
        transferFocusOnly: _shouldOnlyTransferFocusForCharacter(typedCharacter),
      );
    }

    if (inputHasPrimaryFocus) {
      return null;
    }

    if (key == LogicalKeyboardKey.arrowDown) {
      return const ScrollChatByCommand(_scrollStep);
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      return const ScrollChatByCommand(-_scrollStep);
    }

    return null;
  }

  static String? _typedCharacterToRedirect({
    required KeyEvent event,
    required bool inputHasPrimaryFocus,
    required bool isChatSelectionActive,
  }) {
    if (inputHasPrimaryFocus || isChatSelectionActive) {
      return null;
    }

    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed ||
        keyboard.isAltPressed ||
        keyboard.isMetaPressed) {
      return null;
    }

    final character = event.character;
    if (character == null || character.isEmpty) {
      return null;
    }

    if (RegExp(r'[\u0000-\u001F\u007F]').hasMatch(character)) {
      return null;
    }

    return character;
  }

  static bool _shouldOnlyTransferFocusForCharacter(String character) {
    if (character.runes.length != 1) {
      return true;
    }

    final rune = character.runes.first;

    if (rune < 0x20 || rune == 0x7F || rune > 0x7E) {
      return true;
    }

    final isCombiningMark =
        (rune >= 0x0300 && rune <= 0x036F) ||
        (rune >= 0x1AB0 && rune <= 0x1AFF) ||
        (rune >= 0x1DC0 && rune <= 0x1DFF) ||
        (rune >= 0x20D0 && rune <= 0x20FF) ||
        (rune >= 0xFE20 && rune <= 0xFE2F);

    return isCombiningMark;
  }
}
