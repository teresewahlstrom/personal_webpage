 import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef GestureRecognizerFactory = GestureRecognizer? Function(String href);
typedef ChatMarkupHeadingStyleResolver = TextStyle Function(int level);

class ChatMarkupTheme {
  const ChatMarkupTheme({
    required this.baseStyle,
    required this.strongStyle,
    required this.emphasisStyle,
    required this.strikethroughStyle,
    required this.underlineStyle,
    required this.linkStyle,
    required this.blockquoteStyle,
    required this.headingStyleResolver,
  });

  final TextStyle baseStyle;
  final TextStyle strongStyle;
  final TextStyle emphasisStyle;
  final TextStyle strikethroughStyle;
  final TextStyle underlineStyle;
  final TextStyle linkStyle;
  final TextStyle blockquoteStyle;
  final ChatMarkupHeadingStyleResolver headingStyleResolver;
}

class ChatMarkupDocument {
  const ChatMarkupDocument(this.blocks);

  static const String blockSeparator = '\n\n';

  final List<ChatMarkupBlock> blocks;

  String toPlainText() {
    return _joinBlockPlainText(blocks, separator: blockSeparator).trimRight();
  }

  TextSpan toTextSpan({
    required ChatMarkupTheme theme,
    required GestureRecognizerFactory gestureRecognizerFactory,
  }) {
    return _joinBlockTextSpan(
      blocks,
      separator: blockSeparator,
      theme: theme,
      gestureRecognizerFactory: gestureRecognizerFactory,
    );
  }
}

class ChatMarkupInline {
  const ChatMarkupInline({
    required this.text,
    this.isStrong = false,
    this.isEmphasis = false,
    this.isStrikethrough = false,
    this.isUnderline = false,
    this.href,
  });

  final String text;
  final bool isStrong;
  final bool isEmphasis;
  final bool isStrikethrough;
  final bool isUnderline;
  final String? href;

  String toPlainText() {
    if (href == null || href!.isEmpty || href == text) {
      return text;
    }
    return '$text ($href)';
  }

  TextSpan toTextSpan({
    required ChatMarkupTheme theme,
    required GestureRecognizerFactory gestureRecognizerFactory,
  }) {
    final isLink = href != null && href!.isNotEmpty;
    var effectiveStyle = theme.baseStyle;

    if (isStrong) {
      effectiveStyle = effectiveStyle.merge(theme.strongStyle);
    }
    if (isEmphasis) {
      effectiveStyle = effectiveStyle.merge(theme.emphasisStyle);
    }
    if (isStrikethrough) {
      effectiveStyle = effectiveStyle.merge(theme.strikethroughStyle);
    }
    if (isUnderline) {
      effectiveStyle = effectiveStyle.merge(theme.underlineStyle);
    }
    if (isLink) {
      effectiveStyle = effectiveStyle.merge(theme.linkStyle);
    }

    return TextSpan(
      text: text,
      style: effectiveStyle,
      semanticsLabel: isLink && href != text ? '$text ($href)' : null,
      recognizer: isLink ? gestureRecognizerFactory(href!) : null,
    );
  }
}

abstract class ChatMarkupBlock {
  const ChatMarkupBlock();

  String toPlainText();

  TextSpan toTextSpan({
    required ChatMarkupTheme theme,
    required GestureRecognizerFactory gestureRecognizerFactory,
  });
}

class ChatMarkupParagraphBlock extends ChatMarkupBlock {
  const ChatMarkupParagraphBlock(this.inlines);

  final List<ChatMarkupInline> inlines;

  @override
  String toPlainText() {
    return inlines.map((inline) => inline.toPlainText()).join();
  }

  @override
  TextSpan toTextSpan({
    required ChatMarkupTheme theme,
    required GestureRecognizerFactory gestureRecognizerFactory,
  }) {
    return TextSpan(
      style: theme.baseStyle,
      children: inlines
          .map(
            (inline) => inline.toTextSpan(
              theme: theme,
              gestureRecognizerFactory: gestureRecognizerFactory,
            ),
          )
          .toList(growable: false),
    );
  }
}

class ChatMarkupHeadingBlock extends ChatMarkupBlock {
  const ChatMarkupHeadingBlock({required this.level, required this.inlines});

  final int level;
  final List<ChatMarkupInline> inlines;

  @override
  String toPlainText() {
    return inlines.map((inline) => inline.toPlainText()).join();
  }

  @override
  TextSpan toTextSpan({
    required ChatMarkupTheme theme,
    required GestureRecognizerFactory gestureRecognizerFactory,
  }) {
    final headingStyle = theme.headingStyleResolver(level);
    final headingTheme = ChatMarkupTheme(
      baseStyle: headingStyle,
      strongStyle: headingStyle.merge(theme.strongStyle),
      emphasisStyle: headingStyle.merge(theme.emphasisStyle),
      strikethroughStyle: headingStyle.merge(theme.strikethroughStyle),
      underlineStyle: headingStyle.merge(theme.underlineStyle),
      linkStyle: headingStyle.merge(theme.linkStyle),
      blockquoteStyle: theme.blockquoteStyle,
      headingStyleResolver: theme.headingStyleResolver,
    );

    return TextSpan(
      style: headingStyle,
      children: inlines
          .map(
            (inline) => inline.toTextSpan(
              theme: headingTheme,
              gestureRecognizerFactory: gestureRecognizerFactory,
            ),
          )
          .toList(growable: false),
    );
  }
}

class ChatMarkupBlockQuoteBlock extends ChatMarkupBlock {
  const ChatMarkupBlockQuoteBlock(this.blocks);

  final List<ChatMarkupBlock> blocks;

  @override
  String toPlainText() {
    return _prefixMultilinePlainText(
      _joinBlockPlainText(blocks, separator: ChatMarkupDocument.blockSeparator),
      firstLinePrefix: '> ',
      continuationPrefix: '> ',
    );
  }

  @override
  TextSpan toTextSpan({
    required ChatMarkupTheme theme,
    required GestureRecognizerFactory gestureRecognizerFactory,
  }) {
    final contentSpan = _joinBlockTextSpan(
      blocks,
      separator: ChatMarkupDocument.blockSeparator,
      theme: theme,
      gestureRecognizerFactory: gestureRecognizerFactory,
    );

    return _prefixMultilineSpan(
      contentSpan,
      firstLinePrefix: '> ',
      continuationPrefix: '> ',
      prefixStyle: theme.blockquoteStyle,
      mergedStyle: theme.blockquoteStyle,
    );
  }
}

class ChatMarkupListBlock extends ChatMarkupBlock {
  const ChatMarkupListBlock({
    required this.ordered,
    required this.startingIndex,
    required this.items,
  });

  final bool ordered;
  final int startingIndex;
  final List<ChatMarkupListItem> items;

  @override
  String toPlainText() {
    return items.indexed
        .map((entry) {
          final marker = ordered ? '${startingIndex + entry.$1}. ' : '• ';
          return _prefixMultilinePlainText(
            entry.$2.toPlainText(),
            firstLinePrefix: marker,
            continuationPrefix: ' ' * marker.length,
          );
        })
        .join('\n');
  }

  @override
  TextSpan toTextSpan({
    required ChatMarkupTheme theme,
    required GestureRecognizerFactory gestureRecognizerFactory,
  }) {
    final itemChildren = <InlineSpan>[];

    for (final entry in items.indexed) {
      if (entry.$1 > 0) {
        itemChildren.add(const TextSpan(text: '\n'));
      }
      final marker = ordered ? '${startingIndex + entry.$1}. ' : '• ';
      itemChildren.add(
        _prefixMultilineSpan(
          entry.$2.toTextSpan(
            theme: theme,
            gestureRecognizerFactory: gestureRecognizerFactory,
          ),
          firstLinePrefix: marker,
          continuationPrefix: ' ' * marker.length,
          prefixStyle: theme.baseStyle,
        ),
      );
    }

    return TextSpan(style: theme.baseStyle, children: itemChildren);
  }
}

class ChatMarkupListItem {
  const ChatMarkupListItem(this.blocks);

  final List<ChatMarkupBlock> blocks;

  String toPlainText() {
    return _joinBlockPlainText(blocks, separator: '\n');
  }

  TextSpan toTextSpan({
    required ChatMarkupTheme theme,
    required GestureRecognizerFactory gestureRecognizerFactory,
  }) {
    return _joinBlockTextSpan(
      blocks,
      separator: '\n',
      theme: theme,
      gestureRecognizerFactory: gestureRecognizerFactory,
    );
  }
}

String _joinBlockPlainText(
  List<ChatMarkupBlock> blocks, {
  required String separator,
}) {
  return blocks
      .map((block) => block.toPlainText())
      .where((blockText) => blockText.isNotEmpty)
      .join(separator);
}

TextSpan _joinBlockTextSpan(
  List<ChatMarkupBlock> blocks, {
  required String separator,
  required ChatMarkupTheme theme,
  required GestureRecognizerFactory gestureRecognizerFactory,
}) {
  final children = <InlineSpan>[];
  var wroteContent = false;

  for (final block in blocks) {
    final blockText = block.toPlainText();
    if (blockText.isEmpty) {
      continue;
    }
    if (wroteContent) {
      children.add(TextSpan(text: separator, style: theme.baseStyle));
    }
    children.add(
      block.toTextSpan(
        theme: theme,
        gestureRecognizerFactory: gestureRecognizerFactory,
      ),
    );
    wroteContent = true;
  }

  return TextSpan(style: theme.baseStyle, children: children);
}

String _prefixMultilinePlainText(
  String text, {
  required String firstLinePrefix,
  required String continuationPrefix,
}) {
  if (text.isEmpty) {
    return '';
  }

  final lines = text.split('\n');
  return lines.indexed
      .map((entry) {
        final prefix = entry.$1 == 0 ? firstLinePrefix : continuationPrefix;
        return '$prefix${entry.$2}';
      })
      .join('\n');
}

TextSpan _prefixMultilineSpan(
  TextSpan span, {
  required String firstLinePrefix,
  required String continuationPrefix,
  required TextStyle prefixStyle,
  TextStyle? mergedStyle,
}) {
  final fragments = _flattenTextSpan(span);
  final children = <InlineSpan>[];
  var lineIndex = 0;
  var pendingPrefix = true;
  StringBuffer? currentBuffer;
  TextStyle? currentStyle;
  GestureRecognizer? currentRecognizer;

  void flushBuffer() {
    if (currentBuffer == null || currentBuffer!.isEmpty) {
      return;
    }
    children.add(
      TextSpan(
        text: currentBuffer!.toString(),
        style: currentStyle,
        recognizer: currentRecognizer,
      ),
    );
    currentBuffer = null;
    currentStyle = null;
    currentRecognizer = null;
  }

  void ensurePrefix() {
    if (!pendingPrefix) {
      return;
    }
    flushBuffer();
    final prefix = lineIndex == 0 ? firstLinePrefix : continuationPrefix;
    if (prefix.isNotEmpty) {
      children.add(TextSpan(text: prefix, style: prefixStyle));
    }
    pendingPrefix = false;
  }

  for (final fragment in fragments) {
    final fragmentStyle = _mergeStyles(fragment.style, mergedStyle);
    for (var index = 0; index < fragment.text.length; index += 1) {
      final character = fragment.text[index];
      ensurePrefix();
      if (character == '\n') {
        flushBuffer();
        children.add(TextSpan(text: '\n', style: fragmentStyle));
        pendingPrefix = true;
        lineIndex += 1;
        continue;
      }
      if (currentBuffer == null ||
          currentStyle != fragmentStyle ||
          currentRecognizer != fragment.recognizer) {
        flushBuffer();
        currentBuffer = StringBuffer();
        currentStyle = fragmentStyle;
        currentRecognizer = fragment.recognizer;
      }
      currentBuffer!.write(character);
    }
  }

  flushBuffer();
  return TextSpan(
    style: _mergeStyles(span.style, mergedStyle),
    children: children,
  );
}

TextStyle? _mergeStyles(TextStyle? base, TextStyle? overlay) {
  if (base == null) {
    return overlay;
  }
  if (overlay == null) {
    return base;
  }
  return base.merge(overlay);
}

List<_ChatMarkupTextFragment> _flattenTextSpan(
  TextSpan span, [
  TextStyle? inheritedStyle,
]) {
  final effectiveStyle = _mergeStyles(inheritedStyle, span.style);
  final fragments = <_ChatMarkupTextFragment>[];

  if (span.text != null && span.text!.isNotEmpty) {
    fragments.add(
      _ChatMarkupTextFragment(
        text: span.text!,
        style: effectiveStyle,
        recognizer: span.recognizer,
      ),
    );
  }

  for (final child in span.children ?? const <InlineSpan>[]) {
    if (child is TextSpan) {
      fragments.addAll(_flattenTextSpan(child, effectiveStyle));
    }
  }

  return fragments;
}

class _ChatMarkupTextFragment {
  const _ChatMarkupTextFragment({
    required this.text,
    this.style,
    this.recognizer,
  });

  final String text;
  final TextStyle? style;
  final GestureRecognizer? recognizer;
}
