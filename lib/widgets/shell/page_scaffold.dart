import 'package:flutter/material.dart';

import '../../config/app_ui_config.dart';
import '_chat_overlay.dart';
import '_grid_background.dart';
import '_page_footer.dart';

/// A reusable widget that combines a grid background with content.
///
/// Use this widget to display content over a grid background pattern.
/// The grid and content are properly layered with IgnorePointer on the grid
/// to allow interaction with content beneath.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.child,
    this.overlays = const <Widget>[],
    this.showTwinChat = true,
    this.showFooter = true,
    this.footerBrandName = 'T1 grid',
    this.footerPrivacyLabel = 'Privacy & Cookies Note.',
    this.twinBackendUrl = AppRuntimeConfig.twinBackendUrl,
    this.gridColor = ShellUiConfig.pageBackgroundColor,
    this.gridLineColor = ShellUiConfig.gridLineColor,
  });

  /// The main content to display on top of the grid background.
  final Widget child;

  /// Optional floating layers rendered above page content (for docks/overlays).
  final List<Widget> overlays;

  /// Enables the built-in twin chat dock overlay.
  final bool showTwinChat;

  /// Enables the built-in footer.
  final bool showFooter;

  /// Footer brand label shown in copyright line.
  final String footerBrandName;

  /// Footer link label.
  final String footerPrivacyLabel;

  /// Backend URL used by the built-in twin chat dock.
  final String twinBackendUrl;

  /// Background color of the grid.
  final Color gridColor;

  /// Color of the grid lines.
  final Color gridLineColor;

  @override
  Widget build(BuildContext context) {
    return GridBackground(
      backgroundColor: gridColor,
      gridLineColor: gridLineColor,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(child: child),
              if (showFooter)
                PageFooter(
                  brandName: footerBrandName,
                  privacyLabel: footerPrivacyLabel,
                ),
            ],
          ),
          ...overlays,
          if (showTwinChat && AppRuntimeConfig.showChatInUi)
            TwinChatOverlay(twinBackendUrl: twinBackendUrl),
        ],
      ),
    );
  }
}
