import 'package:flutter/material.dart';

import 'app_color_theme.dart';
import 'app_line_theme.dart';

export 'app_color_theme.dart';
export 'app_line_theme.dart';

final class AppRuntimeConfig {
  static const bool useChatBackend = true;
  static const bool showChatInUi = true;
  static const String appBuildSha = String.fromEnvironment(
    'APP_BUILD_SHA',
    defaultValue: 'dev',
  );
  static const String appBuildTimeUtc = String.fromEnvironment(
    'APP_BUILD_TIME_UTC',
    defaultValue: 'local',
  );
  static const String appBuildId = String.fromEnvironment(
    'APP_BUILD_ID',
    defaultValue: 'dev@local',
  );
  static const String twinBackendUrl = String.fromEnvironment(
    'TWIN_BACKEND_URL',
    defaultValue: 'http://localhost:8787',
  );
  static const String backendDisabledReply =
      'Chat backend is disabled in this build. Set AppRuntimeConfig.useChatBackend to true to re-enable server replies.';
}

final class ShellUiConfig {
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
  static Color pageBackgroundFor(Brightness brightness) {
    return AppColorTheme.pageBackgroundFor(brightness);
  }

  static AppLineStyle gridLineFor(Brightness brightness) {
    return AppLineTheme.subtleFor(brightness);
  }

  static Color headerBackgroundFor(Brightness brightness) {
    return AppColorTheme.headerBackgroundFor(brightness);
  }

  static AppLineStyle headerBorderFor(Brightness brightness) {
    return AppLineTheme.subtleSecondaryFor(brightness);
  }

  static Color headerToggleFor(Brightness brightness) {
    return AppLineTheme.interactiveFor(brightness).color;
  }

  static Color headerToggleHoverFor(Brightness brightness) {
    return AppLineTheme.interactiveFor(brightness, hovered: true).color;
  }

  static Color buttonBackgroundFor(Brightness brightness) {
    return AppColorTheme.buttonBackgroundFor(brightness);
  }

  static Color footerBackgroundFor(Brightness brightness) {
    return AppColorTheme.footerBackgroundFor(brightness);
  }

  static AppLineStyle footerBorderFor(Brightness brightness) {
    return AppLineTheme.subtleSecondaryFor(brightness);
  }

  static Color footerTextFor(Brightness brightness) {
    return AppColorTheme.footerTextFor(brightness);
  }

  static Color linkTextFor(Brightness brightness) {
    return AppColorTheme.linkTextFor(brightness);
  }

  static Color linkTextHoverFor(Brightness brightness) {
    return AppColorTheme.linkTextHoverFor(brightness);
  }
}

final class ModalUiConfig {
  static const Color barrierColor = AppColorTheme.modalBarrier;
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

  static Color backgroundFor(Brightness brightness) {
    return AppColorTheme.modalBackgroundFor(brightness);
  }

  static Color headerBorderFor(Brightness brightness) {
    return AppColorTheme.modalHeaderBorderFor(brightness);
  }

  static Color closeIconFor(Brightness brightness) {
    return AppColorTheme.modalCloseIconFor(brightness);
  }

  static Color closeIconHoverFor(Brightness brightness) {
    return AppColorTheme.modalCloseIconHoverFor(brightness);
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

final class PagePalette {
  static Color accentFor(Brightness brightness) {
    return AppColorTheme.pageLoaderFor(brightness);
  }

  static Color headingFor(Brightness brightness) {
    return AppColorTheme.pageHeadingTextFor(brightness);
  }

  static Color bodyFor(Brightness brightness) {
    return AppColorTheme.pageBodyTextFor(brightness);
  }
}

final class PageTextStyles {
  static TextStyle body(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontFamily: 'Inter18pt',
      fontWeight: FontWeight.w300,
      fontSize: 17.3,
      height: 1.4,
      color: PagePalette.bodyFor(brightness),
    );
  }

  static TextStyle h2(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontFamily: 'ComingSoon',
      fontWeight: FontWeight.w700,
      fontSize: 35,
      height: 1,
      color: PagePalette.headingFor(brightness),
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

final class ModalTextStyles {
  static TextStyle h3(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return TextStyle(
      fontFamily: "Inter18pt",
      fontWeight: FontWeight.w500,
      fontSize: 22,
      color: AppColorTheme.modalContentTextFor(brightness),
      height: 1.2,
    );
  }

  static TextStyle body(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return TextStyle(
      fontFamily: "Inter18pt",
      fontWeight: FontWeight.w300,
      fontSize: 16,
      height: 1.6,
      color: AppColorTheme.modalContentTextFor(brightness),
    );
  }

  static TextStyle link(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return TextStyle(
      fontFamily: "Inter18pt",
      fontWeight: FontWeight.w300,
      fontSize: 16,
      height: 1.6,
      color: AppColorTheme.linkTextFor(brightness),
      decoration: TextDecoration.underline,
    );
  }
}
