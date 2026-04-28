import 'package:flutter/material.dart' hide GestureRecognizerFactory;

import '../config/config.dart';
import '../logic/message_markup.dart';

class MessageBubbleMarkupRenderer extends StatelessWidget {
  const MessageBubbleMarkupRenderer({
    super.key,
    required this.document,
    required this.style,
    required this.bubbleColor,
    required this.isUserBubble,
    required this.truncatedContentHeight,
    required this.isTruncated,
    required this.gestureRecognizerFactory,
  });

  final ChatMarkupDocument document;
  final TextStyle style;
  final Color bubbleColor;
  final bool isUserBubble;
  final double truncatedContentHeight;
  final bool isTruncated;
  final GestureRecognizerFactory gestureRecognizerFactory;

  @override
  Widget build(BuildContext context) {
    final skin = ChatSkin.dataOf(context);
    final colors = skin.colors;
    final tokens = skin.tokens;
    final markupTheme = _buildMarkupTheme(context, style);

    if (!isTruncated) {
      final visibleMarkupLayer = _buildRenderedMarkupDocument(
        context,
        document,
        markupTheme,
        selectable: false,
        chromeVisible: true,
      );
      final hiddenSelectionLayer = Positioned.fill(
        child: _buildRenderedMarkupDocument(
          context,
          document,
          _transparentMarkupTheme(markupTheme),
          selectable: true,
          chromeVisible: false,
        ),
      );

      return Stack(
        clipBehavior: Clip.none,
        children: [hiddenSelectionLayer, visibleMarkupLayer],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final hiddenSelectionLayer = _buildTruncatedMarkupLayer(
          context,
          document: document,
          theme: _transparentMarkupTheme(markupTheme),
          maxWidth: constraints.maxWidth,
          selectable: true,
          chromeVisible: false,
        );
        final visibleMarkupLayer = _buildTruncatedMarkupLayer(
          context,
          document: document,
          theme: markupTheme,
          maxWidth: constraints.maxWidth,
          selectable: false,
          chromeVisible: true,
        );
        final fadeHeight =
            truncatedContentHeight < tokens.markupTruncationMaxFadeHeight
            ? truncatedContentHeight
            : tokens.markupTruncationMaxFadeHeight;
        final overlayMidAlpha = isUserBubble
            ? tokens.markupTruncationOverlayMidAlphaUser
            : tokens.markupTruncationOverlayMidAlphaBot;
        final overlayLateAlpha = isUserBubble
            ? tokens.markupTruncationOverlayLateAlphaUser
            : tokens.markupTruncationOverlayLateAlphaBot;
        final midFadeFactor = isUserBubble
            ? tokens.markupFadeMaskMidFactorUser
            : tokens.markupFadeMaskMidFactorBot;
        final lateFadeFactor = isUserBubble
            ? tokens.markupFadeMaskLateFactorUser
            : tokens.markupFadeMaskLateFactorBot;
        final overlayStops = isUserBubble
            ? tokens.markupTruncationOverlayStopsUser
            : tokens.markupTruncationOverlayStopsBot;

        return SizedBox(
          height: truncatedContentHeight,
          child: ClipRect(
            child: Stack(
              children: [
                hiddenSelectionLayer,
                ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) {
                    final normalizedFadeStart = bounds.height <= 0
                        ? 0.0
                        : ((bounds.height - fadeHeight) / bounds.height).clamp(
                            0.0,
                            1.0,
                          );
                    final midFadeStart =
                        (normalizedFadeStart +
                                (1.0 - normalizedFadeStart) * midFadeFactor)
                            .clamp(0.0, 1.0);
                    final lateFadeStart =
                        (normalizedFadeStart +
                                (1.0 - normalizedFadeStart) * lateFadeFactor)
                            .clamp(0.0, 1.0);

                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.markupFadeMaskOpaque,
                        colors.markupFadeMaskOpaque,
                        colors.markupFadeMaskOpaque,
                        colors.markupFadeMaskSoft,
                        colors.transparent,
                      ],
                      stops: [
                        0.0,
                        normalizedFadeStart,
                        midFadeStart,
                        lateFadeStart,
                        1.0,
                      ],
                    ).createShader(bounds);
                  },
                  child: visibleMarkupLayer,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: fadeHeight,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            bubbleColor.withValues(
                              alpha: tokens.alphaTransparent,
                            ),
                            bubbleColor.withValues(alpha: overlayMidAlpha),
                            bubbleColor.withValues(alpha: overlayLateAlpha),
                            bubbleColor,
                          ],
                          stops: overlayStops,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ChatMarkupTheme _buildMarkupTheme(BuildContext context, TextStyle baseStyle) {
    final skin = ChatSkin.dataOf(context);
    final colors = skin.colors;
    final tokens = skin.tokens;
    final textStyles = skin.textStyles;
    final linkStyle = baseStyle.copyWith(
      color: colors.markupLink,
      decoration: TextDecoration.underline,
      decorationColor: colors.markupLinkDecoration,
      decorationThickness: textStyles.markdownDecorationThickness(tokens),
    );
    return ChatMarkupTheme(
      baseStyle: baseStyle,
      strongStyle: textStyles.markdownStrongStyle(baseStyle, colors),
      emphasisStyle: textStyles.markdownEmphasisStyle(baseStyle),
      strikethroughStyle: textStyles.markdownStrikethroughStyle(
        baseStyle,
        tokens,
      ),
      underlineStyle: textStyles.markdownUnderlineStyle(baseStyle, tokens),
      linkStyle: linkStyle,
      blockquoteStyle: textStyles.markdownBlockquoteStyle(baseStyle, colors),
      headingStyleResolver: (level) =>
          textStyles.markdownHeadingStyle(baseStyle, level, colors),
    );
  }

  Widget _buildTruncatedMarkupLayer(
    BuildContext context, {
    required ChatMarkupDocument document,
    required ChatMarkupTheme theme,
    required double maxWidth,
    required bool selectable,
    required bool chromeVisible,
  }) {
    return PrimaryScrollController.none(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        primary: false,
        clipBehavior: Clip.hardEdge,
        child: Align(
          alignment: Alignment.topLeft,
          widthFactor: 1.0,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: _buildRenderedMarkupDocument(
              context,
              document,
              theme,
              selectable: selectable,
              chromeVisible: chromeVisible,
            ),
          ),
        ),
      ),
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
    final children = <Widget>[];

    for (final (index, block) in document.blocks.indexed) {
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
      final quoteTheme = ChatMarkupTheme(
        baseStyle: theme.blockquoteStyle,
        strongStyle: theme.blockquoteStyle.merge(theme.strongStyle),
        emphasisStyle: theme.blockquoteStyle.merge(theme.emphasisStyle),
        strikethroughStyle: theme.blockquoteStyle.merge(
          theme.strikethroughStyle,
        ),
        underlineStyle: theme.blockquoteStyle.merge(theme.underlineStyle),
        linkStyle: theme.blockquoteStyle.merge(theme.linkStyle),
        blockquoteStyle: theme.blockquoteStyle,
        headingStyleResolver: (level) =>
            theme.headingStyleResolver(level).merge(theme.blockquoteStyle),
      );
      final railColor = chromeVisible
          ? ChatSkin.dataOf(context).colors.bubbleText
          : ChatSkin.dataOf(context).colors.transparent;
        final tokens = ChatSkin.tokens;
        final fontSize = theme.baseStyle.fontSize ?? 12.0;
      return Padding(
        padding: EdgeInsets.only(
          left: fontSize * tokens.markupBlockquoteIndentFactor,
        ),
        child: CustomPaint(
          foregroundPainter: _BlockQuoteRailPainter(
            color: railColor,
            railThickness: tokens.markupBlockquoteRailWidth,
            capLength: tokens.composerCornerAccentSegment,
            railInset: 5.0,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 7),
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

    if (block is ChatMarkupHorizontalRuleBlock) {
      final hrColor = chromeVisible
          ? ChatSkin.dataOf(context).colors.bubbleText
          : ChatSkin.dataOf(context).colors.transparent;
      return Container(height: 0.25, color: hrColor);
    }

    if (block is ChatMarkupListBlock) {
      final children = <Widget>[];
      for (final entry in block.items.indexed) {
        if (entry.$1 > 0) {
          children.add(
            SizedBox(
              height: _listItemSpacing(
                theme.baseStyle,
                listDepth: listDepth,
              ),
            ),
          );
        }

        final marker = block.ordered
            ? '${block.startingIndex + entry.$1}. '
            : '• ';
        final itemBlocks = entry.$2.blocks;
        final bool canUseBaseline =
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
              children: [
                SizedBox(
                  width: _listMarkerSlotWidth(theme.baseStyle, listDepth),
                  child: Align(
                    alignment: block.ordered
                        ? const Alignment(0.78, 0.0)
                        : const Alignment(0.45, 0.0),
                    child: _buildSelectableRichText(
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

  ChatMarkupTheme _transparentMarkupTheme(ChatMarkupTheme theme) {
    TextStyle transparent(TextStyle style) {
      return _transparentTextStyle(style);
    }

    return ChatMarkupTheme(
      baseStyle: transparent(theme.baseStyle),
      strongStyle: transparent(theme.strongStyle),
      emphasisStyle: transparent(theme.emphasisStyle),
      strikethroughStyle: transparent(theme.strikethroughStyle),
      underlineStyle: transparent(theme.underlineStyle),
      linkStyle: transparent(theme.linkStyle),
      blockquoteStyle: transparent(theme.blockquoteStyle),
      headingStyleResolver: (level) =>
          transparent(theme.headingStyleResolver(level)),
    );
  }

  TextStyle _transparentTextStyle(TextStyle style) {
    final transparent = Colors.transparent;
    return style.copyWith(
      color: transparent,
      backgroundColor: transparent,
      decorationColor: transparent,
      shadows: const <Shadow>[],
    );
  }

  double _blockSpacing(
    ChatMarkupTheme theme, {
    required ChatMarkupBlock previousBlock,
    required ChatMarkupBlock nextBlock,
    required bool inListItem,
  }) {
    final fontSize = theme.baseStyle.fontSize ?? 12.0;
    final tokens = ChatSkin.tokens;

    double spacing = fontSize * tokens.markupBlockBaseSpacingFactor;
    if (inListItem && nextBlock is ChatMarkupListBlock) {
      spacing += fontSize * tokens.markupNestedListTopSpacingAdjustment;
    } else if (inListItem && previousBlock is ChatMarkupListBlock) {
      spacing += fontSize * tokens.markupNestedListBottomSpacingAdjustment;
    } else if (nextBlock is ChatMarkupBlockQuoteBlock) {
      spacing += fontSize * tokens.markupBlockQuoteTopSpacingAdjustment;
    }

    if (previousBlock is ChatMarkupHeadingBlock) {
      final headingBottomSpacingFactor = tokens
          .markupHeadingBottomSpacingFactorForLevel(previousBlock.level);
      final headingFontSize = _resolveHeadingFontSize(
        theme: theme,
        fallbackFontSize: fontSize,
        level: previousBlock.level,
      );
      spacing += headingFontSize * headingBottomSpacingFactor;
    }
    if (nextBlock is ChatMarkupHeadingBlock) {
      final headingTopSpacingFactor = tokens
          .markupHeadingTopSpacingFactorForLevel(nextBlock.level);
      final headingFontSize = _resolveHeadingFontSize(
        theme: theme,
        fallbackFontSize: fontSize,
        level: nextBlock.level,
      );
      spacing += headingFontSize * headingTopSpacingFactor;
    }

    if (previousBlock is ChatMarkupBlockQuoteBlock) {
      spacing += fontSize * tokens.markupBlockQuoteExtraSpacing;
    }
    if (nextBlock is ChatMarkupBlockQuoteBlock) {
      spacing += fontSize * tokens.markupBlockQuoteExtraSpacing;
    }
    if (!inListItem &&
        nextBlock is ChatMarkupListBlock &&
        previousBlock is! ChatMarkupHeadingBlock &&
        previousBlock is! ChatMarkupListBlock) {
      spacing += fontSize * tokens.markupListTopSpacingAdjustment;
    }
    if (!inListItem && previousBlock is ChatMarkupListBlock) {
      spacing += fontSize * tokens.markupListBottomSpacingAdjustment;
    }
    return spacing < 0 ? 0 : spacing;
  }

  double _listItemSpacing(
    TextStyle style, {
    required int listDepth,
  }) {
    final fontSize = style.fontSize ?? 12.0;
    final tokens = ChatSkin.tokens;

    var spacing = fontSize * tokens.markupListItemBaseSpacingFactor;
    if (listDepth <= 0) {
      spacing += fontSize * tokens.markupTopLevelListItemSpacingAdjustment;
    }

    return spacing < 0 ? 0 : spacing;
  }

  double _listIndent() {
    return 0.0;
  }

  double _listMarkerGap(TextStyle style) {
    final fontSize = style.fontSize ?? 12.0;
    return fontSize * ChatSkin.tokens.markupListMarkerGapFactor;
  }

  double _listMarkerSlotWidth(TextStyle style, int depth) {
    final fontSize = style.fontSize ?? 12.0;
    final tokens = ChatSkin.tokens;
    final factor = depth <= 0
        ? tokens.markupTopLevelListMarkerSlotFactor
        : tokens.markupNestedListMarkerSlotFactor;
    return fontSize * factor;
  }

  double _resolveHeadingFontSize({
    required ChatMarkupTheme theme,
    required double fallbackFontSize,
    required int level,
  }) {
    final resolvedFontSize = theme.headingStyleResolver(level).fontSize;
    return resolvedFontSize ?? fallbackFontSize;
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

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = railThickness
      ..strokeCap = StrokeCap.square;

    const verticalOvershoot = 3.0;
    final railX = railInset + railThickness / 2;
    final topY = -verticalOvershoot;
    final bottomY = size.height + verticalOvershoot;
    final maxCapLength = (size.width - railX).clamp(0.0, double.infinity);
    final boundedCapLength = capLength.clamp(0.0, maxCapLength);

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
