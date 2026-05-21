import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'markup_ast.dart';

typedef LinkGestureRecognizerFactory = GestureRecognizer? Function(String href);
typedef MarkupHeadingStyleResolver = TextStyle Function(int level);

class MarkupTheme {
  const MarkupTheme({
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
  final MarkupHeadingStyleResolver headingStyleResolver;
}

extension MarkupDocumentRendering on MarkupDocument {
  TextSpan toTextSpan({
    required MarkupTheme theme,
    required LinkGestureRecognizerFactory gestureRecognizerFactory,
  }) {
    return _joinBlockTextSpan(
      blocks,
      separator: MarkupDocument.blockSeparator,
      theme: theme,
      gestureRecognizerFactory: gestureRecognizerFactory,
    );
  }
}

extension MarkupInlineRendering on MarkupInline {
  TextSpan toTextSpan({
    required MarkupTheme theme,
    required LinkGestureRecognizerFactory gestureRecognizerFactory,
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
      final TextStyle strikeStyle = effectiveStyle.merge(
        theme.strikethroughStyle,
      );
      effectiveStyle = strikeStyle.copyWith(
        decorationThickness: _scaledStrikethroughThickness(strikeStyle),
      );
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

extension MarkupBlockRendering on MarkupBlock {
  TextSpan toTextSpan({
    required MarkupTheme theme,
    required LinkGestureRecognizerFactory gestureRecognizerFactory,
  }) {
    switch (this) {
      case final MarkupParagraphBlock paragraph:
        return TextSpan(
          style: theme.baseStyle,
          children: paragraph.inlines
              .map(
                (inline) => inline.toTextSpan(
                  theme: theme,
                  gestureRecognizerFactory: gestureRecognizerFactory,
                ),
              )
              .toList(growable: false),
        );
      case final MarkupHeadingBlock heading:
        final headingStyle = theme.headingStyleResolver(heading.level);
        final headingTheme = MarkupTheme(
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
          children: heading.inlines
              .map(
                (inline) => inline.toTextSpan(
                  theme: headingTheme,
                  gestureRecognizerFactory: gestureRecognizerFactory,
                ),
              )
              .toList(growable: false),
        );
      case final MarkupBlockquoteBlock quote:
        final contentSpan = _joinBlockTextSpan(
          quote.blocks,
          separator: MarkupDocument.blockSeparator,
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
      case final MarkupListBlock list:
        final itemChildren = <InlineSpan>[];

        for (final entry in list.items.indexed) {
          if (entry.$1 > 0) {
            itemChildren.add(const TextSpan(text: '\n'));
          }
          final marker = list.ordered ? '${list.startingIndex + entry.$1}. ' : '• ';
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
}

extension MarkupListItemRendering on MarkupListItem {
  TextSpan toTextSpan({
    required MarkupTheme theme,
    required LinkGestureRecognizerFactory gestureRecognizerFactory,
  }) {
    return _joinBlockTextSpan(
      blocks,
      separator: '\n',
      theme: theme,
      gestureRecognizerFactory: gestureRecognizerFactory,
    );
  }
}

double _scaledStrikethroughThickness(TextStyle style) {
  final double fallbackThickness = (style.fontSize ?? 14.0) / 14.0;
  final double baseThickness = style.decorationThickness ?? fallbackThickness;
  return (baseThickness * 0.5).clamp(0.5, double.infinity);
}

TextSpan _joinBlockTextSpan(
  List<MarkupBlock> blocks, {
  required String separator,
  required MarkupTheme theme,
  required LinkGestureRecognizerFactory gestureRecognizerFactory,
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

List<_MarkupTextFragment> _flattenTextSpan(
  TextSpan span, [
  TextStyle? inheritedStyle,
]) {
  final effectiveStyle = _mergeStyles(inheritedStyle, span.style);
  final fragments = <_MarkupTextFragment>[];

  if (span.text != null && span.text!.isNotEmpty) {
    fragments.add(
      _MarkupTextFragment(
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

class _MarkupTextFragment {
  const _MarkupTextFragment({
    required this.text,
    this.style,
    this.recognizer,
  });

  final String text;
  final TextStyle? style;
  final GestureRecognizer? recognizer;
}
