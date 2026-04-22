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
  static const Color appSeed = Color(0xFF394183);
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
  static const Color modalContentText = Color(0xFF252525);

  static const Color pageAccent = Color(0xFF394183);
  static const Color pageAccentHover = Color(0xFF843F02);
  static const Color pageHeadingText = Color(0xFF161C45);
  static const Color pageBodyText = Color(0xFF252525);

  static const Color lineSubtle = Color(0xFFE1E4F2);
  static const Color lineSubtleSecondary = Color(0x40394183);
  static const Color lineSubtleTertiary = Color(0x40394183);
  static const Color lineAccent = Color(0xFF394183);
  static const Color lineAccentHover = Color(0xFF843F02);
}

final class _AppDarkColors {
  static const Color appSeed = Color(0xFF90E8F8);
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
  static const Color modalContentText = Color(0xFFEAF7FF);

  static const Color pageAccent = Color(0xFF90E8F8);
  static const Color pageAccentHover = Color(0xFF4EF0FF);
  static const Color pageHeadingText = Color(0xEBDCF6F8);
  static const Color pageBodyText = Color(0xD6DCF6F8);

  static const Color lineSubtle = Color(0xFF2B364A);
  static const Color lineSubtleSecondary = Color(0x397199FF);
  static const Color lineSubtleTertiary = Color(0x397199FF);
  static const Color lineAccent = Color(0xFF90E8F8);
  static const Color lineAccentHover = Color(0xFF4EF0FF);
}

final class AppColorTheme {
  static const Color newsletterEmbedText = Color(0xFFFFFFFF);

  static const _ThemeColor _appSeed = _ThemeColor(
    _AppLightColors.appSeed,
    _AppDarkColors.appSeed,
  );

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
  static const _ThemeColor _modalContentText = _ThemeColor(
    _AppLightColors.modalContentText,
    _AppDarkColors.modalContentText,
  );

  // Page text/link palette
  static const _ThemeColor _pageAccent = _ThemeColor(
    _AppLightColors.pageAccent,
    _AppDarkColors.pageAccent,
  );
  static const _ThemeColor _pageAccentHover = _ThemeColor(
    _AppLightColors.pageAccentHover,
    _AppDarkColors.pageAccentHover,
  );
  static const _ThemeColor _pageHeadingText = _ThemeColor(
    _AppLightColors.pageHeadingText,
    _AppDarkColors.pageHeadingText,
  );
  static const _ThemeColor _pageBodyText = _ThemeColor(
    _AppLightColors.pageBodyText,
    _AppDarkColors.pageBodyText,
  );

  // Line theme colors
  static const _ThemeColor _lineSubtle = _ThemeColor(
    _AppLightColors.lineSubtle,
    _AppDarkColors.lineSubtle,
  );
  static const _ThemeColor _lineSubtleSecondary = _ThemeColor(
    _AppLightColors.lineSubtleSecondary,
    _AppDarkColors.lineSubtleSecondary,
  );
  static const _ThemeColor _lineSubtleTertiary = _ThemeColor(
    _AppLightColors.lineSubtleTertiary,
    _AppDarkColors.lineSubtleTertiary,
  );
  static const _ThemeColor _lineAccent = _ThemeColor(
    _AppLightColors.lineAccent,
    _AppDarkColors.lineAccent,
  );
  static const _ThemeColor _lineAccentHover = _ThemeColor(
    _AppLightColors.lineAccentHover,
    _AppDarkColors.lineAccentHover,
  );

    static Color appSeedFor(Brightness brightness) =>
      _appSeed.resolve(brightness);

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

    static Color modalContentTextFor(Brightness brightness) =>
      _modalContentText.resolve(brightness);

  static Color pageAccentFor(Brightness brightness) =>
      _pageAccent.resolve(brightness);

  static Color pageAccentHoverFor(Brightness brightness) =>
      _pageAccentHover.resolve(brightness);

  static Color pageHeadingTextFor(Brightness brightness) =>
      _pageHeadingText.resolve(brightness);

  static Color pageBodyTextFor(Brightness brightness) =>
      _pageBodyText.resolve(brightness);

  static Color lineSubtleFor(Brightness brightness) =>
      _lineSubtle.resolve(brightness);

    static Color lineSubtleSecondaryFor(Brightness brightness) =>
      _lineSubtleSecondary.resolve(brightness);

    static Color lineSubtleTertiaryFor(Brightness brightness) =>
      _lineSubtleTertiary.resolve(brightness);

    static Color lineAccentFor(Brightness brightness) =>
      _lineAccent.resolve(brightness);

    static Color lineAccentHoverFor(Brightness brightness) =>
      _lineAccentHover.resolve(brightness);
}
