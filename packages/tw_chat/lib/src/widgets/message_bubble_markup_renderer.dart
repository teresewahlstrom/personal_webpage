import 'package:flutter/material.dart' hide GestureRecognizerFactory;
import 'package:tw_primitives/markdown.dart';

import '../config/config.dart';

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
    final ChatSkinData skin = ChatSkin.dataOf(context);
    final ChatSkinColors colors = skin.colors;
    final ChatSkinTokens tokens = skin.tokens;
    final ChatMarkupTheme markupTheme = _buildMarkupTheme(context, style);
    final ChatMarkupViewStyle markupViewStyle = _buildMarkupViewStyle(tokens);

    if (!isTruncated) {
      final Widget visibleMarkupLayer = _buildRenderedMarkupDocument(
        context,
        document,
        markupTheme,
        markupViewStyle,
        selectable: false,
        chromeVisible: true,
      );
      final Widget hiddenSelectionLayer = Positioned.fill(
        child: _buildRenderedMarkupDocument(
          context,
          document,
          _transparentMarkupTheme(markupTheme),
          markupViewStyle,
          selectable: true,
          chromeVisible: false,
        ),
      );

      return Stack(
        clipBehavior: Clip.none,
        children: <Widget>[hiddenSelectionLayer, visibleMarkupLayer],
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Widget hiddenSelectionLayer = _buildTruncatedMarkupLayer(
          context,
          document: document,
          theme: _transparentMarkupTheme(markupTheme),
          viewStyle: markupViewStyle,
          maxWidth: constraints.maxWidth,
          selectable: true,
          chromeVisible: false,
        );
        final Widget visibleMarkupLayer = _buildTruncatedMarkupLayer(
          context,
          document: document,
          theme: markupTheme,
          viewStyle: markupViewStyle,
          maxWidth: constraints.maxWidth,
          selectable: false,
          chromeVisible: true,
        );
        final double fadeHeight =
            truncatedContentHeight < tokens.markupTruncationMaxFadeHeight
            ? truncatedContentHeight
            : tokens.markupTruncationMaxFadeHeight;
        final double overlayMidAlpha = isUserBubble
            ? tokens.markupTruncationOverlayMidAlphaUser
            : tokens.markupTruncationOverlayMidAlphaBot;
        final double overlayLateAlpha = isUserBubble
            ? tokens.markupTruncationOverlayLateAlphaUser
            : tokens.markupTruncationOverlayLateAlphaBot;
        final double midFadeFactor = isUserBubble
            ? tokens.markupFadeMaskMidFactorUser
            : tokens.markupFadeMaskMidFactorBot;
        final double lateFadeFactor = isUserBubble
            ? tokens.markupFadeMaskLateFactorUser
            : tokens.markupFadeMaskLateFactorBot;
        final List<double> overlayStops = isUserBubble
            ? tokens.markupTruncationOverlayStopsUser
            : tokens.markupTruncationOverlayStopsBot;

        return SizedBox(
          height: truncatedContentHeight,
          child: ClipRect(
            child: Stack(
              children: <Widget>[
                hiddenSelectionLayer,
                ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (Rect bounds) {
                    final double normalizedFadeStart = bounds.height <= 0
                        ? 0.0
                        : ((bounds.height - fadeHeight) / bounds.height).clamp(
                            0.0,
                            1.0,
                          );
                    final double midFadeStart =
                        (normalizedFadeStart +
                                (1.0 - normalizedFadeStart) * midFadeFactor)
                            .clamp(0.0, 1.0);
                    final double lateFadeStart =
                        (normalizedFadeStart +
                                (1.0 - normalizedFadeStart) * lateFadeFactor)
                            .clamp(0.0, 1.0);

                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        colors.markupFadeMaskOpaque,
                        colors.markupFadeMaskOpaque,
                        colors.markupFadeMaskOpaque,
                        colors.markupFadeMaskSoft,
                        colors.transparent,
                      ],
                      stops: <double>[
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
                if (isUserBubble)
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
                            colors: <Color>[
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
    final ChatSkinData skin = ChatSkin.dataOf(context);
    final ChatSkinColors colors = skin.colors;
    final ChatSkinTokens tokens = skin.tokens;
    final ChatSkinTextStyles textStyles = skin.textStyles;
    final TextStyle linkStyle = baseStyle.copyWith(
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
        isDark: ChatSkin.isDarkOf(context),
      ),
      underlineStyle: textStyles.markdownUnderlineStyle(baseStyle, tokens),
      linkStyle: linkStyle,
      blockquoteStyle: textStyles.markdownBlockquoteStyle(baseStyle, colors),
      headingStyleResolver: (int level) =>
          textStyles.markdownHeadingStyle(baseStyle, level, colors),
    );
  }

  ChatMarkupViewStyle _buildMarkupViewStyle(ChatSkinTokens tokens) {
    return ChatMarkupViewStyle(
      blockquoteRailWidth: tokens.markupBlockquoteRailWidth,
      blockBaseSpacingFactor: tokens.markupBlockBaseSpacingFactor,
      blockQuoteExtraSpacing: tokens.markupBlockQuoteExtraSpacing,
      listTopSpacingAdjustment: tokens.markupListTopSpacingAdjustment,
      nestedListTopSpacingAdjustment:
          tokens.markupNestedListTopSpacingAdjustment,
      nestedListBottomSpacingAdjustment:
          tokens.markupNestedListBottomSpacingAdjustment,
      blockQuoteTopSpacingAdjustment:
          tokens.markupBlockQuoteTopSpacingAdjustment,
      listBottomSpacingAdjustment: tokens.markupListBottomSpacingAdjustment,
      headingBottomSpacingFactors: tokens.markupHeadingBottomSpacingFactors,
      headingTopSpacingFactors: tokens.markupHeadingTopSpacingFactors,
      listItemBaseSpacingFactor: tokens.markupListItemBaseSpacingFactor,
      topLevelListItemSpacingAdjustment:
          tokens.markupTopLevelListItemSpacingAdjustment,
      listMarkerGapFactor: tokens.markupListMarkerGapFactor,
      topLevelListMarkerSlotFactor: tokens.markupTopLevelListMarkerSlotFactor,
      nestedListMarkerSlotFactor: tokens.markupNestedListMarkerSlotFactor,
      blockquoteIndentFactor: tokens.markupBlockquoteIndentFactor,
      blockquoteCapLength: tokens.composerCornerAccentSegment,
      blockquoteRailInset: 5.0,
    );
  }

  Widget _buildTruncatedMarkupLayer(
    BuildContext context, {
    required ChatMarkupDocument document,
    required ChatMarkupTheme theme,
    required ChatMarkupViewStyle viewStyle,
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
              viewStyle,
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
    ChatMarkupTheme theme,
    ChatMarkupViewStyle viewStyle, {
    required bool selectable,
    required bool chromeVisible,
  }) {
    return ChatMarkupView(
      document: document,
      theme: theme,
      style: viewStyle,
      selectable: selectable,
      chromeVisible: chromeVisible,
      blockquoteRailColor: chromeVisible
          ? ChatSkin.dataOf(context).colors.bubbleText
          : ChatSkin.dataOf(context).colors.transparent,
      gestureRecognizerFactory: gestureRecognizerFactory,
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
      headingStyleResolver: (int level) =>
          transparent(theme.headingStyleResolver(level)),
    );
  }

  TextStyle _transparentTextStyle(TextStyle style) {
    const Color transparent = Colors.transparent;
    return style.copyWith(
      color: transparent,
      backgroundColor: transparent,
      decorationColor: transparent,
      shadows: const <Shadow>[],
    );
  }
}
