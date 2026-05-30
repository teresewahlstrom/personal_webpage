import 'package:attributed_text/attributed_text.dart';
import 'package:flutter/material.dart';
import 'package:tw_primitives/src/text_field/core/attributions.dart';

/// Default [TextStyles] for [TwTextField].
TextStyle defaultTextFieldStyleBuilder(Set<Attribution> attributions) {
  TextStyle newStyle = const TextStyle(
    fontFamily: 'Rubik',
    fontSize: 16,
    height: 1,
    color: Colors.black,
  );

  for (final attribution in attributions) {
    if (attribution == boldAttribution) {
      newStyle = newStyle.copyWith(
        fontWeight: FontWeight.bold,
      );
    } else if (attribution == italicsAttribution) {
      newStyle = newStyle.copyWith(
        fontStyle: FontStyle.italic,
      );
    } else if (attribution == underlineAttribution) {
      newStyle = newStyle.copyWith(
        decoration: newStyle.decoration == null
            ? TextDecoration.underline
            : TextDecoration.combine([TextDecoration.underline, newStyle.decoration!]),
      );
    } else if (attribution == strikethroughAttribution) {
      newStyle = newStyle.copyWith(
        decoration: newStyle.decoration == null
            ? TextDecoration.lineThrough
            : TextDecoration.combine([TextDecoration.lineThrough, newStyle.decoration!]),
      );
    } else if (attribution is ColorAttribution) {
      newStyle = newStyle.copyWith(
        color: attribution.color,
      );
    } else if (attribution is LinkAttribution) {
      newStyle = newStyle.copyWith(
        color: Colors.lightBlue,
        decoration: TextDecoration.underline,
      );
    }
  }
  return newStyle;
}


