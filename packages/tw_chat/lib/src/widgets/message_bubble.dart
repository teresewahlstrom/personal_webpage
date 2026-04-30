import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart' hide GestureRecognizerFactory;
import 'package:url_launcher/url_launcher.dart';

import '../config/config.dart';
import '../logic/message_markup.dart';
import 'message_bubble_markup_renderer.dart' as bubble_markup_renderer;

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
    this.onOpenLink,
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
  final void Function(Uri uri)? onOpenLink;

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  String? _lastParsedText;
  _ParsedMarkupPayload? _cachedParsedMarkup;
  String? _lastMeasuredText;
  double? _lastMeasuredMaxTextWidth;
  double? _lastMeasuredFontSize;
  double? _lastMeasuredLineHeight;
  String? _lastMeasuredFontFamily;
  FontWeight? _lastMeasuredFontWeight;
  double? _lastMeasuredLetterSpacing;
  double? _lastMeasuredTextScale;
  _RenderedTextLayout? _cachedLayout;
  final Map<String, TapGestureRecognizer> _linkTextRecognizersByHref =
      <String, TapGestureRecognizer>{};

  static bool _sameDouble(double? left, double? right) {
    if (left == null || right == null) {
      return left == right;
    }
    return (left - right).abs() <= 0.01;
  }

  _RenderedTextLayout _getMeasuredLayout({
    required String text,
    required TextStyle style,
    required TextScaler textScaler,
    required double maxTextWidth,
  }) {
    final fontSize = style.fontSize;
    final lineHeight = style.height;
    final fontFamily = style.fontFamily;
    final fontWeight = style.fontWeight;
    final letterSpacing = style.letterSpacing;
    final textScale = textScaler.scale(1.0);

    if (_cachedLayout != null &&
        _lastMeasuredText == text &&
        _sameDouble(_lastMeasuredMaxTextWidth, maxTextWidth) &&
        _sameDouble(_lastMeasuredFontSize, fontSize) &&
        _sameDouble(_lastMeasuredLineHeight, lineHeight) &&
        _lastMeasuredFontFamily == fontFamily &&
        _lastMeasuredFontWeight == fontWeight &&
        _sameDouble(_lastMeasuredLetterSpacing, letterSpacing) &&
        _sameDouble(_lastMeasuredTextScale, textScale)) {
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
    );

    _lastMeasuredText = text;
    _lastMeasuredMaxTextWidth = maxTextWidth;
    _lastMeasuredFontSize = fontSize;
    _lastMeasuredLineHeight = lineHeight;
    _lastMeasuredFontFamily = fontFamily;
    _lastMeasuredFontWeight = fontWeight;
    _lastMeasuredLetterSpacing = letterSpacing;
    _lastMeasuredTextScale = textScale;
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
        (widget.availableWidth * ChatBubbleRules.minWidthFactor)
            .clamp(0.0, bubbleMaxWidth);
    final textScaler = MediaQuery.textScalerOf(context);
    final parsedMarkup = widget.isTypingIndicator
        ? null
        : _getParsedMarkup(widget.text);
    final measuredLayout = _getMeasuredLayout(
      text: parsedMarkup?.plainText ?? widget.text,
      style: bubbleTextStyle,
      textScaler: textScaler,
      maxTextWidth: (bubbleMaxWidth - horizontalInset * 2).clamp(
        0.0,
        double.infinity,
      ),
    );
    final isTruncatable =
        measuredLayout.lineCount > ChatBubbleRules.collapsibleLineThreshold;
    final truncatedContentHeight =
        measuredLayout.lineHeight * ChatBubbleRules.collapsedVisibleLines;
    final bubbleTopMargin = widget.isFirstMessage
        ? 0.0
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
      : colors.shellBackgroundStart;
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
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        widget.isUser ? horizontalInset : 0.0,
                        verticalInset,
                        horizontalInset,
                        (isTruncatable && widget.isTruncated) ? 0.0 : verticalInset,
                      ),
                      constraints: widget.isUser
                          ? BoxConstraints(
                              minWidth: bubbleMinWidth,
                              maxWidth: bubbleMaxWidth,
                            )
                          : null,
                      decoration: widget.isUser
                          ? BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.circular(
                                tokens.bubbleRadius,
                              ),
                              border: (isTruncatable && widget.isTruncated)
                                  ? Border(
                                      top: bubbleBorderSide,
                                      left: bubbleBorderSide,
                                      right: bubbleBorderSide,
                                    )
                                  : Border.fromBorderSide(bubbleBorderSide),
                              boxShadow: [tokens.surfaceShadow(colors)],
                            )
                          : null,
                      child: _buildBubbleText(
                        parsedMarkup,
                        style: bubbleTextStyle,
                        bubbleColor: bubbleColor,
                        isUserBubble: widget.isUser,
                        truncatedContentHeight: truncatedContentHeight,
                        isTruncated: isTruncatable && widget.isTruncated,
                      ),
                    ),
                    if (isTruncatable && widget.isTruncated)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 1.0,
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _DashedLinePainter(
                              color: colors.composerCornerAccent,
                              strokeWidth: 0.25,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isTruncatable)
                Positioned(
                  left:
                      tokens.collapseButtonRightInset +
                      collapseButtonOverflowLeft,
                  bottom: 0,
                  child: Tooltip(
                    message: widget.isTruncated ? 'Show more' : 'Show less',
                    child: SizedBox(
                      width: tokens.collapseButtonDiameter,
                      height: tokens.collapseButtonDiameter,
                      child: Material(
                        color: toggleButtonBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            tokens.collapseButtonRadius,
                          ),
                          side: toggleButtonBorderSide,
                        ),
                        child: InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              tokens.collapseButtonRadius,
                            ),
                            side: toggleButtonBorderSide,
                          ),
                          onTap: widget.onToggleTruncation,
                          child: Center(
                            child: SizedBox(
                              width: tokens.collapseButtonIconSize,
                              height: tokens.collapseButtonIconSize,
                              child: CustomPaint(
                                painter: _PlusMinusPainter(
                                  isPlus: widget.isTruncated,
                                  color: toggleButtonIconColor,
                                  strokeWidth: tokens.collapseButtonStroke,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
      child: bubble_markup_renderer.MessageBubbleMarkupRenderer(
        document: parsedMarkup!.document,
        style: style,
        bubbleColor: bubbleColor,
        isUserBubble: isUserBubble,
        truncatedContentHeight: truncatedContentHeight,
        isTruncated: isTruncated,
        gestureRecognizerFactory: _createLinkRecognizer,
      ),
    );
  }

  Future<void> _launchMarkdownLink(String href) async {
    final uri = _normalizeLink(href);
    if (uri == null) {
      return;
    }
    final onOpenLink = widget.onOpenLink;
    if (onOpenLink != null) {
      onOpenLink(uri);
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
  });

  final int lineCount;
  final double lineHeight;
}

class _ParsedMarkupPayload {
  const _ParsedMarkupPayload({required this.document, required this.plainText});

  final ChatMarkupDocument document;
  final String plainText;
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

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  static const double _dashWidth = 12.0;
  static const double _gapWidth = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (color.a == 0.0) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;
    final y = size.height / 2;
    double x = 0;
    while (x < size.width) {
      final end = (x + _dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += _dashWidth + _gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    // _dashWidth and _gapWidth are static constants so they never change.
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
