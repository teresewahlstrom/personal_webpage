import 'package:flutter/material.dart' hide GestureRecognizerFactory;
import 'package:flutter_svg/flutter_svg.dart';

import 'message_markup_model.dart';

class ChatMarkupViewStyle {
  const ChatMarkupViewStyle({
    this.blockquoteRailWidth = 0.4,
    this.blockBaseSpacingFactor = 0.75,
    this.blockQuoteExtraSpacing = 1.2,
    this.listTopSpacingAdjustment = -0.12,
    this.nestedListTopSpacingAdjustment = -0.59,
    this.nestedListBottomSpacingAdjustment = -0.55,
    this.blockQuoteTopSpacingAdjustment = 0.0,
    this.listBottomSpacingAdjustment = 1.05,
    this.headingBottomSpacingFactors = const <double>[-0.12, -0.14],
    this.headingTopSpacingFactors = const <double>[1.0, 1.0],
    this.listItemBaseSpacingFactor = 0.26,
    this.topLevelListItemSpacingAdjustment = 0.52,
    this.listMarkerGapFactor = 0.3333333333,
    this.topLevelListMarkerSlotFactor = 2.0,
    this.nestedListMarkerSlotFactor = 1.75,
    this.blockquoteIndentFactor = 0.4,
    this.blockquoteCapLength = 12.0,
    this.blockquoteRailInset = 5.0,
    this.unorderedListMarkerAssetPath = 'assets/images/arrow.svg',
    this.unorderedListMarkerSizeFactor = 0.7,
  });

  final double blockquoteRailWidth;
  final double blockBaseSpacingFactor;
  final double blockQuoteExtraSpacing;
  final double listTopSpacingAdjustment;
  final double nestedListTopSpacingAdjustment;
  final double nestedListBottomSpacingAdjustment;
  final double blockQuoteTopSpacingAdjustment;
  final double listBottomSpacingAdjustment;
  final List<double> headingBottomSpacingFactors;
  final List<double> headingTopSpacingFactors;
  final double listItemBaseSpacingFactor;
  final double topLevelListItemSpacingAdjustment;
  final double listMarkerGapFactor;
  final double topLevelListMarkerSlotFactor;
  final double nestedListMarkerSlotFactor;
  final double blockquoteIndentFactor;
  final double blockquoteCapLength;
  final double blockquoteRailInset;
  final String? unorderedListMarkerAssetPath;
  final double unorderedListMarkerSizeFactor;

  double headingBottomSpacingFactorForLevel(int level) {
    return _factorByLevel(headingBottomSpacingFactors, level);
  }

  double headingTopSpacingFactorForLevel(int level) {
    return _factorByLevel(headingTopSpacingFactors, level);
  }

  double _factorByLevel(List<double> factors, int level) {
    final int index = level.clamp(1, factors.length).toInt() - 1;
    return factors[index];
  }
}

class ChatMarkupView extends StatelessWidget {
  const ChatMarkupView({
    super.key,
    required this.document,
    required this.theme,
    required this.gestureRecognizerFactory,
    this.style = const ChatMarkupViewStyle(),
    this.selectable = true,
    this.chromeVisible = true,
    this.blockquoteRailColor,
    this.textAlign = TextAlign.start,
  });

  final ChatMarkupDocument document;
  final ChatMarkupTheme theme;
  final GestureRecognizerFactory gestureRecognizerFactory;
  final ChatMarkupViewStyle style;
  final bool selectable;
  final bool chromeVisible;
  final Color? blockquoteRailColor;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildRenderedMarkupDocument(
          context,
          document,
          theme,
          selectable: selectable,
          chromeVisible: chromeVisible,
        ),
      ],
    );
  }

  Widget _buildRenderedMarkupDocument(
    BuildContext context,
    ChatMarkupDocument document,
    ChatMarkupTheme theme, {
    int listDepth = 0,
    bool inListItem = false,
    bool selectable = true,
    bool chromeVisible = true,
  }) {
    final List<Widget> children = <Widget>[];

    for (final (int index, ChatMarkupBlock block) in document.blocks.indexed) {
      if (index > 0) {
        children.add(
          SizedBox(
            height: _blockSpacing(
              theme,
              previousBlock: document.blocks[index - 1],
              nextBlock: block,
              inListItem: inListItem,
            ),
          ),
        );
      }
      children.add(
        _buildRenderedMarkupBlock(
          context,
          block,
          theme: theme,
          listDepth: listDepth,
          inListItem: inListItem,
          selectable: selectable,
          chromeVisible: chromeVisible,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildRenderedMarkupBlock(
    BuildContext context,
    ChatMarkupBlock block, {
    required ChatMarkupTheme theme,
    required int listDepth,
    required bool inListItem,
    required bool selectable,
    required bool chromeVisible,
  }) {
    if (block is ChatMarkupParagraphBlock || block is ChatMarkupHeadingBlock) {
      return _buildSelectableRichText(
        context,
        block.toTextSpan(
          theme: theme,
          gestureRecognizerFactory: gestureRecognizerFactory,
        ),
        selectable: selectable,
      );
    }

    if (block is ChatMarkupBlockQuoteBlock) {
      final ChatMarkupTheme quoteTheme = ChatMarkupTheme(
        baseStyle: theme.blockquoteStyle,
        strongStyle: theme.blockquoteStyle.merge(theme.strongStyle),
        emphasisStyle: theme.blockquoteStyle.merge(theme.emphasisStyle),
        strikethroughStyle: theme.blockquoteStyle.merge(
          theme.strikethroughStyle,
        ),
        underlineStyle: theme.blockquoteStyle.merge(theme.underlineStyle),
        linkStyle: theme.blockquoteStyle.merge(theme.linkStyle),
        blockquoteStyle: theme.blockquoteStyle,
        headingStyleResolver: (int level) =>
            theme.headingStyleResolver(level).merge(theme.blockquoteStyle),
      );
      final Color railColor = chromeVisible
          ? (blockquoteRailColor ??
                theme.baseStyle.color ??
                DefaultTextStyle.of(context).style.color ??
                Colors.transparent)
          : Colors.transparent;
      final double fontSize = theme.baseStyle.fontSize ?? 12.0;
      return Padding(
        padding: EdgeInsets.only(
          left: fontSize * style.blockquoteIndentFactor * 3.0,
        ),
        child: CustomPaint(
          foregroundPainter: _BlockQuoteRailPainter(
            color: railColor,
            railThickness: style.blockquoteRailWidth,
            capLength: style.blockquoteCapLength,
            railInset: style.blockquoteRailInset,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 0, 4),
            child: _buildRenderedMarkupDocument(
              context,
              ChatMarkupDocument(block.blocks),
              quoteTheme,
              listDepth: listDepth,
              inListItem: inListItem,
              selectable: selectable,
              chromeVisible: chromeVisible,
            ),
          ),
        ),
      );
    }

    if (block is ChatMarkupListBlock) {
      final List<Widget> children = <Widget>[];
      for (final (int itemIndex, ChatMarkupListItem item)
          in block.items.indexed) {
        if (itemIndex > 0) {
          children.add(
            SizedBox(
              height: _listItemSpacing(theme.baseStyle, listDepth: listDepth),
            ),
          );
        }

        final String marker = block.ordered
            ? '${block.startingIndex + itemIndex}. '
            : '• ';
        final bool useAssetMarker =
          !block.ordered &&
          chromeVisible &&
          style.unorderedListMarkerAssetPath != null;
        final List<ChatMarkupBlock> itemBlocks = item.blocks;
        final bool canUseBaseline =
          !useAssetMarker &&
            itemBlocks.length == 1 &&
            (itemBlocks.first is ChatMarkupParagraphBlock ||
                itemBlocks.first is ChatMarkupHeadingBlock);

        children.add(
          Padding(
            padding: EdgeInsets.only(left: _listIndent()),
            child: Row(
              crossAxisAlignment: canUseBaseline
                  ? CrossAxisAlignment.baseline
                  : CrossAxisAlignment.start,
              textBaseline: canUseBaseline ? TextBaseline.alphabetic : null,
              children: <Widget>[
                SizedBox(
                  width: _listMarkerSlotWidth(theme.baseStyle, listDepth),
                  child: Align(
                    alignment: block.ordered
                        ? const Alignment(0.78, 0.0)
                        : const Alignment(0.45, 0.0),
                    child: useAssetMarker
                        ? _buildUnorderedListAssetMarker(theme.baseStyle)
                        : _buildSelectableRichText(
                            context,
                            TextSpan(text: marker, style: theme.baseStyle),
                            softWrap: false,
                            selectable: selectable,
                          ),
                  ),
                ),
                SizedBox(width: _listMarkerGap(theme.baseStyle)),
                Expanded(
                  child: canUseBaseline
                      ? _buildRenderedMarkupBlock(
                          context,
                          itemBlocks.first,
                          theme: theme,
                          listDepth: listDepth + 1,
                          inListItem: true,
                          selectable: selectable,
                          chromeVisible: chromeVisible,
                        )
                      : _buildRenderedMarkupDocument(
                          context,
                          ChatMarkupDocument(itemBlocks),
                          theme,
                          listDepth: listDepth + 1,
                          inListItem: true,
                          selectable: selectable,
                          chromeVisible: chromeVisible,
                        ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    return _buildSelectableRichText(
      context,
      block.toTextSpan(
        theme: theme,
        gestureRecognizerFactory: gestureRecognizerFactory,
      ),
      selectable: selectable,
    );
  }

  Widget _buildSelectableRichText(
    BuildContext context,
    TextSpan text, {
    bool softWrap = true,
    bool selectable = true,
  }) {
    return RichText(
      text: text,
      textAlign: textAlign,
      softWrap: softWrap,
      selectionRegistrar: selectable
          ? SelectionContainer.maybeOf(context)
          : null,
      selectionColor: selectable
          ? (DefaultSelectionStyle.of(context).selectionColor ??
                DefaultSelectionStyle.defaultColor)
          : null,
    );
  }

  double _blockSpacing(
    ChatMarkupTheme theme, {
    required ChatMarkupBlock previousBlock,
    required ChatMarkupBlock nextBlock,
    required bool inListItem,
  }) {
    final double fontSize = theme.baseStyle.fontSize ?? 12.0;

    double spacing = fontSize * style.blockBaseSpacingFactor;
    if (inListItem && nextBlock is ChatMarkupListBlock) {
      spacing += fontSize * style.nestedListTopSpacingAdjustment;
    } else if (inListItem && previousBlock is ChatMarkupListBlock) {
      spacing += fontSize * style.nestedListBottomSpacingAdjustment;
    } else if (nextBlock is ChatMarkupBlockQuoteBlock) {
      spacing += fontSize * style.blockQuoteTopSpacingAdjustment;
    }

    if (previousBlock is ChatMarkupHeadingBlock) {
      final double headingBottomSpacingFactor = style
          .headingBottomSpacingFactorForLevel(previousBlock.level);
      final double headingFontSize = _resolveHeadingFontSize(
        theme: theme,
        fallbackFontSize: fontSize,
        level: previousBlock.level,
      );
      spacing += headingFontSize * headingBottomSpacingFactor;
    }
    if (nextBlock is ChatMarkupHeadingBlock) {
      final double headingTopSpacingFactor = style
          .headingTopSpacingFactorForLevel(nextBlock.level);
      final double headingFontSize = _resolveHeadingFontSize(
        theme: theme,
        fallbackFontSize: fontSize,
        level: nextBlock.level,
      );
      spacing += headingFontSize * headingTopSpacingFactor;
    }

    if (previousBlock is ChatMarkupBlockQuoteBlock) {
      spacing += fontSize * style.blockQuoteExtraSpacing;
    }
    if (nextBlock is ChatMarkupBlockQuoteBlock) {
      spacing += fontSize * style.blockQuoteExtraSpacing;
    }
    if (!inListItem &&
        nextBlock is ChatMarkupListBlock &&
        previousBlock is! ChatMarkupHeadingBlock &&
        previousBlock is! ChatMarkupListBlock) {
      spacing += fontSize * style.listTopSpacingAdjustment;
    }
    if (!inListItem && previousBlock is ChatMarkupListBlock) {
      spacing += fontSize * style.listBottomSpacingAdjustment;
    }
    return spacing < 0 ? 0 : spacing;
  }

  double _listItemSpacing(TextStyle baseStyle, {required int listDepth}) {
    final double fontSize = baseStyle.fontSize ?? 12.0;

    double spacing = fontSize * style.listItemBaseSpacingFactor;
    if (listDepth <= 0) {
      spacing += fontSize * style.topLevelListItemSpacingAdjustment;
    }

    return spacing < 0 ? 0 : spacing;
  }

  double _listIndent() {
    return 0.0;
  }

  double _listMarkerGap(TextStyle baseStyle) {
    final double fontSize = baseStyle.fontSize ?? 12.0;
    return fontSize * style.listMarkerGapFactor;
  }

  double _listMarkerSlotWidth(TextStyle baseStyle, int depth) {
    final double fontSize = baseStyle.fontSize ?? 12.0;
    final double factor = depth <= 0
        ? style.topLevelListMarkerSlotFactor
        : style.nestedListMarkerSlotFactor;
    return fontSize * factor;
  }

  double _resolveHeadingFontSize({
    required ChatMarkupTheme theme,
    required double fallbackFontSize,
    required int level,
  }) {
    final double? resolvedFontSize = theme.headingStyleResolver(level).fontSize;
    return resolvedFontSize ?? fallbackFontSize;
  }

  Widget _buildUnorderedListAssetMarker(TextStyle baseStyle) {
    final double fontSize = baseStyle.fontSize ?? 12.0;
    final double markerSize = fontSize * style.unorderedListMarkerSizeFactor;
    final Color? markerColor = baseStyle.color;

    return SvgPicture.asset(
      style.unorderedListMarkerAssetPath!,
      width: markerSize,
      height: markerSize,
      fit: BoxFit.contain,
      colorFilter: markerColor == null
          ? null
          : ColorFilter.mode(markerColor, BlendMode.srcIn),
    );
  }
}

class _BlockQuoteRailPainter extends CustomPainter {
  const _BlockQuoteRailPainter({
    required this.color,
    required this.railThickness,
    required this.capLength,
    required this.railInset,
  });

  final Color color;
  final double railThickness;
  final double capLength;
  final double railInset;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0 || color.a == 0.0) {
      return;
    }

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = railThickness
      ..strokeCap = StrokeCap.square;

    const double verticalOvershoot = 3.0;
    final double railX = railInset + railThickness / 2;
    final double topY = -verticalOvershoot;
    final double bottomY = size.height + verticalOvershoot;
    final double maxCapLength = (size.width - railX).clamp(
      0.0,
      double.infinity,
    );
    final double boundedCapLength = capLength.clamp(0.0, maxCapLength);

    canvas.drawLine(Offset(railX, topY), Offset(railX, bottomY), paint);
    canvas.drawLine(
      Offset(railX, topY),
      Offset(railX + boundedCapLength, topY),
      paint,
    );
    canvas.drawLine(
      Offset(railX, bottomY),
      Offset(railX + boundedCapLength, bottomY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BlockQuoteRailPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.railThickness != railThickness ||
        oldDelegate.capLength != capLength ||
        oldDelegate.railInset != railInset;
  }
}
