import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart' hide GestureRecognizerFactory;
import 'package:tw_primitives/markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/config.dart';

class ChatMessageBubble extends StatefulWidget {
  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.selectionListenerNotifier,
    required this.isUser,
    required this.isTypingIndicator,
    required this.isTruncated,
    required this.isFirstMessage,
    required this.isLastMessage,
    required this.availableWidth,
    required this.onToggleTruncation,
  });

  final String text;
  final SelectionListenerNotifier selectionListenerNotifier;
  final bool isUser;
  final bool isTypingIndicator;
  final bool isTruncated;
  final bool isFirstMessage;
  final bool isLastMessage;
  final double availableWidth;
  final VoidCallback onToggleTruncation;

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
    required String text,
    required TextStyle style,
    required TextScaler textScaler,
    required double maxTextWidth,
  }) {
    final key = _MeasurementKey(
      text: text,
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

    final painter = TextPainter(
      text: TextSpan(text: _sanitizeTextForMeasurement(text), style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout(maxWidth: maxTextWidth);
    final lines = painter.computeLineMetrics();
    final layout = _RenderedTextLayout(
      lineCount: lines.length,
      lineHeight: painter.preferredLineHeight,
      contentWidth: painter.width,
    );
    painter.dispose();

    _lastMeasurementKey = key;
    _cachedLayout = layout;
    return layout;
  }

  String _sanitizeTextForMeasurement(String raw) {
    return ChatMessageMarkup.toPlainText(raw).trim();
  }

  _ParsedMarkupPayload _getParsedMarkup(String raw) {
    if (_cachedParsedMarkup != null && _lastParsedText == raw) {
      return _cachedParsedMarkup!;
    }

    final document = ChatMessageMarkup.parse(raw);
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
            .clamp(tokens.bubbleMinMaxWidth, widget.availableWidth);
    final bubbleMinWidth =
        (widget.availableWidth * ChatBubbleRules.minWidthFactor).clamp(
          0.0,
          bubbleMaxWidth,
        );
    final contentMaxWidth = widget.isUser
        ? bubbleMaxWidth
        : widget.availableWidth;
    final textMeasureHorizontalInset = widget.isUser
        ? horizontalInset * 2
        : tokens.composerTextInsetLeft + horizontalInset;
    final textScaler = MediaQuery.textScalerOf(context);
    final parsedMarkup = widget.isTypingIndicator
        ? null
        : _getParsedMarkup(widget.text);
    final measuredLayout = _getMeasuredLayout(
      text: parsedMarkup?.plainText ?? widget.text,
      style: bubbleTextStyle,
      textScaler: textScaler,
      maxTextWidth: (contentMaxWidth - textMeasureHorizontalInset).clamp(
        0.0,
        double.infinity,
      ),
    );
    final isTruncatable =
        measuredLayout.lineCount > ChatBubbleRules.collapsibleLineThreshold;
    final isCollapsed = isTruncatable && widget.isTruncated;
    final maxUserBubbleWidth = (bubbleMaxWidth - horizontalInset).clamp(
      bubbleMinWidth,
      bubbleMaxWidth,
    );
    final userBubbleWidth =
        (measuredLayout.contentWidth + textMeasureHorizontalInset).clamp(
          bubbleMinWidth,
          maxUserBubbleWidth,
        );
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
    final align = widget.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = widget.isUser
        ? ChatBubbleRules.userFill(context)
        : ChatBubbleRules.botFill(context);
    final borderColor = widget.isUser
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
                      width: contentMaxWidth,
                      child: Stack(
                        children: [
                          if (widget.isUser)
                            Padding(
                              padding: EdgeInsets.only(right: horizontalInset),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width: userBubbleWidth,
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
                                        ),
                                      ),
                                      if (showFooter) buildFooter(),
                                    ],
                                  ),
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
  }) {
    final skin = ChatSkin.dataOf(context);
    final colors = skin.colors;
    final tokens = skin.tokens;
    if (widget.isTypingIndicator) {
      return SelectionListener(
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
    return SelectionListener(
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

class _RenderedTextLayout {
  const _RenderedTextLayout({
    required this.lineCount,
    required this.lineHeight,
    required this.contentWidth,
  });

  final int lineCount;
  final double lineHeight;
  final double contentWidth;
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

  final ChatMarkupDocument document;
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
    final viewStyle = ChatMarkupViewStyle(
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
    );

    if (!isTruncated) {
      final Widget visibleMarkupLayer = ChatMarkupView(
        document: document,
        theme: markupTheme,
        gestureRecognizerFactory: gestureRecognizerFactory,
        style: viewStyle,
        selectable: false,
        chromeVisible: true,
        blockquoteRailColor: colors.bubbleText,
      );
      final Widget hiddenSelectionLayer = Positioned.fill(
        child: ChatMarkupView(
          document: document,
          theme: _transparentMarkupTheme(markupTheme),
          gestureRecognizerFactory: gestureRecognizerFactory,
          style: viewStyle,
          selectable: true,
          chromeVisible: false,
          blockquoteRailColor: colors.transparent,
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
          document: document,
          theme: _transparentMarkupTheme(markupTheme),
          maxWidth: constraints.maxWidth,
          selectable: true,
          chromeVisible: false,
          viewStyle: viewStyle,
          blockquoteRailColor: colors.transparent,
        );
        final Widget visibleMarkupLayer = _buildTruncatedMarkupLayer(
          document: document,
          theme: markupTheme,
          maxWidth: constraints.maxWidth,
          selectable: false,
          chromeVisible: true,
          viewStyle: viewStyle,
          blockquoteRailColor: colors.bubbleText,
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
    final skin = ChatSkin.dataOf(context);
    final colors = skin.colors;
    final tokens = skin.tokens;
    final textStyles = skin.textStyles;
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

  Widget _buildTruncatedMarkupLayer({
    required ChatMarkupDocument document,
    required ChatMarkupTheme theme,
    required double maxWidth,
    required bool selectable,
    required bool chromeVisible,
    required ChatMarkupViewStyle viewStyle,
    required Color blockquoteRailColor,
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
            child: ChatMarkupView(
              document: document,
              theme: theme,
              gestureRecognizerFactory: gestureRecognizerFactory,
              style: viewStyle,
              selectable: selectable,
              chromeVisible: chromeVisible,
              blockquoteRailColor: blockquoteRailColor,
            ),
          ),
        ),
      ),
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
        ? tokens.bubbleBorderWidth * 1.4 // Nudge down do that the dashed line does not appear to coincide with bubble shadow when truncated
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
            onTap: onToggleTruncation,
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
