import 'package:flutter/material.dart';
import 'package:tw_primitives/src/theme/text_styles/_light.dart' as light;
import 'package:tw_primitives/src/theme/text_styles/_dark.dart' as dark;
import 'impl.dart';

// Public convenience accessor for the canonical font family token.
// This allows consumers to import the public `package:tw_primitives/theme.dart`
// and use `twFontFamily` without reaching into `lib/src` implementation files.
const String twFontFamily = dark.twFontFamily;

/// Router that exposes text-style helpers per-brightness (light/dark).
class TwTextStyles {
  const TwTextStyles._(this._impl);

  final TwTextStylesImpl _impl;

  /// Convenience: return by [Brightness].
  static TwTextStyles forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? TwTextStyles._(dark.TwTextStylesDark()) : TwTextStyles._(light.TwTextStylesLight());
  }

  /// Convenience: return by [BuildContext].
  static TwTextStyles of(BuildContext context) => TwTextStyles.forBrightness(Theme.of(context).brightness);

  TextStyle bodyForContext({required BuildContext context, required Color color, double baseSize = 17.0}) =>
      _impl.bodyForContext(context: context, color: color, baseSize: baseSize);

  TextStyle bodyForContextless({required Color color, required double textScale}) =>
      _impl.bodyForContextless(color: color, textScale: textScale);

  TextStyle sectionTitleForContext({required BuildContext context, required Color color, double baseSize = 40.0}) =>
      _impl.sectionTitleForContext(context: context, color: color, baseSize: baseSize);

  TextStyle modalHeaderTitle({required Color color}) => _impl.modalHeaderTitle(color: color);

  TextStyle modalCloseGlyph({required Color color}) => _impl.modalCloseGlyph(color: color);

  TextStyle footerBodyForContext({required BuildContext context, required Color color}) =>
      _impl.footerBodyForContext(context: context, color: color);

  TextStyle get transparentSelectionSpacer => _impl.transparentSelectionSpacer;
}

extension TwTextStylesBuildContextExtension on BuildContext {
  TwTextStyles get twTextStyles => TwTextStyles.of(this);
}
