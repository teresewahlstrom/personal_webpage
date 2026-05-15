import 'package:attributed_text/attributed_text.dart';
import 'package:flutter/material.dart';
import 'package:super_text_layout/super_text_layout.dart' show CaretStyle;
import 'package:tw_primitives/src/scrollbar/scroll_area.dart';
import 'package:tw_primitives/src/scrollbar/tw_scrollbar.dart';
import 'package:tw_primitives/src/text_field/infrastructure/attributed_text_styles.dart' show AttributionStyleBuilder;
import 'package:tw_primitives/src/text_field/tw_textfield/tw_textfield.dart';

/// Beginner-friendly controller for [TwReadyTextField].
///
/// Exposes plain-text and selection APIs while wrapping the richer attributed
/// editing controller internally.
class TwReadyTextController extends ChangeNotifier {
  TwReadyTextController({String text = ''})
    : _raw = AttributedTextEditingController(text: AttributedText(text)) {
    _raw.addListener(_handleRawChange);
  }

  final AttributedTextEditingController _raw;

  String get text => _raw.text.toPlainText();

  set text(String value) {
    _raw.text = AttributedText(value);
  }

  TextSelection get selection => _raw.selection;

  set selection(TextSelection value) {
    _raw.selection = value;
  }

  bool get isEmpty => text.isEmpty;

  bool get isBlank => text.trim().isEmpty;

  void clear() {
    text = '';
    selection = const TextSelection.collapsed(offset: 0);
  }

  AttributedTextEditingController get raw => _raw;

  @override
  void dispose() {
    _raw.removeListener(_handleRawChange);
    _raw.dispose();
    super.dispose();
  }

  void _handleRawChange() {
    notifyListeners();
  }
}

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
    this.displayHintUntilTextEntered = false,
    this.hintBuilder,
    this.hintText,
    this.hintTextStyle,
    this.controlsColor,
    this.caretColor,
    this.caretWidth,
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

  final TwReadyTextController? controller;
  final String initialText;
  final ValueChanged<String>? onTextChanged;
  final FocusNode? focusNode;
  final ScrollController? scrollController;
  final TextAlign? textAlign;
  final AttributionStyleBuilder textStyleBuilder;
  final bool displayHintUntilTextEntered;
  final WidgetBuilder? hintBuilder;
  final String? hintText;
  final TextStyle? hintTextStyle;
  final Color? controlsColor;
  final Color? caretColor;
  final double? caretWidth;
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
  late final TwReadyTextController _ownedController;
  late final ScrollController _ownedScrollController;

  TwReadyTextController get _textController =>
      widget.controller ?? _ownedController;

  bool get _ownsTextController => widget.controller == null;

  ScrollController get _scrollController =>
      widget.scrollController ?? _ownedScrollController;

  bool get _ownsScrollController => widget.scrollController == null;

  @override
  void initState() {
    super.initState();
    _ownedController = TwReadyTextController(text: widget.initialText);
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
    final hintBehavior = widget.displayHintUntilTextEntered
        ? HintBehavior.displayHintUntilTextEntered
        : HintBehavior.displayHintUntilFocus;
    final resolvedCaretStyle = _resolveCaretStyle();
    final textField = TwTextField(
      scrollController: _scrollController,
      focusNode: widget.focusNode,
      textController: _textController.raw,
      textAlign: widget.textAlign,
      textStyleBuilder: widget.textStyleBuilder,
      hintBehavior: hintBehavior,
      hintBuilder: resolvedHintBuilder,
      controlsColor: widget.controlsColor,
      caretStyle: resolvedCaretStyle,
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
    widget.onTextChanged?.call(_textController.text);
  }

  CaretStyle? _resolveCaretStyle() {
    if (widget.caretColor == null && widget.caretWidth == null) {
      return null;
    }
    return CaretStyle(
      color: widget.caretColor ?? widget.controlsColor ?? Colors.black,
      width: widget.caretWidth ?? 1,
    );
  }
}