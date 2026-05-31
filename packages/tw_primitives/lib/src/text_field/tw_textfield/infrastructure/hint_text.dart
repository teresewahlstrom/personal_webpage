import 'package:attributed_text/attributed_text.dart';
import 'package:flutter/material.dart';
import 'package:tw_primitives/src/text_field/core/attributions.dart';
import 'package:tw_primitives/src/text_field/infrastructure/attributed_text_styles.dart';
import 'package:tw_primitives/theme.dart';

/// Policy that dictates when to display a hint in a Super Text Field.
enum HintBehavior {
  /// Display a hint when the text field is empty until
  /// the text field receives focus, then hide the hint.
  displayHintUntilFocus,

  /// Display a hint when the text field is empty until
  /// at least 1 character is entered into the text field.
  displayHintUntilTextEntered,

  /// Do not display a hint.
  noHint,
}

/// Builds a hint widget based on given [hintText] and a [hintTextStyleBuilder].
class StyledHintBuilder {
  StyledHintBuilder({
    this.hintText,
    this.hintTextStyleBuilder = defaultHintStyleBuilder,
  });

  /// Text displayed when the text field has no content.
  final AttributedText? hintText;

  /// Text style factory that creates styles for the [hintText],
  /// which is displayed when [textController] is empty.
  final AttributionStyleBuilder hintTextStyleBuilder;

  Widget build(BuildContext context) {
    return Text.rich(
      hintText?.computeInlineSpan(context, hintTextStyleBuilder, const <InlineWidgetBuilder>[]) ??
          TextSpan(text: "", style: hintTextStyleBuilder({})),
    );
  }
}

/// Creates default [TextStyles] for hint text in a super text field.
TextStyle defaultHintStyleBuilder(Set<Attribution> attributions) {
  // Use centralized text-style router for hint defaults, then adjust where necessary.
    TextStyle newStyle = TwTextStyles.forBrightness(Brightness.light)
      .bodyForContextless(color: Colors.grey, textScale: 1.0);
    newStyle = TwTextStyles.forBrightness(Brightness.light).adaptBase(newStyle, height: 1.4);

  for (final attribution in attributions) {
    if (attribution == header1Attribution) {
      newStyle = TwTextStyles.forBrightness(Brightness.light).adaptBase(
        newStyle,
        fontSize: twHeader1FontSize,
        fontWeight: FontWeight.bold,
        height: 1.0,
      );
    } else if (attribution == header2Attribution) {
      newStyle = TwTextStyles.forBrightness(Brightness.light).adaptBase(
        newStyle,
        fontSize: twHeader2FontSize,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF888888),
        height: 1.0,
      );
    } else if (attribution == blockquoteAttribution) {
      newStyle = TwTextStyles.forBrightness(Brightness.light).adaptBase(
        newStyle,
        fontSize: twBlockquoteFontSize,
        fontWeight: FontWeight.bold,
        height: 1.4,
        color: Colors.grey,
      );
    } else if (attribution == boldAttribution) {
      newStyle = TwTextStyles.forBrightness(Brightness.light).adaptBase(
        newStyle,
        fontWeight: FontWeight.bold,
      );
    } else if (attribution == italicsAttribution) {
      newStyle = TwTextStyles.forBrightness(Brightness.light).adaptBase(
        newStyle,
        fontStyle: FontStyle.italic,
      );
    } else if (attribution == strikethroughAttribution) {
      newStyle = TwTextStyles.forBrightness(Brightness.light).adaptBase(
        newStyle,
        decoration: TextDecoration.lineThrough,
      );
    } else if (attribution is LinkAttribution) {
      newStyle = TwTextStyles.forBrightness(Brightness.light).adaptBase(
        newStyle,
        color: Colors.lightBlue,
        decoration: TextDecoration.underline,
      );
    }
  }
  return newStyle;
}

