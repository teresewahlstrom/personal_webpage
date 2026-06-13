import 'package:attributed_text/attributed_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tw_primitives/src/text_field/core/document.dart';
import 'package:tw_primitives/src/text_field/core/document_selection.dart';

/// A logical selection within a [TextNode].
///
/// The selection begins at [baseOffset] and ends at [extentOffset].
class TextNodeSelection extends TextSelection implements NodeSelection {
  TextNodeSelection.fromTextSelection(TextSelection textSelection)
      : super(
          baseOffset: textSelection.baseOffset,
          extentOffset: textSelection.extentOffset,
          affinity: textSelection.affinity,
          isDirectional: textSelection.isDirectional,
        );

  const TextNodeSelection.collapsed({
    required int offset,
    super.affinity,
  }) : super(
          baseOffset: offset,
          extentOffset: offset,
        );

  const TextNodeSelection({
    required super.baseOffset,
    required super.extentOffset,
    super.affinity,
    super.isDirectional,
  });

  @override
  TextNodePosition get base => TextNodePosition(offset: baseOffset, affinity: affinity);

  @override
  TextNodePosition get extent => TextNodePosition(offset: extentOffset, affinity: affinity);
}

/// A logical position within a [TextNode].
class TextNodePosition extends TextPosition implements NodePosition {
  TextNodePosition.fromTextPosition(TextPosition position)
      : super(offset: position.offset, affinity: position.affinity);

  const TextNodePosition({
    required super.offset,
    super.affinity,
  });

  @override
  bool isEquivalentTo(NodePosition other) {
    if (other is! TextNodePosition) {
      return false;
    }

    // Equivalency is determined by text offset. Affinity is ignored, because
    // affinity doesn't alter the actual location in the text that a
    // TextNodePosition refers to.
    return offset == other.offset;
  }

  TextNodePosition copyWith({
    int? offset,
    TextAffinity? affinity,
  }) {
    return TextNodePosition(
      offset: offset ?? this.offset,
      affinity: affinity ?? this.affinity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other && other is TextNodePosition && runtimeType == other.runtimeType && offset == other.offset;

  @override
  int get hashCode => super.hashCode ^ super.offset.hashCode;
}

/// Keys to access metadata that are specific to a [TextNode].
class TextNodeMetadata {
  /// The [TextAlign] of the [TextNode].
  static const String textAlign = 'textAlign';
}

/// A logical node that stores attributed text.
@immutable
class TextNode extends DocumentNode {
  TextNode({
    required this.id,
    required this.text,
    super.metadata,
  });

  @override
  final String id;

  /// The content text within this [TextNode].
  final AttributedText text;

  @override
  TextNodePosition get beginningPosition => const TextNodePosition(offset: 0);

  @override
  TextNodePosition get endPosition => TextNodePosition(offset: text.length);

  @override
  bool containsPosition(Object position) {
    if (position is! TextNodePosition) {
      return false;
    }

    if (position.offset < 0 || position.offset > text.length) {
      return false;
    }

    return true;
  }

  @override
  NodePosition selectUpstreamPosition(NodePosition position1, NodePosition position2) {
    if (position1 is! TextNodePosition) {
      throw Exception('Expected a TextNodePosition for position1 but received a ${position1.runtimeType}');
    }
    if (position2 is! TextNodePosition) {
      throw Exception('Expected a TextNodePosition for position2 but received a ${position2.runtimeType}');
    }

    return position1.offset < position2.offset ? position1 : position2;
  }

  @override
  NodePosition selectDownstreamPosition(NodePosition position1, NodePosition position2) {
    if (position1 is! TextNodePosition) {
      throw Exception('Expected a TextNodePosition for position1 but received a ${position1.runtimeType}');
    }
    if (position2 is! TextNodePosition) {
      throw Exception('Expected a TextNodePosition for position2 but received a ${position2.runtimeType}');
    }

    return position1.offset > position2.offset ? position1 : position2;
  }

  /// Returns a [DocumentSelection] within this [TextNode] from [startIndex] to [endIndex].
  DocumentSelection selectionBetween(int startIndex, int endIndex) {
    return DocumentSelection(
      base: DocumentPosition(
        nodeId: id,
        nodePosition: TextNodePosition(offset: startIndex),
      ),
      extent: DocumentPosition(
        nodeId: id,
        nodePosition: TextNodePosition(offset: endIndex),
      ),
    );
  }

  /// Returns a collapsed [DocumentSelection], positioned within this [TextNode] at the
  /// given [collapsedIndex].
  DocumentSelection selectionAt(int collapsedIndex) {
    return DocumentSelection.collapsed(
      position: positionAt(collapsedIndex),
    );
  }

  /// Returns a [DocumentPosition] within this [TextNode] at the given text [index].
  DocumentPosition positionAt(int index) {
    return DocumentPosition(
      nodeId: id,
      nodePosition: TextNodePosition(offset: index),
    );
  }

  /// Returns a [DocumentRange] within this [TextNode] between [startIndex] and [endIndex].
  DocumentRange rangeBetween(int startIndex, int endIndex) {
    return DocumentRange(
      start: DocumentPosition(
        nodeId: id,
        nodePosition: TextNodePosition(offset: startIndex),
      ),
      end: DocumentPosition(
        nodeId: id,
        nodePosition: TextNodePosition(offset: endIndex),
      ),
    );
  }

  @override
  TextNodeSelection computeSelection({
    required NodePosition base,
    required NodePosition extent,
  }) {
    assert(base is TextNodePosition);
    assert(extent is TextNodePosition);

    return TextNodeSelection(
      baseOffset: (base as TextNodePosition).offset,
      extentOffset: (extent as TextNodePosition).offset,
      affinity: extent.affinity,
    );
  }

  @override
  String copyContent(dynamic selection) {
    assert(selection is TextSelection);

    return (selection as TextSelection).textInside(text.toPlainText());
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is TextNode && text == other.text && super.hasEquivalentContent(other);
  }

  TextNode copyTextNodeWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
  }) {
    return TextNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  DocumentNode copyAndReplaceMetadata(Map<String, dynamic> newMetadata) {
    return copyTextNodeWith(
      metadata: newMetadata,
    );
  }

  @override
  DocumentNode copyWithAddedMetadata(Map<String, dynamic> newProperties) {
    return copyTextNodeWith(
      metadata: {...metadata, ...newProperties},
    );
  }

  TextNode copy() {
    return TextNode(id: id, text: text.copyText(0), metadata: Map.from(metadata));
  }

  @override
  String toString() => '[TextNode] - text: $text, metadata: ${copyMetadata()}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other && other is TextNode && runtimeType == other.runtimeType && id == other.id && text == other.text;

  @override
  int get hashCode => super.hashCode ^ id.hashCode ^ text.hashCode;
}

extension TextNodeExtensions on DocumentNode {
  TextNode get asTextNode => this as TextNode;
}
