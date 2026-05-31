import 'package:flutter/material.dart';
// NOTE: keep this file minimal — implementations live in per-brightness files.

/// Internal interface implemented by per-brightness text-style providers.
abstract class TwTextStylesImpl {
  TextStyle bodyForContext({required BuildContext context, required Color color, double baseSize});
  TextStyle bodyForContextless({required Color color, required double textScale});
  TextStyle sectionTitleForContext({required BuildContext context, required Color color, double baseSize});
  TextStyle modalHeaderTitle({required Color color});
  TextStyle modalCloseGlyph({required Color color});
  TextStyle footerBodyForContext({required BuildContext context, required Color color});
  TextStyle get transparentSelectionSpacer;
}
