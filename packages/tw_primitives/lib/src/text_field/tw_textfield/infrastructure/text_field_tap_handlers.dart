import 'package:flutter/widgets.dart';
import 'package:tw_primitives/src/text_field/core/attributions.dart';
import 'package:tw_primitives/src/text_field/infrastructure/document_gestures_interaction_overrides.dart';
import 'package:tw_primitives/src/text_field/infrastructure/links.dart';
import 'package:tw_primitives/src/text_field/tw_textfield/infrastructure/text_field_gestures_interaction_overrides.dart';

/// A [TwTextFieldTapHandler] that opens links when the user taps text with
/// a [LinkAttribution].
class TwTextFieldLaunchLinkTapHandler extends TwTextFieldTapHandler {
  @override
  MouseCursor? mouseCursorForContentHover(TwTextFieldGestureDetails details) {
    final linkAttribution = _getLinkAttribution(details);
    if (linkAttribution == null) {
      return null;
    }

    return SystemMouseCursors.click;
  }

  @override
  TapHandlingInstruction onTapUp(TwTextFieldGestureDetails details) {
    final linkAttribution = _getLinkAttribution(details);
    if (linkAttribution == null) {
      return TapHandlingInstruction.continueHandling;
    }

    UrlLauncher.instance.launchUrl(
      linkAttribution.launchableUri,
    );

    return TapHandlingInstruction.halt;
  }

  /// Returns the [LinkAttribution] at the given [details.textOffset], if any.
  LinkAttribution? _getLinkAttribution(TwTextFieldGestureDetails details) {
    final textPosition = details.textLayout.getPositionNearestToOffset(details.textOffset);

    final attributions = details.textController.text //
        .getAllAttributionsAt(textPosition.offset)
        .whereType<LinkAttribution>();

    if (attributions.isEmpty) {
      return null;
    }

    return attributions.first;
  }
}

