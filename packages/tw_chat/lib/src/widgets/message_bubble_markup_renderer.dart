import 'package:flutter/material.dart';
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

  final MarkupDocument document;
  final TextStyle style;
  final Color bubbleColor;
  final bool isUserBubble;
  final double truncatedContentHeight;
  final bool isTruncated;
  final LinkGestureRecognizerFactory gestureRecognizerFactory;

  @override
  Widget build(BuildContext context) {
    final ChatSkinData skin = ChatSkin.dataOf(context);
    final ChatSkinColors colors = skin.colors;
    final ChatSkinTokens tokens = skin.tokens;
    final MarkupTheme markupTheme = _buildMarkupTheme(context);

    if (!isTruncated) {
      final Widget visibleMarkupLayer = _buildRenderedMarkupDocument(
        context,
        document,
        markupTheme,
        selectable: false,
        chromeVisible: true,
      );
      final Widget hiddenSelectionLayer = Positioned.fill(
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
        children: <Widget>[hiddenSelectionLayer, visibleMarkupLayer],
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Widget hiddenSelectionLayer = _buildTruncatedMarkupLayer(
          context,
          document: document,
          theme: _transparentMarkupTheme(markupTheme),
          maxWidth: constraints.maxWidth,
          selectable: true,
          chromeVisible: false,
        );
        final Widget visibleMarkupLayer = _buildTruncatedMarkupLayer(
          context,
          document: document,
          theme: markupTheme,
          maxWidth: constraints.maxWidth,
          selectable: false,
          chromeVisible: true,
        );
        final double fadeHeight =
            truncatedContentHeight < tokens.bubbleTruncationMaxFadeHeight
            ? truncatedContentHeight
            : tokens.bubbleTruncationMaxFadeHeight;
        final double overlayMidAlpha = isUserBubble
            ? tokens.bubbleTruncationOverlayMidAlphaUser
            : tokens.bubbleTruncationOverlayMidAlphaBot;
        final double overlayLateAlpha = isUserBubble
            ? tokens.bubbleTruncationOverlayLateAlphaUser
            : tokens.bubbleTruncationOverlayLateAlphaBot;
        final double midFadeFactor = isUserBubble
            ? tokens.bubbleFadeMaskMidFactorUser
            : tokens.bubbleFadeMaskMidFactorBot;
        final double lateFadeFactor = isUserBubble
            ? tokens.bubbleFadeMaskLateFactorUser
            : tokens.bubbleFadeMaskLateFactorBot;
        final List<double> overlayStops = isUserBubble
            ? tokens.bubbleTruncationOverlayStopsUser
            : tokens.bubbleTruncationOverlayStopsBot;

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
                        colors.bubbleFadeMaskOpaque,
                        colors.bubbleFadeMaskOpaque,
                        colors.bubbleFadeMaskOpaque,
                        colors.bubbleFadeMaskSoft,
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

  MarkupTheme _buildMarkupTheme(BuildContext context) {
    final ChatSkinData skin = ChatSkin.dataOf(context);
    final ChatSkinColors colors = skin.colors;
    return buildMarkdownTheme(
      MarkdownThemeConfig(
        baseTextColor: colors.bubbleText,
        linkColor: colors.markupLink,
        isDark: ChatSkin.isDarkOf(context),
      ),
    );
  }

  Widget _buildTruncatedMarkupLayer(
    BuildContext context, {
    required MarkupDocument document,
    required MarkupTheme theme,
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
    MarkupDocument document,
    MarkupTheme theme, {
    required bool selectable,
    required bool chromeVisible,
  }) {
    return MarkupView(
      document: document,
      theme: theme,
      selectable: selectable,
      chromeVisible: chromeVisible,
      blockquoteRailColor: chromeVisible
          ? ChatSkin.dataOf(context).colors.bubbleText
          : ChatSkin.dataOf(context).colors.transparent,
      gestureRecognizerFactory: gestureRecognizerFactory,
    );
  }

  MarkupTheme _transparentMarkupTheme(MarkupTheme theme) {
    TextStyle transparent(TextStyle style) {
      return _transparentTextStyle(style);
    }

    return MarkupTheme(
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
