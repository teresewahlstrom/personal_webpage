import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'markup_model.dart';

class _MarkupViewStyle {
  const _MarkupViewStyle();

  final double blockquoteRailWidth = 0.4;
  final double blockBaseSpacingFactor = 0.75;
  final double blockQuoteExtraSpacing = 1.2;
  final double listTopSpacingAdjustment = -0.12;
  final double nestedListTopSpacingAdjustment = -0.59;
  final double nestedListBottomSpacingAdjustment = -0.55;
  final double blockQuoteTopSpacingAdjustment = 0.0;
  final double listBottomSpacingAdjustment = 1.05;
  final List<double> headingBottomSpacingFactors = const <double>[-0.12, -0.14];
  final List<double> headingTopSpacingFactors = const <double>[1.0, 1.0];
  final double listItemBaseSpacingFactor = 0.26;
  final double topLevelListItemSpacingAdjustment = 0.52;
  final double listMarkerGapFactor = 0.3333333333;
  final double topLevelListMarkerSlotFactor = 2.0;
  final double nestedListMarkerSlotFactor = 1.75;
  final double blockquoteIndentFactor = 0.4;
  final double blockquoteCapLength = 12.0;
  final double blockquoteRailInset = 5.0;

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

class MarkupView extends StatelessWidget {
  const MarkupView({
    super.key,
    required this.document,
    required this.theme,
    required this.gestureRecognizerFactory,
    this.selectable = true,
    this.chromeVisible = true,
    this.blockquoteRailColor,
    this.textAlign = TextAlign.start,
  });

  final MarkupDocument document;
  final MarkupTheme theme;
  final LinkGestureRecognizerFactory gestureRecognizerFactory;
  final bool selectable;
  final bool chromeVisible;
  final Color? blockquoteRailColor;
  final TextAlign textAlign;

  static const _MarkupViewStyle _style = _MarkupViewStyle();
  static const String _unorderedListMarkerAssetPath =
      'assets/images/arrow2.svg';
  static const String _unorderedListMarkerAssetPackage = 'tw_primitives';
  static const double _unorderedListMarkerSizeFactor = 1.05;

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
    MarkupDocument document,
    MarkupTheme theme, {
    int listDepth = 0,
    bool inListItem = false,
    bool selectable = true,
    bool chromeVisible = true,
  }) {
    final List<Widget> children = <Widget>[];

    for (final (int index, MarkupBlock block) in document.blocks.indexed) {
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
    MarkupBlock block, {
    required MarkupTheme theme,
    required int listDepth,
    required bool inListItem,
    required bool selectable,
    required bool chromeVisible,
  }) {
    if (block is MarkupParagraphBlock || block is MarkupHeadingBlock) {
      return _buildSelectableRichText(
        context,
        block.toTextSpan(
          theme: theme,
          gestureRecognizerFactory: gestureRecognizerFactory,
        ),
        selectable: selectable,
      );
    }

    if (block is MarkupBlockQuoteBlock) {
      final MarkupTheme quoteTheme = MarkupTheme(
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
          left: fontSize * _style.blockquoteIndentFactor * 3.0,
        ),
        child: CustomPaint(
          foregroundPainter: _BlockQuoteRailPainter(
            color: railColor,
            railThickness: _style.blockquoteRailWidth,
            capLength: _style.blockquoteCapLength,
            railInset: _style.blockquoteRailInset,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 0, 4),
            child: _buildRenderedMarkupDocument(
              context,
              MarkupDocument(block.blocks),
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

    if (block is MarkupListBlock) {
      final List<Widget> children = <Widget>[];
      for (final (int itemIndex, MarkupListItem item)
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
          !block.ordered && chromeVisible;
        final List<MarkupBlock> itemBlocks = item.blocks;
        final bool canUseBaseline =
          !useAssetMarker &&
            itemBlocks.length == 1 &&
            (itemBlocks.first is MarkupParagraphBlock ||
              itemBlocks.first is MarkupHeadingBlock);

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
                          MarkupDocument(itemBlocks),
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
    MarkupTheme theme, {
    required MarkupBlock previousBlock,
    required MarkupBlock nextBlock,
    required bool inListItem,
  }) {
    final double fontSize = theme.baseStyle.fontSize ?? 12.0;

    double spacing = fontSize * _style.blockBaseSpacingFactor;
    if (inListItem && nextBlock is MarkupListBlock) {
      spacing += fontSize * _style.nestedListTopSpacingAdjustment;
    } else if (inListItem && previousBlock is MarkupListBlock) {
      spacing += fontSize * _style.nestedListBottomSpacingAdjustment;
    } else if (nextBlock is MarkupBlockQuoteBlock) {
      spacing += fontSize * _style.blockQuoteTopSpacingAdjustment;
    }

    if (previousBlock is MarkupHeadingBlock) {
      final double headingBottomSpacingFactor = _style
          .headingBottomSpacingFactorForLevel(previousBlock.level);
      final double headingFontSize = _resolveHeadingFontSize(
        theme: theme,
        fallbackFontSize: fontSize,
        level: previousBlock.level,
      );
      spacing += headingFontSize * headingBottomSpacingFactor;
    }
    if (nextBlock is MarkupHeadingBlock) {
      final double headingTopSpacingFactor = _style
          .headingTopSpacingFactorForLevel(nextBlock.level);
      final double headingFontSize = _resolveHeadingFontSize(
        theme: theme,
        fallbackFontSize: fontSize,
        level: nextBlock.level,
      );
      spacing += headingFontSize * headingTopSpacingFactor;
    }

    if (previousBlock is MarkupBlockQuoteBlock) {
      spacing += fontSize * _style.blockQuoteExtraSpacing;
    }
    if (nextBlock is MarkupBlockQuoteBlock) {
      spacing += fontSize * _style.blockQuoteExtraSpacing;
    }
    if (!inListItem &&
        nextBlock is MarkupListBlock &&
        previousBlock is! MarkupHeadingBlock &&
        previousBlock is! MarkupListBlock) {
      spacing += fontSize * _style.listTopSpacingAdjustment;
    }
    if (!inListItem && previousBlock is MarkupListBlock) {
      spacing += fontSize * _style.listBottomSpacingAdjustment;
    }
    return spacing < 0 ? 0 : spacing;
  }

  double _listItemSpacing(TextStyle baseStyle, {required int listDepth}) {
    final double fontSize = baseStyle.fontSize ?? 12.0;

    double spacing = fontSize * _style.listItemBaseSpacingFactor;
    if (listDepth <= 0) {
      spacing += fontSize * _style.topLevelListItemSpacingAdjustment;
    }

    return spacing < 0 ? 0 : spacing;
  }

  double _listIndent() {
    return 0.0;
  }

  double _listMarkerGap(TextStyle baseStyle) {
    final double fontSize = baseStyle.fontSize ?? 12.0;
    return fontSize * _style.listMarkerGapFactor;
  }

  double _listMarkerSlotWidth(TextStyle baseStyle, int depth) {
    final double fontSize = baseStyle.fontSize ?? 12.0;
    final double factor = depth <= 0
      ? _style.topLevelListMarkerSlotFactor
      : _style.nestedListMarkerSlotFactor;
    return fontSize * factor;
  }

  double _resolveHeadingFontSize({
    required MarkupTheme theme,
    required double fallbackFontSize,
    required int level,
  }) {
    final double? resolvedFontSize = theme.headingStyleResolver(level).fontSize;
    return resolvedFontSize ?? fallbackFontSize;
  }

  Widget _buildUnorderedListAssetMarker(TextStyle baseStyle) {
    final double fontSize = baseStyle.fontSize ?? 12.0;
    final double markerSize = fontSize * _unorderedListMarkerSizeFactor;
    final Color? markerColor = baseStyle.color;

    return SvgPicture.asset(
      _unorderedListMarkerAssetPath,
      package: _unorderedListMarkerAssetPackage,
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
