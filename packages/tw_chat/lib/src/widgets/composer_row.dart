import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/config.dart';

class ChatComposerRow extends StatefulWidget {
  const ChatComposerRow({
    super.key,
    required this.controller,
    required this.inputFocusNode,
    required this.inputScroll,
    required this.showInputScrollbarTrack,
    required this.minInputHeight,
    required this.maxInputHeight,
    required this.sendButtonMinWidth,
    required this.isAwaitingResponse,
    required this.onSubmit,
    required this.onStop,
    this.onMeasuredHeight,
  });

  final TextEditingController controller;
  final FocusNode inputFocusNode;
  final ScrollController inputScroll;
  final bool showInputScrollbarTrack;
  final double minInputHeight;
  final double maxInputHeight;
  final double sendButtonMinWidth;
  final bool isAwaitingResponse;
  final VoidCallback onSubmit;
  final VoidCallback onStop;
  final ValueChanged<double>? onMeasuredHeight;

  @override
  State<ChatComposerRow> createState() => _ChatComposerRowState();
}

class _ChatComposerRowState extends State<ChatComposerRow> {
  final GlobalKey _inputShellKey = GlobalKey();
  bool _heightSyncScheduled = false;
  double _actionHeight = 0.0;

  bool get _useNativeMobileWebSelectionControls {
    if (!kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_scheduleHeightSync);
    _scheduleHeightSync();
  }

  @override
  void didUpdateWidget(covariant ChatComposerRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_scheduleHeightSync);
      widget.controller.addListener(_scheduleHeightSync);
    }
    if (oldWidget.minInputHeight != widget.minInputHeight ||
        oldWidget.maxInputHeight != widget.maxInputHeight) {
      _scheduleHeightSync();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scheduleHeightSync);
    super.dispose();
  }

  void _scheduleHeightSync() {
    if (_heightSyncScheduled) {
      return;
    }
    _heightSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _heightSyncScheduled = false;
      if (!mounted) {
        return;
      }
      final inputContext = _inputShellKey.currentContext;
      if (inputContext == null) {
        return;
      }
      final renderObject = inputContext.findRenderObject();
      if (renderObject is! RenderBox) {
        return;
      }

      final measuredHeight = renderObject.size.height.clamp(
        widget.minInputHeight,
        widget.maxInputHeight,
      );
      if ((_actionHeight - measuredHeight).abs() <= 0.5) {
        return;
      }
      setState(() {
        _actionHeight = measuredHeight;
      });
      widget.onMeasuredHeight?.call(measuredHeight);
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleHeightSync();
    final skin = ChatSkin.dataOf(context);
    final colors = skin.colors;
    final tokens = skin.tokens;

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final composerTextStyle = ChatBubbleRules.textStyle(context, textScale);
    final composerHintStyle = ChatComposerLayout.hintStyle(context, textScale);
    final composerButtonTooltip = widget.isAwaitingResponse
        ? 'Stop response'
        : 'Send message';
    final composerButtonIcon = widget.isAwaitingResponse
        ? Icons.stop_rounded
        : Icons.send_rounded;
    final inputScrollbarThickness = tokens.scrollbarThickness;
    final inputScrollbarCrossAxisInset =
        tokens.composerScrollbarReservedWidth > inputScrollbarThickness
        ? (tokens.composerScrollbarReservedWidth - inputScrollbarThickness) / 2
        : 0.0;
    final inputScrollbarPadding = _useNativeMobileWebSelectionControls
        ? EdgeInsets.zero
        : EdgeInsets.only(
            bottom: -tokens.composerInputTextInsetTopBottom,
          );
    final actionHeight =
        (_actionHeight > 0 ? _actionHeight : widget.minInputHeight).clamp(
          widget.minInputHeight,
          widget.maxInputHeight,
        );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: widget.minInputHeight,
        maxHeight: widget.maxInputHeight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: CustomPaint(
              foregroundPainter: _CornerAccentPainter(
                color: ChatComposerLayout.cornerAccentColor(context),
                radius: tokens.composerCornerAccentRadius,
                strokeWidth: tokens.composerCornerAccentStroke,
                segmentLength: tokens.composerCornerAccentSegment,
              ),
              child: Container(
                key: _inputShellKey,
                decoration: BoxDecoration(
                  color: ChatComposerLayout.fillColor(context),
                  borderRadius: BorderRadius.circular(tokens.composerRadius),
                  border: Border.all(
                    color: ChatComposerLayout.borderColor(context),
                  ),
                  boxShadow: [tokens.surfaceShadow(colors)],
                ),
                constraints: BoxConstraints(
                  minHeight: widget.minInputHeight,
                  maxHeight: widget.maxInputHeight,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(tokens.composerRadius),
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      if (widget.showInputScrollbarTrack)
                        ChatScrollbar.buildTrack(
                          context: context,
                          thickness: inputScrollbarThickness,
                          crossAxisInset: inputScrollbarCrossAxisInset,
                        ),
                      ChatFadingScrollbar(
                        controller: widget.inputScroll,
                        thumbVisibility: true,
                        trackVisibility: false,
                        interactive: !_useNativeMobileWebSelectionControls,
                        thickness: inputScrollbarThickness,
                        minThumbLength: tokens.scrollbarMinThumbLength,
                        mainAxisMargin: 0,
                        crossAxisMargin:
                            inputScrollbarCrossAxisInset +
                            tokens.scrollbarThumbCrossAxisMargin,
                        padding: inputScrollbarPadding,
                        radius: tokens.scrollbarRadius,
                        child: ScrollConfiguration(
                          behavior: const ChatNoScrollbarBehavior(),
                          child: TextField(
                            controller: widget.controller,
                            focusNode: widget.inputFocusNode,
                            scrollController: widget.inputScroll,
                            selectionControls:
                                _useNativeMobileWebSelectionControls
                                ? null
                                : materialTextSelectionControls,
                            style: composerTextStyle,
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor: ChatComposerLayout.cursorColor(context),
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            minLines: 1,
                            maxLines: null,
                            autofocus: true,
                            decoration: InputDecoration(
                              isCollapsed: true,
                              constraints: BoxConstraints(
                                minHeight: widget.minInputHeight,
                                maxHeight: widget.maxInputHeight,
                              ),
                              border: InputBorder.none,
                              hintText: 'Ask me anything...',
                              hintStyle: composerHintStyle,
                              contentPadding: EdgeInsets.fromLTRB(
                                tokens.composerTextInsetLeft,
                                tokens.composerInputTextInsetTop,
                                tokens.composerTextInsetRight +
                                    tokens.composerScrollbarReservedWidth,
                                tokens.composerInputTextInsetTopBottom,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.sendButtonMinWidth,
              minHeight: actionHeight,
              maxHeight: actionHeight,
            ),
            child: Material(
              color: colors.transparent,
              child: Tooltip(
                message: composerButtonTooltip,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    tokens.composerSendButtonRadius,
                  ),
                  onTap: widget.isAwaitingResponse
                      ? widget.onStop
                      : widget.onSubmit,
                  child: Center(
                    child: Icon(
                      composerButtonIcon,
                      size: tokens.composerSendIconSize,
                      color: ChatComposerLayout.sendIconColor(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerAccentPainter extends CustomPainter {
  const _CornerAccentPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.segmentLength,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double segmentLength;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    final left = rect.left;
    final right = rect.right;
    final top = rect.top;
    final bottom = rect.bottom;

    final path = Path()
      ..moveTo(left + radius, top)
      ..lineTo(left + radius + segmentLength, top)
      ..moveTo(left, top + radius)
      ..lineTo(left, top + radius + segmentLength)
      ..moveTo(right - radius - segmentLength, top)
      ..lineTo(right - radius, top)
      ..moveTo(right, top + radius)
      ..lineTo(right, top + radius + segmentLength)
      ..moveTo(left + radius, bottom)
      ..lineTo(left + radius + segmentLength, bottom)
      ..moveTo(left, bottom - radius)
      ..lineTo(left, bottom - radius - segmentLength)
      ..moveTo(right - radius - segmentLength, bottom)
      ..lineTo(right - radius, bottom)
      ..moveTo(right, bottom - radius)
      ..lineTo(right, bottom - radius - segmentLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerAccentPainter oldDelegate) {
    return color != oldDelegate.color ||
        radius != oldDelegate.radius ||
        strokeWidth != oldDelegate.strokeWidth ||
        segmentLength != oldDelegate.segmentLength;
  }
}
