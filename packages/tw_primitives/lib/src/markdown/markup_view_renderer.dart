import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'markup_ast.dart';
import 'markup_blockquote_rail_painter.dart';
import 'markup_rendering.dart';
import 'markup_view_style.dart';

class MarkupViewRenderer {
  MarkupViewRenderer({
    required this.context,
    required this.document,
    required this.theme,
    required this.gestureRecognizerFactory,
    required this.selectable,
    required this.chromeVisible,
    required this.blockquoteRailColor,
    required this.textAlign,
  });

  final BuildContext context;
  final MarkupDocument document;
  final MarkupTheme theme;
  final LinkGestureRecognizerFactory gestureRecognizerFactory;
  final bool selectable;
  final bool chromeVisible;
  final Color? blockquoteRailColor;
  final TextAlign textAlign;

  static const MarkupViewStyle _style = kMarkupViewStyle;
  static const String _unorderedListMarkerAssetPath =
      'assets/images/arrow2.svg';
  static const String _unorderedListMarkerAssetPackage = 'tw_primitives';
  static const double _unorderedListMarkerSizeFactor = 0.50;
  static const double _unorderedListMarkerVerticalOffsetFactor = 0.27;
  static const double _blockquoteRailVerticalOverhang = 3.0;
  static const double _blockquoteInnerVerticalPadding = 2.0;

  Widget build() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildRenderedMarkupDocument(
          document,
          theme,
          selectable: selectable,
          chromeVisible: chromeVisible,
        ),
      ],
    );
  }

  Widget _buildRenderedMarkupDocument(
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
    MarkupBlock block, {
    required MarkupTheme theme,
    required int listDepth,
    required bool inListItem,
    required bool selectable,
    required bool chromeVisible,
  }) {
    if (block is MarkupParagraphBlock || block is MarkupHeadingBlock) {
      return _buildSelectableRichText(
        block.toTextSpan(
          theme: theme,
          gestureRecognizerFactory: gestureRecognizerFactory,
        ),
        selectable: selectable,
      );
    }

    if (block is MarkupBlockquoteBlock) {
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
          foregroundPainter: BlockQuoteRailPainter(
            color: railColor,
            railThickness: _style.blockquoteRailWidth,
            capLength: _style.blockquoteCapLength,
            railInset: _style.blockquoteRailInset,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              12,
              _blockquoteRailVerticalOverhang + _blockquoteInnerVerticalPadding,
              0,
              _blockquoteRailVerticalOverhang + _blockquoteInnerVerticalPadding,
            ),
            child: _buildRenderedMarkupDocument(
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
      for (final (int itemIndex, MarkupListItem item) in block.items.indexed) {
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
        final bool useAssetMarker = !block.ordered && chromeVisible;
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
                          itemBlocks.first,
                          theme: theme,
                          listDepth: listDepth + 1,
                          inListItem: true,
                          selectable: selectable,
                          chromeVisible: chromeVisible,
                        )
                      : _buildRenderedMarkupDocument(
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
      block.toTextSpan(
        theme: theme,
        gestureRecognizerFactory: gestureRecognizerFactory,
      ),
      selectable: selectable,
    );
  }

  Widget _buildSelectableRichText(
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
    } else if (nextBlock is MarkupBlockquoteBlock) {
      spacing += fontSize * _style.blockquoteTopSpacingAdjustment;
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

    if (previousBlock is MarkupBlockquoteBlock) {
      spacing += fontSize * _style.blockquoteExtraSpacing;
    }
    if (nextBlock is MarkupBlockquoteBlock) {
      spacing += fontSize * _style.blockquoteExtraSpacing;
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
    final double markerSize = _snapToDevicePixels(
      fontSize * _unorderedListMarkerSizeFactor,
    );
    final double verticalOffset = _snapToDevicePixels(
      fontSize * _unorderedListMarkerVerticalOffsetFactor,
    );
    final Color? markerColor = baseStyle.color;

    return Transform.translate(
      offset: Offset(0, verticalOffset),
      child: SvgPicture.asset(
        _unorderedListMarkerAssetPath,
        package: _unorderedListMarkerAssetPackage,
        width: markerSize,
        height: markerSize,
        fit: BoxFit.contain,
        colorFilter: markerColor == null
            ? null
            : ColorFilter.mode(markerColor, BlendMode.srcIn),
      ),
    );
  }

  double _snapToDevicePixels(double logicalSize) {
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    if (dpr <= 0) {
      return logicalSize;
    }

    final double snapped = (logicalSize * dpr).roundToDouble() / dpr;
    return snapped.clamp(1.0, double.infinity);
  }
}
