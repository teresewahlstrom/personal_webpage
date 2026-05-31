import 'package:attributed_text/attributed_text.dart';
import 'package:flutter/material.dart';
import 'package:tw_primitives/src/text_field/core/attributions.dart';
import 'package:tw_primitives/theme.dart';

/// Default [TextStyles] for [TwTextField].
TextStyle defaultTextFieldStyleBuilder(Set<Attribution> attributions) {
  // Use centralized text-style router for defaults (contextless).
  TextStyle newStyle = TwTextStyles.forBrightness(Brightness.light)
      .bodyForContextless(color: Colors.black, textScale: 1.0);

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


