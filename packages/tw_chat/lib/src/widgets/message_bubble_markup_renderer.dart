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
    final skin = ChatSkin.data;
    final colors = skin.colors;
    final tokens = skin.tokens;
    final markupTheme = _buildMarkupTheme(style);

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
              fit: StackFit.expand,
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

  ChatMarkupTheme _buildMarkupTheme(TextStyle baseStyle) {
    final skin = ChatSkin.data;
    final colors = skin.colors;
    final tokens = skin.tokens;
    final textStyles = skin.textStyles;
    final linkStyle = baseStyle.copyWith(
      color: colors.markupLink,
      decoration: TextDecoration.underline,
      decorationColor: colors.markupLinkDecoration,
      decorationThickness: tokens.markupUnderlineThickness,
    );
    return ChatMarkupTheme(
      baseStyle: baseStyle,
      strongStyle: textStyles.markdownStrongStyle(baseStyle, colors),
      emphasisStyle: textStyles.markdownEmphasisStyle(baseStyle),
      strikethroughStyle: textStyles.markdownStrikethroughStyle(baseStyle),
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
        child: SizedBox(
          width: maxWidth,
          child: _buildRenderedMarkupDocument(
            context,
            document,
            theme,
            selectable: selectable,
            chromeVisible: chromeVisible,
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
          ? ChatBubbleRules.botBorder
          : ChatSkin.data.colors.transparent;
      final tokens = ChatSkin.data.tokens;
      return CustomPaint(
        foregroundPainter: _BlockQuoteRailPainter(
          color: railColor,
          railThickness: tokens.bubbleBorderWidth,
          capLength: tokens.composerCornerAccentSegment,
          railInset: 5.0,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
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
      );
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
                previousItemBlocks: block.items[entry.$1 - 1].blocks,
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
                  width: _listMarkerSlotWidth(listDepth),
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
                SizedBox(width: _listMarkerGap()),
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

      if (listDepth <= 0) {
        final fontSize = theme.baseStyle.fontSize ?? 12.0;
        children.add(SizedBox(height: fontSize * 0.9));
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
    final transparent = ChatSkin.data.colors.transparent;
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
    const blockQuoteExtraSpacing = 1.2;
    const headingScales = <double>[1.55, 1.36, 1.22, 1.12, 1.06, 1.0];
    double spacing;
    if (inListItem && nextBlock is ChatMarkupListBlock) {
      spacing = fontSize * 0.16;
    } else if (inListItem && previousBlock is ChatMarkupListBlock) {
      spacing = fontSize * 0.2;
    } else if (previousBlock is ChatMarkupHeadingBlock) {
      final index = (previousBlock.level.clamp(1, 6)) - 1;
      final headingFontSize = fontSize * headingScales[index];
      spacing = headingFontSize * 0.2;
    } else if (nextBlock is ChatMarkupListBlock) {
      spacing = fontSize * 0.45;
    } else if (nextBlock is ChatMarkupBlockQuoteBlock) {
      spacing = fontSize * 0.65;
    } else if (nextBlock is ChatMarkupHeadingBlock) {
      final index = (nextBlock.level.clamp(1, 6)) - 1;
      final headingFontSize = fontSize * headingScales[index];
      spacing = headingFontSize * 1.1;
    } else {
      spacing = fontSize * 0.75;
    }

    if (previousBlock is ChatMarkupBlockQuoteBlock) {
      spacing += fontSize * blockQuoteExtraSpacing;
    }
    if (nextBlock is ChatMarkupBlockQuoteBlock) {
      spacing += fontSize * blockQuoteExtraSpacing;
    }
    return spacing;
  }

  double _listItemSpacing(
    TextStyle style, {
    required int listDepth,
    required List<ChatMarkupBlock> previousItemBlocks,
  }) {
    final fontSize = style.fontSize ?? 12.0;
    if (listDepth <= 0) {
      return fontSize * 0.42;
    }
    return fontSize * 0.14;
  }

  double _listIndent() {
    return 0.0;
  }

  double _listMarkerGap() {
    return 4.0;
  }

  double _listMarkerSlotWidth(int depth) {
    if (depth <= 0) {
      return 24.0;
    }
    return 21.0;
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
