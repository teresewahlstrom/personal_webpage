// Portions of this text-field subtree are derived from super_editor.
// See packages/tw_primitives/THIRD_PARTY_NOTICES.md for attribution and license details.
import 'package:attributed_text/attributed_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tw_primitives/src/text_field/infrastructure/attributed_text_styles.dart';
import 'package:tw_primitives/src/text_field/infrastructure/ime_input_owner.dart';
import 'package:tw_primitives/src/text_field/infrastructure/platforms/android/selection_handles.dart';
import 'package:tw_primitives/src/text_field/tw_textfield/android/android_textfield.dart';
import 'package:tw_primitives/src/text_field/tw_textfield/desktop/desktop_textfield.dart';
import 'package:tw_primitives/src/text_field/tw_textfield/infrastructure/attributed_text_editing_controller.dart';
import 'package:tw_primitives/src/text_field/tw_textfield/infrastructure/hint_text.dart';
import 'package:tw_primitives/src/text_field/tw_textfield/infrastructure/text_field_gestures_interaction_overrides.dart';
import 'package:tw_primitives/src/text_field/tw_textfield/input_method_engine/_ime_text_editing_controller.dart';
import 'package:tw_primitives/src/text_field/tw_textfield/ios/ios_textfield.dart';
import 'package:tw_primitives/src/text_field/infrastructure/text_input.dart';
import 'package:super_text_layout/super_text_layout.dart';

import 'styles.dart';

export 'android/android_textfield.dart';
export 'desktop/desktop_textfield.dart';
export 'infrastructure/attributed_text_editing_controller.dart';
export 'infrastructure/hint_text.dart';
export 'infrastructure/magnifier.dart';
export 'infrastructure/text_scrollview.dart';
export 'infrastructure/text_field_gestures_interaction_overrides.dart';
export 'infrastructure/text_field_tap_handlers.dart';
export 'input_method_engine/_ime_text_editing_controller.dart';
export 'ios/ios_textfield.dart';
export 'styles.dart';
export 'tw_textfield_context.dart';

/// Custom text field implementations that offer greater control than traditional
/// Flutter text fields.
///
/// For example, the custom text fields in this package use [AttributedText]
/// instead of regular `String`s or `InlineSpan`s, which makes it easier to style
/// text and edit other text metadata.

export "tw_text_field_keys.dart";

/// Text field that supports styled text.
///
/// [TwTextField] adapts to the expectations of the current platform, or
/// conforms to a specified [configuration].
///
///  - desktop uses a blinking cursor and mouse gestures
///  - Android uses draggable handles in the Android style
///  - iOS uses draggable handles in the iOS style
///
/// [TwTextField] is built on top of platform-specific text field implementations,
/// which may offer additional customization beyond that of [TwTextField]:
///
///  - [TwDesktopTextField], configured for a typical desktop experience.
///  - [TwAndroidTextField], configured for a typical Android experience.
///  - [TwIOSTextField], configured for a typical iOS experience.
class TwTextField extends StatefulWidget {
  const TwTextField({
    Key? key,
    this.focusNode,
    this.tapRegionGroupId,
    this.configuration,
    this.textController,
    this.textAlign,
    this.textStyleBuilder = defaultTextFieldStyleBuilder,
    this.inlineWidgetBuilders = const [],
    this.hintBehavior = HintBehavior.displayHintUntilFocus,
    this.hintBuilder,
    this.controlsColor,
    this.caretStyle,
    this.handlesRadius,
    this.blinkTimingMode = BlinkTimingMode.ticker,
    this.selectionColor,
    this.minLines,
    this.maxLines = 1,
    this.lineHeight,
    this.inputSource,
    this.keyboardHandlers,
    this.selectorHandlers,
    this.tapHandlers = const [],
    this.padding,
    this.imeConfiguration,
    this.showComposingUnderline,
    this.scrollController,
  }) : super(key: key);

  final FocusNode? focusNode;

  /// {@template super_text_field_tap_region_group_id}
  /// An optional group ID for a tap region that surrounds this text field
  /// and also surrounds any related widgets, such as drag handles and a toolbar.
  /// {@endtemplate}
  final String? tapRegionGroupId;

  /// The platform-style configuration for this text field, or `null` to
  /// automatically configure for the current platform.
  final TwTextFieldPlatformConfiguration? configuration;

  /// Controller that holds the current text and selection for this field,
  /// similar to a standard Flutter `TextEditingController`.
  final AttributedTextEditingController? textController;

  /// The alignment of the text in this text field.
  ///
  /// If `null`, the text alignment is determined by the text direction
  /// of the content.
  final TextAlign? textAlign;

  /// Text style factory that creates styles for the content in
  /// [textController] based on the attributions in that content.
  final AttributionStyleBuilder textStyleBuilder;

  /// {@template super_text_field_inline_widget_builders}
  /// A Chain of Responsibility that's used to build inline widgets.
  ///
  /// The first builder in the chain to return a non-null `Widget` will be
  /// used for a given inline placeholder.
  /// {@endtemplate}
  final InlineWidgetBuilderChain inlineWidgetBuilders;

  /// Policy for when the hint should be displayed.
  final HintBehavior hintBehavior;

  /// Builder that creates the hint widget, when a hint is displayed.
  ///
  /// To easily build a hint with styled text, see [StyledHintBuilder].
  final WidgetBuilder? hintBuilder;

  /// The color of the caret, drag handles, and other controls.
  ///
  /// The color in [caretStyle] overrides the [controlsColor].
  final Color? controlsColor;

  /// The visual representation of the caret.
  ///
  /// The color in [caretStyle] overrides the [controlsColor].
  final CaretStyle? caretStyle;

  /// The radius of drag handles in logical pixels.
  ///
  /// For Android, this controls the [AndroidSelectionHandle.radius].
  /// For iOS, this controls the ball radius on [IOSSelectionHandle].
  /// When `null`, platform defaults are used.
  final double? handlesRadius;

  /// The timing mechanism used to blink, e.g., `Ticker` or `Timer`.
  ///
  /// `Timer`s are not expected to work in tests.
  final BlinkTimingMode blinkTimingMode;

  /// The color of selection rectangles that appear around selected text.
  final Color? selectionColor;

  /// The minimum height of this text field, represented as a
  /// line count.
  ///
  /// If [minLines] is non-null and greater than `1`, [lineHeight]
  /// must also be provided because there is no guarantee that all
  /// lines of text have the same height.
  ///
  /// See also:
  ///
  ///  * [maxLines]
  ///  * [lineHeight]
  final int? minLines;

  /// The maximum height of this text field, represented as a
  /// line count.
  ///
  /// If text exceeds the maximum line height, scrolling dynamics
  /// are added to accommodate the overflowing text.
  ///
  /// If [maxLines] is non-null and greater than `1`, [lineHeight]
  /// must also be provided because there is no guarantee that all
  /// lines of text have the same height.
  ///
  /// See also:
  ///
  ///  * [minLines]
  ///  * [lineHeight]
  final int? maxLines;

  /// The height of a single line of text in this text field, used
  /// with [minLines] and [maxLines] to size the text field.
  ///
  /// An explicit [lineHeight] is required because rich text in this
  /// text field might have lines of varying height, which would
  /// result in a constantly changing text field height during scrolling.
  /// To avoid that situation, a single, explicit [lineHeight] is
  /// provided and used for all text field height calculations.
  final double? lineHeight;

  /// The [TwTextField] input source, e.g., keyboard or Input Method Engine.
  ///
  /// Only used on desktop. On mobile platforms, only [TextInputSource.ime] is available.
  final TextInputSource? inputSource;

  /// Priority list of handlers that process all physical keyboard
  /// key presses, for text input, deletion, caret movement, etc.
  ///
  /// Only used on desktop.
  final List<TextFieldKeyboardHandler>? keyboardHandlers;

  /// Handlers for all Mac OS "selectors" reported by the IME.
  ///
  /// The IME reports selectors as unique `String`s, therefore selector handlers are
  /// defined as a mapping from selector names to handler functions.
  final Map<String, TwTextFieldSelectorHandler>? selectorHandlers;

  /// {@template super_text_field_tap_handlers}
  /// Optional list of handlers that respond to taps on content, e.g., opening
  /// a link when the user taps on text with a link attribution.
  ///
  /// If a handler returns [TapHandlingInstruction.halt], no subsequent handlers
  /// nor the default tap behavior will be executed.
  /// {@endtemplate}
  final List<TwTextFieldTapHandler> tapHandlers;

  /// Padding placed around the text content of this text field, but within the
  /// scrollable viewport.
  final EdgeInsets? padding;

  /// An optional [ScrollController] for the internal scroll view.
  ///
  /// When provided, the same controller can be passed to a scrollbar widget
  /// that wraps this text field.
  final ScrollController? scrollController;

  /// Preferences for how the platform IME should look and behave during editing.
  final TextInputConfiguration? imeConfiguration;

  /// Whether to show an underline beneath the text in the composing region, or `null`
  /// to let [TwTextField] decide when to show the underline.
  final bool? showComposingUnderline;

  @override
  State<TwTextField> createState() => TwTextFieldState();
}

class TwTextFieldState extends State<TwTextField> implements ImeInputOwner {
  final _platformFieldKey = GlobalKey();
  late FocusNode _focusNode;
  late ImeAttributedTextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();

    _controller = widget.textController != null
        ? widget.textController is ImeAttributedTextEditingController
              ? (widget.textController as ImeAttributedTextEditingController)
              : ImeAttributedTextEditingController(
                  controller: widget.textController,
                  disposeClientController: false,
                )
        : ImeAttributedTextEditingController();
  }

  @override
  void didUpdateWidget(TwTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
    }

    if (widget.textController != oldWidget.textController) {
      _controller = widget.textController != null
          ? widget.textController is ImeAttributedTextEditingController
                ? (widget.textController as ImeAttributedTextEditingController)
                : ImeAttributedTextEditingController(
                    controller: widget.textController,
                    disposeClientController: false,
                  )
          : ImeAttributedTextEditingController();
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  @visibleForTesting
  bool get hasFocus => _focusNode.hasFocus;

  @visibleForTesting
  AttributedTextEditingController get controller => _controller;

  @visibleForTesting
  ProseTextLayout get textLayout =>
      (_platformFieldKey.currentState as ProseTextBlock).textLayout;

  @visibleForTesting
  @override
  DeltaTextInputClient get imeClient {
    switch (_configuration) {
      case TwTextFieldPlatformConfiguration.desktop:
        return (_platformFieldKey.currentState as TwDesktopTextFieldState)
            // ignore: invalid_use_of_visible_for_testing_member
            .imeClient;
      case TwTextFieldPlatformConfiguration.android:
        return (_platformFieldKey.currentState as TwAndroidTextFieldState)
            // ignore: invalid_use_of_visible_for_testing_member
            .imeClient;
      case TwTextFieldPlatformConfiguration.iOS:
        return (_platformFieldKey.currentState as TwIOSTextFieldState)
            // ignore: invalid_use_of_visible_for_testing_member
            .imeClient;
    }
  }

  bool get _isMultiline => (widget.minLines ?? 1) != 1 || widget.maxLines != 1;

  TwTextFieldPlatformConfiguration get _configuration {
    if (widget.configuration != null) {
      return widget.configuration!;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return TwTextFieldPlatformConfiguration.android;
      case TargetPlatform.iOS:
        return TwTextFieldPlatformConfiguration.iOS;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return TwTextFieldPlatformConfiguration.desktop;
    }
  }

  /// Returns the desired [TextInputSource] for this text field.
  ///
  /// If the [widget.inputSource] is configured, it is used. Otherwise,
  /// the [TextInputSource] is chosen based on the platform.
  TextInputSource get _inputSource {
    if (widget.inputSource != null) {
      return widget.inputSource!;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return TextInputSource.ime;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return TextInputSource.keyboard;
    }
  }

  /// Shortcuts that should be ignored on web.
  ///
  /// Without this we can't handle space and arrow keys inside [TwTextField].
  ///
  /// For exemple, when [TwTextField] is inside a [ScrollView],
  /// pressing [LogicalKeyboardKey.space] scrolls the scrollview.
  final Map<LogicalKeySet, Intent> _scrollShortcutOverrides = kIsWeb
      ? {
          LogicalKeySet(LogicalKeyboardKey.space):
              const DoNothingAndStopPropagationIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowUp):
              const DoNothingAndStopPropagationIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowDown):
              const DoNothingAndStopPropagationIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowLeft):
              const DoNothingAndStopPropagationIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowRight):
              const DoNothingAndStopPropagationIntent(),
        }
      : const <LogicalKeySet, Intent>{};

  @override
  Widget build(BuildContext context) {
    switch (_configuration) {
      case TwTextFieldPlatformConfiguration.desktop:
        return TwDesktopTextField(
          key: _platformFieldKey,
          focusNode: _focusNode,
          tapRegionGroupId: widget.tapRegionGroupId,
          textController: _controller,
          textAlign: widget.textAlign,
          textStyleBuilder: widget.textStyleBuilder,
          inlineWidgetBuilders: widget.inlineWidgetBuilders,
          hintBehavior: widget.hintBehavior,
          hintBuilder: widget.hintBuilder,
          selectionHighlightStyle: SelectionHighlightStyle(
            color: widget.selectionColor ?? defaultSelectionColor,
          ),
          caretStyle:
              widget.caretStyle ??
              CaretStyle(
                color: widget.controlsColor ?? defaultDesktopCaretColor,
                width: 1,
                borderRadius: BorderRadius.zero,
              ),
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          keyboardHandlers: widget.keyboardHandlers,
          selectorHandlers: widget.selectorHandlers,
          tapHandlers: widget.tapHandlers,
          padding: widget.padding ?? EdgeInsets.zero,
          inputSource: _inputSource,
          imeConfiguration: widget.imeConfiguration,
          showComposingUnderline:
              widget.showComposingUnderline ??
              defaultTargetPlatform == TargetPlatform.macOS,
          blinkTimingMode: widget.blinkTimingMode,
          scrollController: widget.scrollController,
        );
      case TwTextFieldPlatformConfiguration.android:
        return Shortcuts(
          shortcuts: _scrollShortcutOverrides,
          child: TwAndroidTextField(
            key: _platformFieldKey,
            focusNode: _focusNode,
            tapRegionGroupId: widget.tapRegionGroupId,
            tapHandlers: widget.tapHandlers,
            textController: _controller,
            textAlign: widget.textAlign,
            textStyleBuilder: widget.textStyleBuilder,
            inlineWidgetBuilders: widget.inlineWidgetBuilders,
            hintBehavior: widget.hintBehavior,
            hintBuilder: widget.hintBuilder,
            caretStyle:
                widget.caretStyle ??
                CaretStyle(
                  color: widget.controlsColor ?? defaultAndroidControlsColor,
                ),
            selectionColor: widget.selectionColor ?? defaultSelectionColor,
            handlesColor: widget.controlsColor ?? defaultAndroidControlsColor,
            handlesRadius:
                widget.handlesRadius ?? AndroidSelectionHandle.defaultRadius,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            lineHeight: widget.lineHeight,
            imeConfiguration: widget.imeConfiguration,
            showComposingUnderline: widget.showComposingUnderline ?? true,
            padding: widget.padding,
            scrollController: widget.scrollController,
            blinkTimingMode: widget.blinkTimingMode,
          ),
        );
      case TwTextFieldPlatformConfiguration.iOS:
        return Shortcuts(
          shortcuts: _scrollShortcutOverrides,
          child: TwIOSTextField(
            key: _platformFieldKey,
            focusNode: _focusNode,
            tapRegionGroupId: widget.tapRegionGroupId,
            tapHandlers: widget.tapHandlers,
            textController: _controller,
            textAlign: widget.textAlign,
            textStyleBuilder: widget.textStyleBuilder,
            inlineWidgetBuilders: widget.inlineWidgetBuilders,
            padding: widget.padding,
            hintBehavior: widget.hintBehavior,
            hintBuilder: widget.hintBuilder,
            caretStyle:
                widget.caretStyle ??
                CaretStyle(
                  color: widget.controlsColor ?? defaultIOSControlsColor,
                ),
            selectionColor: widget.selectionColor ?? defaultSelectionColor,
            handlesColor: widget.controlsColor ?? defaultIOSControlsColor,
            handlesRadius: widget.handlesRadius,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            lineHeight: widget.lineHeight,
            imeConfiguration: widget.imeConfiguration,
            showComposingUnderline: widget.showComposingUnderline ?? true,
            blinkTimingMode: widget.blinkTimingMode,
            scrollController: widget.scrollController,
          ),
        );
    }
  }
}

/// Configures a [TwTextField] for the given platform.
///
/// Desktop uses physical keyboard handlers, while mobile uses the IME.
///
/// Desktop uses a blinking caret, while mobile uses a draggable caret
/// and selection handles, styled per platform.
enum TwTextFieldPlatformConfiguration { desktop, android, iOS }
