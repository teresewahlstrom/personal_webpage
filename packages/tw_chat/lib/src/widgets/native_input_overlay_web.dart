// On Flutter Web the `dart:js_interop` library is available, so this file is
// selected by the conditional export in `native_input_overlay.dart`.
//
// This implementation places a transparent HTML <textarea> on top of the
// Flutter TextField using a platform view.  The browser treats the <textarea>
// as the active text element and therefore applies its native text services
// (spell-check, autocorrect, long-press copy/paste context menu on mobile) to
// it, while the Flutter TextField below continues to handle visual rendering
// (cursor, selection highlight, hint text, scrollbar).
//
// Sync contract
// ─────────────
// • User types  → _handleInput fires on <textarea> → updates controller.value.
//                 Flutter re-renders from the new controller value.
// • Flutter updates controller externally (e.g. submit clears text) →
//   _onControllerChanged fires → textarea.value is updated to match.
// • Focus  → when the <textarea> receives browser focus _handleFocus requests
//   focus on the Flutter FocusNode so Flutter renders the cursor.
// • Submit → Enter (without Shift) calls widget.onSubmit, matching the
//   TextField's TextInputAction.newline / submit key behaviour.

import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

int _nextViewId = 0;

/// Wraps [child] (normally the chat composer [TextField]) with a transparent
/// native HTML `<textarea>` overlay that enables browser-native text features.
///
/// The overlay is transparent so [child] shows through visually, but the
/// browser recognises it as the active text element and provides:
///   • Spell-check red-underlines on desktop browsers.
///   • Autocorrect / autocapitalise on mobile browsers.
///   • The browser's long-press copy / paste context menu on iOS and Android.
class NativeInputOverlay extends StatefulWidget {
  const NativeInputOverlay({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.child,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  /// The Flutter widget (TextField) to overlay on top of.
  final Widget child;

  @override
  State<NativeInputOverlay> createState() => _NativeInputOverlayState();
}

class _NativeInputOverlayState extends State<NativeInputOverlay> {
  late final String _viewType;
  late final web.HTMLTextAreaElement _textarea;

  // Guards against recursive controller↔textarea sync loops.
  bool _syncingToNative = false;
  bool _syncingFromNative = false;

  // Stored JS-interop wrappers for addEventListener/removeEventListener parity.
  late final JSFunction _onInputJs;
  late final JSFunction _onKeyDownJs;
  late final JSFunction _onFocusJs;
  late final JSFunction _onBlurJs;
  late final JSFunction _onSelectJs;

  @override
  void initState() {
    super.initState();
    _viewType = 'tw_chat_nio_${_nextViewId++}';
    _textarea = web.HTMLTextAreaElement();
    _configureTextarea();
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _textarea,
    );
    widget.controller.addListener(_onControllerChanged);
  }

  // ---------------------------------------------------------------------------
  // Textarea setup
  // ---------------------------------------------------------------------------

  void _configureTextarea() {
    final s = _textarea.style;

    // Fill the HtmlElementView bounds that Flutter assigns.
    s.position = 'absolute';
    s.setProperty('inset', '0');
    s.width = '100%';
    s.height = '100%';

    // Visually transparent – Flutter TextField shows through.
    s.background = 'transparent';
    s.border = 'none';
    s.outline = 'none';
    s.resize = 'none';
    s.color = 'transparent';
    s.setProperty('caret-color', 'transparent');

    // Remove any default spacing so layout matches the Flutter TextField.
    s.padding = '0';
    s.margin = '0';
    s.overflow = 'hidden';
    s.setProperty('box-sizing', 'border-box');

    // Ensure the overlay receives pointer events (it sits above the canvas).
    s.setProperty('pointer-events', 'auto');

    // Enable native browser text-editing services.
    _textarea.setAttribute('spellcheck', 'true');
    _textarea.setAttribute('autocorrect', 'on');
    _textarea.setAttribute('autocapitalize', 'sentences');
    _textarea.setAttribute('autocomplete', 'off');

    // Build JS-interop wrappers once so we can remove them on dispose.
    _onInputJs = _handleInput.toJS;
    _onKeyDownJs = _handleKeyDown.toJS;
    _onFocusJs = _handleFocus.toJS;
    _onBlurJs = _handleBlur.toJS;
    _onSelectJs = _handleSelect.toJS;

    _textarea.addEventListener('input', _onInputJs);
    _textarea.addEventListener('keydown', _onKeyDownJs);
    _textarea.addEventListener('focus', _onFocusJs);
    _textarea.addEventListener('blur', _onBlurJs);
    // 'select' fires when the user changes the selection inside the textarea.
    _textarea.addEventListener('select', _onSelectJs);
  }

  // ---------------------------------------------------------------------------
  // DOM → Flutter sync
  // ---------------------------------------------------------------------------

  void _handleInput(web.Event event) {
    if (_syncingToNative) return;
    _syncingFromNative = true;
    try {
      final text = _textarea.value;
      final start = _textarea.selectionStart ?? 0;
      final end = _textarea.selectionEnd ?? 0;
      widget.controller.value = TextEditingValue(
        text: text,
        selection: TextSelection(baseOffset: start, extentOffset: end),
      );
    } finally {
      _syncingFromNative = false;
    }
  }

  void _handleKeyDown(web.Event event) {
    final ke = event as web.KeyboardEvent;
    // Enter without Shift submits, matching TextInputAction.newline behaviour.
    if (ke.key == 'Enter' && !ke.shiftKey) {
      ke.preventDefault();
      widget.onSubmit();
    }
  }

  void _handleFocus(web.Event event) {
    // Keep Flutter FocusNode in sync so the TextField renders its cursor.
    if (!widget.focusNode.hasFocus) {
      widget.focusNode.requestFocus();
    }
  }

  void _handleBlur(web.Event event) {
    if (widget.focusNode.hasFocus) {
      widget.focusNode.unfocus();
    }
  }

  void _handleSelect(web.Event event) {
    if (_syncingToNative) return;
    _syncingFromNative = true;
    try {
      final start = _textarea.selectionStart ?? 0;
      final end = _textarea.selectionEnd ?? 0;
      final current = widget.controller.value;
      if (current.selection.baseOffset != start ||
          current.selection.extentOffset != end) {
        widget.controller.value = current.copyWith(
          selection: TextSelection(baseOffset: start, extentOffset: end),
        );
      }
    } finally {
      _syncingFromNative = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Flutter → DOM sync
  // ---------------------------------------------------------------------------

  void _onControllerChanged() {
    if (_syncingFromNative) return;
    _syncingToNative = true;
    try {
      final text = widget.controller.text;
      if (_textarea.value != text) {
        _textarea.value = text;
        // Mirror selection so the textarea cursor matches Flutter's.
        final sel = widget.controller.selection;
        if (sel.isValid) {
          final maxOffset = text.length;
          _textarea.setSelectionRange(
            sel.baseOffset.clamp(0, maxOffset),
            sel.extentOffset.clamp(0, maxOffset),
          );
        }
      }
    } finally {
      _syncingToNative = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void didUpdateWidget(covariant NativeInputOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _textarea.value = widget.controller.text;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _textarea.removeEventListener('input', _onInputJs);
    _textarea.removeEventListener('keydown', _onKeyDownJs);
    _textarea.removeEventListener('focus', _onFocusJs);
    _textarea.removeEventListener('blur', _onBlurJs);
    _textarea.removeEventListener('select', _onSelectJs);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        // Flutter TextField: handles visual rendering (cursor, text, hint).
        widget.child,
        // Transparent native textarea: browser applies spell-check, autocorrect
        // and native selection handles on top of the Flutter canvas.
        Positioned.fill(
          child: HtmlElementView(viewType: _viewType),
        ),
      ],
    );
  }
}
