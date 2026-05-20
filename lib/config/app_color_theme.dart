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
  static const Color seedColor = Color(0xFF394183);
  static const Color pageLoader = pageBodyText;

  // background colors
  static const Color _mainBackground = Color.fromARGB(255, 238, 238, 238);
  static const Color pageBackground = _mainBackground;
  static const Color headerBackground = _mainBackground;
  static const Color buttonBackground = _mainBackground;
  static const Color footerBackground = _mainBackground;
  static const Color modalBackground = _mainBackground;

  // line colors
  static const Color lineSubtle = Color(0xFFFFFFFF);
  static const Color lineSubtleSecondary = Color(0xFFFFFFFF);
  static const Color lineSubtleTertiary = Color(0xFFFFFFFF);
  static const Color modalHeaderBorder = Color(0xFFFFFFFF);

  // text colors
  static const Color pageHeadingText = Color(0xFF161C45);
  static const Color footerText = Color(0xFF555764);
  static const Color modalContentText = Color(0xFF252525);
  static const Color pageBodyText = Color(0xFF252525);
  static const Color pageScrollbarThumb = Color(0xFFFFFFFF);
  static const Color pageScrollbarThumbInactive = Color(0xFFFFFFFF);
  static const Color pageScrollbarTrack = Color(0x00F8F9F7);
  static const double projectCardFillAlpha = 0.70;

  // clickable accent colors
  static const Color _interactive = Color(0xFF394183);
  static const Color _interactiveHover = Color(0xFF843F02);
  static const Color linkText = _interactive;
  static const Color linkTextHover = _interactiveHover;
  static const Color modalCloseIcon = _interactive;
  static const Color modalCloseIconHover = _interactiveHover;
  static const Color lineInteractive = _interactive;
  static const Color lineInteractiveHover = _interactiveHover;
}

final class _AppDarkColors {
  static const Color seedColor = Color(0xFF90E8F8);
  static const Color pageLoader = Color(0xFF90E8F8);

  // background colors
  static const Color _mainBackground = Color(0xFF212835);
  static const Color pageBackground = _mainBackground;
  static const Color headerBackground = _mainBackground;
  static const Color buttonBackground = _mainBackground;
  static const Color footerBackground = _mainBackground;
  static const Color modalBackground = _mainBackground;

  // line colors
  static const Color lineSubtle = Color(0xFF2B364A);
  static const Color lineSubtleSecondary = Color(0x397199FF);
  static const Color lineSubtleTertiary = Color(0x397199FF);
  static const Color modalHeaderBorder = Color(0x3390E8F8);

  // text colors
  static const Color pageHeadingText = Color(0xEBDCF6F8);
  static const Color footerText = Color(0xD6DCF6F8);
  static const Color modalContentText = Color(0xFFEAF7FF);
  static const Color pageBodyText = Color(0xD6DCF6F8);
  static const Color pageScrollbarThumb = Color(0x397199FF);
  static const Color pageScrollbarThumbInactive = Color(0xFF283143);
  static const Color pageScrollbarTrack = Color(0x004EF0FF);
  static const double projectCardFillAlpha = 0.65;
  
  // clickable accent colors
  static const Color _interactive = Color(0xFF90E8F8);
  static const Color _interactiveHover = Color(0xFF90E8F8);
  static const Color linkText = _interactive;
  static const Color linkTextHover = _interactiveHover;
  static const Color modalCloseIcon = _interactive;
  static const Color modalCloseIconHover = _interactiveHover;
  static const Color lineInteractive = _interactive;
  static const Color lineInteractiveHover = _interactiveHover;
}

final class AppColorTheme {
  static const Color newsletterEmbedText = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  static const _ThemeColor _seedColor = _ThemeColor(
    _AppLightColors.seedColor,
    _AppDarkColors.seedColor,
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
  static const _ThemeColor _buttonBackground = _ThemeColor(
    _AppLightColors.buttonBackground,
    _AppDarkColors.buttonBackground,
  );
  static const _ThemeColor _footerBackground = _ThemeColor(
    _AppLightColors.footerBackground,
    _AppDarkColors.footerBackground,
  );
  static const _ThemeColor _footerText = _ThemeColor(
    _AppLightColors.footerText,
    _AppDarkColors.footerText,
  );
  static const _ThemeColor _linkText = _ThemeColor(
    _AppLightColors.linkText,
    _AppDarkColors.linkText,
  );
  static const _ThemeColor _linkTextHover = _ThemeColor(
    _AppLightColors.linkTextHover,
    _AppDarkColors.linkTextHover,
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
  static const _ThemeColor _pageLoader = _ThemeColor(
    _AppLightColors.pageLoader,
    _AppDarkColors.pageLoader,
  );
  static const _ThemeColor _pageHeadingText = _ThemeColor(
    _AppLightColors.pageHeadingText,
    _AppDarkColors.pageHeadingText,
  );
  static const _ThemeColor _pageBodyText = _ThemeColor(
    _AppLightColors.pageBodyText,
    _AppDarkColors.pageBodyText,
  );
  static const _ThemeColor _pageScrollbarThumb = _ThemeColor(
    _AppLightColors.pageScrollbarThumb,
    _AppDarkColors.pageScrollbarThumb,
  );
  static const _ThemeColor _pageScrollbarThumbInactive = _ThemeColor(
    _AppLightColors.pageScrollbarThumbInactive,
    _AppDarkColors.pageScrollbarThumbInactive,
  );
  static const _ThemeColor _pageScrollbarTrack = _ThemeColor(
    _AppLightColors.pageScrollbarTrack,
    _AppDarkColors.pageScrollbarTrack,
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
  static const _ThemeColor _lineInteractive = _ThemeColor(
    _AppLightColors.lineInteractive,
    _AppDarkColors.lineInteractive,
  );
  static const _ThemeColor _lineInteractiveHover = _ThemeColor(
    _AppLightColors.lineInteractiveHover,
    _AppDarkColors.lineInteractiveHover,
  );

  static double projectCardFillAlphaFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? _AppDarkColors.projectCardFillAlpha
        : _AppLightColors.projectCardFillAlpha;
  }

    static Color seedColorFor(Brightness brightness) =>
      _seedColor.resolve(brightness);

  static Color pageBackgroundFor(Brightness brightness) =>
      _pageBackground.resolve(brightness);

  static Color headerBackgroundFor(Brightness brightness) =>
      _headerBackground.resolve(brightness);

  static Color buttonBackgroundFor(Brightness brightness) =>
      _buttonBackground.resolve(brightness);

  static Color footerBackgroundFor(Brightness brightness) =>
      _footerBackground.resolve(brightness);

  static Color footerTextFor(Brightness brightness) =>
      _footerText.resolve(brightness);

  static Color linkTextFor(Brightness brightness) =>
      _linkText.resolve(brightness);

  static Color linkTextHoverFor(Brightness brightness) =>
      _linkTextHover.resolve(brightness);

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

  static Color pageLoaderFor(Brightness brightness) =>
      _pageLoader.resolve(brightness);

  static Color pageHeadingTextFor(Brightness brightness) =>
      _pageHeadingText.resolve(brightness);

  static Color pageBodyTextFor(Brightness brightness) =>
      _pageBodyText.resolve(brightness);

    static Color pageScrollbarThumbFor(Brightness brightness) =>
      _pageScrollbarThumb.resolve(brightness);

    static Color pageScrollbarThumbInactiveFor(Brightness brightness) =>
      _pageScrollbarThumbInactive.resolve(brightness);

    static Color pageScrollbarTrackFor(Brightness brightness) =>
      _pageScrollbarTrack.resolve(brightness);

  static Color lineSubtleFor(Brightness brightness) =>
      _lineSubtle.resolve(brightness);

    static Color lineSubtleSecondaryFor(Brightness brightness) =>
      _lineSubtleSecondary.resolve(brightness);

    static Color lineSubtleTertiaryFor(Brightness brightness) =>
      _lineSubtleTertiary.resolve(brightness);

    static Color lineInteractiveFor(Brightness brightness) =>
      _lineInteractive.resolve(brightness);

    static Color lineInteractiveHoverFor(Brightness brightness) =>
      _lineInteractiveHover.resolve(brightness);
}
