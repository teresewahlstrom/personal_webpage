import 'package:flutter/material.dart';

final class AppRuntimeConfig {
  static const bool useChatBackend = true;
  static const bool showChatInUi = true;
  static const String twinBackendUrl = String.fromEnvironment(
    'TWIN_BACKEND_URL',
    defaultValue: 'http://localhost:8787',
  );
  static const String backendDisabledReply =
      'Chat backend is disabled in this build. Set AppRuntimeConfig.useChatBackend to true to re-enable server replies.';
}

final class ShellUiConfig {
  static const Color pageBackgroundColor = Color(0xFFF8F9F7);
  static const Color pageBackgroundColorDark = Color(0xFF212835);
  static const Color gridLineColor = Color(0xFFE1E4F2);
  static const Color gridLineColorDark = Color(0xFF2B364A);
  static const Color headerBackgroundColor = Color(0xFFF8F9F7);
  static const Color headerBackgroundColorDark = Color(0xFF212835);
  static const Color headerBorderColor = Color(0x40394183);
  static const Color headerBorderColorDark = Color(0x397199FF);
  static const Color headerToggleColor = Color(0xFF394183);
  static const Color headerToggleColorDark = Color(0xFF90E8F8);
  static const Color headerToggleHoverColor = Color(0xFF843F02);
  static const Color headerToggleHoverColorDark = Color(0xFF4EF0FF);
  static const Color headerToggleBackgroundColor = Color(0xFFF8F9F7);
  static const Color headerToggleBackgroundColorDark = Color(0xFF212835);

  static const double gridSpacing = 25;
  static const double gridYStart = 15;

  static const double headerMinHeight = 56;
  static const double headerMaxWidth = 980;
  static const double headerLogoWidth = 44;
  static const double headerLogoHeight = 36;
  static const double headerToggleSize = 42;
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(5.5, 3.3, 5.5, 2.7);

  static const double footerMinHeight = 50;
  static const EdgeInsets footerPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 10,
  );
  static const Color footerBackgroundColor = Color(0xFFF8F9F7);
  static const Color footerBackgroundColorDark = Color(0xFF212835);
  static const Color footerBorderColor = Color(0x40394183);
  static const Color footerBorderColorDark = Color(0x397199FF);
  static const Color footerTextColor = Color(0xFF555764);
  static const Color footerTextColorDark = Color(0xD6DCF6F8);
  static const Color footerLinkColor = Color(0xFF394183);
  static const Color footerLinkColorDark = Color(0xFF90E8F8);
  static const Color footerLinkHoverColor = Color(0xFF843F02);
  static const Color footerLinkHoverColorDark = Color(0xFF4EF0FF);

  static Color pageBackgroundFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? pageBackgroundColorDark
        : pageBackgroundColor;
  }

  static Color gridLineFor(Brightness brightness) {
    return brightness == Brightness.dark ? gridLineColorDark : gridLineColor;
  }

  static Color headerBackgroundFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? headerBackgroundColorDark
        : headerBackgroundColor;
  }

  static Color headerBorderFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? headerBorderColorDark
        : headerBorderColor;
  }

  static Color headerToggleFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? headerToggleColorDark
        : headerToggleColor;
  }

  static Color headerToggleHoverFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? headerToggleHoverColorDark
        : headerToggleHoverColor;
  }

  static Color headerToggleBackgroundFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? headerToggleBackgroundColorDark
        : headerToggleBackgroundColor;
  }

  static Color footerBackgroundFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? footerBackgroundColorDark
        : footerBackgroundColor;
  }

  static Color footerBorderFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? footerBorderColorDark
        : footerBorderColor;
  }

  static Color footerTextFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? footerTextColorDark
        : footerTextColor;
  }

  static Color footerLinkFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? footerLinkColorDark
        : footerLinkColor;
  }

  static Color footerLinkHoverFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? footerLinkHoverColorDark
        : footerLinkHoverColor;
  }
}

final class ModalUiConfig {
  static const Color barrierColor = Color(0xBF000000);
  static const Color backgroundColor = Color(0xFFF8F9F7);
  static const Color backgroundColorDark = Color(0xFF101B34);
  static const Color headerBorderColor = Color(0x1F394183);
  static const Color headerBorderColorDark = Color(0x3390E8F8);
  static const EdgeInsets insetPadding = EdgeInsets.all(14);
  static const EdgeInsets contentPadding = EdgeInsets.fromLTRB(24, 20, 24, 20);
  static const EdgeInsets contentPaddingCompact = EdgeInsets.fromLTRB(
    14,
    12,
    14,
    12,
  );
  static const double maxWidth = 650;
  static const double maxHeightFactor = 0.9;
  static const double maxHeightFactorCompact = 0.96;
  static const double headerHeight = 52;

  static const Color closeIconColor = Color(0xFF394183);
  static const Color closeIconColorDark = Color(0xFF90E8F8);
  static const Color closeIconHoverColor = Color(0xFF843F02);
  static const Color closeIconHoverColorDark = Color(0xFF4EF0FF);

  static Color backgroundFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? backgroundColorDark
        : backgroundColor;
  }

  static Color headerBorderFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? headerBorderColorDark
        : headerBorderColor;
  }

  static Color closeIconFor(Brightness brightness) {
    return brightness == Brightness.dark ? closeIconColorDark : closeIconColor;
  }

  static Color closeIconHoverFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? closeIconHoverColorDark
        : closeIconHoverColor;
  }

  static bool isCompact(Size viewportSize) {
    return viewportSize.width <= 720 || viewportSize.height <= 760;
  }

  static EdgeInsets insetPaddingFor(Size viewportSize) {
    return isCompact(viewportSize) ? const EdgeInsets.all(8) : insetPadding;
  }

  static EdgeInsets contentPaddingFor(Size viewportSize) {
    return isCompact(viewportSize) ? contentPaddingCompact : contentPadding;
  }

  static double maxHeightFactorFor(Size viewportSize) {
    return isCompact(viewportSize) ? maxHeightFactorCompact : maxHeightFactor;
  }
}

final class LandingPagePalette {
  static const Color accent = Color(0xFF394183);
  static const Color accentDark = Color(0xFF90E8F8);
  static const Color hover = Color(0xFF843F02);
  static const Color hoverDark = Color(0xFF4EF0FF);
  static const Color heading2 = Color(0xFF161C45);
  static const Color heading2Dark = Color(0xEBDCF6F8);
  static const Color bodyText = Color(0xFF252525);
  static const Color bodyTextDark = Color(0xD6DCF6F8);

  static Color socialFor(Brightness brightness) {
    return brightness == Brightness.dark ? accentDark : accent;
  }

  static Color socialHoverFor(Brightness brightness) {
    return brightness == Brightness.dark ? hoverDark : hover;
  }

  static Color headingFor(Brightness brightness) {
    return brightness == Brightness.dark ? heading2Dark : heading2;
  }

  static Color bodyFor(Brightness brightness) {
    return brightness == Brightness.dark ? bodyTextDark : bodyText;
  }
}

final class LandingPageStyles {
  static TextStyle body(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontFamily: 'Inter18pt',
      fontWeight: FontWeight.w300,
      fontSize: 17.3,
      height: 1.4,
      color: LandingPagePalette.bodyFor(brightness),
    );
  }

  static TextStyle h2(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontFamily: 'ComingSoon',
      fontWeight: FontWeight.w700,
      fontSize: 35,
      height: 1,
      color: LandingPagePalette.headingFor(brightness),
    );
  }

  static TextStyle socialLink(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Inter18pt',
      fontWeight: FontWeight.w300,
      fontSize: 17.3,
      height: 1.2,
    );
  }
}
