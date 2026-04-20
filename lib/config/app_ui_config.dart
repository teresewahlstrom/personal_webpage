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

  static const double gridSpacing = 25;
  static const double gridYStart = 15;

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
