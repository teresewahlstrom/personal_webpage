import 'message_markup_model.dart';

class ChatMarkupInlineTokenizer {
  ChatMarkupInlineTokenizer(this._raw);

  static const String _escapableCharacters = r'\\`*_{}[]()#+-.!~<>';

  final String _raw;
  final List<ChatMarkupInline> _tokens = <ChatMarkupInline>[];
  final StringBuffer _buffer = StringBuffer();
  int _offset = 0;

  List<ChatMarkupInline> tokenize() {
    while (_offset < _raw.length) {
      if (_consumeEscape()) {
        continue;
      }

      final markdownLink = _consumeMarkdownLink();
      if (markdownLink != null) {
        _flushBuffer();
        _tokens.add(markdownLink);
        continue;
      }

      final underline = _consumeUnderlineTag();
      if (underline != null) {
        _flushBuffer();
        _tokens.add(underline);
        continue;
      }

      final strongAsterisks = _consumeDelimited('**');
      if (strongAsterisks != null) {
        _flushBuffer();
        _tokens.add(ChatMarkupInline(text: strongAsterisks, isStrong: true));
        continue;
      }

      final strongUnderscores = _consumeDelimited('__');
      if (strongUnderscores != null) {
        _flushBuffer();
        _tokens.add(ChatMarkupInline(text: strongUnderscores, isStrong: true));
        continue;
      }

      final strike = _consumeDelimited('~~');
      if (strike != null) {
        _flushBuffer();
        _tokens.add(ChatMarkupInline(text: strike, isStrikethrough: true));
        continue;
      }

      final autolink = _consumeAutolink();
      if (autolink != null) {
        _flushBuffer();
        _tokens.add(autolink);
        continue;
      }

      final emphasisAsterisk = _consumeDelimited('*');
      if (emphasisAsterisk != null) {
        _flushBuffer();
        _tokens.add(ChatMarkupInline(text: emphasisAsterisk, isEmphasis: true));
        continue;
      }

      final emphasisUnderscore = _consumeDelimited('_');
      if (emphasisUnderscore != null) {
        _flushBuffer();
        _tokens.add(
          ChatMarkupInline(text: emphasisUnderscore, isEmphasis: true),
        );
        continue;
      }

      _buffer.write(_raw[_offset]);
      _offset += 1;
    }

    _flushBuffer();
    return List<ChatMarkupInline>.unmodifiable(_tokens);
  }

  bool _consumeEscape() {
    if (_raw[_offset] != r'\' || _offset + 1 >= _raw.length) {
      return false;
    }

    final nextCharacter = _raw[_offset + 1];
    if (!_escapableCharacters.contains(nextCharacter)) {
      return false;
    }

    _buffer.write(nextCharacter);
    _offset += 2;
    return true;
  }

  ChatMarkupInline? _consumeMarkdownLink() {
    if (_raw[_offset] != '[') {
      return null;
    }

    final labelEnd = _findUnescapedCharacter(']', _offset + 1);
    if (labelEnd == -1 ||
        labelEnd + 1 >= _raw.length ||
        _raw[labelEnd + 1] != '(') {
      return null;
    }

    final hrefEnd = _findUnescapedCharacter(')', labelEnd + 2);
    if (hrefEnd == -1) {
      return null;
    }

    final label = _raw.substring(_offset + 1, labelEnd);
    final href = _raw.substring(labelEnd + 2, hrefEnd).trim();
    if (label.isEmpty || href.isEmpty) {
      return null;
    }

    _offset = hrefEnd + 1;
    return ChatMarkupInline(text: label, href: href);
  }

  ChatMarkupInline? _consumeUnderlineTag() {
    const opener = '<u>';
    const closer = '</u>';
    if (!_raw.startsWith(opener, _offset)) {
      return null;
    }

    final closingIndex = _raw.indexOf(closer, _offset + opener.length);
    if (closingIndex == -1) {
      return null;
    }

    final content = _raw.substring(_offset + opener.length, closingIndex);
    if (content.isEmpty) {
      return null;
    }

    _offset = closingIndex + closer.length;
    return ChatMarkupInline(text: content, isUnderline: true);
  }

  String? _consumeDelimited(String delimiter) {
    if (!_raw.startsWith(delimiter, _offset)) {
      return null;
    }

    final searchStart = _offset + delimiter.length;
    final closingIndex = _findClosingDelimiter(delimiter, searchStart);
    if (closingIndex == -1) {
      return null;
    }

    final content = _raw.substring(searchStart, closingIndex);
    if (content.isEmpty) {
      return null;
    }

    _offset = closingIndex + delimiter.length;
    return content;
  }

  ChatMarkupInline? _consumeAutolink() {
    final remainder = _raw.substring(_offset);
    final match = RegExp(r'^(https?:\/\/|www\.)[^\s<]+').firstMatch(remainder);
    if (match == null) {
      return null;
    }

    final rawUrl = match.group(0)!;
    final trimmedUrl = _trimAutolink(rawUrl);
    if (trimmedUrl.isEmpty) {
      return null;
    }

    _offset += trimmedUrl.length;
    return ChatMarkupInline(text: trimmedUrl, href: trimmedUrl);
  }

  int _findClosingDelimiter(String delimiter, int start) {
    var index = start;
    while (index <= _raw.length - delimiter.length) {
      if (_raw[index] == r'\') {
        index += 2;
        continue;
      }
      if (_raw.startsWith(delimiter, index)) {
        return index;
      }
      index += 1;
    }
    return -1;
  }

  int _findUnescapedCharacter(String character, int start) {
    var index = start;
    while (index < _raw.length) {
      if (_raw[index] == r'\') {
        index += 2;
        continue;
      }
      if (_raw[index] == character) {
        return index;
      }
      index += 1;
    }
    return -1;
  }

  String _trimAutolink(String value) {
    var end = value.length;
    while (end > 0 && '.,!?;:'.contains(value[end - 1])) {
      end -= 1;
    }
    while (end > 0 &&
        value[end - 1] == ')' &&
        !_hasBalancedParentheses(value.substring(0, end))) {
      end -= 1;
    }
    return value.substring(0, end);
  }

  bool _hasBalancedParentheses(String value) {
    var balance = 0;
    for (final rune in value.runes) {
      if (rune == 0x28) {
        balance += 1;
      } else if (rune == 0x29) {
        balance -= 1;
      }
    }
    return balance >= 0;
  }

  void _flushBuffer() {
    if (_buffer.isEmpty) {
      return;
    }
    _tokens.add(ChatMarkupInline(text: _buffer.toString()));
    _buffer.clear();
  }
}
