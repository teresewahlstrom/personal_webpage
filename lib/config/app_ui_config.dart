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
  static const Color gridLineColor = Color(0xFFE1E4F2);
  static const Color headerBackgroundColor = Color(0xFFF8F9F7);
  static const Color headerBorderColor = Color(0xFFE1E4F2);
  static const Color headerToggleColor = Color(0xFF394183);
  static const Color headerToggleHoverColor = Color(0xFF843F02);
  static const Color headerToggleBackgroundColor = Color(0xFFFFFFFF);

  static const double gridSpacing = 25;
  static const double gridYStart = 15;

  static const double headerMinHeight = 86;
  static const double headerMaxWidth = 980;
  static const double headerLogoWidth = 88;
  static const double headerLogoHeight = 72;
  static const double headerToggleSize = 42;
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(16, 10, 16, 8);

  static const double footerMinHeight = 50;
  static const EdgeInsets footerPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 10,
  );
  static const Color footerBackgroundColor = Color(0xFFF8F9F7);
  static const Color footerBorderColor = Color(0xFFE1E4F2);
  static const Color footerTextColor = Color(0xFF555764);
  static const Color footerLinkColor = Color(0xFF394183);
  static const Color footerLinkHoverColor = Color(0xFF843F02);
}

final class ModalUiConfig {
  static const Color barrierColor = Color(0xBF000000);
  static const Color backgroundColor = Color(0xFF1A1A1A);
  static const EdgeInsets insetPadding = EdgeInsets.all(16);
  static const EdgeInsets contentPadding = EdgeInsets.fromLTRB(24, 20, 24, 20);
  static const double maxWidth = 650;
  static const double maxHeightFactor = 0.9;

  static const Color closeIconColor = Color(0xFFCCCCCC);
  static const Color closeIconHoverColor = Colors.white;
}

final class LandingPagePalette {
  static const Color accent = Color(0xFF394183);
  static const Color hover = Color(0xFF843F02);
  static const Color heading2 = Color(0xFF161C45);
  static const Color bodyText = Color(0xFF252525);
  static const Color social = accent;
  static const Color socialHover = hover;
}

final class LandingPageStyles {
  static const TextStyle body = TextStyle(
    fontFamily: 'Inter18pt',
    fontWeight: FontWeight.w300,
    fontSize: 17.3,
    height: 1.4,
    color: LandingPagePalette.bodyText,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'ComingSoon',
    fontWeight: FontWeight.w700,
    fontSize: 35,
    height: 1,
    color: LandingPagePalette.heading2,
  );

  static const TextStyle hero = TextStyle(
    fontFamily: 'Inter18pt',
    fontWeight: FontWeight.w400,
    fontSize: 24,
    height: 1.35,
    letterSpacing: 0.1,
    color: LandingPagePalette.heading2,
  );

  static const TextStyle socialLink = TextStyle(
    fontFamily: 'Inter18pt',
    fontWeight: FontWeight.w300,
    fontSize: 17.3,
    height: 1.2,
  );
}
