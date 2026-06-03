import 'package:attributed_text/attributed_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/src/text_field/tw_textfield/tw_textfield.dart';

void main() {
  test(
    'ensureExtentIsVisible retries when target and actual scroll offsets differ',
    () {
      final textController = AttributedTextEditingController(
        text: AttributedText('abc'),
      )..selection = const TextSelection.collapsed(offset: 3);
      final scrollController = TextScrollController(
        textController: textController,
        tickerProvider: const TestVSync(),
      );
      final delegate = _FakeTextScrollControllerDelegate()
        ..currentScrollOffsetValue = 0;
      scrollController.delegate = delegate;

      var notifications = 0;
      scrollController.addListener(() => notifications += 1);

      scrollController.ensureExtentIsVisible();

      expect(scrollController.targetScrollOffset, 45);
      expect(notifications, 1);

      scrollController.ensureExtentIsVisible();

      expect(scrollController.targetScrollOffset, 45);
      expect(notifications, 2);

      delegate.currentScrollOffsetValue = scrollController.targetScrollOffset;
      scrollController.ensureExtentIsVisible();

      expect(notifications, 2);
    },
  );

  test(
    'ensureExtentIsVisible scrolls fully to the bottom when the caret is on the last line',
    () {
      final textController = AttributedTextEditingController(
        text: AttributedText('abc'),
      )..selection = const TextSelection.collapsed(offset: 3);
      final scrollController = TextScrollController(
        textController: textController,
        tickerProvider: const TestVSync(),
      );
      final delegate = _FakeTextScrollControllerDelegate(
        caretRect: const Rect.fromLTWH(0, 40, 0, 10),
        lastCharacterRect: const Rect.fromLTWH(0, 40, 0, 10),
        endScrollOffsetValue: 45,
      );
      scrollController.delegate = delegate;

      scrollController.ensureExtentIsVisible();

      expect(scrollController.targetScrollOffset, 45);
    },
  );

  test(
    'notifies viewport scroll listeners independently of target scroll listeners',
    () {
      final textController = AttributedTextEditingController(
        text: AttributedText('abc'),
      );
      final scrollController = TextScrollController(
        textController: textController,
        tickerProvider: const TestVSync(),
      );

      var viewportNotifications = 0;
      var targetNotifications = 0;
      void onViewportScrolled() => viewportNotifications += 1;

      scrollController
        ..addViewportScrollListener(onViewportScrolled)
        ..addListener(() => targetNotifications += 1);

      scrollController.notifyViewportScrolled();

      expect(viewportNotifications, 1);
      expect(targetNotifications, 0);

      scrollController.removeViewportScrollListener(onViewportScrolled);
      scrollController.notifyViewportScrolled();

      expect(viewportNotifications, 1);
    },
  );
}

class _FakeTextScrollControllerDelegate
    implements TextScrollControllerDelegate {
  static const _viewportHeight = 20.0;
  static const _lineHeight = 10.0;
  static const _caretContentTop = 50.0;

  _FakeTextScrollControllerDelegate({
    this._caretRect,
    this._lastCharacterRect,
    this._endScrollOffsetValue,
  });

  double currentScrollOffsetValue = 0;
  final Rect? _caretRect;
  final Rect? _lastCharacterRect;
  final double? _endScrollOffsetValue;

  @override
  double? get viewportWidth => 100;

  @override
  double? get viewportHeight => _viewportHeight;

  @override
  Offset get textLayoutOffsetInViewport => Offset.zero;

  @override
  bool get isMultiline => true;

  @override
  double get startScrollOffset => 0;

  @override
  double get currentScrollOffset => currentScrollOffsetValue;

  @override
  double get endScrollOffset => _endScrollOffsetValue ?? 45;

  @override
  bool isTextPositionVisible(TextPosition position) => false;

  @override
  bool isInAutoScrollToStartRegion(Offset offsetInViewport) => false;

  @override
  double calculateDistanceBeyondStartingAutoScrollBoundary(
    Offset offsetInViewport,
  ) => 0;

  @override
  bool isInAutoScrollToEndRegion(Offset offsetInViewport) => false;

  @override
  double calculateDistanceBeyondEndingAutoScrollBoundary(
    Offset offsetInViewport,
  ) => 0;

  @override
  double? getHorizontalOffsetForStartOfCharacterLeftOfViewport() => 0;

  @override
  double? getHorizontalOffsetForEndOfCharacterRightOfViewport() => 0;

  @override
  double? getVerticalOffsetForTopOfLineAboveViewport() => 0;

  @override
  double? getVerticalOffsetForBottomOfLineBelowViewport() => 0;

  @override
  Rect getViewportCharacterRectAtPosition(TextPosition position) {
    if (_lastCharacterRect != null && position.offset > 0) {
      return _lastCharacterRect;
    }

    final top = position.offset == 0 ? 0.0 : _caretContentTop;
    return Rect.fromLTWH(0, top - currentScrollOffsetValue, 0, _lineHeight);
  }

  @override
  Rect getViewportCaretRectAtPosition(TextPosition position) {
    if (_caretRect != null) {
      return _caretRect;
    }

    return Rect.fromLTWH(
      0,
      _caretContentTop - currentScrollOffsetValue,
      0,
      _lineHeight,
    );
  }
}
