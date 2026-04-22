import 'package:flutter/material.dart';

final class _ThemeColor {
  const _ThemeColor(this.light, this.dark);

  final Color light;
  final Color dark;

  Color resolve(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }
}

final class _AppLightColors {
  static const Color pageBackground = Color(0xFFF8F9F7);
  static const Color headerBackground = Color(0xFFF8F9F7);
  static const Color headerToggleBackground = Color(0xFFF8F9F7);
  static const Color footerBackground = Color(0xFFF8F9F7);
  static const Color footerText = Color(0xFF555764);
  static const Color footerLink = Color(0xFF394183);
  static const Color footerLinkHover = Color(0xFF843F02);

  static const Color modalBackground = Color(0xFFF8F9F7);
  static const Color modalHeaderBorder = Color(0x1F394183);
  static const Color modalCloseIcon = Color(0xFF394183);
  static const Color modalCloseIconHover = Color(0xFF843F02);

  static const Color landingAccent = Color(0xFF394183);
  static const Color landingHover = Color(0xFF843F02);
  static const Color landingHeading = Color(0xFF161C45);
  static const Color landingBody = Color(0xFF252525);

  static const Color lineSubtle = Color(0xFFE1E4F2);
  static const Color lineSubtle2 = Color(0x40394183);
  static const Color lineSubtle3 = Color(0x40394183);
  static const Color lineAccent1 = Color(0xFF394183);
  static const Color lineAccent1Hover = Color(0xFF843F02);
}

final class _AppDarkColors {
  static const Color pageBackground = Color(0xFF212835);
  static const Color headerBackground = Color(0xFF212835);
  static const Color headerToggleBackground = Color(0xFF212835);
  static const Color footerBackground = Color(0xFF212835);
  static const Color footerText = Color(0xD6DCF6F8);
  static const Color footerLink = Color(0xFF90E8F8);
  static const Color footerLinkHover = Color(0xFF4EF0FF);

  static const Color modalBackground = Color(0xFF101B34);
  static const Color modalHeaderBorder = Color(0x3390E8F8);
  static const Color modalCloseIcon = Color(0xFF90E8F8);
  static const Color modalCloseIconHover = Color(0xFF4EF0FF);

  static const Color landingAccent = Color(0xFF90E8F8);
  static const Color landingHover = Color(0xFF4EF0FF);
  static const Color landingHeading = Color(0xEBDCF6F8);
  static const Color landingBody = Color(0xD6DCF6F8);

  static const Color lineSubtle = Color(0xFF2B364A);
  static const Color lineSubtle2 = Color(0x397199FF);
  static const Color lineSubtle3 = Color(0x397199FF);
  static const Color lineAccent1 = Color(0xFF90E8F8);
  static const Color lineAccent1Hover = Color(0xFF4EF0FF);
}

final class AppColorTheme {
  // Shell surfaces
  static const _ThemeColor _pageBackground = _ThemeColor(
    _AppLightColors.pageBackground,
    _AppDarkColors.pageBackground,
  );
  static const _ThemeColor _headerBackground = _ThemeColor(
    _AppLightColors.headerBackground,
    _AppDarkColors.headerBackground,
  );
  static const _ThemeColor _headerToggleBackground = _ThemeColor(
    _AppLightColors.headerToggleBackground,
    _AppDarkColors.headerToggleBackground,
  );
  static const _ThemeColor _footerBackground = _ThemeColor(
    _AppLightColors.footerBackground,
    _AppDarkColors.footerBackground,
  );
  static const _ThemeColor _footerText = _ThemeColor(
    _AppLightColors.footerText,
    _AppDarkColors.footerText,
  );
  static const _ThemeColor _footerLink = _ThemeColor(
    _AppLightColors.footerLink,
    _AppDarkColors.footerLink,
  );
  static const _ThemeColor _footerLinkHover = _ThemeColor(
    _AppLightColors.footerLinkHover,
    _AppDarkColors.footerLinkHover,
  );

  // Modal
  static const Color modalBarrier = Color(0xBF000000);
  static const _ThemeColor _modalBackground = _ThemeColor(
    _AppLightColors.modalBackground,
    _AppDarkColors.modalBackground,
  );
  static const _ThemeColor _modalHeaderBorder = _ThemeColor(
    _AppLightColors.modalHeaderBorder,
    _AppDarkColors.modalHeaderBorder,
  );
  static const _ThemeColor _modalCloseIcon = _ThemeColor(
    _AppLightColors.modalCloseIcon,
    _AppDarkColors.modalCloseIcon,
  );
  static const _ThemeColor _modalCloseIconHover = _ThemeColor(
    _AppLightColors.modalCloseIconHover,
    _AppDarkColors.modalCloseIconHover,
  );

  // Landing page palette
  static const _ThemeColor _landingAccent = _ThemeColor(
    _AppLightColors.landingAccent,
    _AppDarkColors.landingAccent,
  );
  static const _ThemeColor _landingHover = _ThemeColor(
    _AppLightColors.landingHover,
    _AppDarkColors.landingHover,
  );
  static const _ThemeColor _landingHeading = _ThemeColor(
    _AppLightColors.landingHeading,
    _AppDarkColors.landingHeading,
  );
  static const _ThemeColor _landingBody = _ThemeColor(
    _AppLightColors.landingBody,
    _AppDarkColors.landingBody,
  );

  // Line theme colors
  static const _ThemeColor _lineSubtle = _ThemeColor(
    _AppLightColors.lineSubtle,
    _AppDarkColors.lineSubtle,
  );
  static const _ThemeColor _lineSubtle2 = _ThemeColor(
    _AppLightColors.lineSubtle2,
    _AppDarkColors.lineSubtle2,
  );
  static const _ThemeColor _lineSubtle3 = _ThemeColor(
    _AppLightColors.lineSubtle3,
    _AppDarkColors.lineSubtle3,
  );
  static const _ThemeColor _lineAccent1 = _ThemeColor(
    _AppLightColors.lineAccent1,
    _AppDarkColors.lineAccent1,
  );
  static const _ThemeColor _lineAccent1Hover = _ThemeColor(
    _AppLightColors.lineAccent1Hover,
    _AppDarkColors.lineAccent1Hover,
  );

  static Color pageBackgroundFor(Brightness brightness) =>
      _pageBackground.resolve(brightness);

  static Color headerBackgroundFor(Brightness brightness) =>
      _headerBackground.resolve(brightness);

  static Color headerToggleBackgroundFor(Brightness brightness) =>
      _headerToggleBackground.resolve(brightness);

  static Color footerBackgroundFor(Brightness brightness) =>
      _footerBackground.resolve(brightness);

  static Color footerTextFor(Brightness brightness) =>
      _footerText.resolve(brightness);

  static Color footerLinkFor(Brightness brightness) =>
      _footerLink.resolve(brightness);

  static Color footerLinkHoverFor(Brightness brightness) =>
      _footerLinkHover.resolve(brightness);

  static Color modalBackgroundFor(Brightness brightness) =>
      _modalBackground.resolve(brightness);

  static Color modalHeaderBorderFor(Brightness brightness) =>
      _modalHeaderBorder.resolve(brightness);

  static Color modalCloseIconFor(Brightness brightness) =>
      _modalCloseIcon.resolve(brightness);

  static Color modalCloseIconHoverFor(Brightness brightness) =>
      _modalCloseIconHover.resolve(brightness);

  static Color landingAccentFor(Brightness brightness) =>
      _landingAccent.resolve(brightness);

  static Color landingHoverFor(Brightness brightness) =>
      _landingHover.resolve(brightness);

  static Color landingHeadingFor(Brightness brightness) =>
      _landingHeading.resolve(brightness);

  static Color landingBodyFor(Brightness brightness) =>
      _landingBody.resolve(brightness);

  static Color lineSubtleFor(Brightness brightness) =>
      _lineSubtle.resolve(brightness);

  static Color lineSubtle2For(Brightness brightness) =>
      _lineSubtle2.resolve(brightness);

  static Color lineSubtle3For(Brightness brightness) =>
      _lineSubtle3.resolve(brightness);

  static Color lineAccent1For(Brightness brightness) =>
      _lineAccent1.resolve(brightness);

  static Color lineAccent1HoverFor(Brightness brightness) =>
      _lineAccent1Hover.resolve(brightness);
}
