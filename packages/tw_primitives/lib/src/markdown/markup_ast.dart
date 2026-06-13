class MarkupDocument {
  const MarkupDocument(this.blocks);

  static const String blockSeparator = '\n\n';

  final List<MarkupBlock> blocks;

  String toPlainText() {
    return _joinBlockPlainText(blocks, separator: blockSeparator).trimRight();
  }
}

class MarkupInline {
  const MarkupInline({
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
}

sealed class MarkupBlock {
  const MarkupBlock();

  String toPlainText();
}

class MarkupParagraphBlock extends MarkupBlock {
  const MarkupParagraphBlock(this.inlines);

  final List<MarkupInline> inlines;

  @override
  String toPlainText() {
    return inlines.map((inline) => inline.toPlainText()).join();
  }
}

class MarkupHeadingBlock extends MarkupBlock {
  const MarkupHeadingBlock({required this.level, required this.inlines});

  final int level;
  final List<MarkupInline> inlines;

  @override
  String toPlainText() {
    return inlines.map((inline) => inline.toPlainText()).join();
  }
}

class MarkupHorizontalRuleBlock extends MarkupBlock {
  const MarkupHorizontalRuleBlock();

  @override
  String toPlainText() => '';
}

class MarkupBlockquoteBlock extends MarkupBlock {
  const MarkupBlockquoteBlock(this.blocks);

  final List<MarkupBlock> blocks;

  @override
  String toPlainText() {
    return _prefixMultilinePlainText(
      _joinBlockPlainText(blocks, separator: MarkupDocument.blockSeparator),
      firstLinePrefix: '> ',
      continuationPrefix: '> ',
    );
  }
}

class MarkupListBlock extends MarkupBlock {
  const MarkupListBlock({
    required this.ordered,
    required this.startingIndex,
    required this.items,
  });

  final bool ordered;
  final int startingIndex;
  final List<MarkupListItem> items;

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
}

class MarkupListItem {
  const MarkupListItem(this.blocks);

  final List<MarkupBlock> blocks;

  String toPlainText() {
    return _joinBlockPlainText(blocks, separator: '\n');
  }
}

String _joinBlockPlainText(
  List<MarkupBlock> blocks, {
  required String separator,
}) {
  return blocks
      .map((block) => block.toPlainText())
      .where((blockText) => blockText.isNotEmpty)
      .join(separator);
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
