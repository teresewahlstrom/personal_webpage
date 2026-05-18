import 'package:flutter/material.dart';
import 'package:tw_primitives/composer.dart'
    show TwComposer, TwComposerSkin;
import 'package:tw_primitives/text_field.dart'
    show TwReadyTextController, TwReadyTextField;

import '../config/config.dart';

class ChatComposerRow extends StatefulWidget {
  const ChatComposerRow({
    super.key,
    required this.controller,
    required this.inputFocusNode,
    required this.minInputHeight,
    required this.maxInputHeight,
    required this.sendButtonMinWidth,
    required this.isAwaitingResponse,
    required this.onSubmit,
    required this.onStop,
    this.onMeasuredHeight,
  });

  final TwReadyTextController controller;
  final FocusNode inputFocusNode;
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
    final actionHeight =
        (_actionHeight > 0 ? _actionHeight : widget.minInputHeight).clamp(
          widget.minInputHeight,
          widget.maxInputHeight,
        );

    final inputField = TwReadyTextField(
      controller: widget.controller,
      focusNode: widget.inputFocusNode,
      thumbColor: ChatScrollbar.thumbColor(context),
      thumbInactiveColor: ChatScrollbar.thumbInactiveColor(context),
      trackColor: ChatScrollbar.trackColor(context),
      thickness: tokens.composerScrollbarThickness,
      minThumbLength: tokens.scrollbarMinThumbLength,
      crossAxisMargin: tokens.composerScrollbarCrossAxisMargin,
      mainAxisMargin: 0,
      radius: tokens.scrollbarRadius,
      thumbVisibility: true,
      interactive: true,
      trackVisibility: false,
      textStyleBuilder: (_) => composerTextStyle,
      displayHintUntilTextEntered: true,
      hintBuilder: (context) =>
          Text('Ask me anything...', style: composerHintStyle),
      minLines: 1,
      maxLines: null,
      padding: EdgeInsets.fromLTRB(
        tokens.composerTextInsetLeft + 2.0,
        tokens.composerInputTextInsetTop,
        tokens.composerTextInsetRight + 2.0,
        tokens.composerInputTextInsetTopBottom,
      ),
      controlsColor: ChatComposerLayout.cursorColor(context),
      caretColor: ChatComposerLayout.cursorColor(context),
      caretWidth: tokens.composerCaretWidth,
      handlesRadius: tokens.composerHandleRadius,
    );

    return TwComposer(
      skin: TwComposerSkin(
        fillColor: ChatComposerLayout.fillColor(context),
        outlineColor: ChatComposerLayout.borderColor(context),
        accentColor: ChatComposerLayout.cornerAccentColor(context),
        outlineWidth: tokens.shellOuterBorderWidth,
        cornerStrokeWidth: tokens.composerCornerAccentStroke,
      ),
      textField: inputField,
      inputShellKey: _inputShellKey,
      minInputHeight: widget.minInputHeight,
      maxInputHeight: widget.maxInputHeight,
      sendButtonMinWidth: widget.sendButtonMinWidth,
      sendButtonHeight: actionHeight,
      sendButtonIcon: composerButtonIcon,
      sendButtonTooltip: composerButtonTooltip,
      onSendPressed:
          widget.isAwaitingResponse ? widget.onStop : widget.onSubmit,
      shellRadius: tokens.composerRadius,
      cornerRadius: tokens.composerCornerAccentRadius,
      cornerSegmentLength: tokens.composerCornerAccentSegment,
      sendButtonRadius: tokens.composerSendButtonRadius,
      sendIconSize: tokens.composerSendIconSize,
      boxShadow: [tokens.surfaceShadow(colors)],
    );
  }
}
