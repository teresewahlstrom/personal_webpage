import 'package:flutter/widgets.dart';
import 'package:tw_primitives/src/text_field/infrastructure/touch_controls.dart';
import 'package:super_text_layout/super_text_layout.dart';

/// A strategy for selecting text while the user is dragging a drag handle,
/// similar to how the Android OS selects text during a handle drag.
///
/// The selection edge follows the drag handle by character so the user can stop
/// anywhere inside a word.
class AndroidDocumentDragHandleSelectionStrategy {
  AndroidDocumentDragHandleSelectionStrategy({
    required GlobalKey textContentKey,
    required ProseTextLayout textLayout,
    required void Function(TextSelection) select,
  }) : _textLayout = textLayout,
       _select = select;

  final ProseTextLayout _textLayout;
  final void Function(TextSelection) _select;

  TextSelection? _lastSelection;

  /// The drag handle used to start the gesture.
  HandleType? _dragHandleType;

  /// Clients should call this method when a drag handle gesture is initially recognized.
  void onHandlePanStart(
    DragStartDetails details,
    TextSelection initialSelection,
    HandleType handleType,
  ) {
    if (handleType == HandleType.collapsed && !initialSelection.isCollapsed) {
      throw Exception(
        "Tried to drag a collapsed Android handle but the selection is expanded.",
      );
    }
    if (handleType != HandleType.collapsed && initialSelection.isCollapsed) {
      throw Exception(
        "Tried to drag an expanded Android handle but the selection is collapsed.",
      );
    }

    _dragHandleType = handleType;
    _lastSelection = initialSelection;
  }

  /// Clients should call this method when a drag handle gesture is updated.
  void onHandlePanUpdate(Offset handleFocalPoint) {
    final nearestPosition = _textLayout.getPositionNearestToOffset(
      handleFocalPoint,
    );
    if (nearestPosition.offset < 0) {
      return;
    }

    if (_dragHandleType == HandleType.collapsed) {
      // A collapsed handle always produces a collapsed selection.
      _lastSelection = TextSelection.collapsed(offset: nearestPosition.offset);
      _select(_lastSelection!);
      return;
    }

    final rangeToExpandSelection = TextSelection.collapsed(
      offset: nearestPosition.offset,
    );

    if (rangeToExpandSelection.isValid) {
      _lastSelection = _lastSelection!.copyWith(
        baseOffset:
            _dragHandleType ==
                HandleType
                    .upstream //
            ? rangeToExpandSelection.baseOffset
            : _lastSelection!.baseOffset,
        extentOffset: _dragHandleType == HandleType.downstream
            ? rangeToExpandSelection.extentOffset
            : _lastSelection!.extentOffset,
      );
      _select(_lastSelection!);
    }
  }
}
