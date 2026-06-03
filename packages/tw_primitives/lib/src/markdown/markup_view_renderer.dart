import 'package:flutter/material.dart';
import 'package:tw_primitives/theme.dart';
import 'markup_rendering.dart';
import 'markup_view_style.dart';
import '../svg/tw_svg_asset.dart';

import 'markup_ast.dart';
import 'markup_blockquote_rail_painter.dart';

class MarkupViewRenderer {
  MarkupViewRenderer({
    required this.context,
    required this.document,
    required this.theme,
    required this.gestureRecognizerFactory,
    required this.selectable,
    required this.chromeVisible,
    required this.textAlign,
  });

  final BuildContext context;
  final MarkupDocument document;
  final MarkupTheme theme;
  final LinkGestureRecognizerFactory gestureRecognizerFactory;
  final bool selectable;
  final bool chromeVisible;
  final TextAlign textAlign;

    static const MarkupViewStyle _style = kMarkupViewStyle;
    static const String _unorderedListMarkerAssetPath =
      'assets/images/arrow2.svg';
    static const String _unorderedListMarkerAssetPackage = 'tw_primitives';

  Widget build() {
    final Widget root = _renderLayoutNode(
      _buildLayoutDocument(
        document,
        theme,
        selectable: selectable,
        chromeVisible: chromeVisible,
      ),
    );
    if (!selectable) {
      return SelectionContainer.disabled(child: root);
    }
    return root;
  }

  _MarkupLayoutNode _buildLayoutDocument(
    MarkupDocument document,
    MarkupTheme theme, {
    int listDepth = 0,
    bool inListItem = false,
    bool selectable = true,
    bool chromeVisible = true,
  }) {
    final List<_MarkupLayoutNode> children = <_MarkupLayoutNode>[];

    for (final (int index, MarkupBlock block) in document.blocks.indexed) {
      if (index > 0) {
        children.add(
          _MarkupLayoutGapNode(
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
        _buildLayoutBlock(
          block,
          theme: theme,
          listDepth: listDepth,
          inListItem: inListItem,
          selectable: selectable,
          chromeVisible: chromeVisible,
        ),
      );
    }

    return _MarkupLayoutColumnNode(children);
  }

  _MarkupLayoutNode _buildLayoutBlock(
    MarkupBlock block, {
    required MarkupTheme theme,
    required int listDepth,
    required bool inListItem,
    required bool selectable,
    required bool chromeVisible,
  }) {
    switch (block) {
      case MarkupParagraphBlock() || MarkupHeadingBlock():
        return _MarkupLayoutTextNode(
          text: block.toTextSpan(
            theme: theme,
            gestureRecognizerFactory: gestureRecognizerFactory,
          ),
          selectable: selectable,
        );
      case final MarkupBlockquoteBlock quote:
        final TwLinkPillStyle? linkPillStyle = theme.linkPillStyle;
        final MarkupTheme quoteTheme = MarkupTheme(
          baseStyle: theme.blockquoteStyle,
          strongStyle: theme.blockquoteStyle.merge(theme.strongStyle),
          emphasisStyle: theme.blockquoteStyle.merge(theme.emphasisStyle),
          strikethroughStyle: theme.blockquoteStyle.merge(
            theme.strikethroughStyle,
          ),
          underlineStyle: theme.blockquoteStyle.merge(theme.underlineStyle),
          linkStyle: theme.blockquoteStyle.merge(theme.linkStyle),
          // When rendering blockquote pills, merge the blockquote text style
          // into the pill so the pill matches blockquote typography. This
          // affects markdown views in the main app and also markdown shown
          // inside chat bubbles.
          linkPillStyle: linkPillStyle?.copyWith(
            textStyle: theme.blockquoteStyle.merge(linkPillStyle.textStyle),
          ),
            transparentSelectionSpacer: theme.transparentSelectionSpacer,
          blockquoteStyle: theme.blockquoteStyle,
          headingStyleResolver: (int level) =>
              theme.headingStyleResolver(level).merge(theme.blockquoteStyle),
        );
          final Color railColor = chromeVisible
          ? (theme.baseStyle.color ??
            DefaultTextStyle.of(context).style.color ??
            Colors.transparent)
          : Colors.transparent;
        final double fontSize = theme.baseStyle.fontSize ?? 12.0;
        return _MarkupLayoutBlockquoteNode(
          indent: fontSize * _style.blockquoteIndentFactor * 3.0,
          railColor: railColor,
          contentPadding: EdgeInsets.fromLTRB(
            20,
            MarkupViewStyle.blockquoteRailVerticalOverhang + MarkupViewStyle.blockquoteInnerVerticalPadding,
            0,
            MarkupViewStyle.blockquoteRailVerticalOverhang + MarkupViewStyle.blockquoteInnerVerticalPadding,
          ),
          child: _buildLayoutDocument(
            MarkupDocument(quote.blocks),
            quoteTheme,
            listDepth: listDepth,
            inListItem: inListItem,
            selectable: selectable,
            chromeVisible: chromeVisible,
          ),
        );
      case final MarkupListBlock list:
        final List<_MarkupLayoutListItemNode> items =
            <_MarkupLayoutListItemNode>[];
        for (final (int itemIndex, MarkupListItem item) in list.items.indexed) {
          final String marker = list.ordered
              ? '${list.startingIndex + itemIndex}. '
              : '• ';
          final bool useAssetMarker = !list.ordered && chromeVisible;
          final List<MarkupBlock> itemBlocks = item.blocks;
          final bool canUseBaseline =
              !useAssetMarker &&
              itemBlocks.length == 1 &&
              (itemBlocks.first is MarkupParagraphBlock ||
                  itemBlocks.first is MarkupHeadingBlock);

          items.add(
            _MarkupLayoutListItemNode(
              topSpacing: itemIndex == 0
                  ? 0.0
                  : _listItemSpacing(theme.baseStyle, listDepth: listDepth),
              leftPadding: _listIndent(),
              crossAxisAlignment: canUseBaseline
                  ? CrossAxisAlignment.baseline
                  : CrossAxisAlignment.start,
              textBaseline: canUseBaseline ? TextBaseline.alphabetic : null,
              markerSlotWidth: _listMarkerSlotWidth(theme.baseStyle, listDepth),
              markerAlignment: list.ordered
                  ? const Alignment(0.78, 0.0)
                  : const Alignment(0.45, 0.0),
              marker: useAssetMarker
                  ? _MarkupLayoutAssetMarkerNode(theme.baseStyle)
                  : _MarkupLayoutTextNode(
                      text: TextSpan(text: marker, style: theme.baseStyle),
                      softWrap: false,
                      selectable: selectable,
                    ),
              markerGap: _listMarkerGap(theme.baseStyle),
              content: canUseBaseline
                  ? _buildLayoutBlock(
                      itemBlocks.first,
                      theme: theme,
                      listDepth: listDepth + 1,
                      inListItem: true,
                      selectable: selectable,
                      chromeVisible: chromeVisible,
                    )
                  : _buildLayoutDocument(
                      MarkupDocument(itemBlocks),
                      theme,
                      listDepth: listDepth + 1,
                      inListItem: true,
                      selectable: selectable,
                      chromeVisible: chromeVisible,
                    ),
            ),
          );
        }

        return _MarkupLayoutListNode(items);
    }
  }

  Widget _renderLayoutNode(_MarkupLayoutNode node) {
    switch (node) {
      case final _MarkupLayoutColumnNode column:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: column.children
              .map(_renderLayoutNode)
              .toList(growable: false),
        );
      case final _MarkupLayoutGapNode gap:
        return SizedBox(height: gap.height);
      case final _MarkupLayoutTextNode text:
        return _buildSelectableRichText(
          text.text,
          softWrap: text.softWrap,
          selectable: text.selectable,
        );
      case final _MarkupLayoutBlockquoteNode blockquote:
        return Padding(
          padding: EdgeInsets.only(left: blockquote.indent),
          child: CustomPaint(
            foregroundPainter: BlockQuoteRailPainter(
              color: blockquote.railColor,
              railThickness: _style.blockquoteRailWidth,
              capLength: _style.blockquoteCapLength,
              railInset: _style.blockquoteRailInset,
            ),
            child: Padding(
              padding: blockquote.contentPadding,
              child: _renderLayoutNode(blockquote.child),
            ),
          ),
        );
      case final _MarkupLayoutListNode list:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: list.items.map(_renderListItem).toList(growable: false),
        );
    }
  }

  Widget _renderListItem(_MarkupLayoutListItemNode item) {
    final children = <Widget>[];

    if (item.topSpacing > 0) {
      children.add(SizedBox(height: item.topSpacing));
    }

    children.add(
      Padding(
        padding: EdgeInsets.only(left: item.leftPadding),
        child: Row(
          crossAxisAlignment: item.crossAxisAlignment,
          textBaseline: item.textBaseline,
          children: <Widget>[
            SizedBox(
              width: item.markerSlotWidth,
              child: Align(
                alignment: item.markerAlignment,
                child: _renderMarkerNode(item.marker),
              ),
            ),
            SizedBox(width: item.markerGap),
            Expanded(child: _renderLayoutNode(item.content)),
          ],
        ),
      ),
    );

    if (children.length == 1) {
      return children.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _renderMarkerNode(_MarkupLayoutMarkerNode marker) {
    return switch (marker) {
      _MarkupLayoutAssetMarkerNode(:final baseStyle) =>
        _buildUnorderedListAssetMarker(baseStyle),
      _MarkupLayoutTextNode() => _buildSelectableRichText(
        marker.text,
        softWrap: marker.softWrap,
        selectable: marker.selectable,
      ),
    };
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
    final double fontSize = theme.baseStyle.fontSize ?? context.twTextStyleTokens.twBodyBaseFontSize;

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
    final double fontSize = baseStyle.fontSize ?? context.twTextStyleTokens.twBodyBaseFontSize; 

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
      fontSize * MarkupViewStyle.unorderedListMarkerSizeFactor,
    );
    final double verticalOffset = _snapToDevicePixels(
      fontSize * MarkupViewStyle.unorderedListMarkerVerticalOffsetFactor,
    );
    final Color? markerColor = baseStyle.color;

    return Transform.translate(
      offset: Offset(0, verticalOffset),
      child: TwSvgAsset(
        _unorderedListMarkerAssetPath,
        package: _unorderedListMarkerAssetPackage,
        width: markerSize,
        height: markerSize,
        fit: BoxFit.contain,
        color: markerColor,
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

sealed class _MarkupLayoutNode {
  const _MarkupLayoutNode();
}

class _MarkupLayoutColumnNode extends _MarkupLayoutNode {
  const _MarkupLayoutColumnNode(this.children);

  final List<_MarkupLayoutNode> children;
}

class _MarkupLayoutGapNode extends _MarkupLayoutNode {
  const _MarkupLayoutGapNode({required this.height});

  final double height;
}

sealed class _MarkupLayoutMarkerNode {
  const _MarkupLayoutMarkerNode();
}

class _MarkupLayoutTextNode extends _MarkupLayoutNode
    implements _MarkupLayoutMarkerNode {
  const _MarkupLayoutTextNode({
    required this.text,
    this.softWrap = true,
    this.selectable = true,
  });

  final TextSpan text;
  final bool softWrap;
  final bool selectable;
}

class _MarkupLayoutAssetMarkerNode extends _MarkupLayoutMarkerNode {
  const _MarkupLayoutAssetMarkerNode(this.baseStyle);

  final TextStyle baseStyle;
}

class _MarkupLayoutBlockquoteNode extends _MarkupLayoutNode {
  const _MarkupLayoutBlockquoteNode({
    required this.indent,
    required this.railColor,
    required this.contentPadding,
    required this.child,
  });

  final double indent;
  final Color railColor;
  final EdgeInsets contentPadding;
  final _MarkupLayoutNode child;
}

class _MarkupLayoutListNode extends _MarkupLayoutNode {
  const _MarkupLayoutListNode(this.items);

  final List<_MarkupLayoutListItemNode> items;
}

class _MarkupLayoutListItemNode {
  const _MarkupLayoutListItemNode({
    required this.topSpacing,
    required this.leftPadding,
    required this.crossAxisAlignment,
    required this.textBaseline,
    required this.markerSlotWidth,
    required this.markerAlignment,
    required this.marker,
    required this.markerGap,
    required this.content,
  });

  final double topSpacing;
  final double leftPadding;
  final CrossAxisAlignment crossAxisAlignment;
  final TextBaseline? textBaseline;
  final double markerSlotWidth;
  final Alignment markerAlignment;
  final _MarkupLayoutMarkerNode marker;
  final double markerGap;
  final _MarkupLayoutNode content;
}
