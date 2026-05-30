import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:tw_primitives/markdown.dart';
import 'package:tw_primitives/scrollbar.dart' as tw_scrollbar;
import 'package:url_launcher/url_launcher.dart';

import '../config/config.dart';

class ChatMessageBubble extends StatefulWidget {
  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.selectionListenerNotifier,
    required this.isUserBubble,
    required this.isTypingIndicator,
    required this.isTruncated,
    required this.isFirstMessage,
    required this.isLastMessage,
    required this.availableWidth,
    required this.onToggleTruncation,
    this.botBubbleWidth,
  });

  final String text;
  final tw_scrollbar.SelectionListenerNotifier selectionListenerNotifier;
  final bool isUserBubble;
  final bool isTypingIndicator;
  final bool isTruncated;
  final bool isFirstMessage;
  final bool isLastMessage;
  final double availableWidth;
  final VoidCallback onToggleTruncation;
  final double? botBubbleWidth;

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  String? _lastParsedText;
  _ParsedMarkupPayload? _cachedParsedMarkup;
  _MeasurementKey? _lastMeasurementKey;
  _RenderedTextLayout? _cachedLayout;
  final Map<String, TapGestureRecognizer> _linkTextRecognizersByHref =
      <String, TapGestureRecognizer>{};

  _RenderedTextLayout _getMeasuredLayout({
    required String rawText,
    required _ParsedMarkupPayload? parsedMarkup,
    required TextStyle style,
    required TextScaler textScaler,
    required double maxTextWidth,
    required MarkupTheme markupTheme,
  }) {
    final key = _MeasurementKey(
      text: rawText,
      maxTextWidth: maxTextWidth,
      fontSize: style.fontSize,
      lineHeight: style.height,
      fontFamily: style.fontFamily,
      fontWeight: style.fontWeight,
      letterSpacing: style.letterSpacing,
      textScale: textScaler.scale(1.0),
    );

    if (_cachedLayout != null && _lastMeasurementKey?.matches(key) == true) {
      return _cachedLayout!;
    }

    final TextSpan measuredText = parsedMarkup == null
        ? TextSpan(text: _sanitizeTextForMeasurement(rawText), style: style)
        : parsedMarkup.document.toTextSpan(
            theme: markupTheme,
            gestureRecognizerFactory: (_) => null,
          );

    final painter = TextPainter(
      text: measuredText,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout(maxWidth: maxTextWidth);
    final lines = painter.computeLineMetrics();
    final layout = _RenderedTextLayout(
      lineCount: lines.length,
      lineHeight: painter.preferredLineHeight,
    );
    painter.dispose();

    _lastMeasurementKey = key;
    _cachedLayout = layout;
    return layout;
  }

  String _sanitizeTextForMeasurement(String raw) {
    return MessageMarkup.toPlainText(raw).trim();
  }

  _ParsedMarkupPayload _getParsedMarkup(String raw) {
    if (_cachedParsedMarkup != null && _lastParsedText == raw) {
      return _cachedParsedMarkup!;
    }

    final document = MessageMarkup.parse(raw);
    final parsedMarkup = _ParsedMarkupPayload(
      document: document,
      plainText: document.toPlainText().trim(),
    );
    _lastParsedText = raw;
    _cachedParsedMarkup = parsedMarkup;
    return parsedMarkup;
  }

  @override
  Widget build(BuildContext context) {
    final skin = ChatSkin.dataOf(context);
    final colors = skin.colors;
    final tokens = skin.tokens;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final bubbleTextStyle = ChatBubbleRules.textStyle(context, textScale);
    final horizontalInset = ChatBubbleRules.horizontalTextInset(textScale);
    final verticalInset = ChatBubbleRules.verticalTextInset(textScale);
    final bubbleMaxWidth =
        (widget.availableWidth * ChatBubbleRules.maxWidthFactor +
                tokens.bubbleWidthCompensation)
            .clamp(tokens.bubbleMinWidthClamp, widget.availableWidth);
    final bubbleMinWidth =
        (widget.availableWidth * ChatBubbleRules.minWidthFactor).clamp(
          0.0,
          bubbleMaxWidth,
        );
    final resolvedBotBubbleWidth =
        (widget.botBubbleWidth ?? widget.availableWidth)
            .clamp(0.0, widget.availableWidth)
            .toDouble();
    final contentMaxWidth = widget.isUserBubble
        ? bubbleMaxWidth
        : resolvedBotBubbleWidth;
    final textMeasureHorizontalInset = widget.isUserBubble
        ? horizontalInset * 2
        : tokens.composerTextInsetLeft + horizontalInset;
    final textScaler = MediaQuery.textScalerOf(context);
    final parsedMarkup = widget.isTypingIndicator
        ? null
        : _getParsedMarkup(widget.text);
    final markupTheme = _buildSharedMarkdownSurfaceForChat(context).theme;
    final textContentMaxWidth = (contentMaxWidth - textMeasureHorizontalInset)
        .clamp(0.0, double.infinity);
    final measuredLayout = _getMeasuredLayout(
      rawText: widget.text,
      parsedMarkup: parsedMarkup,
      style: bubbleTextStyle,
      textScaler: textScaler,
      maxTextWidth: textContentMaxWidth,
      markupTheme: markupTheme,
    );
    final isTruncatable =
        measuredLayout.lineCount > ChatBubbleRules.collapsibleLineThreshold;
    final isCollapsed = isTruncatable && widget.isTruncated;
    final truncatedContentHeight =
        measuredLayout.lineHeight * ChatBubbleRules.collapsedVisibleLines;
    final bubbleTopMargin = widget.isFirstMessage
        ? tokens.chatListTopShadowHeight + 15
        : tokens.bubbleVerticalMargin;
    final collapseButtonOverflowLeft = tokens.collapseButtonRightInset < 0
        ? -tokens.collapseButtonRightInset
        : 0.0;
    final collapseButtonOverflowBottom = tokens.collapseButtonBottomInset < 0
        ? -tokens.collapseButtonBottomInset
        : 0.0;
    final collapseButtonReservedBottom = isTruncatable
        ? collapseButtonOverflowBottom * 2
        : collapseButtonOverflowBottom;
    final toggleButtonBackgroundColor = widget.isTruncated
        ? ChatBubbleRules.collapseButtonColor(context)
        : colors.shellBackground;
    final toggleButtonIconColor = widget.isTruncated
        ? ChatBubbleRules.collapseButtonIconColor(context)
        : ChatBubbleRules.collapseButtonColor(context);
    final toggleButtonBorderSide = widget.isTruncated
        ? BorderSide.none
        : BorderSide(
            color: ChatBubbleRules.collapseButtonColor(context),
            width: 0.5,
          );
    final align = widget.isUserBubble
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final bubbleColor = widget.isUserBubble
        ? ChatBubbleRules.userFill(context)
        : ChatBubbleRules.botFill(context);
    final borderColor = widget.isUserBubble
        ? ChatBubbleRules.userBorder(context)
        : ChatBubbleRules.botBorder(context);
    final bubbleBorderSide = BorderSide(
      color: borderColor,
      width: tokens.bubbleBorderWidth,
    );
    final showFooter = !widget.isTypingIndicator;
    Widget buildFooter() {
      return _BubbleFooter(
        borderColor: borderColor,
        isCollapsed: isCollapsed,
        isTruncatable: isTruncatable,
        onToggleTruncation: widget.onToggleTruncation,
        toggleButtonBackgroundColor: toggleButtonBackgroundColor,
        toggleButtonIconColor: toggleButtonIconColor,
        toggleButtonBorderSide: toggleButtonBorderSide,
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Align(
        alignment: align,
        child: Padding(
          padding: EdgeInsets.only(top: bubbleTopMargin),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: collapseButtonOverflowLeft,
                  bottom: collapseButtonReservedBottom,
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      width: widget.isUserBubble ? null : contentMaxWidth,
                      child: Stack(
                        children: [
                          if (widget.isUserBubble)
                            IntrinsicWidth(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: bubbleMinWidth,
                                  maxWidth: bubbleMaxWidth,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.fromLTRB(
                                        horizontalInset,
                                        verticalInset,
                                        horizontalInset,
                                        isCollapsed ? 0.0 : verticalInset,
                                      ),
                                      decoration: BoxDecoration(
                                        color: bubbleColor,
                                        borderRadius: BorderRadius.circular(
                                          tokens.bubbleRadius,
                                        ),
                                        border: showFooter || isCollapsed
                                            ? Border(
                                                top: bubbleBorderSide,
                                                left: bubbleBorderSide,
                                                right: bubbleBorderSide,
                                              )
                                            : Border.fromBorderSide(
                                                bubbleBorderSide,
                                              ),
                                        boxShadow: [
                                          tokens.surfaceShadow(colors),
                                        ],
                                      ),
                                      child: _buildBubbleText(
                                        parsedMarkup,
                                        style: bubbleTextStyle,
                                        bubbleColor: bubbleColor,
                                        isUserBubble: true,
                                        truncatedContentHeight:
                                            truncatedContentHeight,
                                        isTruncated: isCollapsed,
                                        maxTextWidth: textContentMaxWidth,
                                      ),
                                    ),
                                    if (showFooter) buildFooter(),
                                  ],
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              width: contentMaxWidth,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    width: contentMaxWidth,
                                    padding: EdgeInsets.fromLTRB(
                                      tokens.composerTextInsetLeft,
                                      verticalInset,
                                      horizontalInset,
                                      isCollapsed ? 0.0 : verticalInset,
                                    ),
                                    child: _buildBubbleText(
                                      parsedMarkup,
                                      style: bubbleTextStyle,
                                      bubbleColor: bubbleColor,
                                      isUserBubble: false,
                                      truncatedContentHeight:
                                          truncatedContentHeight,
                                      isTruncated: isCollapsed,
                                      maxTextWidth: textContentMaxWidth,
                                    ),
                                  ),
                                  if (showFooter)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: isCollapsed ? 0.0 : 10.0,
                                        left: tokens.composerTextInsetLeft,
                                        right: horizontalInset,
                                      ),
                                      child: buildFooter(),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubbleText(
    _ParsedMarkupPayload? parsedMarkup, {
    required TextStyle style,
    required Color bubbleColor,
    required bool isUserBubble,
    required double truncatedContentHeight,
    required bool isTruncated,
    required double maxTextWidth,
  }) {
    final skin = ChatSkin.dataOf(context);
    final colors = skin.colors;
    final tokens = skin.tokens;
    if (widget.isTypingIndicator) {
      return tw_scrollbar.SelectionListener(
        selectionNotifier: widget.selectionListenerNotifier,
        child: Padding(
          padding: tokens.typingIndicatorPadding,
          child: _TypingDotsIndicator(
            color: colors.scrollbarThumb,
            dotDiameter:
                ((style.fontSize ?? tokens.typingIndicatorDefaultFontSize) *
                        0.5)
                    .clamp(
                      tokens.typingIndicatorDotMinDiameter,
                      tokens.typingIndicatorDotMaxDiameter,
                    ),
          ),
        ),
      );
    }
    return tw_scrollbar.SelectionListener(
      selectionNotifier: widget.selectionListenerNotifier,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TruncatedMessageBubbleMarkupRenderer(
            document: parsedMarkup!.document,
            style: style,
            bubbleColor: bubbleColor,
            isUserBubble: isUserBubble,
            truncatedContentHeight: truncatedContentHeight,
            isTruncated: isTruncated,
            maxTextWidth: maxTextWidth,
            gestureRecognizerFactory: _createLinkRecognizer,
          ),
        ],
      ),
    );
  }

  Future<void> _launchMarkdownLink(String href) async {
    final uri = _normalizeLink(href);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, webOnlyWindowName: '_blank');
  }

  Uri? _normalizeLink(String href) {
    final parsed = Uri.tryParse(href.trim());
    if (parsed == null) {
      return null;
    }
    if (parsed.hasScheme) {
      const allowedSchemes = <String>{'http', 'https', 'mailto', 'tel'};
      return allowedSchemes.contains(parsed.scheme.toLowerCase())
          ? parsed
          : null;
    }
    return Uri.tryParse('https://$href');
  }

  TapGestureRecognizer _createLinkRecognizer(String href) {
    final recognizer = _linkTextRecognizersByHref.putIfAbsent(
      href,
      TapGestureRecognizer.new,
    );
    recognizer.onTap = () => _launchMarkdownLink(href);
    return recognizer;
  }

  @override
  void didUpdateWidget(covariant ChatMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text == widget.text) {
      return;
    }
    _lastParsedText = null;
    _cachedParsedMarkup = null;
    for (final recognizer in _linkTextRecognizersByHref.values) {
      recognizer.dispose();
    }
    _linkTextRecognizersByHref.clear();
  }

  @override
  void dispose() {
    for (final recognizer in _linkTextRecognizersByHref.values) {
      recognizer.dispose();
    }
    _linkTextRecognizersByHref.clear();
    super.dispose();
  }
}

MarkdownSurfaceStyle _buildSharedMarkdownSurfaceForChat(BuildContext context) {
  final skin = ChatSkin.dataOf(context);
  final colors = skin.colors;
  final textScale = MediaQuery.textScalerOf(context).scale(1.0);
  return buildMarkdownSurfaceStyle(
    MarkdownThemeConfig(
      baseTextColor: colors.bubbleText,
      linkColor: colors.markupLink,
      isDark: ChatSkin.isDarkOf(context),
      textScale: MarkdownThemeConfig.bodyTextScaleOf(context),
      linkPillStyle: MarkupLinkPillStyle(
        fillColor: ChatComposerLayout.fillColor(context),
        borderColor: ChatComposerLayout.borderColor(context),
        textStyle: skin.textStyles.appBarTitleStyle(textScale, colors),
        shadows: <BoxShadow>[skin.tokens.jumpToLatestButtonShadow(colors)],
      ),
    ),
  );
}

class _RenderedTextLayout {
  const _RenderedTextLayout({
    required this.lineCount,
    required this.lineHeight,
  });

  final int lineCount;
  final double lineHeight;
}

class _MeasurementKey {
  const _MeasurementKey({
    required this.text,
    required this.maxTextWidth,
    required this.fontSize,
    required this.lineHeight,
    required this.fontFamily,
    required this.fontWeight,
    required this.letterSpacing,
    required this.textScale,
  });

  final String text;
  final double maxTextWidth;
  final double? fontSize;
  final double? lineHeight;
  final String? fontFamily;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final double textScale;

  bool matches(_MeasurementKey other) {
    return text == other.text &&
        fontFamily == other.fontFamily &&
        fontWeight == other.fontWeight &&
        _approxEq(maxTextWidth, other.maxTextWidth) &&
        _approxEq(fontSize, other.fontSize) &&
        _approxEq(lineHeight, other.lineHeight) &&
        _approxEq(letterSpacing, other.letterSpacing) &&
        _approxEq(textScale, other.textScale);
  }

  static bool _approxEq(double? a, double? b) {
    if (a == null || b == null) return a == b;
    return (a - b).abs() <= 0.01;
  }
}

class _ParsedMarkupPayload {
  const _ParsedMarkupPayload({required this.document, required this.plainText});

  final MarkupDocument document;
  final String plainText;
}

class _TruncatedMessageBubbleMarkupRenderer extends StatelessWidget {
  const _TruncatedMessageBubbleMarkupRenderer({
    required this.document,
    required this.style,
    required this.bubbleColor,
    required this.isUserBubble,
    required this.truncatedContentHeight,
    required this.isTruncated,
    required this.maxTextWidth,
    required this.gestureRecognizerFactory,
  });

  final MarkupDocument document;
  final TextStyle style;
  final Color bubbleColor;
  final bool isUserBubble;
  final double truncatedContentHeight;
  final bool isTruncated;
  final double maxTextWidth;
  final LinkGestureRecognizerFactory gestureRecognizerFactory;

  @override
  Widget build(BuildContext context) {
    final skin = ChatSkin.dataOf(context);
    final colors = skin.colors;
    final tokens = skin.tokens;
    final markdownSurface = _buildMarkupSurface(context);
    final markupTheme = markdownSurface.theme;

    if (!isTruncated) {
      return MarkupView(
        document: document,
        theme: markupTheme,
        gestureRecognizerFactory: gestureRecognizerFactory,
        selectable: true,
        chromeVisible: true,
        blockquoteRailColor: markdownSurface.blockquoteRailColor,
      );
    }

    final Widget visibleMarkupLayer = _buildTruncatedMarkupLayer(
      document: document,
      theme: markupTheme,
      maxWidth: maxTextWidth,
      selectable: false,
      chromeVisible: true,
      blockquoteRailColor: markdownSurface.blockquoteRailColor,
    );
    final Widget selectionLayer = _buildTruncatedMarkupLayer(
      document: _visibleSelectionDocument(
        document: document,
        theme: markupTheme,
        maxWidth: maxTextWidth,
        textScaler: MediaQuery.textScalerOf(context),
      ),
      theme: _transparentMarkupTheme(markupTheme),
      maxWidth: maxTextWidth,
      selectable: true,
      chromeVisible: false,
      blockquoteRailColor: colors.transparent,
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
            selectionLayer,
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
  }

  MarkdownSurfaceStyle _buildMarkupSurface(BuildContext context) {
    return _buildSharedMarkdownSurfaceForChat(context);
  }

  Widget _buildTruncatedMarkupLayer({
    required MarkupDocument document,
    required MarkupTheme theme,
    required double maxWidth,
    required bool selectable,
    required bool chromeVisible,
    required Color blockquoteRailColor,
  }) {
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: 0,
        maxWidth: maxWidth,
        minHeight: 0,
        maxHeight: double.infinity,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: MarkupView(
            document: document,
            theme: theme,
            gestureRecognizerFactory: gestureRecognizerFactory,
            selectable: selectable,
            chromeVisible: chromeVisible,
            blockquoteRailColor: blockquoteRailColor,
          ),
        ),
      ),
    );
  }

  MarkupDocument _visibleSelectionDocument({
    required MarkupDocument document,
    required MarkupTheme theme,
    required double maxWidth,
    required TextScaler textScaler,
  }) {
    // Keep collapsed bubble selection slightly more permissive than the visible
    // fade boundary so transcript-level select-all still captures the intended
    // leading message content without changing the rendered bubble preview.
    var remainingLines = ChatBubbleRules.collapsedVisibleLines + 1;
    final visibleBlocks = <MarkupBlock>[];

    for (final block in document.blocks) {
      if (remainingLines <= 0) {
        break;
      }

      final visibleBlock = _visibleSelectionBlock(
        block: block,
        theme: theme,
        maxWidth: maxWidth,
        textScaler: textScaler,
        maxLines: remainingLines,
      );
      if (visibleBlock == null) {
        break;
      }
      visibleBlocks.add(visibleBlock.block);
      remainingLines -= visibleBlock.lineCount;
    }

    if (visibleBlocks.isEmpty && document.blocks.isNotEmpty) {
      final fallbackText = document.blocks.first.toPlainText();
      if (fallbackText.isNotEmpty) {
        visibleBlocks.add(
          MarkupParagraphBlock(<MarkupInline>[
            MarkupInline(
              text: fallbackText.length > 160
                  ? fallbackText.substring(0, 160)
                  : fallbackText,
            ),
          ]),
        );
      }
    }

    return MarkupDocument(List<MarkupBlock>.unmodifiable(visibleBlocks));
  }

  ({MarkupBlock block, int lineCount})? _visibleSelectionBlock({
    required MarkupBlock block,
    required MarkupTheme theme,
    required double maxWidth,
    required TextScaler textScaler,
    required int maxLines,
  }) {
    if (block is MarkupParagraphBlock) {
      return _visibleTextBlock(
        block: block,
        inlines: block.inlines,
        theme: theme,
        maxWidth: maxWidth,
        textScaler: textScaler,
        maxLines: maxLines,
        buildBlock: MarkupParagraphBlock.new,
      );
    }

    if (block is MarkupHeadingBlock) {
      return _visibleTextBlock(
        block: block,
        inlines: block.inlines,
        theme: theme,
        maxWidth: maxWidth,
        textScaler: textScaler,
        maxLines: maxLines,
        buildBlock: (inlines) =>
            MarkupHeadingBlock(level: block.level, inlines: inlines),
      );
    }

    final lineCount = _measurePlainLineCount(
      text: block.toPlainText(),
      style: theme.baseStyle,
      maxWidth: maxWidth,
      textScaler: textScaler,
    );
    if (lineCount > maxLines) {
      return null;
    }
    return (block: block, lineCount: lineCount);
  }

  ({MarkupBlock block, int lineCount})? _visibleTextBlock({
    required MarkupBlock block,
    required List<MarkupInline> inlines,
    required MarkupTheme theme,
    required double maxWidth,
    required TextScaler textScaler,
    required int maxLines,
    required MarkupBlock Function(List<MarkupInline> inlines) buildBlock,
  }) {
    final textSpan = block.toTextSpan(
      theme: theme,
      gestureRecognizerFactory: (_) => null,
    );
    final painter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);
    final lines = painter.computeLineMetrics();
    if (lines.isEmpty) {
      painter.dispose();
      return null;
    }

    final lineCount = lines.length.clamp(1, maxLines).toInt();
    if (!painter.didExceedMaxLines) {
      painter.dispose();
      return (block: block, lineCount: lineCount);
    }

    final lastLine = lines[lineCount - 1];
    final visibleOffset = painter
        .getPositionForOffset(Offset(maxWidth, lastLine.baseline))
        .offset
        .clamp(1, block.toPlainText().length)
        .toInt();
    painter.dispose();

    return (
      block: buildBlock(_sliceInlines(inlines, visibleOffset)),
      lineCount: lineCount,
    );
  }

  int _measurePlainLineCount({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required TextScaler textScaler,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout(maxWidth: maxWidth);
    final lineCount = painter.computeLineMetrics().length;
    painter.dispose();
    return lineCount;
  }

  List<MarkupInline> _sliceInlines(List<MarkupInline> inlines, int maxLength) {
    final sliced = <MarkupInline>[];
    var remaining = maxLength;
    for (final inline in inlines) {
      if (remaining <= 0) {
        break;
      }
      if (inline.text.length <= remaining) {
        sliced.add(inline);
        remaining -= inline.text.length;
        continue;
      }
      sliced.add(
        MarkupInline(
          text: inline.text.substring(0, remaining),
          isStrong: inline.isStrong,
          isEmphasis: inline.isEmphasis,
          isStrikethrough: inline.isStrikethrough,
          isUnderline: inline.isUnderline,
          href: inline.href,
        ),
      );
      break;
    }
    return List<MarkupInline>.unmodifiable(sliced);
  }

  MarkupTheme _transparentMarkupTheme(MarkupTheme theme) {
    TextStyle transparent(TextStyle style) {
      return _transparentTextStyle(style);
    }

    final linkPillStyle = theme.linkPillStyle;
    return MarkupTheme(
      baseStyle: transparent(theme.baseStyle),
      strongStyle: transparent(theme.strongStyle),
      emphasisStyle: transparent(theme.emphasisStyle),
      strikethroughStyle: transparent(theme.strikethroughStyle),
      underlineStyle: transparent(theme.underlineStyle),
      linkStyle: transparent(theme.linkStyle),
      linkPillStyle: linkPillStyle?.copyWith(
        fillColor: Colors.transparent,
        borderColor: Colors.transparent,
        shadows: const <BoxShadow>[],
        textStyle: transparent(linkPillStyle.textStyle),
      ),
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

class _BubbleFooter extends StatelessWidget {
  const _BubbleFooter({
    required this.borderColor,
    required this.isCollapsed,
    required this.isTruncatable,
    required this.onToggleTruncation,
    required this.toggleButtonBackgroundColor,
    required this.toggleButtonIconColor,
    required this.toggleButtonBorderSide,
  });

  final Color borderColor;
  final bool isCollapsed;
  final bool isTruncatable;
  final VoidCallback onToggleTruncation;
  final Color toggleButtonBackgroundColor;
  final Color toggleButtonIconColor;
  final BorderSide toggleButtonBorderSide;

  @override
  Widget build(BuildContext context) {
    final tokens = ChatSkin.tokens;
    final double footerLineYOffset = isCollapsed
        ? tokens.bubbleBorderWidth *
              1.1 // Nudge down do that the dashed line does not appear to coincide with bubble shadow when truncated
        : -tokens.bubbleBorderWidth;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.translate(
          offset: Offset(0, footerLineYOffset),
          child: SizedBox(
            height: tokens.bubbleBorderWidth,
            width: double.infinity,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BottomLinePainter(
                  color: borderColor,
                  strokeWidth: isCollapsed
                      ? tokens.bubbleBorderWidth * 2
                      : tokens.bubbleBorderWidth,
                  dashed: isCollapsed,
                ),
              ),
            ),
          ),
        ),
        if (isTruncatable)
          Align(
            alignment: Alignment.centerLeft,
            child: _BubbleTruncationToggleButton(
              isCollapsed: isCollapsed,
              onToggleTruncation: onToggleTruncation,
              toggleButtonBackgroundColor: toggleButtonBackgroundColor,
              toggleButtonIconColor: toggleButtonIconColor,
              toggleButtonBorderSide: toggleButtonBorderSide,
            ),
          ),
      ],
    );
  }
}

class _BubbleTruncationToggleButton extends StatelessWidget {
  const _BubbleTruncationToggleButton({
    required this.isCollapsed,
    required this.onToggleTruncation,
    required this.toggleButtonBackgroundColor,
    required this.toggleButtonIconColor,
    required this.toggleButtonBorderSide,
  });

  final bool isCollapsed;
  final VoidCallback onToggleTruncation;
  final Color toggleButtonBackgroundColor;
  final Color toggleButtonIconColor;
  final BorderSide toggleButtonBorderSide;

  @override
  Widget build(BuildContext context) {
    final tokens = ChatSkin.tokens;
    return Tooltip(
      message: isCollapsed ? 'Show more' : 'Show less',
      child: SizedBox(
        width: tokens.collapseButtonDiameter,
        height: tokens.collapseButtonDiameter,
        child: Material(
          color: toggleButtonBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.collapseButtonRadius),
            side: toggleButtonBorderSide,
          ),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.collapseButtonRadius),
              side: toggleButtonBorderSide,
            ),
            onTap: () {
              Tooltip.dismissAllToolTips();
              onToggleTruncation();
            },
            child: Center(
              child: SizedBox(
                width: tokens.collapseButtonIconSize,
                height: tokens.collapseButtonIconSize,
                child: CustomPaint(
                  painter: _PlusMinusPainter(
                    isPlus: isCollapsed,
                    color: toggleButtonIconColor,
                    strokeWidth: tokens.collapseButtonStroke,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingDotsIndicator extends StatefulWidget {
  const _TypingDotsIndicator({required this.color, required this.dotDiameter});

  final Color color;
  final double dotDiameter;

  @override
  State<_TypingDotsIndicator> createState() => _TypingDotsIndicatorState();
}

class _TypingDotsIndicatorState extends State<_TypingDotsIndicator>
    with SingleTickerProviderStateMixin {
  ChatSkinTokens get _tokens => ChatSkin.tokens;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _tokens.typingIndicatorAnimationDuration,
  );
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotionPreference();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion) {
      return _buildDotsRow((_) => 0.0);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _buildDotsRow(_dotPulseStrength);
      },
    );
  }

  Widget _buildDotsRow(double Function(int index) strengthResolver) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int index = 0; index < 3; index++)
          Padding(
            padding: EdgeInsets.only(
              right: index < 2 ? _tokens.typingIndicatorDotGap : 0.0,
            ),
            child: _TypingDot(
              diameter: widget.dotDiameter,
              color: widget.color,
              strength: strengthResolver(index),
            ),
          ),
      ],
    );
  }

  void _syncMotionPreference() {
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion =
        mediaQuery?.disableAnimations == true ||
        mediaQuery?.accessibleNavigation == true ||
        WidgetsBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .disableAnimations;
    if (_reduceMotion != reduceMotion) {
      _reduceMotion = reduceMotion;
    }

    if (_reduceMotion) {
      _controller
        ..stop()
        ..value = 0.0;
      return;
    }

    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  double _dotPulseStrength(int index) {
    final shifted = (_controller.value - index / 3) % 1.0;
    final wave = 1.0 - ((shifted * 2.0) - 1.0).abs();
    return Curves.easeInOut.transform(wave.clamp(0.0, 1.0));
  }
}

class _TypingDot extends StatelessWidget {
  const _TypingDot({
    required this.diameter,
    required this.color,
    required this.strength,
  });

  final double diameter;
  final Color color;
  final double strength;

  @override
  Widget build(BuildContext context) {
    final tokens = ChatSkin.tokens;
    final scale =
        tokens.typingDotScaleBase + (tokens.typingDotScaleAmplitude * strength);
    final alpha =
        tokens.typingDotAlphaBase + (tokens.typingDotAlphaAmplitude * strength);
    return Transform.scale(
      scale: scale,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          color: color.withValues(alpha: alpha),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _PlusMinusPainter extends CustomPainter {
  const _PlusMinusPainter({
    required this.isPlus,
    required this.color,
    required this.strokeWidth,
  });

  final bool isPlus;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final halfLength = size.width * 0.35;

    canvas.drawLine(
      Offset(center.dx - halfLength, center.dy),
      Offset(center.dx + halfLength, center.dy),
      paint,
    );
    if (isPlus) {
      canvas.drawLine(
        Offset(center.dx, center.dy - halfLength),
        Offset(center.dx, center.dy + halfLength),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PlusMinusPainter oldDelegate) {
    return isPlus != oldDelegate.isPlus ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}

class _BottomLinePainter extends CustomPainter {
  const _BottomLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashed,
  });

  final Color color;
  final double strokeWidth;
  final bool dashed;

  static const double _dashWidth = 12.0;
  static const double _gapWidth = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (color.a == 0.0) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = dashed ? StrokeCap.butt : StrokeCap.square;
    final y = size.height / 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }

    final double width = size.width;
    if (width <= _dashWidth) {
      canvas.drawLine(Offset(0, y), Offset(width, y), paint);
      return;
    }

    final layout = _dashLayout(width);
    if (layout.dashCount <= 1) {
      canvas.drawLine(Offset(0, y), Offset(width, y), paint);
      return;
    }

    double x = 0.0;
    for (int index = 0; index < layout.dashCount; index++) {
      canvas.drawLine(Offset(x, y), Offset(x + _dashWidth, y), paint);
      x += _dashWidth + layout.gapWidth;
    }
  }

  ({int dashCount, double gapWidth}) _dashLayout(double width) {
    final double nominalSegmentWidth = _dashWidth + _gapWidth;
    final int maxDashCount = (width / _dashWidth).floor();
    final int dashCount = ((width + _gapWidth) / nominalSegmentWidth)
        .round()
        .clamp(1, maxDashCount)
        .toInt();
    if (dashCount <= 1) {
      return (dashCount: dashCount, gapWidth: 0.0);
    }

    final double totalDashWidth = dashCount * _dashWidth;
    return (
      dashCount: dashCount,
      gapWidth: (width - totalDashWidth) / (dashCount - 1),
    );
  }

  @visibleForTesting
  ({int dashCount, double gapWidth}) dashLayoutForTesting(double width) {
    return _dashLayout(width);
  }

  @override
  bool shouldRepaint(covariant _BottomLinePainter oldDelegate) {
    // _dashWidth and _gapWidth are static constants so they never change.
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashed != dashed;
  }
}
