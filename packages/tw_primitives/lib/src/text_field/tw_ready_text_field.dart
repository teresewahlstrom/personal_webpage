import 'package:attributed_text/attributed_text.dart';
import 'package:flutter/material.dart';
import 'package:super_text_layout/super_text_layout.dart' show CaretStyle;
import 'package:tw_primitives/src/scrollbar/scroll_area.dart';
import 'package:tw_primitives/src/scrollbar/tw_scrollbar.dart';
import 'package:tw_primitives/src/text_field/infrastructure/attributed_text_styles.dart' show AttributionStyleBuilder;
import 'package:tw_primitives/src/text_field/tw_textfield/tw_textfield.dart';

/// A ready-to-use text input that wires [TwTextField] with [TwScrollArea].
///
/// This widget is intended as the default entry point for callers that want
/// a complete text input without manually composing a text field and scrollbar.
class TwReadyTextField extends StatefulWidget {
  const TwReadyTextField({
    super.key,
    this.controller,
    this.initialText = '',
    this.onTextChanged,
    this.focusNode,
    this.scrollController,
    this.textAlign,
    this.textStyleBuilder = defaultTextFieldStyleBuilder,
    this.hintBehavior = HintBehavior.displayHintUntilFocus,
    this.hintBuilder,
    this.hintText,
    this.hintTextStyle,
    this.controlsColor,
    this.caretStyle,
    this.handlesRadius,
    this.selectionColor,
    this.minLines = 1,
    this.maxLines,
    this.lineHeight,
    this.padding,
    this.showScrollbar = true,
    this.hideSystemScrollbars = true,
    this.thumbColor = TwScrollbarDefaults.thumbColor,
    this.thumbInactiveColor = TwScrollbarDefaults.thumbInactiveColor,
    this.trackColor = TwScrollbarDefaults.trackColor,
    this.thickness = TwScrollbarDefaults.thickness,
    this.minThumbLength = TwScrollbarDefaults.minThumbLength,
    this.crossAxisMargin = TwScrollbarDefaults.crossAxisMargin,
    this.mainAxisMargin = TwScrollbarDefaults.mainAxisMargin,
    this.radius = TwScrollbarDefaults.radius,
    this.thumbVisibility = true,
    this.interactive = true,
    this.trackVisibility = false,
    this.fadeDuration = TwScrollbarDefaults.thumbFadeDuration,
    this.timeToFade = TwScrollbarDefaults.thumbFadeOutDelay,
    this.scrollPhysics = const ClampingScrollPhysics(),
  });

  final AttributedTextEditingController? controller;
  final String initialText;
  final ValueChanged<String>? onTextChanged;
  final FocusNode? focusNode;
  final ScrollController? scrollController;
  final TextAlign? textAlign;
  final AttributionStyleBuilder textStyleBuilder;
  final HintBehavior hintBehavior;
  final WidgetBuilder? hintBuilder;
  final String? hintText;
  final TextStyle? hintTextStyle;
  final Color? controlsColor;
  final CaretStyle? caretStyle;
  final double? handlesRadius;
  final Color? selectionColor;
  final int? minLines;
  final int? maxLines;
  final double? lineHeight;
  final EdgeInsets? padding;

  final bool showScrollbar;
  final bool hideSystemScrollbars;
  final Color thumbColor;
  final Color thumbInactiveColor;
  final Color trackColor;
  final double thickness;
  final double minThumbLength;
  final double crossAxisMargin;
  final double mainAxisMargin;
  final Radius radius;
  final bool thumbVisibility;
  final bool interactive;
  final bool trackVisibility;
  final Duration fadeDuration;
  final Duration timeToFade;
  final ScrollPhysics scrollPhysics;

  @override
  State<TwReadyTextField> createState() => _TwReadyTextFieldState();
}

class _TwReadyTextFieldState extends State<TwReadyTextField> {
  late final AttributedTextEditingController _ownedController;
  late final ScrollController _ownedScrollController;

  AttributedTextEditingController get _textController =>
      widget.controller ?? _ownedController;

  bool get _ownsTextController => widget.controller == null;

  ScrollController get _scrollController =>
      widget.scrollController ?? _ownedScrollController;

  bool get _ownsScrollController => widget.scrollController == null;

  @override
  void initState() {
    super.initState();
    _ownedController = AttributedTextEditingController(
      text: AttributedText(widget.initialText),
    );
    _ownedScrollController = ScrollController();
    _textController.addListener(_notifyTextChanged);
  }

  @override
  void didUpdateWidget(covariant TwReadyTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final previousController = oldWidget.controller ?? _ownedController;
      previousController.removeListener(_notifyTextChanged);
      _textController.addListener(_notifyTextChanged);
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_notifyTextChanged);
    if (_ownsTextController) {
      _ownedController.dispose();
    }
    if (_ownsScrollController) {
      _ownedScrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedHintBuilder = _resolveHintBuilder();
    final textField = TwTextField(
      scrollController: _scrollController,
      focusNode: widget.focusNode,
      textController: _textController,
      textAlign: widget.textAlign,
      textStyleBuilder: widget.textStyleBuilder,
      hintBehavior: widget.hintBehavior,
      hintBuilder: resolvedHintBuilder,
      controlsColor: widget.controlsColor,
      caretStyle: widget.caretStyle,
      handlesRadius: widget.handlesRadius,
      selectionColor: widget.selectionColor,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      lineHeight: widget.lineHeight,
      padding: widget.padding,
    );

    if (!widget.showScrollbar) {
      if (!widget.hideSystemScrollbars) {
        return textField;
      }
      return ScrollConfiguration(
        behavior: const TwNoScrollbarBehavior(),
        child: textField,
      );
    }

    return TwScrollArea(
      controller: _scrollController,
      hideSystemScrollbars: widget.hideSystemScrollbars,
      thumbColor: widget.thumbColor,
      thumbInactiveColor: widget.thumbInactiveColor,
      trackColor: widget.trackColor,
      thickness: widget.thickness,
      minThumbLength: widget.minThumbLength,
      crossAxisMargin: widget.crossAxisMargin,
      mainAxisMargin: widget.mainAxisMargin,
      radius: widget.radius,
      physics: widget.scrollPhysics,
      thumbVisibility: widget.thumbVisibility,
      interactive: widget.interactive,
      trackVisibility: widget.trackVisibility,
      fadeDuration: widget.fadeDuration,
      timeToFade: widget.timeToFade,
      child: textField,
    );
  }

  WidgetBuilder? _resolveHintBuilder() {
    if (widget.hintBuilder != null) {
      return widget.hintBuilder;
    }
    final hintText = widget.hintText;
    if (hintText == null || hintText.isEmpty) {
      return null;
    }
    return (context) => Text(hintText, style: widget.hintTextStyle);
  }

  void _notifyTextChanged() {
    widget.onTextChanged?.call(_textController.text.toPlainText());
  }
}