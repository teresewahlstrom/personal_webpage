import 'package:flutter/material.dart';
import 'impl.dart';
import 'package:tw_primitives/src/theme/text_styles/_dark.dart' as dark;

class TwTextStylesLight implements TwTextStylesImpl {
  final dark.TwTextStylesDark _dark = dark.TwTextStylesDark();

  @override
  TextStyle bodyForContext({required BuildContext context, required Color color, double baseSize = dark.twBodyBaseFontSize}) {
    return _dark.bodyForContext(context: context, color: color, baseSize: baseSize);
  }

  @override
  TextStyle bodyForContextless({required Color color, required double textScale}) {
    return _dark.bodyForContextless(color: color, textScale: textScale);
  }

  @override
  TextStyle sectionTitleForContext({required BuildContext context, required Color color, double baseSize = dark.twSectionBaseFontSize}) {
    return _dark.sectionTitleForContext(context: context, color: color, baseSize: baseSize);
  }

  @override
  TextStyle modalHeaderTitle({required Color color}) => _dark.modalHeaderTitle(color: color);

  @override
  TextStyle modalCloseGlyph({required Color color}) => _dark.modalCloseGlyph(color: color);

  @override
  TextStyle footerBodyForContext({required BuildContext context, required Color color}) => _dark.footerBodyForContext(context: context, color: color);

  @override
  TextStyle get transparentSelectionSpacer => _dark.transparentSelectionSpacer;
}
